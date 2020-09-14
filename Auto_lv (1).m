%ROI=Diast_ROI_V(:,:,5);

%% Function to segment LV blood pool
 function [ROI_Hulled]=Auto_lv(ROI,n)
[H,W]=size(ROI);
%Preprocessing ROI
grad=uint8(imgradient(ROI));
ROI=ROI-grad;
se = strel ('disk', 5);
Ie = imerode(ROI, se);
Ir = imreconstruct (Ie, ROI);
Ird =imdilate(Ir, se);
Io =imreconstruct(imcomplement(Ird),imcomplement(Ir));
Io = imcomplement(Io);
%Choosing the thresold for binarization with Otsu method
threshOtsu = graythresh(Io);


% FCM_ROI =fcm_thresh(ROI);
% if (mean(mean(FCM_ROI))>0.03)
%     FCM_ROI=1-FCM_ROI;
% end
% binarising the image
Bin_ROI = imbinarize(ROI,threshOtsu);
%Bin_ROI = imbinarize(FCM_ROI,threshOtsu);


%Removinge all objects smaller than a predefined threshold (20 pixels)
Clear_ROI = bwareaopen(Bin_ROI,20);
% se = strel('disk',1,4);
% Erode_ROI = imerode(Clear_ROI,se);
%Extracting connected components and properties of those in an binary image
CC_ROI = bwconncomp(Clear_ROI);
prop_ROI = regionprops(CC_ROI,'PixelList','ConvexArea', 'ConvexHull','ConvexImage','Centroid','Solidity','Eccentricity','Perimeter','Image','FilledImage');
%imshow(Clear_ROI);
% hold on
% for k=1:CC_ROI.NumObjects
% plot(prop_ROI(k).ConvexHull(:,2),prop_ROI(k).ConvexHull(:,1), 'r', 'Linewidth',3)
% end
%% Choosing the region which is the closest to the point indicated by user
%Eucledian distance
Euc_Dist=zeros(CC_ROI.NumObjects,1);
 Sol=zeros(CC_ROI.NumObjects,1);
   Ecc=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
    Euc_Dist(k)=sqrt(abs((prop_ROI(k).Centroid(:,1)-(H/2))^2+(prop_ROI(k).Centroid(:,2)-(W/2))^2));
end

%Picking the maximally rounded object
[Min_Dist, Dindex] = min(Euc_Dist);

%% Computing the roundness metric of each surviving convex-hulled object
Round_metric=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
   if (prop_ROI(k).Perimeter)==0
       prop_ROI(k).Perimeter=1;
   end
   Sol(k)=prop_ROI(k).Solidity;
   Ecc(k)=prop_ROI(k).Eccentricity;
    Round_metric(k)=4*pi*((prop_ROI(k).ConvexArea)/(prop_ROI(k).Perimeter)^2);
end
%Picking the maximally rounded object
[Max_Round, idx] = max(Round_metric);
[Max_Solidity, i1]=max(Sol);
[Min_Eccent, i2]=min(Ecc);

InitOrder=[1:CC_ROI.NumObjects]';
CorrMatrix=double([InitOrder,Euc_Dist,Round_metric]);

%Sorting Euc_Dist in ascending order
Euc_Dist_sort=sort(Euc_Dist);
%Sorting Round_metric in descending order
Round_metric_sort=sort(Round_metric,'descend');

Mask=zeros(size(ROI));
ROI_ind=prop_ROI(Dindex).PixelList;
linearInd = sub2ind(size(Mask), ROI_ind(:,2), ROI_ind(:,1));
Mask(linearInd) = 1;
ROI_Hulled=bwconvhull(Mask);


% if (n==5)
% figure,
% set(gcf,'color','w');
% imshow(ROI_Hulled),hold on,plot(prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2), 'g', 'Linewidth',1),title('LV blood pool without watershed'); 
% % subplot(3,3,1), imshow(ROI,[]),title('ROI');
% % subplot(3,3,2), imshow(Bin_ROI,[]),title('Otsu thresholding');
% % subplot(3,3,3), imshow(Clear_ROI,[]),title('Removed objects < 40 pixels');
% % subplot(3,3,4), imshow(prop_ROI(idx).ConvexImage),title('Maximum roundness');
% % subplot(3,3,5),imshow(prop_ROI(Dindex).ConvexImage),title('Minimum Eucledian distance');
% % subplot(3,3,6),imshow(ROI,[]),hold on,plot(prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2), 'g', 'Linewidth',1),title('Endocardial contour');
% % subplot(3,3,7),imshow(prop_ROI(i1).ConvexImage),title('Maximum Solodity');
% % subplot(3,3,8),imshow(prop_ROI(i2).ConvexImage),title('Minimum Eccentricity');
% % subplot(3,3,9), imshow(ROI_Hulled),title('LV blood pool') ;
% end


%figure, imshow(ROI_Hulled);


% X_F=fft(LV_CH(:,1));
% Y_F=fft(LV_CH(:,2));


