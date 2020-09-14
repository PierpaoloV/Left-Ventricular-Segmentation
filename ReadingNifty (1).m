%DataStruct=Read_Files();
%SamplesStruct=Read_Samples();
% %This function should only receive a stack of images from a single patient
% %either in systole or diastole
SystMRIdata=DataStruct(71).SystImage;
DiastMRIdata=DataStruct(71).DiastImage;
SystSample=SamplesStruct(71).SystImage;
DiastSample=SamplesStruct(71).DiastImage;

numSlices_syst=size(SystMRIdata,3);
numSlices_diast=size(DiastMRIdata,3);

%% Choosing ROI of systole and diastole situated around center of LV
figure, imshow(SystMRIdata(:,:,1),[]),title('Choose the LV center in systole');[y1,x1]=getpts; y1=round(y1(1)); x1=round(x1(1));
Syst_ROI_V=uint8(SystMRIdata(x1-45:x1+45,y1-45:y1+45,:));

figure, imshow(DiastMRIdata(:,:,1),[]),title('Choose the LV center in diastole');[y2,x2]=getpts; y2=round(y2(1)); x2=round(x2(1));
Diast_ROI_V=uint8(DiastMRIdata(x2-45:x2+45,y2-45:y2+45,:));
% Placing the cropped ROI images into 3D arrays 
Vsegmented_syst= zeros(size(Syst_ROI_V));
Vsegmented_diast=zeros(size(Diast_ROI_V));

Vsample_syst=uint8(SystSample(x2-45:x2+45,y2-45:y2+45,:));
Vsample_diast=uint8(DiastSample(x2-45:x2+45,y2-45:y2+45,:));
%% Performing segmentation on systole images
for i=1:numSlices_syst
       %imshow(ROI_V(:,:,i));
       % Vsegmented_syst(:,:,i) = regiongrowing(Syst_ROI_V(:,:,i),45,45,0.2); 
        
        %ROI_V(:,:,i)=round(moving_average_filter(ROI_V(:,:,i)));
       % ROI_V(:,:,i)=imsharpen(ROI_V(:,:,i),'Radius',5,'Amount',2);

Vsegmented_syst(:,:,i)=Auto_lv(Syst_ROI_V(:,:,i));
        
end
%% Performing segmentation on Diastole images

for i=1:numSlices_diast
       %imshow(ROI_V(:,:,i));
        %Vsegmented(:,:,i) = regiongrowing(ROI_V(:,:,i),26,26,0.02); 
        
        %ROI_V(:,:,i)=round(moving_average_filter(ROI_V(:,:,i)));
       % ROI_V(:,:,i)=imsharpen(ROI_V(:,:,i),'Radius',5,'Amount',2);
        Vsegmented_diast(:,:,i)=Auto_lv(Diast_ROI_V(:,:,i));
        
end

%% Ejection fraction calculation
Syst_Volume=Volume_calculation(Vsegmented_syst);
Diast_Volume=Volume_calculation(Vsegmented_diast);
EF=100*(Diast_Volume-Syst_Volume)/Diast_Volume;

for k =1:numSlices_diast
for i=1:size(Vsample_diast,1)
    for j=1:size(Vsample_diast,2)
        if Vsample_diast(i,j,k)>2
            Vsample_diast(i,j,k)=1;
        else
            Vsample_diast(i,j,k)=0;
        end
    end
end
end
for k =1:numSlices_syst
for i=1:size(Vsample_syst,1)
    for j=1:size(Vsample_syst,2)
        if Vsample_syst(i,j,k)>2
            Vsample_syst(i,j,k)=1;
        else
            Vsample_syst(i,j,k)=0;
        end
    end
end
end
DiceInd=zeros(numSlices_diast,1);
for k=1:numSlices_syst
[I,DiceInd(k)]=DiceImg(Vsegmented_diast(:,:,k),double(Vsample_diast(:,:,k)));
end
% figure, imshow(Vsegmented(:,:,2));
%dilation +erosion or inverse