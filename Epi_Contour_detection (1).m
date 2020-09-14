%function[SumContHulled]=Epi_Contour_detection(ROI,n)
ROI=Diast_ROI_V(:,:,2);

%% Binarising and extracting properties of ROI
%Choosing the thresold for binarization with Otsu method
[H,W]=size(ROI);
Water_ROI=mywatershed(ROI);

%Choosing the thresold for binarization with Otsu method
threshOtsu = graythresh(Water_ROI);
% binarising the image
Bin_ROI = imbinarize(Water_ROI,threshOtsu);


%Removinge all objects smaller than a predefined threshold (20 pixels)
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
    Euc_Dist(k)=sqrt(abs((prop_ROI(k).Centroid(:,1)-(H/2))^2+(prop_ROI(k).Centroid(:,2)-(W/2))^2));
end


%Picking the maximally rounded object
[Min_Dist, Dindex] = min(Euc_Dist);


%% Computing the roundness metric of each surviving convex-hulled object
Round_metric=zeros(CC_ROI.NumObjects,1);
for k=1:CC_ROI.NumObjects
    Round_metric(k)=4*pi*((prop_ROI(k).ConvexArea)/(prop_ROI(k).Perimeter)^2);
end
%Picking the maximally rounded object
[Max_Round, idx] = max(Round_metric);
CH_LV=[prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2)];
CHlength=size(CH_LV,1);

Mask=zeros(size(ROI));
ROI_ind=prop_ROI(Dindex).PixelList;
linearInd = sub2ind(size(Mask), ROI_ind(:,2), ROI_ind(:,1));
Mask(linearInd) = 1;
ROI_Hulled=bwconvhull(Mask);

 se = strel('sphere',2);
 Dil = imdilate(ROI_Hulled, se);
 Cont=Dil-ROI_Hulled;
 
%% Region Growing of myocardium
 RG_ROI=ROI;

 PolarRoi=ImToPolar(ROI,0.1, 0.9, 20,30);
 %imshow( PolarRoi,[]);
 PolarCont=ImToPolar( Cont,0.1, 0.9, 20,30);
 Cont=zeros(size(PolarRoi));
 ContSum=zeros(size(PolarRoi));
 k=0;
 while k<1
 for i=1:size(PolarCont,1)
     for j=1:size(PolarCont,2)
                  if  PolarCont(i,j)>0
    Cont= regiongrowing(PolarRoi,i,j,0.01);  
    ContSum=ContSum+Cont;
                  end
     end
 end
 k=k+1;
 end
imshow(ContSum);
CartCont=PolarToIm (ContSum, 0,1, W, H);
imshow(CartCont);


SumContHulled=bwconvhull(CartCont);
FinalCont=SumContHulled-ROI_Hulled;
 se = strel('sphere',2);
 Endo_Cont = imdilate(ROI_Hulled, se);
 Endo_Cont=Endo_Cont-ROI_Hulled;
 FinalCont=FinalCont+Endo_Cont;
imshow(FinalCont);
CC_Cont=bwconncomp(SumContHulled);
Cont_prop=regionprops(CC_Cont,'ConvexArea', 'ConvexHull','ConvexImage','PixelList','Centroid','Eccentricity','Perimeter','Image','FilledImage');


 imshow(ROI),hold on,plot(Cont_prop(1).ConvexHull(:,1),Cont_prop(1).ConvexHull(:,2), 'y', 'Linewidth',2),plot(prop_ROI(Dindex).ConvexHull(:,1),prop_ROI(Dindex).ConvexHull(:,2), 'y', 'Linewidth',2)


