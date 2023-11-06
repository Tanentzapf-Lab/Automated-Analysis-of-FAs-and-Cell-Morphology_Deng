clear all; close all %% Close all open figures
folderName = uigetdir; %%
folder = dir([folderName '/*frames*']); %% Select folder containing images

listFA1 = {'Red', 'Green', 'Blue'}; %% 1st FA Channels
[channelFA1, ~] = listdlg('PromptString',...
    'Please declare the 1st FA Channel.', 'ListString', listFA1);

listFA2 = {'Red', 'Green', 'Blue'}; %% 2nd FA Channels
[channelFA2, ~] = listdlg('PromptString',...
    'Please declare the 2nd FA Channel.', 'ListString', listFA2);

conversion = inputdlg('Please enter a conversion Factor');
conversionFactor = str2double(conversion); %% Conversion factor for scaling area

FAAreaScaled = zeros(length(folder), 1);
FolderName = cell(length(folder), 1);

[FANumber, FAAreaPixels, FAMeanIntensity1, FAMeanIntensity2,...
    FAMeanCircularity, FAMeanAR,...
    FAMeanSamplePearsonCoef] = FAData(folder, folderName,...
    channelFA1, channelFA2); %% Get FA data and generate raw data

for i = 1 : length(folder)

    file = fullfile([folderName '/' folder(i).name ]); %% Get each subfolder
    FolderName{i} = folder(i).name; %% Get Folder Name
    FAAreaScaled(i) = FAAreaPixels(i) * (conversionFactor ^ 2); %% Scale the FA area Data
    
end


table = table(FolderName,FANumber, FAAreaPixels, FAAreaScaled, FAMeanIntensity1, FAMeanIntensity2,...
        FAMeanCircularity, FAMeanAR, FAMeanSamplePearsonCoef); %% Build the table with all the gathered information

writetable(table, 'Results.xlsx'); %% Write the table to an excel file