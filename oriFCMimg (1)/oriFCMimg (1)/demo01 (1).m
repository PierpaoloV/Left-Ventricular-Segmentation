function[image]=fcm_thresh(Img)
img = double(Img);
clusterNum = 2;
[ Unow, center, now_obj_fcn ] = FCMforImage( img, clusterNum );
figure;
subplot(2,2,1); imshow(img,[]);
for i=1:clusterNum
    subplot(2,2,i+1);
    imshow(Unow(:,:,i),[]);
end
image=Unow(:,:,2);