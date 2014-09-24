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
 
package de.maxdidit.hardware.font.triangulation 
{ 
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.contours.Vertex; 
	import de.maxdidit.list.CircularLinkedList; 
	import de.maxdidit.list.elements.UnsignedIntegerListElement; 
	 
	/** 
	 * ... 
	 * @author Michael Skeffington
	 */ 
	public class InnerOuterTriangulator implements ITriangulator 
	{ 		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function InnerOuterTriangulator() 
		{ 
		 
		} 
		public var indexBufferOffset:int = 0;
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		 
		//the point of this function is to always have at least one point from the inner path and 
		//one point from the outer path so that a gradient fade appears consistant
		public function triangulatePath(path:Vector.<Vertex>, indexBuffer:Vector.<uint>, indexOffset:uint):uint 
		{ 
			const l:uint = path.length; 
			if (l == 0) 
			{ 
				return 0; 
			} 
			
			var innerIndexOffset:uint = 0; 
			var outerIndexOffset:uint = indexOffset; 
			
			var innerPath:Vector.<Vertex> = path.slice (0, innerIndexOffset - 1);
			var outerPath:Vector.<Vertex> = path.slice (innerIndexOffset, path.length - 1);
			
			var thirdPointOuter:Boolean = true;
			var numTriangles:uint = 0; 
			
			var vertexCIndex:int = 1;
			
			if (innerPath > outerPath)
			{
				var tempPath:Vector.<Vertex> = outerPath;
				outerPath = innerPath;
				innerPath = tempPath;
				innerIndexOffset = outerIndexOffset;
				outerIndexOffset = 0;
			}
			
			var innerPointIndex:int = innerIndexOffset;
			var outerPointIndex:int = outerIndexOffset;
			
			var vertexA:Vertex;
			var vertexB:Vertex;
			var vertexC:Vertex;
			
			var innerComplete:Boolean = false;
			var outerComplete:Boolean = false;
			var index:int = 0;
			while (!innerComplete || !outerComplete)
			{
				vertexA = innerPath[innerPointIndex];
				vertexB = outerPath[outerPointIndex];
			
				thirdPointOuter = isNextClosestTop (innerPointIndex, outerPointIndex, innerPath, outerPath);
				
				if (thirdPointOuter)
				{
					vertexCIndex = outerPointIndex + 1;
					if (vertexCIndex >= outerPath.length)
					{
						vertexCIndex = 0;
						outerComplete = true;
						trace("outer complete")
					}
					vertexC = outerPath[vertexCIndex];
					
				}
				else
				{
					vertexCIndex = innerPointIndex + 1;
					if (vertexCIndex >= innerPath.length)
					{
						vertexCIndex = 0;
						innerComplete = true;
						trace("inner complete")
					}
					vertexC = innerPath[vertexCIndex];
				}
				
				// add triangle to result 
				indexBuffer.push (innerPointIndex, outerPointIndex, vertexCIndex);
				 
				numTriangles++; 
				
				//next set?
				if (thirdPointOuter)
				{
					outerPointIndex = vertexCIndex;
				}
				else
				{
					innerPointIndex = vertexCIndex;
				}
				index ++;
				
			}
			 
			return numTriangles; 
		} 
		 
		private function distanceBetweenPoints (vertexA:Vertex, vertexB:Vertex):Number
		{
			return Math.pow (vertexB.x - vertexA.x, 2) + Math.pow (vertexB.y - vertexA.y, 2);
		}
		
		private function isNextClosestTop (innerIndex:int, outerIndex:int, innerPath:Vector.<Vertex>, outerPath:Vector.<Vertex>):Boolean
		{
			var vertexA:Vertex = innerPath[innerIndex];
			var vertexB:Vertex = outerPath[outerIndex];
			
			
			var vertexTop:Vertex = outerPath[outerIndex + 1 >= outerPath.length ? 0 : outerIndex + 1];
			var vertexBottom:Vertex = innerPath[innerIndex + 1 >= innerPath.length ? 0 : innerIndex + 1];
			
			var topDistance:Number = distanceBetweenPoints (vertexA, vertexTop);
			var bottomDistance:Number = distanceBetweenPoints (vertexB, vertexBottom);
			
			return (topDistance < bottomDistance);
		}
		/*
		private function findNextClosestVertexPair (innerIndex:int, outerIndex:int, innerPath:Vector.<Vertex>, outerPath:Vector.<Vertex>):VertexPair
		{
			var vertexA:Vertex = innerPath[innerIndex];
			var vertexB:Vertex = outerPath[outerIndex];
			var currentDistance:Number = var nextDistance:Number = distanceBetweenPoints (vertexA, vertexB);
			var tempVertex:Vertex = vertexB;
			var currentOuterIndex:int = outerIndex;
			var currentInnerIndex:int = innerIndex;
			
			while (nextDistance <= currentDistance)
			{
				vertexB = tempVertex;
				
				currentOuterIndex++;
				tmpVertex = outerPath[currentOuterIndex];
				nextDistance = distanceBetweenPoints (vertexA, tmpVertex);
			}
			
			//couldnt find a closer point in the outer path so lets reset and try looking 
			//for the next closest point in the inner path
			if (vertexB == tmpVertexB)
			{
				//reset our state
				currentInnerIndex = innerIndex;
				currentOuterIndex = outerIndex;
				nextDistance = currentDistance;
				tempVertex = vertexA;
				
				while (nextDistance <= currentDistance)
				{
					vertexA = tempVertex;
					
					currentInnerIndex++;
					tmpVertex = innerPath[currentInnerIndex];
					nextDistance = distanceBetweenPoints (tmpVertex, vertexB);
				}
			}
			
			
			return new VertexPair (vertexA, vertexB);
		}*/
	} 
} 
