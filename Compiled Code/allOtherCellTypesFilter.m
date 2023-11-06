function [maskedImage] = allOtherCellTypesFilter(image)

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
    
    wdisk1 = fspecial('disk', disk1); %% Disk filter radius disk1
    wdisk2 = fspecial('disk', disk2); %% Disk filter radius disk2
    binary11 = imfilter(image, wdisk1, 'symmetric'); %% Filter, radius disk1
    binary12 = imfilter(image, wdisk2, 'symmetric'); %% Filter, radius disk2
    binaryMask = binary11 - binary12; %% Subtract images to filter
    binaryMask = imadjust(binaryMask, []); %% Auto adjust image
    binaryMask = histeq(binaryMask, 1000); %% Equalize histogram
    binaryMask = imadjust(binaryMask, [0.95 1.0]); %% Threshold image
    binaryMask = imbinarize(binaryMask); %% Binarize image
    binaryMask = bwareaopen(binaryMask, 10); %% Remove noise
    maskedImage = image.*(binaryMask); %% Apply mask
end 