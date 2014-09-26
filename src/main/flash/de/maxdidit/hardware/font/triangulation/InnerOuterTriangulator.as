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
		//public var indexBufferOffset:int = 0;
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
			
			var innerPath:Vector.<Vertex> = path.slice(0, indexOffset);
			var outerPath:Vector.<Vertex> = path.slice (indexOffset, path.length);
			
			var thirdPointOuter:Boolean = true;
			var numTriangles:uint = 0; 
			
			var vertexCIndex:int = 1;
			var vertexCOffset:int = 0;
			
			var innerPointIndex:int = 0;
			var outerPointIndex:int = 0;
			
			var vertexA:Vertex;
			var vertexB:Vertex;
			var vertexC:Vertex;
			
			var innerComplete:Boolean = false;
			var outerComplete:Boolean = false;
			
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
					}
					vertexC = outerPath[vertexCIndex];
					vertexCOffset = outerIndexOffset;
				}
				else
				{
					vertexCIndex = innerPointIndex + 1;
					if (vertexCIndex >= innerPath.length)
					{
						vertexCIndex = 0;
						innerComplete = true;
					}
					vertexC = innerPath[vertexCIndex];
					vertexCOffset = innerIndexOffset;
				}
				
				// add triangle to result 
				indexBuffer.push (	innerPointIndex + innerIndexOffset, 
									outerPointIndex + outerIndexOffset, 
									vertexCIndex + vertexCOffset);
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
		
	} 
} 
