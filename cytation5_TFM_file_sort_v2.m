% Image names retrieved from the cytation 5 should be in the form of
% Well_#_#_#_[Channel]_imageNumber.tif
%
% Users must select the folder that contains the .tif files and then select
% cells to be cropped. All cells must be selected at the same time and once
% all cells have been selected the user must double click on a point to
% advance.
%
% This script takes a folder containing tif files retrieved from the
% cytation 5, splits the images by well and allows the user to select
% cells; from whice cropped images are created.

clc
warning('off', 'Images:initSize:adjustingMag');
cropSize = 500;
currentFolder = pwd;
tempDir = 'Z:\I\pabel\laboratory\personnel\techs\Logan Manlove\';
folder_name = uigetdir('Z:\I\pabel\', 'Select folder with TFM images');
if (exist(fullfile(folder_name, 'trypsin'), 'dir') == 0)
    error('No Trypsin folder found');
end
images = dir( fullfile(folder_name, '*.tif'));

for i = 1:length(images)
    
    % Finds the well Number of the image. Steps from the beginning to the
    % first underscore. Well number is stored in .well
    j = 1;
    try
        while (images(i).name(j) ~= '_')
            j = j + 1;
        end
        images(i).well = images(i).name(1:j-1);
    catch
        error('Image name is incorrectly formatted');
    end
    
    % Find the image Read. Finds the location of the string 'Read' and
    % steps untill a '_' is found. 
    
    j = 4;
    readLocation = strfind(images(i).name, 'Read');
    while (images(i).name(j) ~= '_' && readLocation + j < length(images(i).name))
        j = j + 1;
    end
    images(i).read = str2double(images(i).name(readLocation + 5:readLocation + j - 1));
    
    
    % Find the image Channel. Steps from the beginning until an open square
    % bracket is found. Then steps from there until a closed bracket is
    % found. Channel is stored in .channel
    % ********************************************************************
    % Check to see that the GFP images are actually GFP images and the
    % phase are phase
    % ********************************************************************
    gfp = strfind(images(i).name, 'GFP');
    phase = strfind(images(i).name, 'Phase Contrast');
    txred = strfind(images(i).name, 'Texas Red');
    if (~isempty(gfp))
        images(i).channel = 'image';
    elseif (~isempty(phase))
        images(i).channel = 'phase';
    elseif (~isempty(txred))
        images(i).channel = 'txred';
    else
        error('No channel information found')
    end
end

wellReads = containers.Map;
wellImages = containers.Map;
for i = 1:length(images)
    if ~isKey(wellReads, images(i).well)
        wellReads(images(i).well) = [images(i).read];
        wellImages(images(i).well) = i;
    else
        if ~any(images(i).read==wellReads(images(i).well))
            wellReads(images(i).well) = sort([wellReads(images(i).well), images(i).read]);
        end
        wellImages(images(i).well) = [wellImages(images(i).well), i];
    end
end

wellKeys = keys(wellReads);
for i = 1:length(wellKeys)
    phase = 1;
    GFP = 1;
    txred = 1;
    tempReads = wellReads(char(wellKeys(i)));
    tempImages = wellImages(char(wellKeys(i)));
    for j = 1:length(tempReads)
       for k = 1:length(tempImages)
           tempIm = tempImages(k);
          if images(tempIm).read == tempReads(j)
              if strcmp(images(tempIm).channel, 'phase')
                  writeNumber = phase;
                  phase = phase + 1;
              elseif strcmp(images(tempIm).channel, 'image')
                  writeNumber = GFP;
                  GFP = GFP + 1;
              elseif strcmp(images(tempIm).channel, 'txred')
                  writeNumber = txred;
                  txred = txred + 1;
              end
              
              if writeNumber < 10
                  images(tempIm).number = strcat('0', num2str(writeNumber));
              else
                  images(tempIm).number = num2str(writeNumber);
              end
          end
       end
    end
end

for i = 1:length(images)
    % Checks to see if a folder for the well exists in the current
    % directory. If it does not one is created. The image is then moved to
    % the folder
    if (exist(fullfile(folder_name, images(i).well), 'dir') == 0)
        mkdir(fullfile(folder_name, images(i).well));
    end
    movefile(fullfile(folder_name, images(i).name), fullfile(folder_name, images(i).well, strcat(images(i).channel, images(i).number, '.tif')), 'f');
end
    
    
trypImages = dir( fullfile(folder_name, 'trypsin', '*.tif'));
for i = 1:length(trypImages)
    
    % Finds the well Number of the image. Steps from the beginning to the
    % first underscore. Well number is stored in .well
    j = 1;
    try
        while (trypImages(i).name(j) ~= '_')
            j = j + 1;
        end
        trypImages(i).well = trypImages(i).name(1:j-1);
    catch
        error('Image name is incorrectly formatted');
    end
    
    % Find the image Channel. Steps from the beginning until an open square
    % bracket is found. Then steps from there until a closed bracket is
    % found. Channel is stored in .channel
    gfp = strfind(trypImages(i).name, 'GFP');
    if (~isempty(gfp))
        if (exist(fullfile(folder_name, trypImages(i).well), 'dir') == 0)
            mkdir(fullfile(folder_name, trypImages(i).well));
        end
        movefile(fullfile(folder_name, 'trypsin', trypImages(i).name), fullfile(folder_name, trypImages(i).well, 'trypsin.tif'));
    end

    % Checks to see if a folder for the well exists in the current
    % directory. If it does not one is created. The image is then moved to
    % the folder
    
end

% Rechecks the selected directory to retrieve the list of created folders. 
% Steps throught the subfolders in the directory.
dirs = regexp(genpath(folder_name),('[^;]*'),'match');
for folder = 1:length(dirs)
    if (~strcmp(folder_name, dirs{folder}) && ~strcmp(fullfile(folder_name, 'trypsin'), dirs{folder}))
        
        % Retrieves a list of .tif files from the current subfolder and
        % opens the first image. 
        tiffs = dir( fullfile(dirs{folder}, '*.tif'));
        A = imread(fullfile(dirs{folder}, 'phase01.tif'));
        imshow(A);
        
        % Gets a list of points selected by the user
        % *****************************************************************
        % Points that are selected are used to locate where the
        % image is cropped with the point indicating the center of the
        % window. All points must be selected in the first pass and once
        % all points are selected the user must double click on a point to
        % advance
        % *****************************************************************
        [x, y] = getpts;
        
        % Steps through all of the .tif files in the current subfolder
        for i = 1:length(tiffs)
            
            % Retrieves the first image and 'opens' the file
            imageName = tiffs(i).name;
            image = imread(fullfile(dirs{folder}, imageName));
            
            % Steps through all the points that were selected by the user
            % and creates a new file with the cropped image at each point
            for j = 1:length(x);
                tempIm = imcrop(image, [floor(x(j) - cropSize/2), floor(y(j) - cropSize/2), cropSize, cropSize]);
                if (exist(fullfile(dirs{folder}, num2str(j)), 'file') == 0)
                    mkdir(dirs{folder}, num2str(j));
                end 

                imwrite(tempIm, fullfile(dirs{folder}, num2str(j), imageName));
            end
        end
    end
end
