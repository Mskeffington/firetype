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
 
package de.maxdidit.hardware.text.format  
{ 
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class TextColor  
	{ 
		 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		private var _id:String; 
		private var _colorVec:Vector.<Number>; 
		private var _alpha:Number = 1;
		private var _r:Number = 0x0;
		private var _g:Number = 0x0;
		private var _b:Number = 0x0;
		private var _color:Number = 0x000000;
		 
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function TextColor(id:String = null, color:uint = 0x0)  
		{ 
			_id = id; 
			_colorVec = new Vector.<Number>(4, true); 
			this.color = color; 
		} 
		 
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		 
		public function get id():String  
		{ 
			if (!_id) 
			{ 
				return "0x" + _color.toString(16); 
			} 
			 
			return _id; 
		} 
		 
		public function set id(value:String):void  
		{ 
			_id = value; 
		} 
		 
		public function get r():Number 
		{ 
			return _r; 
		} 
		public function get g():Number 
		{ 
			return _g; 
		} 
		public function get b():Number 
		{ 
			return _b; 
		} 
		public function get color():uint 
		{ 
			return _color; 
		} 
		 
		public function set color(value:uint):void 
		{ 
			
			_r = Number(value & 0xFF) / 255; // red 
			_g = Number((value >> 8) & 0xFF) / 255; // green 
			_b = Number((value >> 16) & 0xFF) / 255; // blue 
			_alpha =  Number ((value >> 24) & 0xFF) / 255; // alpha 
			
			_colorVec[2] = _r;
			_colorVec[1] = _g;
			_colorVec[0] = _b;
			_colorVec[3] = _alpha;
			_color = value;
		} 
		 
		public function get colorVector():Vector.<Number> 
		{ 
			return _colorVec; 
		} 
		
		public function set alpha (value:Number):void
		{
			_colorVec[3] = value;
			_alpha = value;
			
		}
		
		public function get alpha ():Number
		{
			return _alpha;
		}
	} 
} 
