package de.maxdidit.hardware.text.glyphbuilders
{
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.PathConnector;
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex;
	import de.maxdidit.hardware.font.HardwareGlyph;
	import de.maxdidit.hardware.font.triangulation.InnerOuterTriangulator;
	import de.maxdidit.hardware.font.triangulation.ITriangulator;
	
	/** 
	 * ... 
	 * @author Michael Skeffington
	 */ 
	public class EdgeSofteningGlyphBuilder extends SimpleGlyphBuilder
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _outlineThickness:Number = 45;
		private var _pathConnector:PathConnector;
		private var _innerOuterTriangulator:ITriangulator;
		
		private const MAX_NORMAL_SCALE:Number = 2;
		///////////////////////
		// Constructor
		///////////////////////
		
		public function EdgeSofteningGlyphBuilder(triangulator:ITriangulator)
		{
			super(triangulator);
			_pathConnector = new PathConnector ();
			_innerOuterTriangulator = new InnerOuterTriangulator ();
		}
		
		///////////////////////
		// Member Functions
		///////////////////////		
		override public function buildGlyph(paths:Vector.<Vector.<Vertex>>, originalPaths:Vector.<Vector.<Vertex>>):HardwareGlyph
		{
			var pl:uint = originalPaths.length;
			var i:int = 0;
			
			
			var result:HardwareGlyph = super.buildGlyph(paths, originalPaths);
			for (i = 0; i < pl; i++)
			{
				var path:Vector.<Vertex> = originalPaths[i];
				calculateCurveDistance (-1, path);
				buildOutline(result, path);
			}
			
			
			return result;
		}
		
		private function buildOutline(result:HardwareGlyph, path:Vector.<Vertex>):void
		{
			var outlineBase:Vector.<Vertex> = new Vector.<Vertex>();
			var outlineVertices:Vector.<Vertex> = new Vector.<Vertex>();
			var minDistanceIndices:Vector.<uint> = new Vector.<uint>();
			var vertexA:Vertex;
			var vertexB:Vertex;
			var l:uint = path.length;
			
			//copy original vertices into outlineVertices
			var sumCrossProduct:Number = 0;
			outlineBase.length = l;
			for (var i:int = 0; i < l; i++)
			{
				vertexA = path[i];
				vertexB = path[(i + 1) % l];
				
				sumCrossProduct += vertexA.nX * vertexB.nY - vertexA.nY * vertexB.nX;
				
				vertexB = new Vertex(vertexA.x, vertexA.y, vertexA.onCurve);
				vertexB.nX = -vertexA.nX;
				vertexB.nY = -vertexA.nY;
				
				outlineBase[l - 1 - i] = vertexB;
			}
			
			outlineVertices.length = l;
			
			for (i = 0; i < l; i++)
			{
				vertexA = path[i];
				
				vertexB = new Vertex(vertexA.x, vertexA.y, vertexA.onCurve);
				
				vertexB.nX = vertexA.nX;
				vertexB.nY = vertexA.nY;
				
				vertexB.alpha = 0;
				
				outlineVertices[i] = vertexB;
				
			}
			calculateCurveDistance (3, outlineVertices); 
			calculateCurveDistance (3, outlineBase);
			
			
			var len:int;
			var origLen:int;
			
			// connect outlines
			len = origLen = outlineVertices.length;
			outlineVertices.length += outlineBase.length;
			for (i = outlineBase.length - 1; i >= 0 ; i--)
			{
				outlineVertices[len + (outlineBase.length -i - 1)] = outlineBase[i];
			}
			
			(_innerOuterTriangulator as InnerOuterTriangulator).indexBufferOffset = result.vertices.length;
			_innerOuterTriangulator.triangulatePath (outlineVertices, result.indices, origLen );
			
			// copy outline vertices
			l = outlineVertices.length;
			var k:int = result.vertices.length;
			result.vertices.length += l;
			var prespliceLength:int = k;
			for (i = 0; i < l; i++)
			{
				result.vertices[k++] = outlineVertices[i];
			}
				
		}
		
		private function calculateCurveDistance (distance:int, outlineVertices:Vector.<Vertex>):void
		{
			const outlineLength:uint = outlineVertices.length;
			
			// calculate the distance scale along the normal
			for (var outlineIndex:uint = 0; outlineIndex < outlineLength; outlineIndex++)
			{
				var vertexA:Vertex = outlineVertices[outlineIndex];
				var vertexB:Vertex = outlineVertices[(outlineIndex + 1) % outlineLength];
				var vertexC:Vertex = outlineVertices[(outlineIndex + outlineLength - 1) % outlineLength];
				
				if (vertexA.onCurve == false || vertexB.onCurve == false || vertexC.onCurve == false)
				{
					continue;
				}
				
				var baX:Number = vertexB.y - vertexA.y;
				var baY:Number = -(vertexB.x - vertexA.x);
				var baL:Number = Math.sqrt(baX * baX + baY * baY);
				baX /= baL;
				baY /= baL;
				
				var cosAlpha:Number = Math.abs(baX * vertexA.nX + baY * vertexA.nY);				
				
				var scale:Number = 1 / cosAlpha;
				if (scale > MAX_NORMAL_SCALE)
				{
					scale = MAX_NORMAL_SCALE;
				}
				else if (scale < 1)
				{
					scale = 1;
				}
				
				vertexA.normalOffset = distance * scale;
			}
		}
	
	}

}