function[DataStruct]=Read_Files()
pwd
cd
%Go to the path with systolic images
cd 'E:\Medical sensors\training\SysDiasData\Systola'
SystFiles=dir('*.nii.gz');
%Go to the path with diastolic images
cd 'E:\Medical sensors\training\SysDiasData\Diastole'
DiastFiles=dir('*.nii.gz');
%NUMBER OF FILES TO PROCESS
numfiles = length(DiastFiles);
pwd
% DATA STRUCTURE TO STORE IMAGES AND CORRESPONDING NAMES
DataStruct(1:numfiles) = struct('SystImage', [], 'SystName', '','DiastImage', [], 'DiastName', '');
% PLACING ALL DATA INTO A STRUCTURE
for j = 1:numfiles
    cd 'E:\Medical sensors\training\SysDiasData\Systola'
      DataStruct(j).SystName = SystFiles(j).name;
      DataStruct(j).SystImage = niftiread(SystFiles(j).name);
     cd 'E:\Medical sensors\training\SysDiasData\Diastole' 
      DataStruct(j).DiastName = DiastFiles(j).name;
      DataStruct(j).DiastImage = niftiread(DiastFiles(j).name);
end
pwd
cd 'E:\Medical sensors\Final_Project'