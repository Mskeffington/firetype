/************************************************************************************
 *	
 *	About: Copyright (c) Crestron Electronics, Inc.  All rights reserved.
 *	
 *	Use of this source code is subject to the terms of the Crestron Software
 *	License Agreement under which you licensed this source code.
 *	If you did not accept the terms of the license agreement,
 *	you are not authorized to use this source code. For the terms of the license.
 *	please see the license agreement between you and Crestron at 
 *  http://www.crestron.com/sla.
 *
 *	This source code may be used only for the purpose of developing software for
 *	Crestron Devices and may not be used for any other purpose.  You may not 
 *  sublicense, publish, or distribute this source code in any way.
 *	THE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES OR INDEMNITIES.
 *
 ************************************************************************************/

package de.maxdidit.hardware.text.renderer 
{
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	public class VertexIndexUnion 
	{
		protected var _indexBuffer:IndexBuffer3D;
		protected var _vertexBuffer:VertexBuffer3D;
		
		protected var _flag:Boolean = true;
		protected var _numTriangles:uint = 0;
		
		/**
		 *	...
		 **/
		public function VertexIndexUnion($vertexBuffer:VertexBuffer3D, $indexBuffer:IndexBuffer3D) 
		{
			_vertexBuffer = $vertexBuffer;
			_indexBuffer = $indexBuffer;
		}
		
		/** 
		 * @InheritDoc
		 * @see $(Class)
		 * 
		 * ...
		 **/
		public function get numTriangles():uint 
		{
			return _numTriangles;
		}
		
		public function set numTriangles(value:uint):void 
		{
			_numTriangles = value;
		}
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get indexBuffer():IndexBuffer3D 
		{
			return _indexBuffer;
		}
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get vertexBuffer():VertexBuffer3D 
		{
			return _vertexBuffer;
		}
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get flag():Boolean 
		{
			return _flag;
		}
		
		
		/**
		 * ...
		 * @param	...
		 **/
		
		public function set flag(value:Boolean):void 
		{
			_flag = value;
		}
		
		
		
		
	}

}