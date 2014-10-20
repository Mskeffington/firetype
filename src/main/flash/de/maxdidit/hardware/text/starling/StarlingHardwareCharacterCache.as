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

package de.maxdidit.hardware.text.starling 
{
	import de.maxdidit.hardware.text.cache.HardwareCharacterCache;
	import de.maxdidit.hardware.text.glyphbuilders.IGlyphBuilder;
	import de.maxdidit.hardware.text.renderer.IHardwareTextRenderer;
	import de.maxdidit.hardware.text.renderer.IHardwareTextRendererFactory;
	import starling.core.Starling;
	import starling.events.Event;
	
	/**
	 *	@author Michael Skeffington
	 **/
	public class StarlingHardwareCharacterCache extends HardwareCharacterCache 
	{
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		public function StarlingHardwareCharacterCache(rendererFactory:IHardwareTextRendererFactory, glyphBuilder:IGlyphBuilder=null) 
		{
			super(rendererFactory, glyphBuilder);
			Starling.current.addEventListener(Event.CONTEXT3D_CREATE, handleContext3DCreated);
		}
		
		private function handleContext3DCreated(e:Event):void 
		{
			for each ( var renderer:IHardwareTextRenderer in _renderers)
			{
				renderer.context3d = Starling.current.context;
			}
			this.clearHardwareGlyphCache();
		}
		
		
	}

}