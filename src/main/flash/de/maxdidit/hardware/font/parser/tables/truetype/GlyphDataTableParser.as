package de.maxdidit.hardware.font.parser.tables.truetype 
{
	import de.maxdidit.hardware.font.data.ITableMap;
	import de.maxdidit.hardware.font.data.tables.Table;
	import de.maxdidit.hardware.font.data.tables.TableRecord;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Contour;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.IPathSegment;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.Glyph;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.GlyphHeader;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.GlyphTableData;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.SimpleGlyph;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.SimpleGlyphFlags;
	import de.maxdidit.hardware.font.data.tables.truetype.LocationTableData;
	import de.maxdidit.hardware.font.parser.DataTypeParser;
	import de.maxdidit.hardware.font.parser.tables.ITableParser;
	import de.maxdidit.hardware.font.parser.tables.TableNames;
	import de.maxdidit.hardware.font.parser.tables.truetype.contours.ContourParser;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class GlyphDataTableParser implements ITableParser 
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _dataTypeParser:DataTypeParser;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function GlyphDataTableParser(dataTypeParser:DataTypeParser) 
		{
			this._dataTypeParser = dataTypeParser;
		}
		
		///////////////////////
		// Member Functions
		///////////////////////
		
		/* INTERFACE de.maxdidit.hardware.font.parser.tables.ITableParser */
		
		public function parseTable(data:ByteArray, record:TableRecord, tableMap:ITableMap):* 
		{
			var result:GlyphTableData = new GlyphTableData();
			
			var locationTable:Table = tableMap.retrieveTable(TableNames.INDEX_TO_LOCATION);
			var glyphOffsets:Vector.<uint> = (locationTable.data as LocationTableData).offsets;
			
			var glyphs:Vector.<Glyph> = parseGlyphs(data, record.offset, glyphOffsets);
			result.glyphs = glyphs;
			
			return result;
		}
		
		private function parseGlyphs(data:ByteArray, offset:uint, glyphOffsets:Vector.<uint>):Vector.<Glyph> 
		{
			const l:uint = glyphOffsets.length;
			var result:Vector.<Glyph> = new Vector.<Glyph>(l);
			
			for (var i:uint = 0; i < l; i++)
			{
				// if the next offset is the same as this one, then this glyph has no contours.
				var hasContour:Boolean = i + 1 == l ? true : glyphOffsets[i] != glyphOffsets[i + 1];
				
				var glyph:Glyph = parseGlyph(data, offset + glyphOffsets[i], hasContour);
				result[i] = glyph;
			}
			
			return result;
		}
		
		private function parseGlyph(data:ByteArray, offset:uint, hasContour:Boolean):Glyph 
		{
			data.position = offset;
			
			var result:Glyph;
			var header:GlyphHeader = parseGlyphHeader(data, hasContour);
			
			if (!hasContour)
			{
				result = new Glyph();
				result.header = header;
				return result;
			}
			
			if (header.numCountours > 0)
			{
				result = parseSimpleGlyph(data, header);
			}
			
			return result;
		}
		
		private function parseSimpleGlyph(data:ByteArray, header:GlyphHeader):SimpleGlyph 
		{
			var result:SimpleGlyph = new SimpleGlyph();
			
			// endPointsOfContours
			var endPointsOfContours:Vector.<uint> = new Vector.<uint>(header.numCountours);
			for (var i:uint = 0; i < header.numCountours; i++)
			{
				endPointsOfContours[i] = _dataTypeParser.parseUnsignedShort(data);
			}
			result.endPointsOfContours = endPointsOfContours;
			var numPoints:uint = endPointsOfContours[endPointsOfContours.length - 1] + 1; // Last field of the vector stores the index of the last point of the glyph. This value + 1 designates the total number of points.
			
			// instructions
			var instructionLength:uint = _dataTypeParser.parseUnsignedShort(data);
			result.instructionLength = instructionLength;
			// only read instructions if length is larger than 0, otherwise readBytes will read to the end of the byte array.
			if (instructionLength > 0)
			{
				var instructions:ByteArray = new ByteArray();
				data.readBytes(instructions, 0, instructionLength);
				result.instructions = instructions;
			}
			
			// flags
			var flagData:Vector.<uint> = new Vector.<uint>();
			var flags:Vector.<SimpleGlyphFlags> = new Vector.<SimpleGlyphFlags>();
			parseFlags(data, numPoints, flagData, flags);
			result.flagData = flagData;
			result.flags = flags;
			
			// coordinates
			var xCoordinates:Vector.<int> = parseXCoordinates(data, flags);
			result.xCoordinates = xCoordinates
			
			var yCoordinates:Vector.<int> = parseYCoordinates(data, flags);
			result.yCoordinates = yCoordinates;
			
			var contourParser:ContourParser = new ContourParser();
			result.contours = contourParser.parseContours(xCoordinates, yCoordinates, endPointsOfContours, flags);
			
			result.header = header;	
			return result;
		}
		
		private function parseXCoordinates(data:ByteArray, glyphFlags:Vector.<SimpleGlyphFlags>):Vector.<int> 
		{
			const l:uint = glyphFlags.length;
			var result:Vector.<int> = new Vector.<int>(l);
			
			var flags:SimpleGlyphFlags;
			var x:int = 0;
			var delta:int;
			
			for (var i:uint = 0; i < l; i++)
			{
				flags = glyphFlags[i];
				
				if (!flags.sameXAsPrevious)
				{
					delta = flags.shortXVector ? int(_dataTypeParser.parseByte(data)) : _dataTypeParser.parseShort(data); // in this context "shortXVector" indicates a 1-byte value, not a 2-byte value as usual.
					delta = flags.shortXVector && !flags.isXPositive ? -delta : delta;
					
					x += delta;
				}
				
				result[i] = x;
			}
			
			return result;
		}
		
		private function parseYCoordinates(data:ByteArray, glyphFlags:Vector.<SimpleGlyphFlags>):Vector.<int> 
		{
			const l:uint = glyphFlags.length;
			var result:Vector.<int> = new Vector.<int>(l);
			
			var flags:SimpleGlyphFlags;
			var y:int = 0;
			var delta:int;
			
			for (var i:uint = 0; i < l; i++)
			{
				flags = glyphFlags[i];
				
				if (!flags.sameYAsPrevious)
				{
					delta = flags.shortYVector ? int(_dataTypeParser.parseByte(data)) : _dataTypeParser.parseShort(data); // in this context "shortYVector" indicates a 1-byte value, not a 2-byte value as usual.
					delta = flags.shortYVector && !flags.isYPositive ? -delta : delta;
					
					y += delta;
				}
				
				result[i] = y;
			}
			
			return result;
		}
		
		private function parseFlags(data:ByteArray, numPoints:uint, flagDatas:Vector.<uint>, glyphFlags:Vector.<SimpleGlyphFlags>):void 
		{
			var i:uint = 0; 
			while (i < numPoints)
			{
				var flagData:uint = _dataTypeParser.parseByte(data);
				flagDatas.push(flagData);
				
				var flags:SimpleGlyphFlags = new SimpleGlyphFlags();
				
				flags.onCurve = (flagData & 1) == 1;
				
				flags.shortXVector = ((flagData >> 1) & 1) == 1;
				flags.shortYVector = ((flagData >> 2) & 1) == 1;
				
				flags.isRepeated = ((flagData >> 3) & 1) == 1;
				flags.numRepeats = flags.isRepeated ? _dataTypeParser.parseByte(data) + 1 : 1;
				
				flags.isXPositive = flags.shortXVector ? ((flagData >> 4) & 1) == 1 : false;
				flags.sameXAsPrevious = !flags.shortXVector ? ((flagData >> 4) & 1) == 1 : false;
				
				flags.isYPositive = flags.shortYVector ? ((flagData >> 5) & 1) == 1 : false;
				flags.sameYAsPrevious = !flags.shortYVector ? ((flagData >> 5) & 1) == 1 : false;
				
				for (var j:uint = 0; j < flags.numRepeats; j++)
				{
					glyphFlags.push(flags);
					i++;
				}
			}
		}
		
		private function parseGlyphHeader(data:ByteArray, hasContour:Boolean):GlyphHeader 
		{
			var result:GlyphHeader = new GlyphHeader();
			
			result.hasContour = hasContour;
			
			if (hasContour)
			{
				result.numCountours = _dataTypeParser.parseShort(data);
			
				result.xMin = _dataTypeParser.parseShort(data);
				result.yMin = _dataTypeParser.parseShort(data);
				result.xMax = _dataTypeParser.parseShort(data);
				result.yMax = _dataTypeParser.parseShort(data);
			}
			
			return result;
		}
		
	}

}