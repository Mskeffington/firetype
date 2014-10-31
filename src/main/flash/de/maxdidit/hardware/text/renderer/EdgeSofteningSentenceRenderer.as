/*
   'firetype' is an ActionScript 3 library which loads font files and renders characters via the GPU.
   Copyright ©2013 Max Knoblich
   www.maxdid.it
   me@maxdid.it

   This file is part of 'firetype' by Max Did It.

   'firetype' is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   'firetype' is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with 'firetype'.  If not, see <http://www.gnu.org/licenses/>.
 */

package de.maxdidit.hardware.text.renderer 
{
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.Glyph;
	import de.maxdidit.hardware.font.HardwareGlyph;
	import de.maxdidit.hardware.text.cache.TextColorMap;
	import de.maxdidit.hardware.text.components.HardwareGlyphInstance;
	import de.maxdidit.hardware.text.format.TextColor;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	
	/**
	 * this renderer will render as many characters as it can in a single text field.
	 * 
	 * @author Michael Skeffington
	 */
	public class EdgeSofteningSentenceRenderer extends SentenceRenderer implements IHardwareTextRenderer
	{
		/////////////////////// 
		// Constants 
		///////////////////////
		private static const FIELDS_PER_VERTEX:uint = 13;
		private static const VALUES_PER_CONST_REGISTER:uint = 5;
		
		private static const GLYPHS_PER_BATCH:uint = uint(MAX_CONSTANT_REGISTERS / VALUES_PER_CONST_REGISTER);
		
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		
		protected var _stage:Stage; 
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		public function EdgeSofteningSentenceRenderer($context3d:Context3D, $stage:Stage)
		{
			_stage = $stage;
			
			super ($context3d);
		}
		
		/////////////////////// 
		// Member Properties 
		///////////////////////		
		protected override function get fieldsPerVertex():uint
		{
			//we need x,y,z,rotation,alpha,
			return FIELDS_PER_VERTEX;
		}
		
		protected override function get fieldsPerConstant():uint
		{
			return VALUES_PER_CONST_REGISTER;
		}
		
		protected override function get vertexShaderCode():String
 		{
			/*
			return "mov vt3, va4.wzzx \n" + //create the mvp matrix
			"mov vt4, va4.zwzy \n" +
			"mov vt5, va4.zzwz \n" +
			"mov vt6, va4.zzzw \n" +
			*/
			
			return "m44 vt0, va0, vc[va1.x] \n" + // 4x4 matrix transform to output space
			"mov vt3, va4.wzzx \n" + //create the transpose matrix
			"mov vt4, va4.zwzy \n" +
			"mov vt5, va4.zzwz \n" +
			"mov vt6, va4.zzzw \n" +
			"m44 op, vt0, vt3 \n" + //offset the point by the transpose alone the noraml
			"mul v0, vc[va2.x], va3 \n"; // multiply color with alpha and pass it to fragment shader*/
 		}
		
		/////////////////////// 
		// Member Functions 
		/////////////////////// 		
		protected override function addToVertexData(vertexBufferData:Vector.<Number>, vertices:Vector.<Vertex>, constIndex:uint):void
		{
			const l:uint = vertices.length;
			
			if (l * fieldsPerVertex > MAX_VERTEXBUFFER_BYTES)
			{
				//It is virtually impossible to overflow this buffer
				return;
			}
			
			var index:uint = vertexBufferData.length;
			var newLength:uint = index + (l * fieldsPerVertex);
			
			const stageWidth:int = _stage.stageWidth;
			const stageHeight:int = _stage.stageHeight;
			vertexBufferData.length = newLength;
		
			for (var i:uint = 0; i < l; i++)
			{
				var vertex:Vertex = vertices[i];
				
				var translateX:Number = vertex.normalOffset / stageWidth;
				var translateY:Number = vertex.normalOffset / stageHeight;
				
				vertexBufferData[index++] = vertex.x;
				vertexBufferData[index++] = vertex.y;
				vertexBufferData[index++] = 0;
				
				vertexBufferData[index++] = constIndex * fieldsPerConstant;
				vertexBufferData[index++] = constIndex * fieldsPerConstant + 4;
				
				vertexBufferData[index++] = 1;
				vertexBufferData[index++] = 1;
				vertexBufferData[index++] = 1;
				vertexBufferData[index++] = vertex.alpha;
				
				vertexBufferData[index++] = vertex.nX * translateX;
				vertexBufferData[index++] = vertex.nY * translateY;
				vertexBufferData[index++] = 0;
				vertexBufferData[index++] = 1;
			}
		}
		
		public override function render(instanceMap:Object, textColorMap:TextColorMap):void
		{
			_context3d.setProgram(_programPair);
			_context3d.setBlendFactors (Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			for each (var font:Object in instanceMap)
			{
				for each (var vertexDistance:Object in font)
				{
					//figure out what the string says.
					var currentWord:String = findWord (vertexDistance);
					var renderPasses:int = Math.ceil(currentWord.length / GLYPHS_PER_BATCH);
					
					for (var i:uint = 0; i < renderPasses; i++ )
					{	
						var offset:int = i * GLYPHS_PER_BATCH;
						var wordSubstring:String = currentWord.substr (offset, GLYPHS_PER_BATCH);
						
						//see if we already have the vertex buffer for that string stored
						var vertexAndIndex:VertexIndexUnion = _bufferCache[wordSubstring];
						if (vertexAndIndex == null)
						{
							//create the buffer 
							vertexAndIndex = createBuffers (wordSubstring);
							_bufferCache[wordSubstring] = vertexAndIndex;
						}
						
						if (vertexAndIndex.dirtyFlag == true)
						{
							var vertexBuffer:VertexBuffer3D = _context3d.createVertexBuffer(vertexAndIndex.vertexBufferData.length / vertexAndIndex.fieldsPerVertex, vertexAndIndex.fieldsPerVertex); 
							var indexBuffer:IndexBuffer3D = _context3d.createIndexBuffer(vertexAndIndex.indexBufferData.length); 
							
							vertexAndIndex.vertexBuffer = vertexBuffer;
							vertexAndIndex.indexBuffer = indexBuffer;
							
							vertexAndIndex.dirtyFlag = false;
						}						
						
						//set the vertex buffers
						_context3d.setVertexBufferAt (0, vertexAndIndex.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
						_context3d.setVertexBufferAt (1, vertexAndIndex.vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_1);//constant offset
						_context3d.setVertexBufferAt (2, vertexAndIndex.vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_1);//color offset
						_context3d.setVertexBufferAt (3, vertexAndIndex.vertexBuffer, 5, Context3DVertexBufferFormat.FLOAT_4);//alpha
						_context3d.setVertexBufferAt (4, vertexAndIndex.vertexBuffer, 9, Context3DVertexBufferFormat.FLOAT_4);//normal offset
						
						//position/size
						createConstantBuffer (wordSubstring, offset, vertexDistance, textColorMap);
						_context3d.drawTriangles (vertexAndIndex.indexBuffer, 0, vertexAndIndex.numTriangles);
					}
				}	
			}
		}
		
	}

}