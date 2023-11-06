function [maskedImageTalinHomo] = talinHomozygousFilter(image)

    imageSize = size(im2double(image));%% Check image size [in pixels]

    % Set filter sizes based on image size
    % disk1 = 1, 3, 5, 10
    % disk2 = 3, 6, 10, 15
    if imageSize(1)>2000 % Modify based on size of images used
        disk1 = 3;
        disk2 = 6;
    else
       disk1 = 1;
       disk2 = 3; 
    end 
   
    threshold = graythresh(image);
    imagesubtract = image > threshold;
    imagesubtract = im2double(imagesubtract);
    se = strel('disk',disk1);
    imagesubtract = imclose(imagesubtract,se);

    connectedComp = bwconncomp(imagesubtract); %% Find connected components
    data = regionprops(connectedComp, 'Area', 'PixelList'); %% Cell properties
    [~,index] = max([data.Area]);
    coordinates = [data(index).PixelList(:, 1),data(index).PixelList(:, 2)]; %% XY coordinates
    [ysize, xsize] = size(image); %% Get size of image for creating mask
    mask = zeros(ysize, xsize); %% Create matrix for the mask

for j = 1:length(coordinates)
    mask(coordinates(j, 2), coordinates(j, 1)) = 1; %% Convert coordinates to mask
end


% Making and applying the mask 

    wdisk1 = fspecial('disk', disk1); %% Disk filter radius disk1
    wdisk2 = fspecial('disk', disk2); %% Disk filter radius disk2
    binary11 = imfilter(image, wdisk1, 'symmetric'); %% Filter, radius disk1
    binary12 = imfilter(image, wdisk2, 'symmetric'); %% Filter, radius disk2
    binary1 = binary11 - binary12; %% Subtract images to filter
    binary1 = imadjust(binary1, []); %% Auto adjust image
    binary2 = binary1;
    binary2(~mask)= 0; %% Sets unmasked pixels to 0
    binary1 = binary1-binary2; %% Removes unmasked pixels 
    binary1 = histeq(binary1, 1000); %% Equalize histogramx
    binary1 = imadjust(binary1, [0.95 1.0]); %% Threshold image
    binary1 = imbinarize(binary1); %% Binarize image
    binary1= bwareaopen(binary1, 15); %% Remove noise
    maskedImageTalinHomo = image.*(binary1); %% Apply mask

end 