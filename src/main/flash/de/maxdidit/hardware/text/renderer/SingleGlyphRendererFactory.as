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
 
package de.maxdidit.hardware.text.renderer  
{ 
	import de.maxdidit.hardware.font.triangulation.EarClippingTriangulator; 
	import de.maxdidit.hardware.font.triangulation.ITriangulator; 
	import de.maxdidit.hardware.text.glyphbuilders.IGlyphBuilder;
	import de.maxdidit.hardware.text.utils.FlashPlatform;
	import flash.display.Stage;
	import flash.display3D.Context3D; 
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class SingleGlyphRendererFactory implements IHardwareTextRendererFactory 
	{ 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		 
		private var _context3d:Context3D;
		private var _stage:Stage;
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function SingleGlyphRendererFactory(context3d:Context3D, stage:Stage)  
		{ 
			_stage = stage;
			_context3d = context3d; 
		} 
		 
		 
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		 
		/* INTERFACE de.maxdidit.hardware.text.renderer.IHardwareTextRendererFactory */ 
		 
		public function retrieveHardwareTextRenderer():IHardwareTextRenderer  
		{ 
			var renderer:IHardwareTextRenderer
			if (_stage == null || FlashPlatform.hasAntiAliasing (_context3d))
			{
				renderer = new SingleGlyphRenderer(_context3d);  
			}
			else
			{
				renderer = new EdgeSofteningSingleGlyphRenderer (_context3d, _stage);
			} 
			return renderer; 
		} 
		 
	} 
} 
