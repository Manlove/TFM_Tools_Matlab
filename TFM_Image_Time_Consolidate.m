function TFM_Image_Time_Consolidate()
clc
folder_name = uigetdir('Z:\I\pabel\', 'Select folder with TFM images');
images = dir( fullfile(folder_name, '*.tif'));
names = cell(length(images),1);
for i = 1:length(images)
    names(i) = {images(i).name};
end
imageNum = 1;
phaseNum = 1;
txRedNum = 1;
for i = 1:length(names)
    name = char(names(i));
    index = [strfind(name, 'image', 'ForceCellOutput', true), strfind(name, 'phase', 'ForceCellOutput', true), strfind(name, 'txred', 'ForceCellOutput', true)];
    if (~isempty(cell2mat(index(1))))
        if str2double(name(6:7)) ~= imageNum
            moveFile(folder_name, 'image', imageNum, name)
        end
        imageNum = imageNum + 1;
    elseif (~isempty(cell2mat(index(2))))
        if str2double(name(6:7)) ~= phaseNum
            moveFile(folder_name, 'phase', phaseNum, name)
        end
        phaseNum = phaseNum + 1;
    elseif (~isempty(cell2mat(index(3))))
        if str2double(name(6:7)) ~= txRedNum
            moveFile(folder_name, 'txred', txRedNum, name)
        end
        txRedNum = txRedNum + 1;
    end 
end
end

function moveFile(folder, name, number, file)
if number < 10
    writeNum = strcat('0', num2str(number));
else
    writeNum = num2str(number);
end
movefile(fullfile(folder, file), fullfile(folder, strcat(name, writeNum, '.tif')), 'f')
end 