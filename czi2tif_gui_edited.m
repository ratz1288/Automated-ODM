% Convert CZI to TIF. Works even if they are in folders. With GUI.
% Modified for multiblock images by Radhika (Sep 2022)

tic
%% import external packages
addpath('C:\Users\kunnath\OneDrive - Chalmers\Research\Core MATLAB codes\matlab simple codes\matlab simple codes')
addpath('uipickfiles')
addpath('bfmatlab')

inputList = uipickfiles('Prompt','Select all .czi files. Or the folder contains them','Type',{'*.czi'});

%% Extract file directories from all folders
fileList = {};
for i = 1:length(inputList)
    
    item = inputList{i};
    
    if isfolder(item)
        li = dir(item);
        li = li([li.isdir] == 0);  % exclude others such as '.' and '..' 
        li = fullfile({li.folder}, {li.name}); % full file path
    elseif isfile(item)
        li = item;
    end
    
    fileList = [fileList, li];
    
end

%% Open CZI files. Write TIF files
for m = 1:length(fileList)
    
    item = fileList{m};
    
    % file names
    % Dont have any czi in the file path as all czi will get replaced by
    % tif
    %outputFile = regexprep(item, 'czi','');
    %outputFile = 'C:\Users\kunnath\OneDrive - Chalmers\Desktop\R1000msP2.30ts-01-6_AcquisitionBlock2_pt2'
    [filepath, nameoffile, ext]=fileparts(item);
    myFolders= split(filepath, '\');
    Folderdepth=size(myFolders);
    filepathnew=join(myFolders(1:Folderdepth(1)),'\');
    cd([filepathnew{1,1}])
    mkdir(['tif files'])
    filepathnew2=strcat(filepathnew{1,1},'\','tif files');
    cd([filepathnew2]);
    mkdir([nameoffile]);
    outputFile=strcat(filepathnew2,'\',nameoffile,'\',nameoffile);
    
    % delete if file pre-exist
    if exist(outputFile, 'file')
        delete(outputFile)
    end

    % open the CZI file
    data = bfopen(item);
    sizeofdata=size(data);
    nopositions=sizeofdata(1);
    

    for k=1:nopositions
      if nopositions==1
         imStack = data{1,1}(:,1);
         nframe = numel(imStack);
         name=strcat(outputFile,'.tif');
         name2=strcat(outputFile,'enhanced','.tif');
         for n = 1: nframe 
            im = imStack{n};            
            % saves the original tif file
            imwrite(im,name,'WriteMode','append');               
         end
         im_adjust=imadjust(imStack{1});
         imwrite(im_adjust,name2,'WriteMode','append');
         break;
      end
        strn=num2str(k);
        imStack = data{k,1}(:,1);
        nframe = numel(imStack);
        omeMeta=data{k,4};
        Yposition=double(omeMeta.getPlanePositionY(k-1,1).value);
        ypos=num2str(int64(Yposition));
        Xposition=double(omeMeta.getPlanePositionX(k-1,1).value);
        xpos=num2str(int64(Xposition));
        
         % rename the original image file with series number
        name=strcat(outputFile,strn,'x',xpos,'y',ypos,'.tif');
        % rename the enhanced image file with series number
        name2=strcat(outputFile,'enhanced',strn,'x',xpos,'y',ypos,'.tif');
        ime=imStack{1};
        im_adjust=imadjust(ime);
        %saves the enhanced version of the first frame of the tif file. Comment out if enhanced tif file is not required 
        imwrite(im_adjust,name2,'WriteMode','append');
         %Write to TIF file for multiblock images
        for n = 1: nframe 
            im = imStack{n};            
            % saves the original tif file
            imwrite(im,name,'WriteMode','append');               
        end
    end

end
display('~~~ALL TASK FINISHED!~~~')
toc

