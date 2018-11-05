clc
% Sets the pabel file path as a temporary directory and then starts the UI
% for folder selection either at the temporary directory if available or at
% the default path.
tempDir = 'Z:\I\pabel\';
if (exist(tempDir, 'file') == 0)
    directoryIn = uigetdir('Select folder with images');
else
    directoryIn = uigetdir(tempDir, 'Select folder with images');
end

% Retrieves number of files with '.tif' extensions in the directory
images = dir( fullfile(directoryIn, '*.tif'));
% Steps through each tif file in the directory
for i = 1:length(images)
   % Retrieves the image name
   image = images(i).name;
   
   % Removes the '.tif' extension from the image name
   % Finds the string 'xy' in the name and stores the cell number following
   % it
   % Finds the string 'c' in the name and stores the channel number
   % following it   
   imagex = image( 1 : strfind(image, '.tif') - 1);
   cellNumberStart = strfind(image, 'xy') + 2;
   cellChanStart = strfind(image, 'c') + 1;
   cellNumberEnd = cellNumberStart;
   cellChanEnd = cellChanStart;
   
   % Find the length of the channel number and stores the number to
   % imageChan
   while (~isnan(str2double(imagex(cellChanEnd))) && cellChanEnd < length(imagex))
       cellChanEnd = cellChanEnd + 1;
   end
   if cellChanEnd == length(imagex)
       cellChanEnd = cellChanEnd + 1;
   end
   imageChan = str2double(imagex(cellChanStart:cellChanEnd - 1));
   
   % Find the length of the cell number and stores the number to cellNum.
   while (~isnan(str2double(imagex(cellNumberEnd))) && cellNumberEnd < length(imagex))
       cellNumberEnd = cellNumberEnd + 1;
   end
   if cellNumberEnd == length(imagex)
       cellNumberEnd = cellNumberEnd + 1;
   end
   cellNum = imagex(cellNumberStart:cellNumberEnd - 1);
   
   % Checks if a folder for the cell exists and creates one if it doesn't.
   if (exist(fullfile(directoryIn, cellNum), 'dir') == 0)
        mkdir(directoryIn, cellNum)
   end 
   
   % Checks for the word trypsin in the name and if the channel is 1 moves
   % the trypsin file to the corresponding cell folder and then copies the
   % file to a folder within the cell folder titled 'kinetic'
   if strfind(imagex, 'trypsin')
       if (imageChan == 2) % IMAGE
           movefile(fullfile(directoryIn, image), fullfile(directoryIn, cellNum, 'trypsin.tif'));
           if (exist(fullfile(directoryIn, cellNum, 'kinetic'), 'file'))
               copyfile(fullfile(directoryIn, cellNum, 'trypsin.tif'), fullfile(directoryIn, cellNum, 'kinetic', 'trypsin.tif'));
           else
               mkdir(fullfile(directoryIn, cellNum), 'kinetic');
               copyfile(fullfile(directoryIn, cellNum, 'trypsin.tif'), fullfile(directoryIn, cellNum, 'kinetic', 'trypsin.tif'));
           end
       end
       
   % Checks the name for the word 'baseline' and moves the file to the
   % corresponding cell folder. Renames channel 1 to image01 and channel 2
   % to phase01.
   elseif strfind(imagex, 'baseline')
       if (imageChan == 2) % IMAGE
           movefile(fullfile(directoryIn, image), fullfile(directoryIn, cellNum, 'image01.tif'));
       elseif (imageChan == 1) % PHASE
           movefile(fullfile(directoryIn, image), fullfile(directoryIn, cellNum, 'phase01.tif'));
       end
       
   % For cells that are not trypsin or baseline the name is searched for
   % the letter 't' to locate the time component of the name.
   else
       imageNumberStart = strfind(imagex, 't') + 1;
       imageNumberEnd = imageNumberStart;
       while (~isnan(str2double(imagex(imageNumberEnd))) && imageNumberEnd < length(imagex))
            imageNumberEnd = imageNumberEnd + 1;
       end
       if imageNumberEnd == length(imagex)
           imageNumberEnd = imageNumberEnd + 1;
       end
       time = str2double(imagex(imageNumberStart:imageNumberEnd - 1));
       if (time < 10)
           timeStr = strcat('0', num2str(time));
       else
           timeStr = num2str(time);
       end
       
       % If the kinetic directory for the corresponding cell does not
       % exist; it is created.
       if (exist(fullfile(directoryIn, cellNum, 'kinetic'), 'file') == 0)
            mkdir(fullfile(directoryIn, cellNum), 'kinetic');
       end
       
       % Images are moved to the kinetic folder and renamed image for
       % channel 1 and phase for channel 2 along with the time component.
       if (imageChan == 2) %IMAGE
           name = strcat('image', timeStr, '.tif');
           movefile(fullfile(directoryIn, image), fullfile(directoryIn, cellNum, 'kinetic', name));
       elseif (imageChan == 1) % PHASE
           name = strcat('phase', timeStr, '.tif');
           movefile(fullfile(directoryIn, image), fullfile(directoryIn, cellNum, 'kinetic', name));
       end
       
   end        
end


