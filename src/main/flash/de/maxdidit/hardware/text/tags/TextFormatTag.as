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

package de.maxdidit.hardware.text.tags 
{
	
	public class TextFormatTag extends TextTag
	{
		
		public static const TAG:String = "textformat"; 
		public static const TAG_CLOSE:String = "/textformat"; 
		 
		
		public static const BLOCK_INDENT:String = "blockindent";
		public static const INDENT:String = "indent";
		public static const LEADING:String = "leading";
		public static const LEFT_MARGIN:String = "leftmargin";
		public static const RIGHT_MARGIN:String = "rightmargin";
		public static const TAB_STOPS:String = "tabstops";
		/**
		 *	...
		 **/
		public function TextFormatTag() 
		{
			
		}
		
	}

}