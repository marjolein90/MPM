% Average TEs in a NIfTI for a ME sequence
% It is important that the original NIfTI file is 16 volumes where every
% even volume is phase data
clear all
close all
clc
addpath('C:\Users\Hampus\Documents\MATLAB\NIfTI_20140122\');

% Copy folder and file name in here
folder = 'C:\Users\Hampus\Documents\Linux\MPM\190114_pulse_length';
folder = strcat(folder,'\');
file_name = [folder 'Serie_2303_DelRec_-_mt_04dg_180dg_PCno.nii'];
file_name = file_name(1:end-4);

% Load Nifti data
nii = load_untouch_nii(strcat(file_name,'.nii.gz'));

% Get image data
% Assumes 8 echoes and phase data
j = 1;
for i = 1:8
TE(:,:,:,i) = double(nii.img(:,:,:,j));
j = i*2+1;
end

% Perform averaging
avg = (TE(:,:,:,1)+TE(:,:,:,2)+TE(:,:,:,3)+TE(:,:,:,4)+TE(:,:,:,5)+TE(:,:,:,6)+TE(:,:,:,7)+TE(:,:,:,8))/8;

% Create and save as Nifti-file
nii.hdr.dime.dim = [3 nii.hdr.dime.dim(2) nii.hdr.dime.dim(3) nii.hdr.dime.dim(4) 1 1 1 1];
nii.img(:,:,:,1) = avg;
save_untouch_nii(nii,strcat(file_name,'_avg.nii.gz'))