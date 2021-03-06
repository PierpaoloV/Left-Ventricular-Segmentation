function [ RegROI ] = mywatershed (I)
%   ROI=Diast_ROI_V(:,:,1); 
%   I=ROI;
 %% 1) calculating the gradient of the ROI I am passing
 gradient = imgradient(I);
 Wt = watershed(gradient);
Wtc = label2rgb(Wt);

%% Mark foreground objects
se = strel ('disk', 5);
Ie = imerode(I, se);
Ir = imreconstruct (Ie, I);
Ird =imdilate(Ir, se);
Io =imreconstruct(imcomplement(Ird),imcomplement(Ir));
Io = imcomplement(Io);
%% Calculate region maxima
marker = imregionalmax(Io);
I2 = labeloverlay(I, marker);
se2 = strel(ones(5,5));
marker2 = imclose(marker, se2);
marker3 = imerode(marker2, se2);
marker4 = bwareaopen(marker3, 5);
I3 = labeloverlay(I, marker4);

%% Compute Background markers

% binarising the image
binarim = imregionalmax(Io);
%here choose object with min dist
%binarim = imbinarize(Io);

Dist = bwdist(binarim,'euclidean');
Wtd = watershed(Dist);
bgm = Wtd == 0;
se = strel ('disk', 1);
bgm=imdilate(bgm, se);
RegROI=I-255*uint8(bgm);
gradient2 = imimposemin(gradient, bgm | marker4);
Wt = watershed(gradient2);
labels = imdilate(Wt ==0, ones(5,5))+ 2*bgm+ 3*marker4;
O = labeloverlay(I, labels);

% bgm=imdilate(bgm, se);
% RegROI=ROI-255*uint8(bgm);
Wt=double(Wt);

L_ROI = label2rgb(Wt,'jet','w','shuffle');
% % 
% figure,
% set(gcf,'color','w');
% subplot(3,4,1), imshow(I,[]);%,title('ROI');
% subplot(3,4,2), imshow(gradient,[]);%,title('Gradient');
% subplot(3,4,3), imshow(Wt);%,title('Watershed');
% subplot(3,4,4), imshow(Wtc);%,title('Oversegmentation');
% subplot(3,4,5),imshow(Io);%,title('Morphological operations');
% subplot(3,4,6),imshow(marker);%,title('Regional maxima');
% subplot(3,4,7),imshow(I3);%,title('Labeled Maxima');
% subplot(3,4,8),imshow(I2);%,title('Distance transform'),hold on, imcontour(Dist);
% subplot(3,4,9),imshow(Wtd,[]);%,title('Watershed');
% subplot(3,4,10),imshow(bgm);%,title('Watershed==0');
% subplot(3,4,11),imshow(RegROI);%,title('ROI-(Watershed==0)');
% subplot(3,4,12), imshow(L_ROI);%, title ('Labeled matrix') ;



%end