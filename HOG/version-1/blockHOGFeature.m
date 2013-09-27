function blockFeature = blockHOGFeature(blockGradMag, blockGradBin, cellSize, blockSize, binNum)
% calculate hog feature of a block
% blockMag: gradient magnitude in a block
% blockGradBin: gradient orientation bin in a block
% cellSize: the number of pixels per row (or column)
% blockSize: the number of cells pre row (or column)
% binNum: the number of bins

% initialize block HOG feature histogram
blockFeature = zeros(binNum * blockSize^2, 1);

% divide block into cells
for n = 1: blockSize    % for row
    for m = 1: blockSize    % for column
        % left-top corner coordinate of a cell
        x_off = (m - 1) * cellSize + 1;
        y_off = (n - 1) * cellSize + 1;
        % gradient magnitude and orientation bin of a cell
        cellGradMag = blockGradMag(y_off: y_off + cellSize - 1, x_off: x_off + cellSize - 1);
        cellGradBin = blockGradBin(y_off: y_off + cellSize - 1, x_off: x_off + cellSize - 1);
        % calculate hog feature histogram of a cell
        cellHOGFtr = zeros(binNum, 1);
        for i = 1: binNum
            cellHOGFtr(i) = sum(cellGradMag(cellGradBin == i));     % weight by magnitude itself
        end
        % merge the cell HOG feature histogram into its containing block
        % HOG feature histogram
        num = (n - 1) * blockSize + m;
        blockFeature((num - 1) * binNum + 1: num * binNum, 1) = cellHOGFtr; 
    end
end

% normalize block HOG feature histogram using L2-Norm
total = sum(blockFeature .^ 2);
blockFeature = blockFeature ./ sqrt(total + eps^2);

end

