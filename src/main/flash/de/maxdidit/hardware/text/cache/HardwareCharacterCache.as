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

package de.maxdidit.hardware.text.cache
{
	import de.maxdidit.hardware.font.data.tables.required.cmap.CharacterIndexMappingTableData;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.GlyphTableData;
	import de.maxdidit.hardware.font.parser.tables.TableNames;
	import de.maxdidit.hardware.font.triangulation.EarClippingTriangulator;
	import de.maxdidit.hardware.text.components.HardwareGlyphInstance;
	import de.maxdidit.hardware.text.format.HardwareTextFormat;
	import de.maxdidit.hardware.text.components.HardwareGlyphInstance;
	import de.maxdidit.hardware.text.format.TextColor;
	import de.maxdidit.hardware.text.glyphbuilders.IGlyphBuilder;
	import de.maxdidit.hardware.text.glyphbuilders.SimpleGlyphBuilder;
	import de.maxdidit.hardware.text.HardwareText;
	import de.maxdidit.hardware.text.renderer.AGALMiniAssembler;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.Glyph;
	import de.maxdidit.hardware.font.triangulation.ITriangulator;
	import de.maxdidit.hardware.font.HardwareFont;
	import de.maxdidit.hardware.font.HardwareGlyph;
	import de.maxdidit.hardware.text.renderer.IHardwareTextRenderer;
	import de.maxdidit.hardware.text.renderer.IHardwareTextRendererFactory;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class HardwareCharacterCache
	{
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		
		private var _glyphCache:Object = new Object();
		
		private var _rendererFactory:IHardwareTextRendererFactory;
		private var _sections:Vector.<HardwareCharacterCacheSection>;
		protected var _renderers:Vector.<IHardwareTextRenderer>;
		private var _sectionsByText:Dictionary = new Dictionary (true);
		
		private var _glyphBuilder:IGlyphBuilder;
		
		private var _clientTexts:Vector.<HardwareText>;
		
		private var _textFormatMap:HardwareTextFormatMap;
		private var _textColorMap:TextColorMap;
		private var _fontMap:HardwareFontMap;
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		
		public function HardwareCharacterCache(rendererFactory:IHardwareTextRendererFactory, glyphBuilder:IGlyphBuilder = null)
		{
			_rendererFactory = rendererFactory;
			
			_glyphBuilder = glyphBuilder;
			if (!_glyphBuilder)
			{
				_glyphBuilder = new SimpleGlyphBuilder(new EarClippingTriangulator());
			}
			
			_sections = new Vector.<HardwareCharacterCacheSection>();
			_renderers = new Vector.<IHardwareTextRenderer>();
			
			_clientTexts = new Vector.<HardwareText>();
			
			_textFormatMap = new HardwareTextFormatMap();
			_textColorMap = new TextColorMap();
			_fontMap = new HardwareFontMap();
		}
		
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		
		public function get rendererFactory():IHardwareTextRendererFactory
		{
			return _rendererFactory;
		}
		
		public function set rendererFactory(value:IHardwareTextRendererFactory):void
		{
			_rendererFactory = value;
		}
		
		public function get textFormatMap():HardwareTextFormatMap
		{
			return _textFormatMap;
		}
		
		public function get textColorMap():TextColorMap
		{
			return _textColorMap;
		}
		
		public function get fontMap():HardwareFontMap
		{
			return _fontMap;
		}
		
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		
		private function createGlyph(charCode:uint, paths:Vector.<Vector.<Vertex>>, originalPaths:Vector.<Vector.<Vertex>>, hardwareText:HardwareText = null):HardwareGlyph
		{
			var result:HardwareGlyph;
			
			// create hardware glyph
			result = _glyphBuilder.buildGlyph(paths, originalPaths);
			result.charCode = charCode;
			
			result.renderer = addGlyphToRenderer (result);
			
			return result;
		}
		
		public function addGlyphToRenderer (hardwareGlyph:HardwareGlyph):IHardwareTextRenderer
		{
			var renderer:IHardwareTextRenderer;
			
			// insert into renderer 
			const l:uint = _renderers.length;
			for (var i:uint = 0; i < l; i++)
			{
				renderer = _renderers[i];
				if (renderer.addHardwareGlyph(hardwareGlyph))
				{
					return renderer;
				}
			}
			
			//lets try and reuse renderers if we can
			renderer = _rendererFactory.retrieveHardwareTextRenderer();
			
			//add this renderer to the cache of renderers
			_renderers.push (renderer);
			
			if (!renderer.addHardwareGlyph(hardwareGlyph))
			{
				throw new Error ("Can't render glyph. Glyph polygon data does not fit into buffers. Try increasing the vertex distance.");
				return null;
			}
			
			return renderer;
		}
		
		private function getSection (hardwareGlyph:HardwareGlyph, hardwareText:HardwareText = null):HardwareCharacterCacheSection
		{
			var textInstanceSections:Vector.<HardwareCharacterCacheSection>;
			var section:HardwareCharacterCacheSection;
			var renderer:IHardwareTextRenderer = hardwareGlyph.renderer;
			
			if (renderer == null)
			{
				throw new Error("Can't render glyph. Glyph polygon data does not fit into buffers. Try increasing the vertex distance.");
				return null;
			}
			
			if (hardwareText != null)
			{
				textInstanceSections = _sectionsByText[hardwareText]; 
			}
			else 
			{
				textInstanceSections = _sections;
			}
			
			//get the existing section by renderer 
			const l:uint = textInstanceSections.length;
			for (var i:uint = 0; i < l; i++)
			{
				section = textInstanceSections[i];
				
				if (section.renderer == renderer)
				{
					return section;
				}
			}
			
			//create a new section for this renderer
			section = new HardwareCharacterCacheSection(renderer);
			
			//add this section to the text sections
			textInstanceSections.push (section);
			
			return section;
		}
		
		public function registerGlyphInstance(hardwareText:HardwareText, hardwareGlyphInstance:HardwareGlyphInstance, font:HardwareFont, vertexDistance:uint, textColor:TextColor):void
		{
			var section:HardwareCharacterCacheSection = getSection (hardwareGlyphInstance.hardwareGlyph, hardwareText);
			section.registerGlyphInstance(hardwareGlyphInstance, font, vertexDistance, textColor);
		}
		
		public function cacheHardwareCharactersByTextFormat(characters:String, format:HardwareTextFormat):void
		{
			cacheHardwareCharacters(characters, format.font, format.vertexDistance);
		}
		
		public function cacheHardwareCharacters(characters:String, font:HardwareFont, vertexDistance:uint):void
		{
			var cmapData:CharacterIndexMappingTableData = font.data.retrieveTableData(TableNames.CHARACTER_INDEX_MAPPING) as CharacterIndexMappingTableData;
			var glyfData:GlyphTableData = font.data.retrieveTableData(TableNames.GLYPH_DATA) as GlyphTableData;
			
			var glyphInstances:Vector.<HardwareGlyphInstance> = new Vector.<HardwareGlyphInstance>();
			
			const l:uint = characters.length;
			for (var i:uint = 0; i < l; i++)
			{
				var charCode:Number = characters.charCodeAt(i);
				var glyphIndex:int = cmapData.getGlyphIndex(charCode, 3, 1);
				var glyph:Glyph = glyfData.retrieveGlyph(glyphIndex);
				
				glyphInstances.length = 0;
				glyph.retrieveGlyphInstances(glyphInstances);
				
				var il:uint = glyphInstances.length;
				for (var j:uint = 0; j < il; j++)
				{
					var glyphInstance:HardwareGlyphInstance = glyphInstances[j];
					
					var paths:Vector.<Vector.<Vertex>> = new Vector.<Vector.<Vertex>>();
					var originalPaths:Vector.<Vector.<Vertex>> = new Vector.<Vector.<Vertex>>();
					
					glyphInstance.glyph.retrievePaths(vertexDistance, paths, originalPaths);
					addPathsAsHardwareGlyph(glyphInstance.characterCode, paths, originalPaths, font, vertexDistance, glyphInstance.glyph.header.index);		
				}
			}
		}
		
		public function render(hardwareText:HardwareText = null):void
		{
			var section:HardwareCharacterCacheSection
			if ( hardwareText != null)
			{
				//this is a hack... no?
				hardwareText.update (true);
				
				for each (section in _sectionsByText[hardwareText])
				{
					section.render (_textColorMap);
				}
			}
			else
			{
				const cl:uint = _clientTexts.length;
				for (var i:uint = 0; i < cl; i++)
				{
					_clientTexts[i].update ();
				}
			
				var l:uint = _sections.length;
				for (i = 0; i < l; i++)
				{
					section = _sections[i];
					section.render(_textColorMap);
				}
			}
		}
		
		public function clearInstanceCache(hardwareText:HardwareText = null):void
		{
			var i:uint;
			var sections:Vector.<HardwareCharacterCacheSection>;
			var section:HardwareCharacterCacheSection;
			if ( hardwareText != null)
			{
				sections = _sectionsByText[hardwareText];
				const len:uint = sections.length;
				for (i = 0; i < len; i++)
				{
					section = sections[i];
					section.clearInstances ();
				}
				hardwareText.flagForUpdate ();
			}
			else
			{
				sections = _sections;
				const l:uint = sections.length;
				for (i = 0; i < l; i++)
				{
					section = sections[i];
					section.clearInstances();
				}
				
				flagAllClientTextsForUpdate ();
			}
		}
		
		public function addClient(hardwareText:HardwareText):void
		{
			_clientTexts.push (hardwareText);
			_sectionsByText[hardwareText] = new Vector.<HardwareCharacterCacheSection>();
		}
		
		public function removeClient(hardwareText:HardwareText):void
		{
			var index:int = _clientTexts.indexOf(hardwareText);
			if (index == -1)
			{
				return;
			}
			
			_clientTexts.splice (index, 1);
			
			//delete all the sections associated with this text
			var sections:Vector.<HardwareCharacterCacheSection>;
			var section:HardwareCharacterCacheSection;
			const l:uint = sections.length;
			for (var i:uint = 0; i < l; i++)
			{
				section = sections[i];
				section.clearInstances ();
			}
			sections.splice (0, l);
			
			//clean up the keys
			_sectionsByText[hardwareText] = null;
			delete _sectionsByText[hardwareText];
		}
		
		public function getCachedHardwareGlyph(uniqueIdentifier:String, subdivisions:uint, index:uint):HardwareGlyph
		{
			if (!_glyphCache.hasOwnProperty(uniqueIdentifier))
			{
				return null;
			}
			
			var subdivisionsForFont:Object = _glyphCache[uniqueIdentifier];
			if (!subdivisionsForFont.hasOwnProperty(String(subdivisions)))
			{
				return null;
			}
			
			var glyphsForSubdivision:Object = subdivisionsForFont[String(subdivisions)];
			if (!glyphsForSubdivision.hasOwnProperty(String(index)))
			{
				return null;
			}
			
			var hardwareGlyph:HardwareGlyph = glyphsForSubdivision[String(index)];
			return hardwareGlyph;
		}
		
		public function addPathsAsHardwareGlyph(characterCode:int, paths:Vector.<Vector.<Vertex>>, originalPaths:Vector.<Vector.<Vertex>>, font:HardwareFont, vertexDistance:Number, glyphId:int):HardwareGlyph
		{
			var glyph:HardwareGlyph = createGlyph(characterCode, paths, originalPaths);
			addHardwareGlyphToCache(glyph, font, vertexDistance, glyphId);
			
			return glyph;
		}
		
		//DONT DO THIS!
		public function clearHardwareGlyphCache():void
		{
			_glyphCache = new Object ();

			const l:uint = _renderers.length;
			for (var i:uint = 0; i < l; i++)
			{
				_renderers[i].clear();
			}
			
			flagAllClientTextsForUpdate ();
		}
		
		private function flagAllClientTextsForUpdate():void
		{
			const l:uint = _clientTexts.length;
			for (var i:uint = 0; i < l; i++)
			{
				_clientTexts[i].flagForUpdate();
			}
		}
		
		private function addHardwareGlyphToCache(glyph:HardwareGlyph, font:HardwareFont, vertexDistance:uint, glyphID:uint):void
		{
			var subdivisionsInFont:Object = retrieveProperty(_glyphCache, font.uniqueIdentifier);
			var glyphsInSubdivisions:Object = retrieveProperty(subdivisionsInFont, String(vertexDistance));
			
			glyphsInSubdivisions[String(glyphID)] = glyph;
		}
		
		private function retrieveProperty(map:Object, key:String):Object
		{
			var result:Object = map[key];
			
			if (result)
			{
				return result;
			}
			
			result = new Object();
			map[key] = result;
			return result;
		}
	
	}
}
