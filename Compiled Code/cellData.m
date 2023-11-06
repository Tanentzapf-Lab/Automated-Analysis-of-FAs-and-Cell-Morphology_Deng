function[CellAspectRatio, CellCircularity, CellAreaPixels, coordinates, fullImage] = cellData(image)

imageSize = size(im2double(image));%% Check image size [in pixels]

% Set filter sizes based on image size
    if imageSize>2000
        discSize = 20;
    else
        discSize = 2;
    end 

wlap = fspecial('laplacian'); %% Laplacian edge detection filter
lapImage = imfilter(image, wlap, 'symmetric'); %% Apply filter

wdisk = fspecial('disk', discSize); %% Disk filter, radius of 10 or 40 pixels
diskImage = imfilter(imadjust(image, [0.05 1.0]),...
    wdisk, 'symmetric'); %% Apply filter, adjust image to remove noise

fullImage = image - lapImage; %% Sharpen edges

mask = imfill(diskImage, 'holes'); %% Fill holes to get cell data
mask = bwareaopen(mask, 2); %% Remove noise

connectedComp = bwconncomp(mask); %% Find connected components
data = regionprops(connectedComp, 'Perimeter', 'Area',...
    'MajorAxisLength', 'MinorAxisLength', 'PixelList'); %% Cell properties

[~,index] = max([data.Area]); %% Define the cell as the largest object in the field

coordinates = [data(index).PixelList(:, 1),...
    data(index).PixelList(:, 2)]; %% XY coordinates

CellAreaPixels = data(index).Area; %% Get cell area
CellCircularity = (4 * pi * data(index).Area) / (data(index).Perimeter) ^ 2; %% Get cell circularity 
CellAspectRatio = data(index).MajorAxisLength / data(index).MinorAxisLength; %% Get cell AR