
function NeighboursInd = findNeighbours(Index,MatrixSize ,conn)
%%**************************************************************************
% Module name:      findNeighbours.m
% Version number:   2
% Revision number:  02
% Revision date:    9-2018
%%
% 2013 (C) Copyright by Patrick Granton, Maastro Clinic       
% Permitted Revision and Modification by A.Zankoor September 2018
%%
%  Inputs:
%      Index: Index of pixel/voxel whose neighbours are required 
%      MatrixSize: Size of the 2D/3D Matrix 
%      conn : for 2D matrix: 4 or 8 connectivity, pixels connected by sides only, sides or corners respectiveley.
%             for 3D matrix: 6,18 or 26 connectivity, voxels connected by faces only, faces or edges, faces or edges or corners respectiveley. 
%  Outputs:
%      NeighboursInd : The valid linear indices of  neighbouring pixels/voxels
%      (valid means not out of the Matrix boundaries)

%  Example: NeighboursInd = findNeighbours(14,[3 3 3],18)
%% Description:
%  This function is a correction and modification to findNeighbours function by Patrick Granton.
%  It gives the indices of valid neighbors to a pixel/voxel in a 2D/3D matrix. 
%  Given the linear index of the pixel/voxel, the size of the 2D/3D matrix and the type of connectivity considered 
%  (4 or 8 / 6,18 or 26 connectivity), the function gives the linear indices of the neighboring pixels/voxels within the matrix size.
%  Finds the valid 8,16 or 26 neighbours of a specific index (i.e. voxel) in a 3-D volume
%  Notes:
%  for a voxel with 26 valid neighbours it has : 6  face connected voxels f (each with two zero moves) ,12 edge (only) connected voxels e (each with one zero moves)
%  , 8 corner (only) connected voxel c  (no zero moves)
%*************************************************************************

%% 
if length(MatrixSize) == 3
   NeighboursInd = findNeighbours3(Index,MatrixSize ,conn);
   else if length(MatrixSize) == 2
   NeighboursInd = findNeighbours2(Index,MatrixSize ,conn);
   else
    disp('Only 2D or 3D matrices allowed')
    return;
   end
end

%% 2D matrices (pixels)
function NeighboursInd = findNeighbours2(Index,MatrixSize ,conn)
if conn == 8
%1 , s
Base = [0 +1; ...
%2 , s
0 -1; ...
%3 , s
+1 0; ...
%4 , s
-1 0; ...
%5 , c
+1 +1; ...
%6 , c
+1 -1; ...
%7 , c
-1 -1; ...
%9 , c
-1 +1];

[I J] = ind2sub(MatrixSize,Index);
neighbours = Base + repmat([I J],[8 1]);
else if  conn == 4
%1 , e
Base = [0 +1; ...
%2 , e
0 -1; ...
%3 , 
+1 0; ...
%4 , e
-1 0];

[I J] = ind2sub(MatrixSize,Index);
neighbours = Base + repmat([I J],[4 1]);
   
else 
     disp(' Connectivity for 2D matrix is 4 or 8 only!')
     return;
end
end
valid_neighbours =   neighbours(:,1) > 0 & neighbours(:,1) <= MatrixSize(1)...
                     & neighbours(:,2) > 0 & neighbours(:,2) <= MatrixSize(2);
valid_neighbours_Indices = find(valid_neighbours ==1);
NeighboursInd = sub2ind(MatrixSize,neighbours(valid_neighbours_Indices,1),neighbours(valid_neighbours_Indices,2));
end

%% 3D matrices (voxels)
function NeighboursInd = findNeighbours3(Index,MatrixSize ,conn)
if conn == 26
%1 , e
Base = [+1 +1 0; ...
%2 , e
+1 -1 0; ...
%3 , c
+1 +1 +1; ...
%4 , e
+1 0 +1; ...
%5 , c
+1 -1 +1; ...
%6 , c
+1 +1 -1; ...
%7 , e
+1 0 -1; ...
%8 , c
+1 -1 -1; ...
%9 , f
+1 0 0; ...
%10 , f
0 +1 0;...
%11 , f 
0 -1 0; ...
%12 , e
0 +1 +1; ...
%13 , f
0 0 +1; ...
%14 , e
0 -1 +1; ...
%15 , e
0 +1 -1; ...
%16 , f
0 0 -1; ...
%17 , e
0 -1 -1; ...
%18 , e
-1 +1 0; ...
%19 , e
-1 -1 0; ...
%20 , c
-1 +1 +1; ...
%21 , e
-1 0 +1; ...
%22 , c
-1 -1 +1; ...
%23 , c
-1 +1 -1; ...
%24 , e
-1 0 -1; ...
%25 , c
-1 -1 -1; ...
%26 , f
-1 0 0];
[I J K] = ind2sub([MatrixSize],Index);
neighbours = Base + repmat([I J K],[26 1]);

else if conn == 18
%1 , e
Base = [+1 +1 0; ...
%2 , e
+1 -1 0; ...
%3 , e
+1 0 +1; ...
%4 , e
+1 0 -1; ...
%5 , f
+1 0 0; ...
%6 , f
0 +1 0; ...
%7 , f 
0 -1 0; ...
%8 , e
0 +1 +1; ...
%9 , f
0 0 +1; ...
%10 , e
0 -1 +1; ...
%11 , e
0 +1 -1; ...
%12 , f
0 0 -1; ...
%13 , e
0 -1 -1; ...
%14 , e
-1 +1 0; ...
%15 , e
-1 -1 0; ...
%16 , e
-1 0 +1; ...
%17 , e
-1 0 -1; ...
%18 , f
-1 0 0];
[I J K] = ind2sub([MatrixSize],Index);
neighbours = Base + repmat([I J K],[18 1]);

else if conn == 6           
%1 , f
Base = [+1 0 0; ...
%2 , f
0 +1 0; ...
%3 , f 
0 -1 0; ...
%4 , f
0 0 +1; ...
%5 , f
0 0 -1; ...
%6 , f
-1 0 0];

[I J K] = ind2sub([MatrixSize],Index);
neighbours = Base + repmat([I J K],[6 1]);
    else 
        disp(' Connectivity for 3D matrix is 6,18 or 26 only!')
        return;
    end
    end
end

valid_neighbours =   neighbours(:,1) > 0 & neighbours(:,1) <= MatrixSize(1)...
                     & neighbours(:,2) > 0 & neighbours(:,2) <= MatrixSize(2)...
                     & neighbours(:,3) > 0 & neighbours(:,3) <= MatrixSize(3);
valid_neighbours_Indices = find(valid_neighbours ==1);
NeighboursInd = sub2ind([MatrixSize],[neighbours(valid_neighbours_Indices,1)],[neighbours(valid_neighbours_Indices,2)],[neighbours(valid_neighbours_Indices,3)]);


end
end