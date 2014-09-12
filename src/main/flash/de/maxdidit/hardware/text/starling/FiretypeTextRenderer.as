package de.maxdidit.hardware.text.starling
{
	import com.crestron.common.events.FormattedTextEvent;
	import com.crestron.components.text.FiretypeFontLoader;
	import com.crestron.components.text.utils.CIPTagParser;
	import com.crestron.components.text.utils.HTMLTextParser;
	import de.maxdidit.hardware.text.starling.FiretypeStarlingTextField;
	import feathers.core.IFeathersControl;
	import feathers.core.TokenList;
	import flash.geom.Rectangle;
	import de.maxdidit.hardware.font.HardwareFont;
	import de.maxdidit.hardware.text.cache.HardwareCharacterCache;
	import de.maxdidit.hardware.text.format.HardwareFontFeatures;
	import de.maxdidit.hardware.text.format.TextAlign;
	import de.maxdidit.hardware.text.HardwareText;
	import de.maxdidit.hardware.text.renderer.BatchedGlyphRendererFactory;
	import de.maxdidit.hardware.text.renderer.SingleGlyphRendererFactory;
	import feathers.core.ITextRenderer;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	
	
	public class FiretypeTextRenderer extends FiretypeStarlingTextField implements ITextRenderer, IFeathersControl
	{
		protected var _isEnabled:Boolean = true;
		protected var _wordWrap:Boolean;
		protected var _maxHeight:Number;
		protected var _maxWidth:Number;
		
		protected var _minHeight:Number;
		protected var _minWidth:Number;
		protected var _clipRect:Rectangle;
		protected var _isCreated:Boolean = true;
		protected var _isInitialized:Boolean =true;
		protected var _baseline:int = 0;
		protected var _horizontalAlign:String;
		protected var _isHtml:Boolean;
		protected var _verticalAlign:String;
		protected var _font:String;
		protected var _bold:Boolean = false;
		protected var _italic:Boolean = false;
		protected var _rawText:String;
		protected var _text:String;
		protected var _textObjectArr:Array;
		protected var _maxControlWidth:Number;
		
		public function FiretypeTextRenderer()
		{
			super (null);
			//this.font = FiretypeFontLoader.getFont ();
			//this.vertexDistance = 30;
		}
		public function setSize (width:Number, height:Number):void
		{
			this.width = width;
			this.height = height;
		}
		
		
		public function get wordWrap():Boolean 
		{
			return _wordWrap;
		}
		
		public function set wordWrap(value:Boolean):void 
		{
			_wordWrap = value;
		}
		
		public function measureText (result:Point = null):Point
		{
			return new Point(1,1);
		}
		public function get minWidth():Number 
		{
			return _minWidth;
		}
		public function set minWidth(value:Number):void 
		{
			_minWidth = value;
		}
		public function get minHeight():Number 
		{
			return _minHeight;
		}
		
		public function set minHeight(value:Number):void 
		{
			_minHeight = value;
		}
		
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get maxWidth():Number 
		{
			return _maxWidth;
		}
		
		public function set maxWidth(value:Number):void 
		{
			_maxWidth = value;
		}
		
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get maxHeight():Number 
		{
			return _maxHeight;
		}
		
		public function set maxHeight(value:Number):void 
		{
			_maxHeight = value;
		}
		
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get clipRect():Rectangle 
		{
			return _clipRect;
		}
		public function set clipRect(value:Rectangle):void 
		{
			_clipRect = value;
		}
		
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get isEnabled():Boolean 
		{
			return _isEnabled;
		}
		public function set isEnabled(value:Boolean):void 
		{
			_isEnabled = value;
		}
		
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get isInitialized():Boolean 
		{
			return _isInitialized;
		}
		
		
		/**
		 * ...
		 * @return	...
		 **/
		
		public function get isCreated():Boolean 
		{
			return _isCreated;
		}
		
		
		public function set isHTML(value:Boolean):void 
		{
			_isHtml = value;
		}
		
		public function set multiLine (value:Boolean):void 
		{
			
		}
		
		public function set verticalTextAlignment(value:String):void 
		{
			_verticalAlign = value;
		}
		public function set textFormat(value:TextFormat):void 
		{
			this.color = uint(value.color);
			this.textScale = int (value.size) / 50;
			_horizontalAlign = value.align;
			_font = value.font;
			_bold = value.bold;
			_italic = value.italic;
		}
		
		
		public function get textFormat():TextFormat
		{
			return new TextFormat (_font, this.textScale * 50, this.color, _bold, _italic, false,null,null,_horizontalAlign);
		}
		

		public function get baseline():Number 
		{
			return _baseline;
		}
	
		public override function set text (value:String):void
		{
			super.text = value;
			/*_rawText = value;
				
			//Now we will parse the text and seperate out the CIP relevant objects
			dispatchEvent(new FormattedTextEvent(FormattedTextEvent.START_INIT));
			_textObjectArr = CIPTagParser.parseText(_rawText);// seperates text into sub sections so that tag data can be added
			dispatchEvent(new FormattedTextEvent(FormattedTextEvent.END_INIT));
			
			truncate ();*/
		}
		
		/**
		 * Adjust the width of the supplied text field to be maxWidth (or less),
		 * truncating the text if needed. It's a ballpark guess only; if you
		 * need something more accurate you can always remove 1 char, test
		 * the textWidth, remove another char, test again, etc until it fits,
		 * but that's kinda inefficient.
		 */
		public function truncate():void
		{
			var numCharsToRemove:int = 0;
			var truncChars:String = HTMLTextParser.TRUNC_CHARS; 
			var truncCharsLength:int = truncChars.length;
			
			
				//no vertical truncation
				var maxWidth:Number = _maxControlWidth;
				var widthRatio:Number = textWidth / maxWidth;
				
				if (widthRatio > 1)
				{
					numCharsToRemove = _textObjectArr.join("").length - (Math.floor(_textObjectArr.join("").length / widthRatio) - truncCharsLength);
					_text = htmlText = HTMLTextParser.truncateHtmlText(text, numCharsToRemove, truncChars);
				}
			
			// if the truncated text is just the truncation dots and they are spread out over more than one line,
			// nix them altogether.  This would be because the field is too narrow to support all of them.

				_text = htmlText = HTMLTextParser.truncateHtmlText(text, truncChars.length, "");
		}
		
		
		public function set htmlText (value:String):void
		{
			trace("setting text" + value	)
			super.text = value;
		}
		public function get htmlText ():String
		{
			return _rawText;
		}
		
		/**
		 * functions we dont really need...
		 */
		public function get nameList():TokenList {	return new TokenList();}
		public function get styleNameList():TokenList {	return new TokenList();	}
		public function get styleName():String {return "";}
		public function set styleName(value:String):void {}
		public function validate():void  {}
		public function invalidate():void  {}		
		/*public function get styleProvider():IStyleProvider { return null;	}
		public function set styleProvider(value:IStyleProvider):void {}*/
		public function set disabledTextFormat(value:TextFormat):void  {}
		public function set maxControlWidth (value:Number):void  { _maxControlWidth = value; }
		public function set maxControlHeight(value:Number):void  {}
		public function set truncateText(value:Boolean):void  {}
		public function set embedFonts(value:Boolean):void  {}
		public function set antiAliasType(value:String):void {}
		public function get textObjectArr():Array {	return _textObjectArr;}
		public function set textObjectArr (value:Array):void { _textObjectArr = value; }
		public function get depth ():int { return 0; }
	}

}