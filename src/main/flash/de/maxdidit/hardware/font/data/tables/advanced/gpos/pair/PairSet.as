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
 
package de.maxdidit.hardware.font.data.tables.advanced.gpos.pair 
{
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class PairSet 
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _pairValueCount:uint;
		private var _pairValueRecords:Vector.<PairValueRecord>;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function PairSet() 
		{
			
		}
		
		///////////////////////
		// Member Properties
		///////////////////////
		
		public function get pairValueCount():uint 
		{
			return _pairValueCount;
		}
		
		public function set pairValueCount(value:uint):void 
		{
			_pairValueCount = value;
		}
		
		public function get pairValueRecords():Vector.<PairValueRecord> 
		{
			return _pairValueRecords;
		}
		
		public function set pairValueRecords(value:Vector.<PairValueRecord>):void 
		{
			_pairValueRecords = value;
		}
		
	}

}