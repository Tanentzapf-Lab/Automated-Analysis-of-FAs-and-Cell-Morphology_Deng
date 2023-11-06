% Written for Tanentzapf Lab, University of British Columbia, 2023
% Authors: Rosalyn Carr, Rhea Kaul

clear all; close all %% Close all open figures
folderName = uigetdir; %% Ask user to select directory
folder = dir([folderName '/*frames*']); %% Select folder containing images

listActin = {'Red', 'Green', 'Blue','None'}; %% Actin Channels
[channelActin, ~] = listdlg('PromptString',...
    'Please declare an Actin Channel.', 'ListString', listActin);

listFA1 = {'Red', 'Green', 'Blue'}; %% 1st FA Channels
[channelFA1, ~] = listdlg('PromptString',...
    'Please declare the 1st FA Channel.', 'ListString', listFA1);
listFA2 = {'Red', 'Green', 'Blue'}; %% 2nd FA Channels
[channelFA2, ~] = listdlg('PromptString',...
    'Please declare the 2nd FA Channel.', 'ListString', listFA2);

conversion = inputdlg('Please enter a conversion Factor');
conversionFactor = str2double(conversion); %% Conversion factor for scaling area

ProtrusionNumber = zeros(length(folder), 1); %% Create vectors for
ProtrusionMeanHeightPixels = zeros(length(folder), 1); %% protrusion data
ProtrusionMeanWidthPixels = zeros(length(folder), 1);
ProtrusionMeanAR = zeros(length(folder), 1);
ProtrusionMeanHeightScaled = zeros(length(folder), 1);
ProtrusionMeanWidthScaled = zeros(length(folder), 1);

CellAspectRatio = zeros(length(folder), 1); %% Create vectors for
CellCircularity = zeros(length(folder), 1); %% cell data 
CellAreaPixels = zeros(length(folder), 1);
CellAreaScaled = zeros(length(folder), 1);

ActinAreaPixels = zeros(length(folder), 1); %% Create vectors for
ActinPercentage = zeros(length(folder), 1); %% actin data
ActinMeanOrientation = zeros(length(folder), 1);
ActinSDOrientation = zeros(length(folder), 1);
ActinWeightedMeanOrientation = zeros(length(folder), 1);

FAAreaScaled = zeros(length(folder), 1); %% Create vectors for
FolderName = cell(length(folder), 1); %% FAD and folder data

[FANumber, FAAreaPixels, FAMeanIntensity1, FAMeanIntensity2,...
    FAMeanCircularity, FAMeanAR,...
    FAMeanSamplePearsonCoef] = FAData(folder, folderName,...
    channelFA1,channelFA2); %% Get FA data and generate raw data

if channelActin ~= 4
    [ProtrusionNumber, ProtrusionMeanHeightPixels,...
    ProtrusionMeanWidthPixels, ProtrusionMeanAR] = protrusionData(folder, folderName,...
    channelActin, conversionFactor); %% Get protrusion data and generate raw data
end 


for i = 1 : length(folder)   
    file = fullfile([folderName '/' folder(i).name ]); %% Get each subfolder
    FolderName{i} = folder(i).name; %% Get Folder Name
    FAAreaScaled(i) = FAAreaPixels(i) * (conversionFactor ^ 2); %% Scale the FA area Data

    if channelActin ~= 4 %% Only if actin channel is identified
        imageActin = squashImages(file, channelActin); %% Generate actin max intensity transform
        
        [CellAspectRatio(i), CellCircularity(i), CellAreaPixels(i),...
            coordinates, maskedImage] = cellData(imageActin); %% Get Cell Data
        
        CellAreaScaled(i) = CellAreaPixels(i) * (conversionFactor ^ 2); %% Scale the cell area Data
       
        
        ProtrusionMeanHeightScaled(i) = ProtrusionMeanHeightPixels(i) * conversionFactor; %% Scale the Protrusion Height
        ProtrusionMeanWidthScaled(i) = ProtrusionMeanWidthPixels(i) * conversionFactor; %% Scale the Protrusion Width
        
        [ActinMeanOrientation(i), ActinSDOrientation(i), ActinWeightedMeanOrientation(i),...
            ActinAreaPixels(i)] = actinData(maskedImage, coordinates); %% Get Actin Data
        ActinPercentage(i) = (ActinAreaPixels(i) / CellAreaPixels(i)) * 100; %% Calculate Percentage Actin
    end 
end 

table = table(FolderName, CellAreaPixels, CellAreaScaled, CellAspectRatio, CellCircularity,...
    FANumber, FAAreaPixels, FAAreaScaled, FAMeanIntensity1, FAMeanIntensity2,...
        FAMeanCircularity, FAMeanAR, FAMeanSamplePearsonCoef,...
    ActinMeanOrientation, ActinSDOrientation, ActinPercentage,...
    ActinWeightedMeanOrientation, ProtrusionNumber, ProtrusionMeanHeightPixels,...
    ProtrusionMeanHeightScaled, ProtrusionMeanWidthPixels, ProtrusionMeanWidthScaled,...
        ProtrusionMeanAR); %% Build the table with all the gathered information


writetable(table, 'Results.xlsx'); %% Write the table to an excel file