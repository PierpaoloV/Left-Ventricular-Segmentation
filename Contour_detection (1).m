function[ROI_Hulled]=Contour_detection(ROI,n)
%ROI=Diast_ROI_V(:,:,5);
[H,W]=size(ROI);
Water_ROI=mywatershed(ROI);

%% Binarising and extracting properties of ROI
%Choosing the thresold for binarization with Otsu method
threshOtsu = graythresh(Water_ROI);
% binarising the image
Bin_ROI = imbinarize(Water_ROI,threshOtsu);



%Removinge all objects smaller than a predefined threshold (40 pixels)
Clear_ROI = bwareaopen(Bin_ROI,30);
%Extracting connected components and properties of those in an binary image
CC_ROI = bwconncomp(Clear_ROI);
prop_ROI = regionprops(CC_ROI,'ConvexArea', 'ConvexHull','ConvexImage','Centroid','Eccentricity','PixelList','Perimeter','Image','FilledImage');
%imshow(Clear_ROI);
% hold on
% for k=1:CC_ROI.NumObjects
% plot(prop_ROI(k).ConvexHull(:,2),prop_ROI(k).ConvexHull(:,1), 'r', 'Linewidth',3)
% end
%% Choosing the region which is the closest to the point indicated by user
%Eucledian distance
Euc_Dist=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
    Euc_Dist(k)=sqrt(abs((prop_ROI(k).Centroid(:,1)-(H/2))^2+(prop_ROI(k).Centroid(:,2)-(W/2))^2));
end

%Picking the maximally rounded object
[Min_Dist, Dindex] = min(Euc_Dist);
%% Computing the roundness metric of each surviving convex-hulled object
Round_metric=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
    Round_metric(k)=4*pi*((prop_ROI(k).ConvexArea)/(prop_ROI(k).Perimeter)^2);
end
[Max_Round, idx] = max(Round_metric);
%Convvex hull of LV border
CH_LV=prop_ROI(Dindex).ConvexHull;
% %FT of Convex Hull
% CH_LV_f1=fft(CH_LV(:,1));
% CH_LV_f2=fft(CH_LV(:,2));
% %Lowpass filter
%% Computing epicardial contours
Mask=zeros(size(ROI));
ROI_ind=prop_ROI(Dindex).PixelList;
linearInd = sub2ind(size(Mask), ROI_ind(:,2), ROI_ind(:,1));
Mask(linearInd) = 1;
ROI_Hulled=bwconvhull(Mask);
FusROI=imfuse(ROI,ROI_Hulled);
imshow(ROI_Hulled);

% se = strel('sphere',1);
% Endo_Cont = imdilate(ROI_Hulled, se);
% Endo_Cont=Endo_Cont-ROI_Hulled;
% ROI_CONT=im2double(ROI)+Endo_Cont;
%  if (n==5)
% %    imshow(ROI_CONT);
% imshow(ROI,[]),hold on,plot(prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2), 'r', 'Linewidth',2),title('Endocardial contour with watershed');
% % figure,
% % subplot(3,3,1), imshow(ROI,[]),title('ROI');
% % subplot(3,3,2), imshow(Bin_ROI,[]),title('Otsu thresholding');
% % subplot(3,3,3), imshow(Clear_ROI,[]),title('Pixels<100 removed');
% % subplot(3,3,4), imshow(prop_ROI(idx).Image),title('Object with maximum roundness');
% %  subplot(3,3,5), imshow(prop_ROI(Dindex).ConvexImage),title('Object with minimum Eucledian distance');
% %  subplot(3,3,6), imshow(ROI,[]),hold on,plot(prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2), 'r', 'Linewidth',2),title('Endocardial contour');
% end