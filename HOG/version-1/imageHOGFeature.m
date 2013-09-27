function HOGFeature = imageHOGFeature(image, cellSize, blockSize, overlap, angle, binNum)
% image: path of the image to be processed
% cellSize: the number of pixels per row (or column), default set to 6
% blockSize: the number of cells pre row (or column), default set to 3
% overlap: the proportion of overlap between blocks, default set to 0.5
% angle: 180 for unsigned and 360 for signed, default set to 180
% binNum: the number of bins, default set to 9

if nargin < 2
    % set default parameters
    cellSize = 6;
    blockSize = 3;
    overlap = 0.5;
    angle = 180;
    binNum = 9;
elseif nargin < 6
    error('Input parameters are not enough!');
end

% read in an image
img = imread(image);

% for easy calculation, transform the image into gray scale
if size(img, 3) == 3
    img = rgb2gray(img);
end

% get width and height of the image
[height, width] = size(img);

% calculate gradient image
xFilter = [-1 0 1];     % horizontal filter
yFilter = xFilter';    % vertical filter
xGrad = imfilter(double(img), xFilter);
yGrad = imfilter(double(img), yFilter);

% calculate the magnitude of gradient
gradMag = sqrt(xGrad .^ 2 + yGrad .^ 2);

% calculate orientation of gradient
zeroIndex = xGrad == 0;
xGrad(zeroIndex) = 1e-5;    % prevent divided by 0
slope = yGrad ./ xGrad;
if angle == 180
    orientation = mod((atan(slope) + pi), pi) .* 180 ./ pi;
elseif angle == 360
    orientation = mod((atan2(yGrad, xGrad) + 2 * pi), 2 * pi) .* 360 ./ (2 * pi);
end

% put pixel orientation into corresponding bins
binAngle = angle / binNum;
gradBin = ceil(orientation ./ binAngle);    % number from 1~9

% calculate the number of blocks
blockWidth = cellSize * blockSize;  % blockWidth = blockHeight
skipStep = blockWidth * overlap;
xStepNum = floor((width - blockWidth) / skipStep) + 1;
yStepNum = floor((height - blockWidth) / skipStep) + 1;

% initialize image HOG feature histogram
imageFtrDim = binNum * blockSize^2;  % dimension of a block feature
HOGFeature = zeros(imageFtrDim, xStepNum * yStepNum);   % one column for a block

for y = 1: yStepNum     % for row
    for x = 1: xStepNum     % for column
        x_off = (x - 1) * skipStep + 1;
        y_off = (y - 1) * skipStep + 1;
        % gradient magnitude and orientation bin of a block
        blockGradMag = gradMag(y_off: y_off + blockWidth - 1, x_off: x_off + blockWidth - 1);
        blockGradBin = gradBin(y_off: y_off + blockWidth - 1, x_off: x_off + blockWidth - 1);
        % calculate hog feature of the block
        curBlockHOGFeature = blockHOGFeature(blockGradMag, blockGradBin, cellSize, blockSize, binNum);
        HOGFeature(:, (y - 1) * xStepNum + x) = curBlockHOGFeature;
    end
end

end





































