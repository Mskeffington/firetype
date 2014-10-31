/* 
'firetype' is an ActionScript 3 library which loads font files and renders characters via the GPU. 
Copyright �2013 Max Knoblich 
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
 
package de.maxdidit.hardware.font.parser  
{ 
	import flash.events.ErrorEvent;
	import flash.events.Event; 
	import flash.events.EventDispatcher; 
	import flash.events.IOErrorEvent; 
	import flash.events.SecurityErrorEvent; 
	import flash.net.URLLoader; 
	import flash.net.URLLoaderDataFormat; 
	import flash.net.URLRequest; 
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class FontLoaderJob extends EventDispatcher 
	{ 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		private var _url:String; 
		private var _urlLoader:URLLoader; 
		 
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function FontLoaderJob()  
		{ 
			 
		} 
		 
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		 
		public function get urlLoader():URLLoader  
		{ 
			return _urlLoader; 
		} 
		 
		public function get url():String  
		{ 
			return _url; 
		} 
		 
		public function set url(value:String):void  
		{ 
			_url = value; 
		} 
		 
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		 
		public function loadFont(url:String):void 
		{ 
			var urlRequest:URLRequest = new URLRequest(_url); 
			 
			_urlLoader = new URLLoader(); 
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY; 
			 
			_urlLoader.addEventListener(Event.COMPLETE, handleFontLoaded); 
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError); 
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError); 
			 
			_urlLoader.load(urlRequest); 
		} 
		 
		private function removeEventHandlerFromLoader(urlLoader:URLLoader):void 
		{ 
			urlLoader.removeEventListener(Event.COMPLETE, handleFontLoaded); 
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError); 
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError); 
		} 
		 
		private function onIOError(e:IOErrorEvent):void  
		{ 
			var urlLoader:URLLoader = e.target as URLLoader; 
			removeEventHandlerFromLoader(urlLoader); 
			 
			fontLoadingFailed (e.text);
		} 
		
		private function onSecurityError(e:SecurityErrorEvent):void 
		{
			var urlLoader:URLLoader = e.target as URLLoader; 
			removeEventHandlerFromLoader(urlLoader); 
			
			fontLoadingFailed (e.text);
		}
		
		private function fontLoadingFailed (text:String):void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false, false, text)); 
		}
		 
		private function handleFontLoaded(e:Event):void  
		{			 
			var urlLoader:URLLoader = e.target as URLLoader; 
			removeEventHandlerFromLoader(urlLoader); 
			 
			dispatchEvent(new Event(Event.COMPLETE)); 
		} 
			
	} 
} 
