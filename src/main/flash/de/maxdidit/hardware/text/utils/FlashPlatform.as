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

package de.maxdidit.hardware.text.utils 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.system.Capabilities;
	
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