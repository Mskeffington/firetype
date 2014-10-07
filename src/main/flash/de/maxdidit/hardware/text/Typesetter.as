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

package de.maxdidit.hardware.text
{
	import de.maxdidit.hardware.font.data.tables.advanced.gpos.GlyphPositioningTableData;
	import de.maxdidit.hardware.font.data.tables.advanced.gsub.GlyphSubstitutionTableData;
	import de.maxdidit.hardware.font.data.tables.advanced.ScriptFeatureLookupTable;
	import de.maxdidit.hardware.font.data.tables.common.features.FeatureListTableData;
	import de.maxdidit.hardware.font.data.tables.common.features.FeatureRecord;
	import de.maxdidit.hardware.font.data.tables.common.features.FeatureTable;
	import de.maxdidit.hardware.font.data.tables.common.features.FeatureTag;
	import de.maxdidit.hardware.font.data.tables.common.language.LanguageSystemTable;
	import de.maxdidit.hardware.font.data.tables.common.lookup.LookupTable;
	import de.maxdidit.hardware.font.data.tables.common.script.ScriptTable;
	import de.maxdidit.hardware.font.data.tables.other.kern.KerningTableData;
	import de.maxdidit.hardware.font.data.tables.required.cmap.CharacterIndexMappingTableData;
	import de.maxdidit.hardware.font.data.tables.required.hmtx.HorizontalMetricsData;
	import de.maxdidit.hardware.font.data.tables.Table;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.Glyph;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.GlyphTableData;
	import de.maxdidit.hardware.font.HardwareFont;
	import de.maxdidit.hardware.font.HardwareGlyph;
	import de.maxdidit.hardware.font.parser.tables.TableNames;
	import de.maxdidit.hardware.text.cache.HardwareCharacterCache;
	import de.maxdidit.hardware.text.components.HardwareCharacterInstance;
	import de.maxdidit.hardware.text.components.HardwareGlyphInstance;
	import de.maxdidit.hardware.text.components.HardwareLine;
	import de.maxdidit.hardware.text.components.HardwareWord;
	import de.maxdidit.hardware.text.components.TextSpan;
	import de.maxdidit.hardware.text.format.HardwareFontFeatures;
	import de.maxdidit.hardware.text.format.HardwareTextFormat;
	import de.maxdidit.hardware.text.format.HardwareTextFormatListElement;
	import de.maxdidit.hardware.text.tags.BoldTag;
	import de.maxdidit.hardware.text.tags.FontTag;
	import de.maxdidit.hardware.text.tags.FormatTag;
	import de.maxdidit.hardware.text.tags.ItalicTag;
	import de.maxdidit.hardware.text.tags.TextFormatTag;
	import de.maxdidit.hardware.text.tags.TextTag;
	import de.maxdidit.hardware.text.tags.UnderlineTag;
	import de.maxdidit.hardware.text.tags.UnknownTag;
	import de.maxdidit.list.LinkedList;
	import flash.text.engine.BreakOpportunity;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class Typesetter
	{
		/////////////////////// 
		// Constants 
		/////////////////////// 
		
		public static const CHAR_CODE_ESCAPE_CHARACTER:uint = Keyboard.BACKSLASH;
		public static const CHAR_CODE_SPACE:uint = Keyboard.SPACE;
		public static const CHAR_CODE_NEWLINE:uint = "\n".charCodeAt( 0 );
		public static const CHAR_CODE_OPEN_ANGLE_BRACKET:uint = "<".charCodeAt( 0 );
		public static const CHAR_CODE_CLOSED_ANGLE_BRACKET:uint = ">".charCodeAt( 0 );
		
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		
		public var _escapeSpecialCharacters:Boolean = true;
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		
		public function Typesetter()
		{
		
		}
		
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		
		private function applyCharacterSubstitutions( textSpans:Vector.<TextSpan> ):void
		{
			var lookupIndices:Vector.<int> = new Vector.<int>();
			
			const l:uint = textSpans.length;
			for ( var i:uint = 0; i < l; i++ )
			{
				// set up 
				var textSpan:TextSpan = textSpans[ i ];
				
				var textFormat:HardwareTextFormat = textSpan.textFormat;
				var font:HardwareFont = textFormat.font;
				
				var gsubData:GlyphSubstitutionTableData = font.data.retrieveTableData( TableNames.GLYPH_SUBSTITUTION_DATA ) as GlyphSubstitutionTableData;
				if ( !gsubData )
				{
					continue;
				}
				
				retrieveLookupIndices( gsubData, lookupIndices, textFormat );
				var ll:uint = lookupIndices.length;
				if ( ll == 0 )
				{
					continue
				}
				
				var characterInstances:LinkedList = textSpan.characterInstances;
				characterInstances.gotoFirstElement();
				
				while ( characterInstances.currentElement )
				{
					var currentCharacter:de.maxdidit.hardware.text.components.HardwareCharacterInstance = characterInstances.currentElement as de.maxdidit.hardware.text.components.HardwareCharacterInstance;
					for ( var j:uint = 0; j < ll; j++ )
					{
						currentCharacter.glyph.applyGlyphLookup( TableNames.GLYPH_SUBSTITUTION_DATA, characterInstances, lookupIndices[ j ] );
					}
					characterInstances.gotoNextElement();
				}
			}
		}
		
		private function retrieveLookupIndices( scriptFeatureLookup:ScriptFeatureLookupTable, lookupIndices:Vector.<int>, textFormat:HardwareTextFormat ):void
		{
			lookupIndices.length = 0;
			if ( !scriptFeatureLookup )
			{
				return;
			}
			
			var scriptTable:ScriptTable = scriptFeatureLookup.scriptListTable.retrieveScriptTable( textFormat.scriptTag );
			if ( !scriptTable )
			{
				return;
			}
			var languageSystemTable:LanguageSystemTable = scriptTable.retrieveLanguageSystemTable( textFormat.languageTag );
			
			var featureIndices:Vector.<uint> = languageSystemTable.featureIndices;
			
			const l:uint = featureIndices.length;
			for ( var i:uint = 0; i < l; i++ )
			{
				var feature:FeatureRecord = scriptFeatureLookup.featureListTable.featureRecords[ featureIndices[ i ] ];
				if ( !textFormat.features.hasFeatureTag( feature.featureTag.tag ) )
				{
					continue;
				}
				
				var featureLookupIndices:Vector.<uint> = feature.featureTable.lookupListIndices;
				var fl:uint = featureLookupIndices.length;
				
				for ( var f:uint = 0; f < fl; f++ )
				{
					lookupIndices.push( featureLookupIndices[ f ] );
				}
			}
		}
		
		public function createTextSpans( text:String, standardTextFormat:HardwareTextFormat, cache:HardwareCharacterCache ):Vector.<TextSpan>
		{
			var fontStack:LinkedList = new LinkedList();
			fontStack.addElement( new HardwareTextFormatListElement( standardTextFormat ) );
			if ( !cache.textColorMap.hasTextColorId( standardTextFormat.textColor.id ) )
			{
				cache.textColorMap.addTextColor( standardTextFormat.textColor );
			}
			
			var result:Vector.<TextSpan> = new Vector.<TextSpan>();
			
			var switchFont:Boolean = true;
			
			const l:uint = text.length;
			for ( var i:uint = 0; i < l; i++ )
			{
				// react to tag 
				if ( switchFont )
				{
					var currentFontFormat:HardwareTextFormat = ( fontStack.lastElement as HardwareTextFormatListElement ).hardwareTextFormat;
					
					if ( currentFontFormat )
					{
						var cmapData:CharacterIndexMappingTableData = currentFontFormat.font.data.retrieveTableData( TableNames.CHARACTER_INDEX_MAPPING ) as CharacterIndexMappingTableData;
						var glyfData:GlyphTableData = currentFontFormat.font.data.retrieveTableData( TableNames.GLYPH_DATA ) as GlyphTableData;
						
						var currentSpan:TextSpan = new TextSpan();
						currentSpan.textFormat = currentFontFormat;
						
						var currentCharacterInstances:LinkedList = new LinkedList();
						currentSpan.characterInstances = currentCharacterInstances;
						
						result.push( currentSpan );
					}
					
					switchFont = false;
				}
				
				var charCode:uint = text.charCodeAt( i );
				// check if a tag is starting 
				if ( charCode == CHAR_CODE_OPEN_ANGLE_BRACKET )
				{
					// check which tag this is. 
					var closingIndex:int = getClosingBracketIndex( text, i );
					if ( closingIndex != -1 )
					{
						var tagContent:String = text.substring( i + 1, closingIndex );
						var textTag:TextTag = parseTagContent( tagContent );
						if ( textTag )
						{
							//we really should be passing ALL the containing text here
							textTag.processTag( fontStack, cache, text, i );
							switchFont = textTag.triggerFontSwitch;
							
							i = closingIndex;
							continue;
						}
					}
				}
				
				var glyphIndex:int = cmapData.getGlyphIndex( charCode, 3, 1 );
				
				var glyph:Glyph = glyfData.retrieveGlyph( glyphIndex );
				var currentCharacter:HardwareCharacterInstance = HardwareCharacterInstance.getHardwareCharacterInstance();
				
				currentCharacter.charCode = charCode;
				currentCharacter.glyph = glyph;
				
				currentCharacterInstances.addElement( currentCharacter );
				
				var lastCharacter:HardwareCharacterInstance = currentCharacter;
			}
			
			// apply character substitution 
			applyCharacterSubstitutions( result );
			
			return result;
		}
		
		private function getClosingBracketIndex( text:String, index:int ):int
		{
			var endBracketIndex:int = text.indexOf( ">", index );
			
			if ( isEscaped( text, endBracketIndex ) )
			{
				endBracketIndex = getClosingBracketIndex( text, endBracketIndex + 1 );
			}
			
			return endBracketIndex;
		}
		
		private function isEscaped( text:String, index:int ):Boolean
		{
			return text.charCodeAt( index - 1 ) == CHAR_CODE_ESCAPE_CHARACTER;
		}
		
		private function parseTagContent( tagContent:String ):TextTag
		{
			//var tagElements:Array = tagContent.split(/ +/); 
			//const l:uint = tagElements.length; 
			//if (l < 1) 
			//{ 
			//return null; 
			//} 
			
			var spaceIndex:int = tagContent.indexOf( " " );
			
			var textTag:TextTag = null;
			var tagName:String;
			var tagParameters:String;
			var isSelfTerminating:Boolean = false;
			var isEndTag:Boolean = false;
			
			if ( spaceIndex != -1 )
			{
				tagName = tagContent.substring( 1, spaceIndex );
				tagParameters = tagContent.substring( spaceIndex + 1 );
			}
			else
			{
				tagName = tagContent;
				tagParameters = "";
			}
			
			if ( tagName.charAt( 0 ) == "/" )
			{
				isEndTag = true;
			}
			else if ( tagName.charAt( tagName.length - 1 ) == "/" )
			{
				isSelfTerminating = true;
			}
			
			switch ( tagName.toLowerCase() )
			{
				// Parse the format tag. 
				case BoldTag.TAG: 
					textTag = new BoldTag();
					break;
				case FontTag.TAG: 
					textTag = new FontTag();
					break;
				case FormatTag.TAG: 
					textTag = new FormatTag();
					break;
				case ItalicTag.TAG: 
					textTag = new ItalicTag();
					break;
				case TextFormatTag.TAG: 
					textTag = new TextFormatTag();
					break;
				case UnderlineTag.TAG: 
					textTag = new UnderlineTag();
					break;
				default: 
					textTag = new UnknownTag();
					break;
			}
			
			if ( isEndTag )
			{
				textTag.id = TextTag.CLOSE;
			}
			else
			{
				textTag.id = isSelfTerminating ? TextTag.CLOSE : TextTag.OPEN;
				textTag.parseAttributes( tagParameters );
			}
			
			return textTag;
		}
	}
}
