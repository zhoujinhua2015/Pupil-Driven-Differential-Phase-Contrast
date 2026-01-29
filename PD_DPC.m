clc
clear
close all
% PD-qDPC / PD-DPC demo script
% - Input: four raw DPC images captured under different illuminations
%          (default: rawdata/r1.BMP ... rawdata/r4.BMP)
% - Output: reconstructed phase results saved to examples/<dataset>_output/
%
% Tip: edit the "I/O settings" section below to point to your own dataset.

%% I/O settings
repo_root = fileparts(mfilename('fullpath'));
dataset_name = 'rawdata';

input_dir = fullfile(repo_root, 'rawdata');
output_dir = fullfile(repo_root, 'examples', [dataset_name, '_output']);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% data loading
img1 = mean(double(imread(fullfile(input_dir, 'r1.BMP')))/255,3);
img2 = mean(double(imread(fullfile(input_dir, 'r2.BMP')))/255,3);
img3 = mean(double(imread(fullfile(input_dir, 'r3.BMP')))/255,3);
img4 = mean(double(imread(fullfile(input_dir, 'r4.BMP')))/255,3);

[m,n] = size(img1);
c_x = 2000;
c_y = 2000;
pix2 = 2000;
img_BF = (img1+img2+img3+img4)/4; 

%% computation
init_script = genpath(fullfile(repo_root, 'func'));
addpath(init_script);
disp('initializing environment');init_environment;
disp('initializing computing parameters');init_computation;
disp('initializing pupil parameters');init_pupilpara;
rmpath(init_script);
pupil_extend = sqrt(Fx.^2 + Fy.^2) < (2*na_obj/lambda);
% figure;imshow(1-pupil_extend);
addpath(genpath(fullfile(repo_root,'func')));
%% Adaptive noise sensor

NNN = [-1,2,-1;2,-4,2;-1,2,-1];

filtered = real(ifft2(ifftshift(fftshift(fft2(img_dpc)).*(1-pupil_extend))));
% figure;imshow(fftshift(fft2(filtered(:,:,2))));
f = abs(imfilter(filtered,NNN));
beta_Sp = sqrt(pi/2) * (1/5) * mean(f(:));

%% Solving
iter = 50;
parameter_list = {};
cal = [true,true,true,true,true];

%--------------- L2-qDPC
if cal(1)
para1 = beta_Sp/1;
o_L2 = solver_L2_DPC(numer,denom,para1,0);
figure();imshow(o_L2,[]);
parameter_list{1,1} = "L2-qDPC";
parameter_list{1,2} = para1;
end

%--------------- Iso-qDPC
if cal(2)
para2 = beta_Sp/1;
para3 = beta_Sp/1;
o_Is = solver_GradGauss_DPC(numer,denom,para2,para3,0);
figure();imshow(o_Is,[]);
parameter_list{2,1} = "Iso-qDPC";
parameter_list{2,2} = para2;
parameter_list{2,3} = para3;
end

%--------------- TV-qDPC
if cal(3)
para4 = beta_Sp/10;
o_TV = solver_TVSB_DPC(numer,denom,para4, ...
                                       iter, ...
                                       0);
figure();imshow(o_TV,[]);
parameter_list{3,1} = "TV-qDPC";
parameter_list{3,2} = para4;
end

%-------------- Retinex TV-qDPC
if cal(4)
para5 = beta_Sp/10  ;
o_RetinexTV = solver_TVSB_DPC(numer,denom, para5, ...
                                           iter, ...
                                           1);
figure();imshow(o_RetinexTV,[]);
parameter_list{4,1} = "Retinex TV-qDPC";
parameter_list{4,2} = para5;
end

%--------------- PD-DPC
if cal(5)
para6 = beta_Sp/2;
para7 = beta_Sp/10;
[o_Re,edge] = solver_PupilDriven_DPC(img_dpc,H_ph, para6,...
                                                   para7,...
                                                   iter,...
                                                   1,...
                                                   1);
figure();imshow(o_Re,[]);
parameter_list{5,1} = "pd-qDPC";
parameter_list{5,2} = para6;
parameter_list{5,3} = para7;
end

imwrite(img1,         fullfile(output_dir,'img1_cpt.png'));
imwrite(img2,         fullfile(output_dir,'img2_cpt.png'));
imwrite(img3,         fullfile(output_dir,'img3_cpt.png'));
imwrite(img4,         fullfile(output_dir,'img4_cpt.png'));

imwrite(mat2gray(edge),           fullfile(output_dir,'pd_DPC_edge.png'))
imwrite(mat2gray(abs(img_dpc(:,:,1))), fullfile(output_dir,'I_dpc_1.png'))
imwrite(mat2gray(abs(img_dpc(:,:,2))), fullfile(output_dir,'I_dpc_2.png'))

imwrite(mat2gray(o_L2),        fullfile(output_dir,'qDPC_1_l2.png'));
imwrite(mat2gray(o_Is),        fullfile(output_dir,'qDPC_2_IS.png'));
imwrite(mat2gray(o_TV),        fullfile(output_dir,'qDPC_3_TV.png'));
imwrite(mat2gray(o_RetinexTV), fullfile(output_dir,'qDPC_4_RTV.png'));
imwrite(mat2gray(o_Re),        fullfile(output_dir,'qDPC_5_PD2.png'));
imwrite(mat2gray(img_BF),      fullfile(output_dir,'qDPC_BF.png'));

cmap = jet(256);
imwrite(uint8(255*mat2gray(fftshift(imag(H_ph(:,:,1))))),cmap, ...
    fullfile(output_dir, ['Pupil_all_',dataset_name,'.png']))

save(fullfile(output_dir,'alldata.mat'),'o_L2','o_Is','o_TV','o_RetinexTV','o_Re');
writecell(parameter_list, fullfile(output_dir,'parameters.txt'))
rmpath(genpath(fullfile(repo_root,'func')));