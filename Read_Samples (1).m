function[SamplesStruct]=Read_Samples()
pwd
cd
%Go to the path with systolic images
cd 'E:\Medical sensors\training\Comparison\Systole'
SystSample=dir('*.nii.gz');
%Go to the path with diastolic images
cd 'E:\Medical sensors\training\Comparison\Diastole'
DiastSample=dir('*.nii.gz');
%NUMBER OF FILES TO PROCESS
numfiles = length(DiastSample);
pwd
% DATA STRUCTURE TO STORE IMAGES AND CORRESPONDING NAMES
SamplesStruct(1:numfiles) = struct('SystImage', [], 'SystName', '','DiastImage', [], 'DiastName', '');
% PLACING ALL DATA INTO A STRUCTURE
for j = 1:numfiles
    cd 'E:\Medical sensors\training\Comparison\Systole'
      SamplesStruct(j).SystName = SystSample(j).name;
      SamplesStruct(j).SystImage = niftiread(SystSample(j).name);
     cd 'E:\Medical sensors\training\Comparison\Diastole' 
      SamplesStruct(j).DiastName = DiastSample(j).name;
      SamplesStruct(j).DiastImage = niftiread(DiastSample(j).name);
end
pwd
cd 'E:\Medical sensors\Final_Project'
