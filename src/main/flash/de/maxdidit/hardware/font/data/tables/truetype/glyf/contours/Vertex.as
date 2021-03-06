/* 
'firetype' is an ActionScript 3 library which loads font files and renders characters via the GPU. 
Copyright �2013 Max Knoblich 
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
 
package de.maxdidit.hardware.font.data.tables.truetype.glyf.contours  
{ 
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class Vertex  
	{ 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		public var x:Number; 
		public var y:Number; 
		 
		public var onCurve:Boolean;
		
		private var _nX:Number; 
		private var _nY:Number; 
		
		public var index:int = 0;
		
		public var alpha:Number = 1;
		public var normalOffset:Number = 0;
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function Vertex($x:Number = 0, $y:Number = 0, $onCurve:Boolean = true, $alpha:Number = 1)  
		{ 
			x = $x; 
			y = $y; 
			 
			onCurve = $onCurve; 
		} 
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get nX():Number 
		{
			return _nX;
		}
		
		
		/**
		 * ...
		 * @param	...
		 **/
		
		public function set nX(value:Number):void 
		{
			_nX = value;
		}
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get nY():Number 
		{
			return _nY;
		}
		
		
		/**
		 * ...
		 * @param	...
		 **/
		
		public function set nY(value:Number):void 
		{
			_nY = value;
		}
		
		
		 
	} 
} 
