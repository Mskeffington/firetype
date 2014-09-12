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
	import de.maxdidit.hardware.text.format.HardwareFontFeatures; 
	import de.maxdidit.hardware.text.format.HardwareTextFormat;
	import de.maxdidit.hardware.text.format.HardwareTextFormatListElement;
	import de.maxdidit.list.LinkedList;
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class FontTag extends TextTag  
	{ 
		/////////////////////// 
		// Constants 
		/////////////////////// 
		 
		public static const TAG:String = "font"; 
		public static const TAG_CLOSE:String = "/font"; 
		 
		public static const ATTRIBUTE_SIZE:String = "size"; 
		static public const ATTRIBUTE_COLOR:String = "color"; 
		static public const ATTRIBUTE_FACE:String = "face"; 
		 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		private var _face:String; 
		private var _isFaceSet:Boolean; 
		 
		private var _size:Number; 
		private var _isSizeSet:Boolean = false; 
		 
		private var _color:uint; 
		private var _isColorSet:Boolean = false; 
		 
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function FontTag()  
		{ 
			 
		} 
		 
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		 
		public function get extendsReferencedFormat():Boolean 
		{ 
			return  _isColorSet || _isSizeSet || isFaceSet; 
		} 
		 
		public function get size():Number 
		{ 
			return _size; 
		} 
		 
		public function set size(value:Number):void  
		{ 
			_size = value / 50; 
			_isSizeSet = true; 
		} 
		 
		public function get isSizeSet():Boolean  
		{ 
			return _isSizeSet; 
		} 
		 
		public function get color():uint  
		{ 
			return _color; 
		} 
		 
		public function set color(value:uint):void  
		{ 
			_color = value; 
			_isColorSet = true; 
		} 
		 
		public function get isColorSet():Boolean  
		{ 
			return _isColorSet; 
		} 
		
		public function get face():String  
		{ 
			return _face; 
		} 
		 
		public function set face(value:String):void  
		{ 
			_face = value; 
			_isFaceSet = true; 
		} 
		 
		public function get isFaceSet():Boolean  
		{ 
			return isFaceSet; 
		} 
		
		protected override function parseAttribute( attributeName:String, attributeValue):void
		{
			
			switch ( attributeName )
			{
				case FontTag.ATTRIBUTE_SIZE: 
					var number:Number = Number( attributeValue );
					size = number;
					
					break;
				
				case FontTag.ATTRIBUTE_COLOR: 
					var unsignedInt:uint = uint( attributeValue );
					color = unsignedInt;
					
					break;
				
				case FontTag.ATTRIBUTE_FACE: 
					var string:String = attributeValue;
					face = string;
					
					break;
			}
		}
		
		public override function processTag(fontStack:LinkedList, cache:HardwareCharacterCache, rawText:String, index:int):void
		{
			if (id == TextTag.CLOSE)
			{
				fontStack.removeElement( fontStack.lastElement );
			}
			else
			{
				
				var parentFormat:HardwareTextFormat = ( fontStack.lastElement as HardwareTextFormatListElement ).hardwareTextFormat;
				var newTextFormat:HardwareTextFormat = new HardwareTextFormat( parentFormat );
				
				// pass on values 
				if ( this.isColorSet )
				{
					newTextFormat.color = this.color;
				}
				
				if ( !cache.textColorMap.hasTextColorId( newTextFormat.textColor.id ) )
				{
					cache.textColorMap.addTextColor( newTextFormat.textColor );
				}
				
				if ( this.isSizeSet )
				{
					//todo: 50 is an estimation based on arial....
					newTextFormat.scale = this.size / 50;
				}
				
				if ( this.isFaceSet )
				{//todo: implement font faces
					/*
					if ( cache.fontMap.hasFontId( this.fontId ) )
					{
						var font:HardwareFont = cache.fontMap.getFontById( this.fontId );
						newTextFormat.font = font;
					}
					*/
				}
				
				fontStack.addElement( new HardwareTextFormatListElement( newTextFormat ) );
			}
		}
	} 
} 
