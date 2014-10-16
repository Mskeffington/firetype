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
	import de.maxdidit.hardware.text.cache.HardwareTextFormatMap;
	import de.maxdidit.hardware.text.cache.TextColorMap;
	import de.maxdidit.hardware.text.format.HardwareTextFormat;
	import de.maxdidit.hardware.text.format.TextColor;
	import de.maxdidit.hardware.text.renderer.AGALMiniAssembler;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.Glyph;
	import de.maxdidit.hardware.font.HardwareGlyph;
	import de.maxdidit.hardware.font.triangulation.ITriangulator;
	import de.maxdidit.hardware.text.components.HardwareGlyphInstance;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	
	/** 
	 * ... 
	 * @author Michael Skeffington
	 */ 
	public class EdgeSofteningSingleGlyphRenderer extends HardwareTextRenderer implements IHardwareTextRenderer
	{
		/////////////////////// 
		// Constants 
		/////////////////////// 
		
		/////////////////////// 
		// Member Fields 
		///////////////////////
		protected var _stage:Stage; 
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		
		public function EdgeSofteningSingleGlyphRenderer($context3d:Context3D, $stage:Stage)
		{
			_stage = $stage;
			super($context3d)
		}
		
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		
		override protected function get fieldsPerVertex():uint
 		{
			return 11;
 		}
 		
 		override protected function get vertexShaderCode():String
 		{
			return "m44 vt0, va0, vc0 \n" + // 4x4 matrix transform to output space
			"mov vt3, va2.wzzx \n" +
			"mov vt4, va2.zwzy \n" +
			"mov vt5, va2.zzwz \n" +
			"mov vt6, va2.zzzw \n" +
			"m44 op, vt0, vt3 \n" +// 4x4 matrix transform to output space
			"mul v0, vc4, va1 \n";  // multiply color with alpha and pass it to fragment shader
 		}
 		
 		override protected function get fragmentShaderCode():String
 		{
			return "mov oc, v0";
 		}
		
		/////////////////////// 
		// Member Functions 
		///////////////////////
		
		protected override function addToVertexData(vertices:Vector.<Vertex>):void
		{
			const l:uint = vertices.length;
			
			var index:uint = _vertexData.length;
			const newLength:uint = index + l * fieldsPerVertex;
			
			_vertexData.length = newLength;
			
			const stageWidth:int = _stage.stageWidth;
			const stageHeight:int = _stage.stageHeight;
			
			for (var i:uint = 0; i < l; i++)
			{
				var vertex:Vertex = vertices[i];
				
				_vertexData[index++] = vertex.x;
				_vertexData[index++] = vertex.y;
				_vertexData[index++] = 0;
				_vertexData[index++] = 1; //r
				_vertexData[index++] = 1; //g
				_vertexData[index++] = 1; //b
				_vertexData[index++] = vertex.alpha;
				
				var transposeX:Number = vertex.normalOffset / stageWidth;
				var transposeY:Number = vertex.normalOffset / stageHeight;
				
				_vertexData[index++] = vertex.nX * transposeX;
				_vertexData[index++] = vertex.nY * transposeY;
				_vertexData[index++] = 0;
				_vertexData[index++] = 1;
			}
		}
		
		public override function render(instanceMap:Object, textColorMap:TextColorMap):void
		{
			updateBuffers();
			
			var fallbackTextColor:TextColor = new TextColor();
			var textColor:TextColor = textColor;
			
			_context3d.setProgram(programPair);
			_context3d.setBlendFactors (Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
			
			_context3d.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			_context3d.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_4);
			_context3d.setVertexBufferAt(2, _vertexBuffer, 7, Context3DVertexBufferFormat.FLOAT_4);
			
			for each (var font:Object in instanceMap)
			{
				for each (var vertexDistance:Object in font)
				{
					for (var colorId:String in vertexDistance)
					{
						var color:Object = vertexDistance[colorId];
						
						if (textColorMap.hasTextColorId(colorId))
						{
							textColor = textColorMap.getTextColorById(colorId);
						}
						else
						{
							textColor = fallbackTextColor;
						}
						textColor.alpha = 1;
						_context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, textColor.colorVector, 1);
						
						for each (var instances:Vector.<HardwareGlyphInstance>in color)
						{
							var l:uint = instances.length;
							for (var i:uint = 0; i < l; i++)
							{
								var currentInstance:HardwareGlyphInstance = instances[i];
								
								_context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, currentInstance.globalTransformation, true);
								
								_context3d.drawTriangles(_indexBuffer, currentInstance.hardwareGlyph.indexOffset, currentInstance.hardwareGlyph.numTriangles);
							}
						}
					}
				}
			}
		}
		
		public override function clear():void
		{
			_vertexData.length = 0;
			_indexData.length = 0;
			
			_vertexBuffer.dispose();
			_indexBuffer.dispose();
		}
	}
}
