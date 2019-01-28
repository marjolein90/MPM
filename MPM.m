% MPM
clear all
clc

% Define Source Folders and File names
folder = 'C:\Users\Hampus\Documents\Linux\MPM\190114_pulse_length';
folder = strcat(folder,'\');
T1w_file_name = [folder 'Serie_1103_DelRec_-_16dg_700us_PCno_avg_reg_brain.nii'];
PDw_file_name = [folder 'Serie_1203_DelRec_-_04dg_700us_PCno_avg_reg_brain.nii'];
MTw_file_name = [folder 'Serie_2303_DelRec_-_mt_04dg_180dg_PCno_avg_reg_brain.nii'];
B1_file_name = [folder 'b1mix_brain.nii'];
T1w_file_name = T1w_file_name(1:end-4);
PDw_file_name = PDw_file_name(1:end-4);
MTw_file_name = MTw_file_name(1:end-4);
B1_file_name = B1_file_name(1:end-4);

% Define sequence parameters
TR_T1w = 18.0;
TR_PDw = 18.0;
TR_MTw = 27;
if TR_T1w==TR_PDw
    TR=TR_T1w;
end
alpha_T1w = 16*pi/180;
alpha_PDw = 4*pi/180;
alpha_MTw = 4*pi/180;

% Load Nifti data
T1w_nii = load_untouch_nii(strcat(T1w_file_name,'.nii.gz'));
PDw_nii = load_untouch_nii(strcat(PDw_file_name,'.nii.gz'));
MTw_nii = load_untouch_nii(strcat(MTw_file_name,'.nii.gz'));
B1_nii = load_untouch_nii(strcat(B1_file_name,'.nii.gz'));

% Get image data
S_T1w = double(T1w_nii.img);
S_PDw = double(PDw_nii.img);
S_MTw = double(MTw_nii.img);
B1 = double(B1_nii.img);

% Calculation of Maps
R1_app = (1/2)*(S_T1w*alpha_T1w/TR_T1w - S_PDw*alpha_PDw/TR_PDw)./(S_PDw/alpha_PDw - S_T1w/alpha_T1w);
T1_app = 1./R1_app;
T1_app(T1_app<0) = 0;
A_app = (S_PDw.*S_T1w)*(TR_PDw*alpha_T1w/alpha_PDw - TR_T1w*alpha_PDw/alpha_T1w)./(S_T1w*TR_PDw*alpha_T1w - S_PDw*TR_T1w*alpha_PDw);
delta_app = 100*((A_app*alpha_MTw./S_MTw - 1).*R1_app*TR_MTw-alpha_MTw^2/2);
alpha_E = sqrt(2*TR./T1_app);
alpha_E = alpha_E*180/pi;

%B1 correction
T1 = T1_app./((B1/100).^2);
R1 = 1./T1;
A = A_app./(B1/100);
delta = delta_app*0.6./(1-0.4*(B1/100));

% Remove Inf and Nan
R1(R1==Inf)=0;
R1(R1==-Inf)=0;
R1(isnan(R1)==1) = 0;
T1(T1==Inf)=0;
T1(T1==-Inf)=0;
T1(isnan(T1)==1) = 0;
A(A==Inf)=0;
A(A==-Inf)=0;
A(isnan(A)==1) = 0;
delta(delta==Inf)=0;
delta(delta==-Inf)=0;
delta(isnan(delta)==1) = 0;
alpha_E(alpha_E==Inf)=0;
alpha_E(alpha_E==-Inf)=0;
alpha_E(isnan(alpha_E)==1) = 0;
alpha_E_median = median(nonzeros(alpha_E(:)))

% Plot figures
figure
edges = [-1 -1:0.005:3 3];
centres = edges(1:end-1)+diff(edges)/2;
[N1] = histcounts(nonzeros(delta_app),edges);
subplot(3,3,1)
plot(centres, N1, 'LineWidth', 2)
title('MT_s_a_t_,_a_p_p')
xlabel('[p.u.]')
grid on
edges = [-1 -1:0.005:3 3];
centres = edges(1:end-1)+diff(edges)/2;
[N2] = histcounts(nonzeros(delta),edges);
subplot(3,3,2)
plot(centres, N2, 'LineWidth', 2)
title('MT_s_a_t')
xlabel('[p.u.]')
grid on
edges = [0 0:5: 5000 5000];
centres = edges(1:end-1)+diff(edges)/2;
[N3] = histcounts(nonzeros(T1_app),edges);
subplot(3,3,3)
plot(centres, N3, 'LineWidth', 2)
title('T_1_,_a_p_p')
xlabel('[ms]')
grid on
edges = [0 0:5: 5000 5000];
centres = edges(1:end-1)+diff(edges)/2;
[N4] = histcounts(nonzeros(T1),edges);
subplot(3,3,4)
plot(centres, N4, 'LineWidth', 2)
title('T_1')
xlabel('[ms]')
grid on
edges = [0 0:100: 25000 25000];
centres = edges(1:end-1)+diff(edges)/2;
[N5] = histcounts(nonzeros(A_app),edges);
subplot(3,3,5)
plot(centres, N5, 'LineWidth', 2)
title('A_a_p_p')
xlabel('[a.u.]')
grid on
edges = [0 0:100: 25000 25000];
centres = edges(1:end-1)+diff(edges)/2;
[N6] = histcounts(nonzeros(A),edges);
subplot(3,3,6)
plot(centres, N6, 'LineWidth', 2)
title('A')
xlabel('[a.u.]')
grid on
edges = [0 0:0.5:200 200];
centres = edges(1:end-1)+diff(edges)/2;
[N7] = histcounts(nonzeros(B1),edges);
subplot(3,3,7)
plot(centres, N7, 'LineWidth', 2)
title('B_1')
xlabel('[p.u.]')
grid on
edges = [0 0:0.05:20 20];
centres = edges(1:end-1)+diff(edges)/2;
[N8] = histcounts(nonzeros(alpha_E),edges);
subplot(3,3,8)
plot(centres, N8, 'LineWidth', 2)
title('Ernst angle')
xlabel('[degrees]')
grid on

% Save as NIfTI files
T1w_nii.img = T1;
PDw_nii.img = A;
MTw_nii.img = delta;
save_untouch_nii(T1w_nii,strcat(folder,'T1.nii.gz'))
save_untouch_nii(PDw_nii,strcat(folder,'A.nii.gz'))
save_untouch_nii(MTw_nii,strcat(folder,'MTsat.nii.gz'))
T1w_nii.img = alpha_E;
save_untouch_nii(T1w_nii,strcat(folder,'alpha_E.nii.gz'))
