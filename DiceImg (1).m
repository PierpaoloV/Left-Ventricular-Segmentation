
function [Are_of_overlap DiceIndex] = DiceImg(Image1, Image2)

Image1(Image1>0)=200;

Image2(Image2>0)=300;

Are_of_overlap = Image2-Image1;


[reg,t,p] = find(Are_of_overlap==100);
AreaCount=size(reg);

[reg1,t1,p1] = find(Image1==200);
Image1_200=size(reg1);


[reg2,t2,p2] = find(Image2==300);
Image2_300=size(reg2);

DiceIndex = 2*AreaCount/(Image1_200+Image2_300);


figure(1);image(Are_of_overlap);colormap(gray);title('Area of the overlap')

