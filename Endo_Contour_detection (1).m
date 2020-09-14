%function[LV_Contour]=Endo_Contour_detection(ROI)
%% Uploading images

SystMRIdata=DataStruct(46).SystImage;
% DiastMRIdata=DataStruct(41).DiastImage;
MRIdata=SystMRIdata;
numSlices=size(SystMRIdata,3);
%
figure, imshow(MRIdata(:,:,5),[]);[y,x]=getpts; y=round(y(1)); x=round(x(1));
ROI_V=uint8(MRIdata(x-35:x+35,y-35:y+35,:));
Vsegmented= zeros(size(ROI_V));
ROI=ROI_V(:,:,5);
[H,W]=size(ROI);
%% Binarising and extracting properties of ROI
%Choosing the thresold for binarization with Otsu method
threshOtsu = graythresh(ROI);
% binarising the image
Bin_ROI = imbinarize(ROI,threshOtsu);

%Removinge all objects smaller than a predefined threshold (40 pixels)
Clear_ROI = bwareaopen(Bin_ROI,40);
%Extracting connected components and properties of those in an binary image
CC_ROI = bwconncomp(Clear_ROI);
prop_ROI = regionprops(CC_ROI,'ConvexArea', 'ConvexHull','ConvexImage','PixelList','Centroid','Eccentricity','Perimeter','Image','FilledImage');
%imshow(Clear_ROI);
% hold on
% for k=1:CC_ROI.NumObjects
% plot(prop_ROI(k).ConvexHull(:,2),prop_ROI(k).ConvexHull(:,1), 'r', 'Linewidth',3)
% end
%% Choosing the region which is the closest to the point indicated by user
%Eucledian distance
Euc_Dist=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
    Euc_Dist(k)=sqrt((prop_ROI(k).Centroid(:,1)-35)^2-(prop_ROI(k).Centroid(:,2)-35)^2);
end
%Picking the maximally rounded object
[Min_Dist, Dindex] = min(Euc_Dist);
%% Computing the roundness metric of each surviving convex-hulled object
Round_metric=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
    Round_metric(k)=4*pi*((prop_ROI(k).ConvexArea)/(prop_ROI(k).Perimeter)^2);
end
[Max_Round, idx] = max(Round_metric);

%% Computing epicardial contours
Mask=zeros(size(ROI));
ROI_ind=prop_ROI(Dindex).PixelList;
linearInd = sub2ind(size(Mask), ROI_ind(:,2), ROI_ind(:,1));
Mask(linearInd) = 1;
ROI_Hulled=bwconvhull(Mask);
FusROI=imfuse(ROI,ROI_Hulled);
imshow(FusROI);

se = strel('sphere',1);
Endo_Cont = imdilate(ROI_Hulled, se);
Endo_Cont=Endo_Cont-ROI_Hulled;
ROI_CONT=im2double(ROI)+Endo_Cont;
imshow(ROI_CONT);

PolarCont=ImToPolar (Endo_Cont, 0.1, 0.9, 100,100);
se1 = true(1, 20); % 15 rows tall by one column wide column vector.

PolarCont_dil= imdilate(PolarCont, se1);
PolarCont_dil= PolarCont_dil-PolarCont;


imshow(PolarCont_dil);
CartCont=PolarToIm (PolarCont_dil, 0.1,0.9, W, H);
%imshow(CartCont);


%Convvex hull of LV border
CH_LV=prop_ROI(Dindex).ConvexHull;
CH_LV_rounded=round(CH_LV);
[H,W]=size(ROI);
BND=zeros(size(ROI));

[theta, rho]=cart2pol(CH_LV(:,1),CH_LV(:,2));

figure,
subplot(3,3,1), imshow(ROI,[]),title('ROI');
subplot(3,3,2), imshow(Bin_ROI,[]),title('Otsu thresholding');
subplot(3,3,3), imshow(Clear_ROI,[]),title('Pixels<100 removed');
subplot(3,3,4), imshow(prop_ROI(idx).Image),title('Object with maximum roundness');
subplot(3,3,5), imshow(prop_ROI(Dindex).ConvexImage),title('Object with minimum Eucledian distance');
subplot(3,3,6), imshow(ROI,[]),hold on,plot(prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2), 'r', 'Linewidth',2),title('Endocardial contour');
subplot(3,3,7),polarplot(theta,rho);
subplot(3,3,8),imagesc(BND,[]);