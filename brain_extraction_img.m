% Apply binary brain mask from FSL Bet to other NIfTIs
clc
clear all

% Copy folder and file name in here
folder = 'C:\Users\Hampus\Documents\MATLAB\hMRI_data\Run_03\Results';
mask_folder = 'C:\Users\Hampus\Documents\Linux\MPM\181206_fix_pulse_length_IR\FFE\intermediate';
folder = strcat(folder,'\');
mask_folder = strcat(mask_folder,'\');

file_name = [folder 's20181206-1501-00015-000001-01_PDw_OLSfit_TEzero_reg_shadowreg_s20181206-1501-00015-000001-01_R2s_OLS.nii'];
mask_file_name = [mask_folder 'Serie_1301_04deg_750us_avg_brain_mask.nii'];
file_name = file_name(1:end-4);
mask_file_name = mask_file_name(1:end-4);

% Load Nifti data
nii = load_untouch_nii(strcat(file_name,'.nii.gz'));
mask_nii = load_untouch_nii(strcat(mask_file_name,'.nii.gz'));

% Get image data
img = double(nii.img);
mask = double(mask_nii.img);

%Conversion of R1 and R2*
img = 1./img;
img = img*1000;
img(img==Inf)=0;
img(img==-Inf)=0;
img(isnan(img)==1) = 0;
img(img<0) = max(img(:));

%Perform masking
img_masked = img.*mask;

% save brain extracted image as NIfTI
nii.img = img_masked;
save_untouch_nii(nii,strcat(file_name,'_brain.nii.gz'))