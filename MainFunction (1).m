%% Reading systole image sequence
[file1,path1] = uigetfile('*.nii.gz',...
                        'Select a systole image sequence (.nii.gz)');
if isequal(file1,0)
   disp('You canceled loading systole images');
else
   disp(['You are loading: ', fullfile(path1,file1)]);
end
Selected_syst_seq=fullfile(path1,file1);
Systole=niftiread(Selected_syst_seq);
%% Reading diastole image sequence

[file2,path2] = uigetfile('*.nii.gz',...
                        'Select a diastole image sequence');
if isequal(file2,0)
   disp('You canceled loading diastole images');
else
   disp(['You are loading: ', fullfile(path2,file2)]);
end
Selected_diast_seq=fullfile(path2,file2);
Diastole=niftiread(Selected_diast_seq);

%% Processing the uploaded images
numSlices_syst=size(Systole,3);
numSlices_diast=size(Diastole,3);

%% Choosing ROI of systole and diastole situated around center of LV
figure, imshow(Systole(:,:,1),[]),title('Choose the LV center in systole');[y1,x1]=getpts; y1=round(y1(1)); x1=round(x1(1));
% Placing the cropped ROI images into 3D arrays 
Syst_ROI_V=uint8(Systole(x1-45:x1+45,y1-45:y1+45,:));

figure, imshow(Diastole(:,:,1),[]),title('Choose the LV center in diastole');[y2,x2]=getpts; y2=round(y2(1)); x2=round(x2(1));
% Placing the cropped ROI images into 3D arrays 
Diast_ROI_V=uint8(Diastole(x2-45:x2+45,y2-45:y2+45,:));
% Empty arrays for segmentation results
Vsegmented_syst= zeros(size(Syst_ROI_V));
Vsegmented_diast=zeros(size(Diast_ROI_V));

Cont_syst=zeros(size(Diast_ROI_V));
Cont_diast=zeros(size(Diast_ROI_V));

Epi_syst=zeros(size(Diast_ROI_V));
Epi_diast=zeros(size(Diast_ROI_V));

%% __________________________LV_blood_pool_detection_______________________

% Performing segmentation on systole images
for i=1:numSlices_syst
       %imshow(ROI_V(:,:,i));
       % Vsegmented_syst(:,:,i) = regiongrowing(Syst_ROI_V(:,:,i),45,45,0.2); 
        
        %ROI_V(:,:,i)=round(moving_average_filter(ROI_V(:,:,i)));
       % ROI_V(:,:,i)=imsharpen(ROI_V(:,:,i),'Radius',5,'Amount',2);

Vsegmented_syst(:,:,i)=Auto_lv(Syst_ROI_V(:,:,i),i);
        
end
% Performing segmentation on Diastole images

for i=1:numSlices_diast
       %imshow(ROI_V(:,:,i));
        %Vsegmented(:,:,i) = regiongrowing(ROI_V(:,:,i),26,26,0.02); 
        
        %ROI_V(:,:,i)=round(moving_average_filter(ROI_V(:,:,i)));
       % ROI_V(:,:,i)=imsharpen(ROI_V(:,:,i),'Radius',5,'Amount',2);
        Vsegmented_diast(:,:,i)=Auto_lv(Diast_ROI_V(:,:,i),i);
        
end

%% __________________________LV_Contour_Detection__________________________
% Performing segmentation on systole images
for i=1:numSlices_syst
       %imshow(ROI_V(:,:,i));
       % Vsegmented_syst(:,:,i) = regiongrowing(Syst_ROI_V(:,:,i),45,45,0.2); 
        
        %ROI_V(:,:,i)=round(moving_average_filter(ROI_V(:,:,i)));
       % ROI_V(:,:,i)=imsharpen(ROI_V(:,:,i),'Radius',5,'Amount',2);

Cont_syst(:,:,i)=Contour_detection(Syst_ROI_V(:,:,i),i);
        
end
% Performing segmentation on Diastole images

for i=1:numSlices_diast
       %imshow(ROI_V(:,:,i));
        %Vsegmented(:,:,i) = regiongrowing(ROI_V(:,:,i),26,26,0.02); 
        
        %ROI_V(:,:,i)=round(moving_average_filter(ROI_V(:,:,i)));
       % ROI_V(:,:,i)=imsharpen(ROI_V(:,:,i),'Radius',5,'Amount',2);
       Cont_diast(:,:,i)=Contour_detection(Diast_ROI_V(:,:,i),i);
        
end

%% _____________________LV_myocardium_segmentation_________________________
%Epicardial contour detection
% Performing segmentation on systole images
for i=1:numSlices_syst


Epi_syst(:,:,i)=Epi_Contour_detection(Syst_ROI_V(:,:,i),i);
        
end
% Performing segmentation on Diastole images

for i=1:numSlices_diast
    
        Epi_diast(:,:,i)=Epi_Contour_detection(Diast_ROI_V(:,:,i),i);
        
end

%% ___________________LV_functional_analysis:(DV,SV,EF)____________________

%% Ejection fraction calculation
Syst_Volume=Volume_calculation(Vsegmented_syst);
Diast_Volume=Volume_calculation(Vsegmented_diast);
EF=100*(Diast_Volume-Syst_Volume)/Diast_Volume;

%% Displayig the Results
sn=5;
figure,
set(gcf,'color','w');
subplot(2,4,1),imshow(Diast_ROI_V(:,:,sn)),title('ROI(D)');
subplot(2,4,2),imshow(Vsegmented_diast(:,:,sn)),title('LV blood pool(D)');
subplot(2,4,3),imshow(Cont_diast(:,:,sn)),title('LV blood pool(D) with watershed');
subplot(2,4,4),imshow(Epi_diast(:,:,sn)),title('Myocardium(D)');
subplot(2,4,5),imshow(Syst_ROI_V(:,:,sn)),title('ROI(S)');
subplot(2,4,6),imshow(Vsegmented_syst(:,:,sn)),title('LV blood pool(S)');
subplot(2,4,7),imshow(Cont_syst(:,:,sn)),title('LV blood pool(S) with watershed');
subplot(2,4,8),imshow(Epi_syst(:,:,sn)),title('Myocardium(S)');

%% ______________Quantative_assesment_of_segmentation_quality______________
%%To perform the quality assesment of segmentation uncomment the code below
%%You will need to provide corresponding ground truth image sequences
% Reading systole ground truth image sequence
% [file3,path3] = uigetfile('*.nii.gz',...
%                         'Select a systole ground truth image sequence (.nii.gz)');
% if isequal(file3,0)
%    disp('You canceled loading systole images');
% else
%    disp(['You are loading: ', fullfile(path3,file3)]);
% end
% Sample_syst_seq=fullfile(path3,file3);
% Vsample_syst=niftiread(Sample_syst_seq);
% % Reading diastole ground truth image sequence
% 
% [file4,path4] = uigetfile('*.nii.gz',...
%                         'Select a diastole ground truth image sequence');
% if isequal(file4,0)
%    disp('You canceled loading diastole images');
% else
%    disp(['You are loading: ', fullfile(path4,file4)]);
% end
% Sample_diast_seq=fullfile(path4,file4);
% Vsample_diast=niftiread(Sample_diast_seq);

%Vsample_syst=uint8(SystSample(x2-45:x2+45,y2-45:y2+45,:));
%Vsample_diast=uint8(DiastSample(x2-45:x2+45,y2-45:y2+45,:));

%%Calculating the dice index 
% %Binarizing the ground truth images to estimate the dice index for
% %LV blood pool only
% for k =1:numSlices_diast
% for i=1:size(Vsample_diast,1)
%     for j=1:size(Vsample_diast,2)
%         if Vsample_diast(i,j,k)>2
%             Vsample_diast(i,j,k)=1;
%         else
%             Vsample_diast(i,j,k)=0;
%         end
%     end
% end
% end
% for k =1:numSlices_syst
% for i=1:size(Vsample_syst,1)
%     for j=1:size(Vsample_syst,2)
%         if Vsample_syst(i,j,k)>2
%             Vsample_syst(i,j,k)=1;
%         else
%             Vsample_syst(i,j,k)=0;
%         end
%     end
% end
% end
% DiceInd=zeros(numSlices_diast,1);
% for k=1:numSlices_syst
% [I,DiceInd(k)]=DiceImg(Vsegmented_diast(:,:,k),double(Vsample_diast(:,:,k)));
% end
%DiceIndex=mean(DiceInd);
