function[image] = squashImages(file, channel)
folder2 = dir([file '/*.tif']); %% Get subfolder directory

for i = 1 : length(folder2) 
    imageTemp = imread(fullfile([file '/' folder2(i).name])); %% Read the image into the workspace
    
    imageTempChannel = imageTemp(:,:,channel); %% Retrieve only the channel values
    
    images(:,:,i) = imageTempChannel; %% Save this image plane into a 3D matrix/image for 3D counting
end

image = max(images,[],3); %% Get the maximum pixel values 