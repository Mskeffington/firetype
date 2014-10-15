/* 
'firetype' is an ActionScript 3 library which loads font files and renders characters via the GPU. 
Copyright �2013 Max Knoblich 
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
 
package de.maxdidit.hardware.font.data.tables.truetype.glyf.contours 
{ 
	import de.maxdidit.list.CircularLinkedList; 
	import de.maxdidit.math.AxisAlignedBoundingBox; 
	 
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class Contour 
	{ 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		private var _vertices:CircularLinkedList; 
		private var _segments:Vector.<IPathSegment>; 
		 
		private var _boundingBox:AxisAlignedBoundingBox; 
		private var _clockWise:Boolean; 
		private var _holes:Vector.<Contour>; 
		
		private var _pathConnector:PathConnector;
		 
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function Contour() 
		{ 
			_holes = new Vector.<Contour>(); 
			_boundingBox = new AxisAlignedBoundingBox(); 
			_pathConnector = new PathConnector();
		} 
		 
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		 
		public function get segments():Vector.<IPathSegment> 
		{ 
			return _segments; 
		} 
		 
		public function set segments(value:Vector.<IPathSegment>):void 
		{ 
			_segments = value; 
		} 
		 
		public function get vertices():CircularLinkedList 
		{ 
			return _vertices; 
		} 
		 
		public function set vertices(value:CircularLinkedList):void 
		{ 
			_vertices = value; 
			calculateBoundingBox(); 
			calculateDirection(); 
		} 
		 
		public function get boundingBox():AxisAlignedBoundingBox 
		{ 
			return _boundingBox; 
		} 
		 
		public function get clockWise():Boolean 
		{ 
			return _clockWise; 
		} 
		 
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		 
		public function contains(contour:Contour):Boolean 
		{ 
			var contourBB:AxisAlignedBoundingBox = contour.boundingBox; 
			 
			if (contourBB.left < _boundingBox.left) 
			{ 
				return false; 
			} 
			 
			if (contourBB.right > _boundingBox.right) 
			{ 
				return false; 
			} 
			 
			if (contourBB.top > _boundingBox.top) 
			{ 
				return false; 
			} 
			 
			if (contourBB.bottom < _boundingBox.bottom) 
			{ 
				return false; 
			} 
			 
			return true; 
		} 
		 
		public function retrievePath(vertexDistance:uint, connectedPath:Vector.<Vertex>, originalPaths:Vector.<Vector.<Vertex>>, expectedClockwise:Boolean = true):void
		{ 
			var path:Vector.<Vertex> = new Vector.<Vertex>(); 
			if (!_segments) 
			{ 
				return; 
			} 
			 
			const l:uint = _segments.length; 
			for (var i:uint = 0; i < l; i++) 
			{ 
				_segments[i].addVerticesToList(path, vertexDistance, expectedClockwise == _clockWise); 
			}
			
			// calculate normals
			const fl:uint = path.length;
			for (i = 0; i < fl; i++)
			{
				var vertexA:Vertex = path[i];
				var vertexB:Vertex = path[(i + 1) % fl];
				var vertexC:Vertex = path[(i + 2) % fl];
				
				var vBAx:Number = vertexB.x - vertexA.x;
				var vBAy:Number = vertexB.y - vertexA.y;
				var vBAl:Number = Math.sqrt(vBAx * vBAx + vBAy * vBAy);
				
				var vBCx:Number = vertexC.x - vertexB.x;
				var vBCy:Number = vertexC.y - vertexB.y;
				var vBCl:Number = Math.sqrt(vBCx * vBCx + vBCy * vBCy);
				
				var nX:Number = -vBAy * vBCl + -vBCy * vBAl;
				var nY:Number = vBAx * vBCl + vBCx * vBAl;
				var nL:Number = Math.sqrt(nX * nX + nY * nY);
				
				vertexB.nX = nX / nL;
				vertexB.nY = nY / nL;
				
			}
			 
			originalPaths.push(path);
			_pathConnector.connectPaths(connectedPath, path);
			
			// add holes 
			const h:uint = _holes.length; 
			for (i = 0; i < h; i++)
			{
				_holes[i].retrievePath(vertexDistance, connectedPath, originalPaths, !expectedClockwise);
			}
		} 
		 
		public function addHole(hole:Contour):void 
		{ 
			_holes.push(hole); 
		} 
		 
		public function sortHoles():void 
		{ 
			_holes.sort(sortByUpperBoundary); 
		} 
		 
		private function sortByUpperBoundary(contourA:Contour, contourB:Contour):Number 
		{ 
			return contourB.boundingBox.top - contourA.boundingBox.top; 
		} 
		 
		private function calculateBoundingBox():void 
		{ 
			var firstElement:VertexListElement = _vertices.firstElement as VertexListElement; 
			var currentElement:VertexListElement = firstElement; 
			var vertex:Vertex; 
			 
			var minX:Number = Number.MAX_VALUE; 
			var minY:Number = Number.MAX_VALUE; 
			 
			var maxX:Number = Number.MIN_VALUE; 
			var maxY:Number = Number.MIN_VALUE; 
			 
			do 
			{ 
				vertex = currentElement.vertex; 
				 
				minX = vertex.x < minX ? vertex.x : minX; 
				minY = vertex.y < minY ? vertex.y : minY; 
				 
				maxX = vertex.x > maxX ? vertex.x : maxX; 
				maxY = vertex.y > maxY ? vertex.y : maxY; 
				 
				currentElement = currentElement.next as VertexListElement; 
			} while (firstElement != currentElement); 
			 
			_boundingBox.left = minX; 
			_boundingBox.bottom = minY; 
			 
			_boundingBox.right = maxX; 
			_boundingBox.top = maxY; 
		} 
		 
		private function calculateDirection():void 
		{ 
			var startElement:VertexListElement = _vertices.firstElement as VertexListElement; 
			var currentElement:VertexListElement = startElement as VertexListElement; 
			 
			var result:Number = 0; 
			var biggestXElement:VertexListElement = startElement; 
			do 
			{ 
				var currentVertex:Vertex = currentElement.vertex; 
				if (currentVertex.x > biggestXElement.vertex.x) 
				{ 
					biggestXElement = currentElement; 
				} 
				else if (currentVertex.x == biggestXElement.vertex.x) 
				{ 
					if (currentVertex.y > biggestXElement.vertex.y) 
					{ 
						biggestXElement = currentElement; 
					} 
				} 
				 
				currentElement = currentElement.next as VertexListElement; 
			} while (startElement != currentElement); 
			 
			currentVertex = biggestXElement.vertex; 
			var previousVertex:Vertex = (biggestXElement.previous as VertexListElement).vertex; 
			var nextVertex:Vertex = (biggestXElement.next as VertexListElement).vertex; 
			 
			var determinant:Number = (currentVertex.x * nextVertex.y + previousVertex.x * currentVertex.y + previousVertex.y * nextVertex.x); 
			determinant -= (previousVertex.y * currentVertex.x + currentVertex.y * nextVertex.x + previousVertex.x * nextVertex.y); 
			_clockWise = determinant > 0; 
		} 
	} 
} 
