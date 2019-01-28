% Mix B1 maps with different STEAM FA to avoid bias and maximize SNR
clear all
clc

% Denote amount and values of STEAM FAs in degrees
STEAM_FA(1) = 20;
STEAM_FA(2) = 25;
STEAM_FA(3) = 30;
STEAM_FA(4) = 35;
STEAM_FA(5) = 40;
STEAM_FA(6) = 45;
STEAM_FA(7) = 50;
STEAM_FA(8) = 55;
STEAM_FA(9) = 60;
STEAM_FA_num = length(STEAM_FA);

% Denote which STEAM FA is unbiased until 100 % (40 degrees)
STEAM_FA_100 = 40;

%  Folder containing relevant NIfTI files in ascending order of STEAM FA
folder = 'C:\Users\Hampus\Documents\Linux\MPM\181206_fix_pulse_length_IR\DREAM';
folder = strcat(folder,'\');
file_list = dir(folder);

% Remove superfluous file names
i = 1;
while i<=length(file_list)
    if (file_list(i).isdir==1) || (strcmp(file_list(i).name(1), '.'))
        file_list = file_list([1:i-1 i+1:end]);
    else
        i = i+1;
    end
end

% Extract B1 image data from zipped NIfTI files
for i =1:length(file_list)
    file_name = [folder file_list(i).name];
    [~,~,ext] = fileparts(file_name);
    if strcmp(ext,'.gz') == 1
        nii_name{i} = [folder file_list(i).name];
        nii(i) = load_untouch_nii(nii_name{i});
        b1_all(:,:,:,i) = double(nii(i).img);
    end
end

b1_ref = squeeze(b1_all(:,:,:,1));
b1_ref(:) = 0;
for x = 1:length(b1_all(:,1,1,1))
    x
    for y = 1:length(b1_all(1,:,1,1))
        for z = 1:length(b1_all(1,1,:,1))
            b1_ref(x,y,z) = mean(nonzeros(b1_all(x,y,z,:)));
        end
    end
end
b1_ref(isnan(b1_ref)==1) = 0;

% Set all voxel values predicted to be underestimated or have too low SNR to zero
for i = 1:STEAM_FA_num
    limit_high(i) = 100*STEAM_FA_100/STEAM_FA(i);
    limit_low(i) = (1/2)*100*STEAM_FA_100/STEAM_FA(i);
    b1_temp = b1_all(:,:,:,i);
    if i==1
        b1_temp(b1_ref<limit_low(i)) = 0;
    end
    if i>1 && i<STEAM_FA_num
        b1_temp(b1_ref>limit_high(i)) = 0;
        b1_temp(b1_ref<limit_low(i)) = 0;
    end
    if i==STEAM_FA_num
        b1_temp(b1_ref>limit_high(i)) = 0;
    end
    b1_all(:,:,:,i) = b1_temp;
end

% Calculate average voxel value of unbiased STEAM FAs
b1 = b1_temp;
b1(:) = 0;
for x = 1:length(b1(:,1,1))
    x
    for y = 1:length(b1(1,:,1))
        for z = 1:length(b1(1,1,:))
            b1(x,y,z) = mean(nonzeros(b1_all(x,y,z,:)));
        end
    end
end
b1(isnan(b1)==1) = 0;

% Plot results
figure
for i = 1:STEAM_FA_num
subplot(4,3,i)
imagesc(b1_all(:,:,128,i))
subplot(4,3,STEAM_FA_num+1)
imagesc(b1_ref(:,:,128))
subplot(4,3,STEAM_FA_num+2)
imagesc(b1(:,:,128))
end

nii(1).img = b1;
% save_untouch_nii(nii(1), strcat(folder,'b1mix.nii.gz'));