% global H_ph_pad
H_ph = zeros(pic(1),pic(2),num_dpc);
H_ab = zeros(pic(1),pic(2),num_dpc);
% 
Ft = @(x) fft2(x);
iFt = @(x) ifft2(x);


numer = 0;
denom = 0;
for dpc = 1:2
    S = S0.*mask_dpc(:,:,dpc);
%     figure;imshow(S);
%     imwrite(S,[save_path,name,'//na1.3S.png'])
    FSP = conj(Ft(S.*pupil)).*Ft(pupil);
%     figure;imagesc(ifftshift(iFt(FSP)));axis off;axis equal;colorbar;
% fdFSP = sqrt((real(FSP))^2+(imag(FSP))^2);
%     figure;imagesc((abs(fdFSP)));
    H_ab_0 =  2*iFt(real(FSP));
    H_ph_0 = -2*iFt(imag(FSP));


    Htot = sqrt(abs(H_ab_0).^2+abs(H_ph_0).^2);
%     figure;imagesc(ifftshift(Htot));axis off;axis equal;colorbar;
    Htotmax = max(max(Htot));
    H_ab(:,:,dpc) = H_ab_0./Htotmax;
    H_ph(:,:,dpc) = H_ph_0./Htotmax;
%     figure;
%     imagesc(((fftshift(Htot))));
    numer = numer + Ft(img_dpc(:,:,dpc)).*conj(H_ph(:,:,dpc));
    denom = denom + abs(H_ph(:,:,dpc)).^2;
end

% O_L2 = solver_L2_DPC(numer,denom,1,0);
% figure;imshow(O_L2,[]);
% O_TV = solver_TVSB_DPC(numer,denom,0.01,2,0.5);

%  H_ph_pad(:,:,1) = ifftshift(1i*conv2(S1.*mask_dpc(:,:,1).*pupil_extend,pupil_extend,'same'));
%  H_ph_pad(:,:,2) = ifftshift(1i*conv2(S1.*mask_dpc(:,:,2).*pupil_extend,pupil_extend,'same'));
% % % 
% H_ph_pad(:,:,1) =  H_ph_pad(:,:,1) / max(max(abs(H_ph_pad(:,:,1))));
% H_ph_pad(:,:,2) =  H_ph_pad(:,:,2) / max(max(abs(H_ph_pad(:,:,2))));
% 
% H_ph(:,:,1) = ifftshift(reflected_padding(fftshift(H_ph(:,:,1)).*pupil_extend,pupil_extend));
% H_ph(:,:,2) = ifftshift(reflected_padding(fftshift(H_ph(:,:,2)).*pupil_extend,pupil_extend));
% 
% H_ph_pad(:,:,1) = ifftshift(reflected_padding(fftshift(H_ph(:,:,1)).*pupil_extend,pupil_extend));
% H_ph_pad(:,:,2) = ifftshift(reflected_padding(fftshift(H_ph(:,:,2)).*pupil_extend,pupil_extend));
% 
% H_ph_pad2(:,:,1) = ifftshift(reflected_padding(fftshift(H_ph(:,:,1)).*pupil_extend2,pupil_extend2));
% H_ph_pad2(:,:,2) = ifftshift(reflected_padding(fftshift(H_ph(:,:,2)).*pupil_extend2,pupil_extend2));