function [o_Re,sss] = solver_PupilDriven_DPC(s,H_ph,beta_edge,beta_Sp,iter,...
                                            if_pupil,...
                                            if_show,w)
[m,n,~] = size(s);
dx = [1,-1];
dy = dx';
otf_dx = psf2otf(dx,[m,n]);
otf_dy = psf2otf(dy,[m,n]);
DTD = abs(otf_dx).^2 + abs(otf_dy).^2;
TVO(:,:,1) = otf_dx;
TVO(:,:,2) = otf_dy;
beta0_sp = 1 .* (beta_edge>0);
beta0_tv = 1 .* (beta_edge>0);
numer = 0;
denom = 0;
for dpc = 1:2 
    numer = numer + fft2(s(:,:,dpc)).*conj(H_ph(:,:,dpc));
    denom = denom + abs(H_ph(:,:,dpc)).^2;
end

FFF = H_ph;
SP_R = zeros(m,n,2);
SP_B = zeros(m,n,2);
TV_G = zeros(m,n,2);
TV_D = zeros(m,n,2);
foo = @(x) abs(w*exp(-w*abs(x)));

if if_pupil
    pupil_f = denom;
else
    pupil_f = 1;
end
for loop = 1:iter
%     clc
    disp('TV-Sparse-DPC solver, deconvolution:')
    disp([num2str(round(loop/iter * 100)),'%'])
    
%     u = TV_G(:,:,1) + TV_D(:,:,1);
%     v = TV_G(:,:,2) + TV_D(:,:,2);
%     Normin2 = [u(:,end,:) - u(:, 1,:), -diff(u,1,2)];
%     Normin2 = Normin2 + [v(end,:,:) - v(1, :,:); -diff(v,1,1)];

    fenzi = numer.*pupil_f + ...
                beta0_sp * sum(conj(FFF) .* fft2(SP_R + SP_B),3) + ...
                beta0_tv * sum(conj(TVO) .* fft2(TV_G + TV_D),3); 

    fenmu = denom.*pupil_f + ...
                beta0_sp * sum(abs(FFF).^2,3) + ...
                beta0_tv * DTD + 1e-6; 

    fft_o = fenzi./fenmu;
    o = real(ifft2(fft_o));
    
    if if_show % show latent images
        temp = real(ifft2(fft_o .* FFF));
        c1 = abs(temp(:,:,1));
        c2 = abs(temp(:,:,2));

        c1(c1 < 0.01) = 0;
        c2(c2 < 0.01) = 0;
        cc = sqrt(c1.^2 + c2.^2);

        cc = log10(cc+1e-5);
        figure(2022);
        imshow([mat2gray(o),mat2gray(cc)],[])
    end

    % SP
    if beta_Sp>0
        temp = real(ifft2(fft_o .* FFF));
        sss = sqrt(sum((temp - SP_B).^2,3)) + 1e-5;
        ppp = beta_Sp/beta0_sp;
        SP_R = (temp - SP_B)./sss .* max(sss - ppp .* foo(sss)/foo(ppp),0);
        SP_B = SP_B + SP_R - temp; % Bregman parameters
    end
    % TV
    if beta_edge>0
        temp = real(ifft2(fft_o .* TVO));
        sss = sqrt(sum((temp - TV_D).^2,3)) + 1e-5;
        ppp = beta_edge/beta0_tv;
        TV_G = (temp - TV_D)./sss .* max(sss - ppp .* foo(sss)/foo(ppp),0);
        TV_D = TV_D + TV_G - temp; % Bregman parameters
    end
end

sss = abs(temp(:,:,1)) + abs(temp(:,:,2));

o_Re = o;
% imwrite(mat2gray(sss),'testedge.png')
% save edge_data sss
end
