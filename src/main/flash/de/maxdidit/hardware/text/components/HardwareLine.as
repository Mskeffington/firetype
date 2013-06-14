/* 
Copyright �2013 Max Knoblich 
 
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
 
package de.maxdidit.hardware.text.components
{
	import de.maxdidit.hardware.text.TransformedInstance;
	import de.maxdidit.math.AxisAlignedBoundingBox;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class HardwareLine extends TransformedInstance
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _ascender:int;
		private var _descender:int;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function HardwareLine()
		{
		}
		
		///////////////////////
		// Member Properties
		///////////////////////
		
		public function get ascender():int
		{
			return _ascender;
		}
		
		public function set ascender(value:int):void
		{
			_ascender = value;
		}
		
		public function get descender():int
		{
			return _descender;
		}
		
		public function set descender(value:int):void
		{
			_descender = value;
		}
		
		///////////////////////
		// Member Functions
		///////////////////////
		
		override public function loseAllChildren():void
		{
			// clean up instances
			const l:uint = _children.length;
			for (var i:uint = 0; i < l; i++)
			{
				var word:HardwareWord = _children.shift() as HardwareWord;
				word.loseAllChildren();
			}
		}
	}

}