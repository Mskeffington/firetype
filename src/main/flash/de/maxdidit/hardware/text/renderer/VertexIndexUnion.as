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
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	/**
	 * 
	 * ...
	 * @author Michael Skeffington
	 */
	public class VertexIndexUnion 
	{
		protected var _indexBuffer:IndexBuffer3D;
		protected var _vertexBuffer:VertexBuffer3D;
		
		protected var _dirtyFlag:Boolean = true;
		protected var _numTriangles:uint = 0;
		protected var _indexBufferData:Vector.<uint>;
		protected var _vertexBufferData:Vector.<Number>;
		protected var _fieldsPerVertex:uint;
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		public function VertexIndexUnion($vertexBufferData:Vector.<Number>, $indexBufferData:Vector.<uint>, fieldsPerVertex:uint) 
		{
			_fieldsPerVertex = fieldsPerVertex;
			_indexBufferData = $indexBufferData;
			_vertexBufferData = $vertexBufferData;
		}
		
		/////////////////////// 
		// Member Properties 
		///////////////////////
		public function get numTriangles():uint 
		{
			return _indexBufferData.length / 3;
		}
		
		public function get indexBuffer():IndexBuffer3D 
		{
			return _indexBuffer;
		}
		
		public function set indexBuffer(value:IndexBuffer3D):void 
		{
			_indexBuffer = value;
			indexBuffer.uploadFromVector(_indexBufferData, 0, _indexBufferData.length);
		}
		
		public function get vertexBuffer():VertexBuffer3D 
		{
			return _vertexBuffer;
		}
		
		public function set vertexBuffer(value:VertexBuffer3D):void 
		{
			_vertexBuffer = value;
			_vertexBuffer.uploadFromVector(_vertexBufferData, 0, _vertexBufferData.length / fieldsPerVertex); 
		}
		
		public function get dirtyFlag():Boolean 
		{
			return _dirtyFlag;
		}
		
		public function set dirtyFlag(value:Boolean):void 
		{
			_dirtyFlag = value;
		}
		
		public function get indexBufferData():Vector.<uint> 
		{
			return _indexBufferData;
		}
		
		public function get vertexBufferData():Vector.<Number> 
		{
			return _vertexBufferData;
		}
		
		public function get numVertices ():uint
		{
			return _vertexBufferData.length / _fieldsPerVertex;
		}
		
		public function get fieldsPerVertex():uint 
		{
			return _fieldsPerVertex;
		}
		
		
	}

}