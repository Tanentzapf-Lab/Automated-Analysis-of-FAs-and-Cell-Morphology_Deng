function[ProtrusionNumber, ProtrusionMeanHeight,...
    ProtrusionMeanWidth, ProtrusionMeanAR] = protrusionData(folder,...
    folderName, channelActin, conversionFactor)

ProtrusionNumber = zeros(length(folder), 1); %% Create vectors
ProtrusionMeanHeight = zeros(length(folder), 1); %% to hold the 
ProtrusionMeanWidth = zeros(length(folder), 1); %% information gathered
ProtrusionMeanAR = zeros(length(folder), 1); %% Per each image

ProtrusionHeights = cell(length(folder), 1); %% Create cells
ProtrusionWidths = cell(length(folder), 1); %% To hold the
ProtrusionARs = cell(length(folder), 1); %% The raw data

for i = 1 : length(folder)
    
    file = fullfile([folderName '/' folder(i).name ]); %% Get each subfolder
    image = im2double(squashImages(file, channelActin)); %% Get image

    imageSize = size(image);%% Check image size [in pixels]

% Set filter sizes based on image size
    if imageSize>2000
        discSize = 20;
        minPeakDist = 50;
    else
        discSize = 3;
        minPeakDist = 10;
    end 

    wdisk = fspecial('disk', discSize); %% Disk filter, radius of 3
    diskImage = imfilter(imadjust(image, [0.05 1.0]),...
        wdisk, 'symmetric'); %% Apply filter, adjust image to remove noise
    mask = imfill(diskImage, 'holes'); %% Fill holes to get cell data
    mask = bwareaopen(mask, 2); %% Remove noise
    
    connectedComp = bwconncomp(mask); %% Find connected components
    data = regionprops(connectedComp, 'Area', 'Centroid', 'PixelList'); %% Get data

    [~,index] = max([data.Area]); %% Define the cell as the largest object in the field
    centroid = data(index).Centroid; %% Get Centroid of largest object (cell)
    x = centroid(1, 1); %% Get x coordinate of centroid
    y = centroid(1, 2); %% Get y coordinate of centroid
    
    coordinates = [data(index).PixelList(:, 1),...
    data(index).PixelList(:, 2)]; %% XY coordinates

    [ysize, xsize] = size(image); %% Get image size 
    mask = zeros(ysize, xsize); %% Create a blank mask

    for j = 1:length(coordinates)
        mask(coordinates(j, 2), coordinates(j, 1)) = 1; %% Create a mask
    end

    outline = bwtraceboundary(mask, [coordinates(1, 2), coordinates(1, 1)], 'S'); %% Trace outline
    
    distances = zeros(length(outline), 1); %% Create vector to hold the distances
    
    for k = 1: length(outline)
        distances(k) = sqrt((outline(k, 2) + x) ^ 2 + (outline(k, 1) + y) ^ 2); %% Find the distance between centroid and outside
    end
    
    figure(2)
    plot((1 : length(distances)), distances); %% Make a plot for special effects
    
    [~, ~, widths, prominences] = findpeaks(distances,'MinPeakDistance',minPeakDist); %% Get the width and height of the peaks in the data
    
    ProtrusionHeights{i} = zeros(length(prominences), 1); %% Make space
    ProtrusionWidths{i} = zeros(length(widths), 1); %% For the generated
    ProtrusionARs{i} = zeros(length(prominences), 1); %% Protrusion data for this image
    
    for m = 1 : length(prominences)
        ProtrusionHeights{i}(m) = prominences(m); %% Record heights of protrusions
        ProtrusionWidths{i}(m) = widths(m); %% Record widths of protrusions
        ProtrusionARs{i}(m) = prominences(m) / widths(m); %% Calculate the AR
    end
end

ProtrusionHeightsRaw = cell2mat(ProtrusionHeights); %% Get the
ProtrusionWidthsRaw = cell2mat(ProtrusionWidths); %% raw data 
ProtrusionARRaw = cell2mat(ProtrusionARs); %% Of the protrusions

ProtrusionHeightsRawScaled = zeros(length(ProtrusionHeightsRaw), 1);
ProtrusionWidthsRawScaled = zeros(length(ProtrusionHeightsRaw), 1);

for b = 1: length(ProtrusionHeightsRaw)
ProtrusionHeightsRawScaled(i) = ProtrusionHeightsRawScaled(i) * conversionFactor;
ProtrusionWidthsRawScaled(i) = ProtrusionWidthsRawScaled(i) * conversionFactor;
end
    
for n = 1 : length(folder)
    ProtrusionNumber(n) = length(ProtrusionHeights{n}); %% Get number of protrusions per image
    ProtrusionMeanHeight(n) = mean(ProtrusionHeights{n}); %% Get mean height of protrusions per image
    ProtrusionMeanWidth(n) = mean(ProtrusionWidths{n}); %% Get mean width of protrusions per image
    ProtrusionMeanAR(n) = mean(ProtrusionARs{n}); %% Get mean AR of protrusions per image
end

rawTable = table(ProtrusionHeightsRaw, ProtrusionHeightsRawScaled, ProtrusionWidthsRaw,...
    ProtrusionWidthsRawScaled, ProtrusionARRaw); %% Create table of raw data
writetable(rawTable, 'ProtrusionRawData.xlsx'); %% Write table to excel file
