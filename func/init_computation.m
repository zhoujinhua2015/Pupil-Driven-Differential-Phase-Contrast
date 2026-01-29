%% 
% clc,clear;
% close all;
% data_path     = 'E:\BME-WH\WH\实验\p-qDPC\Experiments_WUHAO\100xOil_none_maoboli\9-data_processing\rawdata'; % PUT YOUR DATA PATH HERE
% image_list    = dir([data_path, filesep, '*.bmp']); % dir()函数用于获得指定文件夹中所有的文件与子文件，并存放在在一种为文件结构体数组中.
% % imshow()
%  % 存放sample_data中tif文件到image_list结构体中
% for image_index = 1:numel(image_list)% numel返回数组image_list中的元素数目
%    image_load = double(rgb2gray(imread([data_path, filesep, image_list(image_index).name]))); % image_load索引每张图片名字
% %    image_load = double(imread([data_path, filesep, image_list(image_index).name])); 
%    if image_index==1
%        IDPC                    = zeros(size(image_load, 1), size(image_load, 2), numel(image_list)); 
%    end
% %  IDPC(:, :, image_index) = image_load/mean2(image_load)-1; % mean2计算image_load中均值，进行归一化
%    IDPC(:, :, image_index) = image_load; % mean2计算image_load中均值，进行归一化
% end
% 
% img1 = IDPC(:,:,1);
% img2 = IDPC(:,:,2);
% img3 = IDPC(:,:,3);
% img4 = IDPC(:,:,4);
%% 
scale = unit / mag;     

pic = size(img1);

x_len = pic(2) * scale;
y_len = pic(1) * scale;

x = linspace(-x_len/2,x_len/2-1,pic(2));
y = linspace(-y_len/2,y_len/2-1,pic(1));
[x,y] = meshgrid(x,y);


fx = (-pic(2)/2:pic(2)/2-1)/x_len; 
fy = (-pic(1)/2:pic(1)/2-1)/y_len; 
[Fx, Fy]   = meshgrid(fx, fy);
pupil = sqrt(Fx.^2 + Fy.^2) < (na_obj/lambda);
%  figure;imshow(pupil);


otf_dx = psf2otf([1,-2,1],size(img1));
otf_dy = psf2otf([1;-2;1],size(img1));
otf_dz = psf2otf([-1,1;1,-1],size(img1));

sss = (img1 + img2 + img3 + img4)/2;

img_dpc(:,:,1) = (img1 - img2)./(sss + eps);
img_dpc(:,:,2) = (img3 - img4)./(sss + eps);

% imwrite(mat2gray(abs(img_dpc(:,:,1))),'I_dpc_1.png')
% imwrite(mat2gray(abs(img_dpc(:,:,2))),'I_dpc_1.png')

S0 = ((sqrt(Fx.^2+Fy.^2) < (na_illum/lambda))) .* ((sqrt(Fx.^2+Fy.^2) > (na_inner*na_illum/lambda)));  
% figure;imshow(S0);
mask_dpc(:,:,1) = -sign(Fy);
% c
mask_dpc(:,:,2) = -sign(Fx);
% figure;imshow(mask_dpc(:,:,1));
% figure;imshow(mask_dpc(:,:,2));

