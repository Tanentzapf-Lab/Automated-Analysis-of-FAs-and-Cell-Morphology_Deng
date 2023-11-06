clear all; close all %% Close all open figures
folderName = uigetdir; %%
folder = dir([folderName '/*frames*']); %% Select folder containing images

listActin = {'Red', 'Green', 'Blue'}; %% Actin Channels
[channelActin, ~] = listdlg('PromptString',...
    'Please declare an Actin Channel.', 'ListString', listActin);

conversion = inputdlg('Please enter a conversion Factor');
conversionFactor = str2double(conversion); %% Conversion factor for scaling area

ProtrusionMeanHeightScaled = zeros(length(folder), 1);
ProtrusionMeanWidthScaled = zeros(length(folder), 1);

CellAspectRatio = zeros(length(folder), 1);
CellCircularity = zeros(length(folder), 1);
CellAreaPixels = zeros(length(folder), 1);
CellAreaScaled = zeros(length(folder), 1);

ActinAreaPixels = zeros(length(folder), 1);
ActinPercentage = zeros(length(folder), 1);
ActinMeanOrientation = zeros(length(folder), 1);
ActinSDOrientation = zeros(length(folder), 1);
ActinWeightedMeanOrientation = zeros(length(folder), 1);

FolderName = cell(length(folder), 1);

[ProtrusionNumber, ProtrusionMeanHeightPixels,...
    ProtrusionMeanWidthPixels, ProtrusionMeanAR] = protrusionData(folder, folderName,...
    channelActin, conversionFactor); %% Get protrusion data and generate raw data

for i = 1 : length(folder)
    
    file = fullfile([folderName '/' folder(i).name ]); %% Get each subfolder
    FolderName{i} = folder(i).name; %% Get Folder Name
    
    imageActin = squashImages(file, channelActin); %% Squash the stack into 2D
    
    [CellAspectRatio(i), CellCircularity(i), CellAreaPixels(i),...
        coordinates, maskedImage] = cellData(imageActin); %% Get Cell Data
    
    CellAreaScaled(i) = CellAreaPixels(i) * (conversionFactor ^ 2); %% Scale the cell area Data
    
    ProtrusionMeanHeightScaled(i) = ProtrusionMeanHeightPixels(i) * conversionFactor; %% Scale the Protrusion Height
    ProtrusionMeanWidthScaled(i) = ProtrusionMeanWidthPixels(i) * conversionFactor; %% Scale the Protrusion Width
    
    [ActinMeanOrientation(i), ActinSDOrientation(i), ActinWeightedMeanOrientation(i),...
        ActinAreaPixels(i)] = actinData(maskedImage, coordinates); %% Get Actin Data
    ActinPercentage(i) = (ActinAreaPixels(i) / CellAreaPixels(i)) * 100; %% Calculate Percentage Actin
    
end

table = table(FolderName, CellAreaPixels, CellAreaScaled, CellAspectRatio, CellCircularity,...
    ActinMeanOrientation, ActinSDOrientation, ActinPercentage,...
    ActinWeightedMeanOrientation, ProtrusionNumber, ProtrusionMeanHeightPixels,...
    ProtrusionMeanHeightScaled, ProtrusionMeanWidthPixels, ProtrusionMeanWidthScaled,...
        ProtrusionMeanAR); %% Build the table with all the gathered information

writetable(table, 'Results.xlsx'); %% Write the table to an excel file