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
 
package de.maxdidit.hardware.font.data.tables.advanced.gpos.marktoligature 
{
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class LigatureArray 
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _ligatureCount:uint;
		private var _ligatureAttachmentOffsets:Vector.<uint>;
		private var _ligatureAttachments:Vector.<LigatureAttachment>;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function LigatureArray() 
		{
			
		}
		
		///////////////////////
		// Member Properties
		///////////////////////
		
		public function get ligatureCount():uint 
		{
			return _ligatureCount;
		}
		
		public function set ligatureCount(value:uint):void 
		{
			_ligatureCount = value;
		}
		
		public function get ligatureAttachmentOffsets():Vector.<uint> 
		{
			return _ligatureAttachmentOffsets;
		}
		
		public function set ligatureAttachmentOffsets(value:Vector.<uint>):void 
		{
			_ligatureAttachmentOffsets = value;
		}
		
		public function get ligatureAttachments():Vector.<LigatureAttachment> 
		{
			return _ligatureAttachments;
		}
		
		public function set ligatureAttachments(value:Vector.<LigatureAttachment>):void 
		{
			_ligatureAttachments = value;
		}
		
	}

}