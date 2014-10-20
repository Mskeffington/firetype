/************************************************************************************
 *	
 *	About: Copyright (c) Crestron Electronics, Inc.  All rights reserved.
 *	
 *	Use of this source code is subject to the terms of the Crestron Software
 *	License Agreement under which you licensed this source code.
 *	If you did not accept the terms of the license agreement,
 *	you are not authorized to use this source code. For the terms of the license.
 *	please see the license agreement between you and Crestron at 
 *  http://www.crestron.com/sla.
 *
 *	This source code may be used only for the purpose of developing software for
 *	Crestron Devices and may not be used for any other purpose.  You may not 
 *  sublicense, publish, or distribute this source code in any way.
 *	THE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES OR INDEMNITIES.
 *
 ************************************************************************************/

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