function[FANumber, FAMeanArea, FAMeanIntensity1, FAMeanIntensity2,...
    FAMeanCircularity, FAMeanAR,...
    FAMeanSamplePearsonCoef] = FAData(folder, folderName,...
    channelFA1, channelFA2)

FANumber = zeros(length(folder), 1); %% Make room
FAMeanArea = zeros(length(folder), 1); %% For all the 
FAMeanIntensity1 = zeros(length(folder), 1); %% Vectors
FAMeanIntensity2 = zeros(length(folder), 1); %% To be returned
FAMeanCircularity = zeros(length(folder), 1); %% For the result sheet
FAMeanAR = zeros(length(folder), 1);
FAMeanSamplePearsonCoef = zeros(length(folder), 1);


FAAreas = cell(length(folder), 1); %% Make space
FAIntensities1 = cell(length(folder), 1); %% For all
FAIntensities2 = cell(length(folder), 1); %% Of the data
FACircularities = cell(length(folder), 1); %% That is about
FAARs = cell(length(folder), 1); %% To be generated
FASamplePearsonCoef = cell(length(folder), 1); %% For all the images


listType = {'AllOther' ,'TalinHomozygous'}; %% Pick cell type
[stainType, ~] = listdlg('PromptString', ...
    'Please declare the type of Stain', 'ListString', listType);

for i = 1 : length(folder)
    
    file = fullfile([folderName '/' folder(i).name ]); %% Get each subfolder
    imageFA1 = im2double(squashImages(file, channelFA1)); %% Get image with first FA channel
    imageFA2 = im2double(squashImages(file, channelFA2));

    % Filter to be used is based on user cell choice
    if stainType == 1
            maskedimageChannelFA1 = allOtherCellTypesFilter(imageFA1);
            maskedimageChannelFA2 = allOtherCellTypesFilter(imageFA2);
    elseif stainType == 2
            maskedimageChannelFA1 = talinHomozygousFilter(imageFA1);
            maskedimageChannelFA2 = talinHomozygousFilter(imageFA2);
    end 


    maskimageFA1 = maskedimageChannelFA1;
    connectCompTotal = bwconncomp(maskimageFA1, 8); %% Find connected components (FAs)
    numObjects = connectCompTotal.NumObjects; %% Get the number of objects to create vectors
    data1 = regionprops(connectCompTotal, maskimageFA1, 'Area', 'Centroid',...
        'MajorAxisLength', 'MinorAxisLength', 'MeanIntensity', 'Perimeter'); %% Get all the FA data for first FA channel
    
    maskimageFA2 = maskedimageChannelFA2; 
    data2 = regionprops(connectCompTotal,maskimageFA2,'MeanIntensity'); %% Get all the FA data for second FA channel

    % Option to save the masked image
    % figure(i)
    % imshowpair(maskimageFA1,maskimageFA2,'montage'); %% Shows the original and processed image side by side in a montage
    % stringname = 'sidebyside%s'; 
    % imagename = sprintf(stringname,folder(i).name); %% The name of the montage image saved
    % saveas(figure(i),imagename,'png'); %% Saves the montage image in the same folder


    FAAreas{i} = zeros(numObjects, 1); %% Make room for 
    FAIntensities1{i} = zeros(numObjects, 1); %% All of the focal adhesion
    FAIntensities2{i} = zeros(numObjects, 1); %% Data generated
    FACircularities{i} = zeros(numObjects, 1); %% From the specific
    FAARs{i} = zeros(numObjects, 1); %% Image
    FASamplePearsonCoef{i} = zeros(numObjects, 1); %% In this iteration
 
    for j = 1 : numObjects
        FAAreas{i}(j) = data1(j).Area; %% Get area
        FAIntensities1{i}(j) = data1(j).MeanIntensity; %% Get intensity for first channel
        FAIntensities2{i}(j) = data2(j).MeanIntensity; %% Get intensity for second channel
        FAARs{i}(j) = (data1(j).MajorAxisLength) / (data1(j).MinorAxisLength); %% Calculate AR from axes
        
        if ((data1(j).Area * 4 * pi) / ((data1(j).Perimeter) ^ 2) > 1) %% If circularity is impossibly above 1
            FACircularities{i}(j) = 1; %% Tell it that it needs to be 1
        else
        FACircularities{i}(j) = (data1(j).Area * 4 * pi) / ((data1(j).Perimeter) ^ 2); %% Otherwise just take the value
        end

        pixels1 = imageFA1(connectCompTotal.PixelIdxList{i}); %% Get the list of pixels for the first channel
        pixels2 = imageFA2(connectCompTotal.PixelIdxList{i}); %% Get the list of pixels from the second channel
        image1 = im2double(pixels1); %% Convert to double values
        image2 = im2double(pixels2); %% Convert to double values
        r = corrcoef(image1, image2); %% Find Sample Pearson Correlation Coefficient between each pixel
        FASamplePearsonCoef{i}(j) = r(1, 2); %% Get the A, B correlation (from 2x2 matrix generated)
    end
end

FAAreasRaw = cell2mat(FAAreas); %% Get the raw data
FAIntensities1Raw = cell2mat(FAIntensities1); %% From all the 
FAIntensities2Raw = cell2mat(FAIntensities2); %% Generated values
FACircularitiesRaw = cell2mat(FACircularities); %% These are combined
FAARsRaw = cell2mat(FAARs); %% From all of
FASamplePearsonCoefRaw = cell2mat(FASamplePearsonCoef); %% The images

for k = 1 : length(folder)
    FANumber(k) = length(FAAreas{k}); %% Get the number of FA per image
    FAMeanArea(k) = mean(FAAreas{k}); %% Get the mean area of FA per image
    FAMeanIntensity1(k) = mean(FAIntensities1{k}); %% Get the mean intensity of the first FA channel per image
    FAMeanIntensity2(k) = mean(FAIntensities2{k}); %% Get the mean intensity of the second FA channel per image
    FAMeanCircularity(k) = mean(FACircularities{k}); %% Get the mean circularity of FA per image
    FAMeanAR(k) = mean(FAARs{k}); %% Get the mean AR of FA per image
    FAMeanSamplePearsonCoef(k) = mean(FASamplePearsonCoef{k}); %% Get the mean SPC of FA per image
end

rawTable = table(FAAreasRaw, FAIntensities1Raw, FAIntensities2Raw,...
    FACircularitiesRaw, FAARsRaw, FASamplePearsonCoefRaw); %% Make table for raw data

filename = 'FARawData.xlsx';
writetable(rawTable, filename); %% Write table to excel file
