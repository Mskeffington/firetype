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
	 * @author Michael Skeffington
	 */
	public class EdgeSofteningSentenceRenderer implements IHardwareTextRenderer
	{
		/////////////////////// 
		// Constants 
		///////////////////////
		private static const FIELDS_PER_VERTEX:uint = 13;
		private static const VALUES_PER_CONST_REGISTER:uint = 5;
		
		public static const MAX_CONSTANT_REGISTERS:uint = 128;
		public static const MAX_VERTEXBUFFER_BYTES:uint = (256 << 9) << 9;
		public static const MAX_INDEXBUFFER_BYTES:uint = (128 << 9) << 9;
		private static const GLYPHS_PER_BATCH:uint = MAX_CONSTANT_REGISTERS / VALUES_PER_CONST_REGISTER;
		
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		
		// shader 
		protected var _vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler(); 
		protected var _fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler(); 
		protected var _programPair:Program3D; 
		
		
		protected var _context3d:Context3D; 
		protected var _stage:Stage; 
		
		private var _fallbackTextColor:TextColor;
		
		private var _bufferCache:Dictionary = new Dictionary (true);
		
		private var _letterCache:Dictionary = new Dictionary (true);
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		public function EdgeSofteningSentenceRenderer($context3d:Context3D, $stage:Stage)
		{
			_context3d = $context3d; 
			_stage = $stage;
			
			// init shaders
			_vertexAssembly.assemble(Context3DProgramType.VERTEX, vertexShaderCode); 
			_fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, fragmentShaderCode); 
			 
			_programPair = _context3d.createProgram(); 
			_programPair.upload(_vertexAssembly.agalcode, _fragmentAssembly.agalcode); 
			
			_fallbackTextColor = new TextColor (null, 0xFFFFFFFF);
		}
		
		/////////////////////// 
		// Member Properties 
		///////////////////////
		
		protected function get fieldsPerVertex():uint
		{
			//we need x,y,z,rotation,alpha,
			return FIELDS_PER_VERTEX;
		}
		
		protected function get fieldsPerConstant():uint
		{
			return VALUES_PER_CONST_REGISTER;
		}
		
		protected function get vertexShaderCode():String
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
 		protected function get fragmentShaderCode():String
 		{
 			//transform v0.alpha by (distance from the edge / thickness of border)
			return "mov oc, v0";
 		}
		
		/////////////////////// 
		// Member Functions 
		/////////////////////// 		
		protected function createConstantBuffer (word:String, instanceOffset:int, instanceMap:Object, textColorMap:TextColorMap):void
		{				
			var fallbackTextColor:TextColor = new TextColor();
			var textColor:TextColor;
			fallbackTextColor.alpha = 1;
						
			var charCount:uint = 0;
			var curCharIdx:uint = 0;
			var currentVectorIndex:uint = 0;
			for (var colorId:String in instanceMap)
			{
				var color:Object = instanceMap[colorId];
				
				if (textColorMap.hasTextColorId(colorId))
				{
					textColor = textColorMap.getTextColorById(colorId);
				}
				else
				{
					textColor = fallbackTextColor;
				}
				if (textColor.alpha == 0)
				{
					textColor.alpha = 1;
				}
				
				for each (var instances:Vector.<HardwareGlyphInstance>in color)
				{
					const l:uint = instances.length;
					for (var i:uint = 0; i < l; i++)
					{
						if (charCount >= instanceOffset)
						{
							var currentInstance:HardwareGlyphInstance = instances[i];
							
							var constantVectorIndex:uint = curCharIdx * fieldsPerConstant;
							_context3d.setProgramConstantsFromMatrix (Context3DProgramType.VERTEX, constantVectorIndex, currentInstance.globalTransformation, true);
							_context3d.setProgramConstantsFromVector (Context3DProgramType.VERTEX, constantVectorIndex + 4, textColor.colorVector, 1);
							curCharIdx++;
						}	
						
						charCount ++;
						if (curCharIdx >= GLYPHS_PER_BATCH)
						{
							return;
						}
					}
				}
			}
		}
		
		//TODO: later optimization.  match up partial words inside of larger words and only create new index buffers
		protected function createBuffers (word:String):VertexIndexUnion
		{
			var vertexData:Vector.<Number> = new Vector.<Number>();
			var indexData:Vector.<uint> = new Vector.<uint>();
			
			var l:uint = word.length;
			
			if (l >= GLYPHS_PER_BATCH)
			{
				l = GLYPHS_PER_BATCH;
			}
			
			var glyph:HardwareGlyph;
			var character:String = "";
			var numTriangles:uint = 0;
			for (var i:int = 0; i < l; i++)
			{
				
				glyph = _letterCache[word.charCodeAt(i)];
				
				addToIndexData (indexData, glyph.indices , vertexData.length / fieldsPerVertex);
				addToVertexData (vertexData, glyph.vertices, i);
				numTriangles += glyph.numTriangles;
			}
			
			var vertexBuffer:VertexBuffer3D = _context3d.createVertexBuffer(vertexData.length / fieldsPerVertex, fieldsPerVertex); 
			vertexBuffer.uploadFromVector(vertexData, 0, vertexData.length / fieldsPerVertex); 
			 
			var indexBuffer:IndexBuffer3D = _context3d.createIndexBuffer(indexData.length); 
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			
			var bufferUnion:VertexIndexUnion = new VertexIndexUnion(vertexBuffer,indexBuffer);
			bufferUnion.numTriangles = indexData.length / 3;
			
			return bufferUnion;
		}
		
		protected function addToVertexData(vertexBufferData:Vector.<Number>, vertices:Vector.<Vertex>, constIndex:uint):void
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
				
				var transposeX:Number = vertex.normalOffset / stageWidth;
				var transposeY:Number = vertex.normalOffset / stageHeight;
				
				vertexBufferData[index++] = vertex.x;
				vertexBufferData[index++] = vertex.y;
				vertexBufferData[index++] = 0;
				
				vertexBufferData[index++] = constIndex * fieldsPerConstant;
				vertexBufferData[index++] = constIndex * fieldsPerConstant + 4;
				
				vertexBufferData[index++] = 1;
				vertexBufferData[index++] = 1;
				vertexBufferData[index++] = 1;
				vertexBufferData[index++] = vertex.alpha;
				
				vertexBufferData[index++] = vertex.nX * transposeX;
				vertexBufferData[index++] = vertex.nY * transposeY;
				vertexBufferData[index++] = 0;
				vertexBufferData[index++] = 1;
			}
		}
		
		protected function addToIndexData(indexBufferData:Vector.<uint>, indices:Vector.<uint>, vertexOffset:uint):void
		{
			const l:uint = indices.length;
			
			if (l > MAX_INDEXBUFFER_BYTES)
			{
				//It is virtually impossible to overflow this buffer
				return;
			}
			
			var index:uint = indexBufferData.length;
			
			indexBufferData.length = index + l;
			
			for (var j:uint = 0; j < l; j++)
			{
				indexBufferData[index++] = indices[j] + vertexOffset;
			}
			
		}
		
		protected function findWord (instanceMap:Object):String
		{
			var word:String = "";
			for (var colorId:String in instanceMap)
			{
				var color:Object = instanceMap[colorId];
				
				for (var curCharacter:String in color)
				{
					
					var instances:Vector.<HardwareGlyphInstance> = color[curCharacter];
					var l:uint = instances.length;
					for (var i:uint = 0; i < l; i++)
					{
						var currentInstance:HardwareGlyphInstance = instances[i];
						word += String.fromCharCode(currentInstance.characterCode);
					}
				}
			}
			
			return word;
		}
		
		public function addHardwareGlyph(glyph:HardwareGlyph):Boolean 
		{
			if (_letterCache[glyph.charCode] == null)
			{
				_letterCache[glyph.charCode] = glyph;
			}
			return true;
		}
		
		public function render(instanceMap:Object, textColorMap:TextColorMap):void
		{
			_context3d.setProgram(_programPair);
			_context3d.setBlendFactors (Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			for each (var font:Object in instanceMap)
			{
				for each (var vertexDistance:Object in font)
				{
					//figure out what the string says.
					var currentWord:String = findWord (vertexDistance);
					var renderPasses:int = currentWord.length / GLYPHS_PER_BATCH;
					
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
							_bufferCache[currentWord] = vertexAndIndex;
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
		
		public function clear():void
		{
			//iterate through all the stored buffers and delete them
		}
	}

}