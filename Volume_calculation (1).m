function[Volume]=Volume_calculation(Vsegmented,SliceThicknes,SliceGap)

% Check number of inputs.
if nargin < 1
    error('The function requires at least an image sequence, use format: Volume_calculation(Image sequence,SliceThicknes,SliceGap');
end

% Fill in unset optional values.
switch nargin
    case 1
        SliceThicknes = 5;
        SliceGap = 0;
    case 2
        SliceGap = 0;
end
[H,W,numslices]=size(Vsegmented);
Area=0;
for n=1:numslices
    for i=1:H
        for j=1:W
            if Vsegmented(i,j,n)~=0
              Area=Area+1;
            end
        end
    end
end
Volume=(SliceThicknes+SliceGap)*Area;

