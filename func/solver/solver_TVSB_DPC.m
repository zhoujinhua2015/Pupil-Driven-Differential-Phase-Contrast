function o_TV = solver_TVSB_DPC(numer,denom,beta_TV, ...
                                            iter, ...
                                            if_retinex)

%% Total variation regularization DPC
beta = 1;

o = real(ifft2(numer./(denom + 1e-6)));

dx = [-1,1];    otf_dx = psf2otf(dx,size(o));
dy = [-1;1];    otf_dy = psf2otf(dy,size(o));
DTD = abs(otf_dx).^2 + abs(otf_dy).^2;

if if_retinex
    NTN = DTD;
else
    NTN = 1;
end

gx = 0;
gy = 0;
bx = 0;
by = 0;


for loop = 1:iter
    clc
    disp('TV-DPC solver, deconvolution:')
    disp([num2str(round(loop/iter * 100)),'%'])
    
    Gxx = conj(otf_dx) .* fft2(gx + bx);
    Gyy = conj(otf_dy) .* fft2(gy + by);
    fenzi = numer .* NTN + beta * (Gxx + Gyy);
    fenmu = denom .* NTN + beta * DTD + 1e-6;

    fft_o = fenzi./fenmu;
    o = real(ifft2(fft_o));
    
    % g sub
    temp_gx = real(ifft2(fft_o.*otf_dx));
    temp_gy = real(ifft2(fft_o.*otf_dy));
    
    sss = sqrt((temp_gx - bx).^2 + (temp_gy - by).^2) + 1e-6;

    gx = (temp_gx - bx)./sss .* max(sss - beta_TV/beta,0);
    gy = (temp_gy - by)./sss .* max(sss - beta_TV/beta,0);
    
    bx = bx + gx - temp_gx;
    by = by + gy - temp_gy;
%     figure;imshow(o,[]);
end

o_TV = o;

end