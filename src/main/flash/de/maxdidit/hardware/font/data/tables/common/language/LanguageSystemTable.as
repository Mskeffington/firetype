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
 
package de.maxdidit.hardware.font.data.tables.common.language 
{
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class LanguageSystemTable 
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _requiredFeatureIndex:uint;
		private var _featureCount:uint;
		private var _featureIndices:Vector.<uint>;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function LanguageSystemTable() 
		{
			
		}
		
		///////////////////////
		// Member Properties
		///////////////////////
		
		public function get requiredFeatureIndex():uint 
		{
			return _requiredFeatureIndex;
		}
		
		public function set requiredFeatureIndex(value:uint):void 
		{
			_requiredFeatureIndex = value;
		}
		
		public function get featureCount():uint 
		{
			return _featureCount;
		}
		
		public function set featureCount(value:uint):void 
		{
			_featureCount = value;
		}
		
		public function get featureIndices():Vector.<uint> 
		{
			return _featureIndices;
		}
		
		public function set featureIndices(value:Vector.<uint>):void 
		{
			_featureIndices = value;
		}
		
	}

}