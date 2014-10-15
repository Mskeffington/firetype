package de.maxdidit.hardware.text.starling
{
	import com.crestron.common.enums.ControlState;
	import com.crestron.common.events.FormattedTextEvent;
	import com.crestron.components.text.utils.CIPTagParser;
	import com.crestron.components.text.utils.HTMLTextParser;
	import de.maxdidit.hardware.text.starling.FiretypeStarlingTextField;
	import feathers.core.FeathersControl;
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
	
	
	
	public class FiretypeTextRenderer extends FeathersControl implements ITextRenderer
	{
		protected var _wordWrap:Boolean;
		protected var _baseline:int = 0;
		protected var _horizontalAlign:String;
		protected var _isHtml:Boolean;
		protected var _verticalAlign:String;
		protected var _font:String;
		protected var _bold:Boolean = false;
		protected var _italic:Boolean = false;
		protected var _rawText:String;
		protected var _text:String;
		protected var _textObjectArr:Array = [];
		protected var _maxControlWidth:Number;
		protected var _firetypeStarlingTextField:FiretypeStarlingTextField;
		
		
		public function FiretypeTextRenderer(cache:HardwareCharacterCache = null)
		{
			super ();
			_firetypeStarlingTextField = new FiretypeStarlingTextField ();
			
			addChild (_firetypeStarlingTextField);
		}
		public override function setSize (width:Number, height:Number):void
		{
			_firetypeStarlingTextField.width = width;
			_firetypeStarlingTextField.height = height;
			super.setSize (width, height);
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
			_firetypeStarlingTextField.color = uint(value.color);
			_firetypeStarlingTextField.textScale = int (value.size) / 50;
			_horizontalAlign = value.align;
			_font = value.font;
			_bold = value.bold;
			_italic = value.italic;
		}
		
		
		public function get textFormat():TextFormat
		{
			return new TextFormat (_font, _firetypeStarlingTextField.textScale * 50, _firetypeStarlingTextField.color, _bold, _italic, false,null,null,_horizontalAlign);
		}
		

		public function get baseline():Number 
		{
			return _baseline;
		}
	
		public function get text ():String
		{
			return _firetypeStarlingTextField.text;
		}
		public function set text (value:String):void
		{
			_firetypeStarlingTextField.text = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
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
				var widthRatio:Number = _firetypeStarlingTextField.textWidth / maxWidth;
				
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
			_rawText = value;
			this.text = value;
		}
		public function get htmlText ():String
		{
			return _rawText;
		}
		override public function invalidate (flag:String = INVALIDATION_FLAG_ALL):void
		{
			super.invalidate (flag);
		}
		
		public override function validate ():void  
		{
			if (this.isInvalid()) 
			{
				super.validate ();
				trace("invalidate")
				dispatchEventWith(ControlState.VALIDATION_COMPLETE, true);				
			}
		}
		public function set disabledTextFormat(value:TextFormat):void  {}
		public function set maxControlWidth (value:Number):void  { _maxControlWidth = value; }
		public function set maxControlHeight(value:Number):void  {}
		public function set truncateText(value:Boolean):void  {}
		public function set embedFonts(value:Boolean):void  {}
		public function set antiAliasType(value:String):void {}
		public function get textObjectArr():Array {	return _textObjectArr;}
		public function set textObjectArr (value:Array):void { _textObjectArr = value; }
	}

}