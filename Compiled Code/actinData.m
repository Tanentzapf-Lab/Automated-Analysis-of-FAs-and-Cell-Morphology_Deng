function[meanActinOrientation, SDActinOrientation, meanWeightedActinOrientation,...
    ActinArea] = actinData(image, coordinates)

imageSize = size(im2double(image)); %% Check image size [in pixels]

% Set filter sizes based on image size
    if imageSize(1)>2000
        widthSize = 70;
        vectorLength = 10;
    else
        widthSize = 40;
        vectorLength = 5;
    end 


image = im2double(image); %% Get image 

[ysize, xsize] = size(image); %% Get size of image for creating mask
mask = zeros(ysize, xsize); %% Create matrix for the mask

for j = 1:length(coordinates)
    mask(coordinates(j, 2), coordinates(j, 1)) = 1; %% Convert coordinates to mask
end

outline = bwtraceboundary(mask,...
    [coordinates(1, 2), coordinates(1, 1)], 'S'); %% Trace outline of the cell

figure(3)
imshow(image); %% Show image
hold on %% Plot overtop of image
plot(outline(:, 2), outline(:, 1), 'g', 'LineWidth', 1) %% Plot the outline

width = widthSize; %% Set width for segments (Must be an even number) (70 for high resolution (>2000px), 40 for low (<2000px))
x = width + 1 : width / 2 : xsize - width; %% Possible x coordinates based on width segmentation
y = width + 1 : width / 2 : ysize - width; %% Possible y coordinates based on width segmentation

wavg = fspecial('average', [width * 2 + 1, width * 2 + 1]); %% Create averaging filter size of segment

% vectorLength = 5; %% Vector length to plot 3 or 5 or 10

angles = zeros(length(y), length(x)); %% Declare vector to hold angles generated
weightedAngles = zeros(length(y), length(x)); %% Declare vector to hold weighted angles generated
weights = zeros(length(y), length(x)); %% Declare vector to hold weights generated

angleWeights = -bwdist(~mask); %% Compliment of distance transform to weight the angle averages (use [] if using imshow)
angleWeights = rescale(angleWeights); %% Scale weights down so that the memory can hold them

for j = 1: length(x)
   for k = 1:length(y)
       if (mask(y(k), x(j)) == 1) %% Flag segments within mask
           segment = image(y(k) - width : y(k) + width,...
               x(j) - width : x(j) + width); %% Get image segment
           weightsegment = angleWeights(y(k) - width : y(k) + width,...
               x(j) - width : x(j) + width); %% Get matching segment for weights
           segment = segment .* wavg; %% Apply averaging filter
           weight = mean(weightsegment, 'all'); %% Weight for that segment will be the average value in the weight seg
           weights(k, j) = weight;
       
           segFFT = fft2(segment); %% 2D Fast fourier transform
           segABSFFT = abs(fftshift(segFFT)); %% Shift fourier transform
           segThresh = mat2gray(log(segABSFFT + 1)); %% Log filter on fourier transform
           
           segThresh = (segThresh > 0.01); %% Filter out noise 
           
           segFinal = imfill(segThresh, 'holes'); %% Fill holes
       
           connectComp = bwconncomp(segFinal, 4); %% Define connectivity as 4x4 
           data = regionprops(connectComp, 'Orientation', 'Area'); %% Get angle and area
      
           [~, index] = max([data.Area]); %% Define the actin as the largest object in the segment
       
           angles(k, j) = data(index).Orientation; %% Get the angle of the actin in the segment
           
           if(angles(k, j) > 0) %% Angle is perpendicular, if positive angle
               angles(k, j) = angles(k, j) + 90; %% Add 90 degrees
               weightedAngles(k , j) = weight*(angles(k, j) + 90); %% Weight new angle
           end
                   
           if(angles(k, j) < 0) %% If negative angle
               angles(k , j) = angles(k, j) - 90; %% Subtract 90 degrees
               weightedAngles(k , j) = weight*(angles(k, j) - 90); %% Weight new angle
           end
           
           weightedAngles(k, j) = weight*(data(index).Orientation); %%for 0 angles, not too important
           
           line([x(j) - vectorLength * cos(angles(k, j) * pi / 180),...
               x(j) + vectorLength * cos(angles(k, j) * pi / 180)],...
               [y(k) + vectorLength * sin(angles(k, j) * pi / 180),...
               y(k) - vectorLength * sin(angles(k,j) * pi / 180)],...
               'Color', 'g', 'LineWidth', 1) %% Plot the line
       end
   end
end

anglesFinal = angles(:); %% Accumulate angles
anglesFinal = anglesFinal(anglesFinal ~= 0); %% Take angles not equal to zero

meanActinOrientation = mean(anglesFinal); %% Find average of angles
SDActinOrientation = std(anglesFinal); %% Find standard deviation of angles

meanWeightedActinOrientation = (sum(weightedAngles, 'all') / sum(weights, 'all')); %% Weighted avg calculation

imageHist = histeq(image, 1000); %% Equalize image histogram
actinThresh = imadjust(imageHist, [0.9 1.0]); %% Threshold out actin
ActinArea = bwarea(actinThresh); %% Find the area of the actin in pixels
