function o_GG = solver_GradGauss_DPC(numer,denom,beta_Grad,beta_Gauss,...
                                       if_retinex)

%{
 This DPC solver is the implemention of Eq.14 from                                     
  Isotropic differential phase contrast microscopy for quantitative phase bio-imaging, 
  Hsi-Hsun Chen, Yu-Zi Lin, Yuan Luo, J Biophotonics 2018 Vol. 11 Issue 8, DOI: 10.1002/jbio.201700364
%}

%% L2-DPC
[m,n,~] = size(numer);

dx = [-1,1];    otf_dx = psf2otf(dx,[m,n]);
dy = [-1;1];    otf_dy = psf2otf(dy,[m,n]);
DTD = abs(otf_dx).^2 + abs(otf_dy).^2;

if if_retinex
    NTN = DTD;
else
    NTN = 1;
end

beta_L2 = 1e-5;
Gau  = psf2otf(fspecial('Gaussian',[m,n],sqrt(m*n)/20));
Fenzi = numer .* NTN;
Fenmu = denom .* NTN + beta_Grad * DTD + beta_Gauss * Gau;
o_GG = real(ifft2(Fenzi./(Fenmu + beta_L2)));

end