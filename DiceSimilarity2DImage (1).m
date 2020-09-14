
function [Are_of_overlap DiceCoef] = DiceSimilarity2DImage(Image1, Image2)

Image1(Image1>0)=200;


Image2(Image2>0)=300;

Are_of_overlap = Image2-Image1;


[r,c,v] = find(Are_of_overlap==100);
AreaCount=size(r);

[r1,c1,v1] = find(Image1==200);
Image1_200=size(r1);


[r2,c2,v2] = find(Image2==300);
Image2_300=size(r2);


DiceCoef = 2*AreaCount/(Image1_200+Image2_300);


figure(1);image(Are_of_overlap);colormap(gray);title('Area of the overlap')

