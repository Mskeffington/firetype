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
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import starling.utils.VertexData;
	
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
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		
		public function EdgeSofteningSingleGlyphRenderer($context3d:Context3D)
		{
			super($context3d)
		}
		
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		
		override protected function get fieldsPerVertex():uint
		{
			return 7;
		}
		
		override protected function get vertexShaderCode():String
		{
			/*return "mov vt0, vc[va1.x]\n" + //
			//"mov vt0.a, va2\n" + //
			"mov v1, va2\n" + //"
			"mov v0, vt0\n" + //
			"m44 op, va0, vc0";*/
			return	"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
			//"mov v0, vc3\n";
			"mul v0, vc4, va1 \n";  // multiply color with alpha and pass it to fragment shader
		}
		
		override protected function get fragmentShaderCode():String
		{
			//transform v0.alpha by (distance from the edge / thickness of border)
			return "mov oc, v0";
			/*return "mov ft0, v0\n" +//
			"mov ft0.a, v1.x\n" +//
			"mov oc, ft0";*/
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
				trace(vertex.x + "," + vertex.y + ",")
				trace(vertex.alpha)
			}
		}
		
		public override function render(instanceMap:Object, textColorMap:TextColorMap):void
		{
			updateBuffers();
			
			var fallbackTextColor:TextColor = new TextColor();
			var textColor:TextColor = textColor;
			_context3d.setProgram(programPair);
			
			_context3d.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			_context3d.setVertexBufferAt(1, _vertexBuffer, VertexData.COLOR_OFFSET + 1/*for z*/, Context3DVertexBufferFormat.FLOAT_4);
			
			
/*			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET,    Context3DVertexBufferFormat.FLOAT_4);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);            
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, alphaVector, 1);
*/			
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
