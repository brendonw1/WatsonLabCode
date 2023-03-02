function [SurfX,SurfY,SurfZ,ClustIdx] = REM_GMMclustering3D(...
    ThreeColumnArray,varargin)
%
% [SurfX,SurfY,SurfZ,ClustIdx] = REM_GMMclustering3D(ThreeColumnArray,varargin)
%
% A combination of plot_gaussian_ellipsoid (a File Exchange contribution)
% and a MathWorks support solution to index data points inside two
% polyhedrons from 3D gaussian mixture model. See links below:
%
% https://www.mathworks.com/matlabcentral/fileexchange/16543-plot_gaussian_ellipsoid
% https://www.mathworks.com/matlabcentral/answers/101396-is-there-a-function-in-matlab-for-detecting-points-inside-a-polyhedron
%
% USAGE
% - ThreeColumnArray: three columns, one per variable. Rows can be from
%                     electrophysiology time samples or video frames.
%
% OUTPUTS
% - SurfX,SurfY,SurfZ: 1x2 cell arrays containing surf coordinates,
%                      one cell per cluster. These coordinates are to plot
%                      the polyhedrons that delimit the clusters.
%
% - ClustIdx: column vector with cluster indices, same length as
%             ThreeColumnArray. NaNs are data points outside the clusters.
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

addParameter(p,'NumClusters',2,@isnumeric)
addParameter(p,'NumFaces',20,@isnumeric)
addParameter(p,'StandDevWidth',20,@isnumeric)

parse(p,varargin{:})
NumClusters   = p.Results.NumClusters;
NumFaces      = p.Results.NumFaces;
StandDevWidth = p.Results.StandDevWidth;



%% Gaussian mixture model
GMModel = fitgmdist(ThreeColumnArray,NumClusters);



%% One iteration per cluster
SurfX = cell(1,NumClusters);
SurfY = cell(1,NumClusters);
SurfZ = cell(1,NumClusters);
ClustIdx = cell(1,NumClusters);
for ClusIdx  = 1:NumClusters
    GMMmu    = GMModel.mu(ClusIdx,:);
    GMMsigma = GMModel.Sigma(:,:,ClusIdx);
    
    % Ellipsoids based on:
    % https://www.mathworks.com/matlabcentral/fileexchange/16543-plot_gaussian_ellipsoid
    [x,y,z] = sphere(NumFaces);
    ap = [x(:) y(:) z(:)]';
    [v,d] = eig(GMMsigma); 
    if any(d(:) < 0)
        fprintf('warning: negative eigenvalues\n');
        d = max(d,0);
    end
    d = StandDevWidth * sqrt(d); % convert variance to StandDevWidth*sd
    bp = (v*d*ap) + repmat(GMMmu(:),1,size(ap,2));
    x = reshape(bp(1,:), size(x));
    y = reshape(bp(2,:), size(y));
    z = reshape(bp(3,:), size(z));
    
    % Data indices based on:
    % https://www.mathworks.com/matlabcentral/answers/101396-is-there-a-function-in-matlab-for-detecting-points-inside-a-polyhedron
    X = [x(:) y(:) z(:)];
    TRI = delaunayn(X);
    ClustIdx{ClusIdx} = tsearchn(X,TRI,ThreeColumnArray);
    ClustIdx{ClusIdx}(~isnan(ClustIdx{ClusIdx})) = ClusIdx;
    
    SurfX{ClusIdx} = x;
    SurfY{ClusIdx} = y;
    SurfZ{ClusIdx} = z;
end

end