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
 
package de.maxdidit.hardware.text.utils 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.system.Capabilities;
	
	/**
	 * ...
	 * @author Michael Skeffington
	 */
	public class FlashPlatform 
	{
		public static function hasAntiAliasing (context3d:Context3D):Boolean
		{
			if (context3d.profile == Context3DProfile.BASELINE_CONSTRAINED)
			{
				return false;
			}
			
			//anti-aliasing is not supported on mobile
			if (Capabilities.cpuArchitecture == "ARM")
			{
				return false;
			}
			
			//how do we check what the anti-aliasing level of the back buffer is?
			
			//none of the obvious tests have failed so we are probably ok to assume anti-aliasing is turned on
			return true;
		}
	}

}