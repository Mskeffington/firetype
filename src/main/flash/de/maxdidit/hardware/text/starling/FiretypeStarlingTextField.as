package de.maxdidit.hardware.text.starling
{
	import de.maxdidit.hardware.font.HardwareFont;
	import de.maxdidit.hardware.text.cache.HardwareCharacterCache;
	import de.maxdidit.hardware.text.format.HardwareFontFeatures;
	import de.maxdidit.hardware.text.format.TextAlign;
	import de.maxdidit.hardware.text.HardwareText;
	import de.maxdidit.hardware.text.renderer.BatchedGlyphRendererFactory;
	import de.maxdidit.hardware.text.renderer.SentenceRendererFactory;
	import de.maxdidit.hardware.text.renderer.SingleGlyphRendererFactory;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import starling.core.CrestronRenderSupport;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class FiretypeStarlingTextField extends DisplayObjectContainer
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _text:String;
		private var _hardwareText:HardwareText;
		
		private var _color:uint = 0xFF000000; // standard color
		private var _textAlign:uint = TextAlign.LEFT;
		private var _textScale:Number = 1;
		private var _textSkewX:Number = 0;
		private var _textSkewY:Number = 0;
		private var _font:HardwareFont;
		private var _features:HardwareFontFeatures;
		private var _vertexDistance:Number;
		
		private var _cache:HardwareCharacterCache;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function FiretypeStarlingTextField(cache:StarlingHardwareCharacterCache = null)
		{
			_cache = cache;
			
			if (!_cache)
			{
				//starling cache needs to handle its own handling of lost context
				_cache = new StarlingHardwareCharacterCache(new SentenceRendererFactory(Starling.current.context, Starling.current.nativeStage));
			}
			
			if (Starling.current.context)
			{
				_hardwareText = new HardwareText (Starling.current.context, cache);
				_hardwareText.enableTextInstancing = true;
				_hardwareText.scaleX = 0.025;
				_hardwareText.scaleY = -0.025;
				_hardwareText.standardFormat.color = _color;
			}
		}
		
		///////////////////////
		// Member Properties
		///////////////////////
		
		public function get cache():HardwareCharacterCache
		{
			if (!_hardwareText)
			{
				return null;
			}
			
			return _hardwareText.cache;
		}
		
		public function set cache(cache:HardwareCharacterCache):void
		{
			if (_cache != cache)
			{
				_cache = cache;
				
				if (_hardwareText)
				{
					_hardwareText.cache = cache;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		override public function get height():Number 
		{
			if (!_hardwareText)
			{
				return 0;
			}
			
			return _hardwareText.height * scaleY;
		}
		
		override public function set height(value:Number):void 
		{
			//super.height = value;
		}
		
		override public function get width():Number
		{
			if (!_hardwareText)
			{
				return 0;
			}
			
			return _hardwareText.width * scaleX;
		}
		
		override public function set width(value:Number):void
		{
			if (value != super.width)
			{	
				if (_hardwareText)
				{
					_hardwareText.width = value;
				}
			}
		}
		
		public function get textWidth():Number
		{
			if (!_hardwareText)
			{
				return 0;
			}
			
			return _hardwareText.textWidth * scaleX;
		}
		
		public function get textHeight():Number
		{
			if (!_hardwareText)
			{
				return 0;
			}
			
			return _hardwareText.textHeight * scaleY;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			if (_text != value)
			{
				_text = value;
				
				if (!_hardwareText)
				{
					return;
				}
				
				_hardwareText.text = _text;
			}
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			if (value != _color)
			{
				_color = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.color = _color;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		public function get textAlign():uint
		{
			return _textAlign;
		}
		
		public function set textAlign(value:uint):void
		{
			if (_textAlign != value)
			{
				_textAlign = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.textAlign = _textAlign;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		public function get textScale():Number
		{
			return _textScale;
		}
		
		public function set textScale(value:Number):void
		{
			if (_textScale != value)
			{
				_textScale = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.scale = _textScale;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		public function get textSkewX():Number
		{
			return _textSkewX;
		}
		
		public function set textSkewX(value:Number):void
		{
			if (_textSkewX != value)
			{
				_textSkewX = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.shearX = _textSkewX;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		public function get textSkewY():Number
		{
			return _textSkewX;
		}
		
		public function set textSkewY(value:Number):void
		{
			if (_textSkewY != value)
			{
				_textSkewY = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.shearY = _textSkewY;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		public function get font():HardwareFont
		{
			return _font;
		}
		
		public function set font(value:HardwareFont):void
		{
			if (_font != value)
			{
				_font = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.font = _font;
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		public function get features():HardwareFontFeatures
		{
			if (!_hardwareText)
			{
				return null;
			}
			
			return _hardwareText.standardFormat.features;
		}
		
		public function get vertexDistance():Number
		{
			return _vertexDistance;
		}
		
		public function set vertexDistance(value:Number):void
		{
			if (_vertexDistance != value)
			{
				_vertexDistance = value;
				
				if (_hardwareText)
				{
					_hardwareText.standardFormat.vertexDistance = _vertexDistance;
					_hardwareText.cache.clearInstanceCache (_hardwareText);
					_hardwareText.flagForUpdate();
				}
			}
		}
		
		///////////////////////
		// Member Functions
		///////////////////////
		
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (_hardwareText)
			{
				support.finishQuadBatch();
				_hardwareText.calculateTransformations (support.mvpMatrix3D, true);
				_hardwareText.cache.render(_hardwareText);
				
				// Reset vertex buffers
				Starling.current.context.setVertexBufferAt(0, null);
				Starling.current.context.setVertexBufferAt(1, null);
			}
			super.render(support, parentAlpha);
		}
		
		public function update(cacheGlyphs:Boolean = true):void
		{
			if (!_hardwareText)
			{
				return;
			}
			
			_hardwareText.update(cacheGlyphs);
		}
	
	}

}