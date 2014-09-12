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
 
package de.maxdidit.hardware.text.tags  
{ 
	import de.maxdidit.hardware.text.cache.HardwareCharacterCache;
	import de.maxdidit.list.LinkedList;
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class TextTag  
	{ 
		/////////////////////// 
		// Constants 
		/////////////////////// 
		 
		public static const OPEN:uint = 0; 
		public static const CLOSE:uint = 1; 
		 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		private var _id:uint; 
		protected var _triggerFontSwitch:Boolean = false;
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function TextTag()  
		{ 
			 
		} 
		 
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		public function get triggerFontSwitch ():Boolean
		{
			return _triggerFontSwitch;
		}
		
		public function get id():uint  
		{ 
			return _id; 
		} 
		 
		public function set id(value:uint):void  
		{ 
			_id = value; 
		} 
		
		public function parseAttributes( tagAttributes:String ):void
		{
			var attributes:Array = tagAttributes.match( /([\w]+=["']?[-\w\s,.:]+["']?)/g );
			const l:uint = attributes.length;
			
			for ( var i:uint = 0; i < l; i++ )
			{
				var tagAttribute:String = attributes[ i ];
				var indexOfEqualSign:int = tagAttribute.indexOf( "=" );
				if ( indexOfEqualSign == -1 )
				{
					continue;
				}
				
				var attributeName:String = tagAttribute.substring( 0, indexOfEqualSign ).toLowerCase();
				var attributeValue:String = tagAttribute.substr( indexOfEqualSign + 1 );
				attributeValue = attributeValue.replace( /[(\\")']/g, "" );
				
				parseAttribute( attributeName, attributeValue );
			}
		}
		
		protected function parseAttribute( attributeName:String, attributeValue ):void
		{
			//Meant to be overwritten
		}
		
		public function processTag (fontStack:LinkedList, cache:HardwareCharacterCache, rawText:String, index:int):void
		{
			//meant to be overwritten
		}
	} 
} 
