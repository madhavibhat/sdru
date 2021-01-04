y = datasegF;
m = table2array(y);
mm = real(m);
figure (1)
[avar,tau] = allanvar(mm);
adev = sqrt(avar);
loglog(tau,avar,'-x', 'linewidth', 2)
set(gca, 'FontSize', 20)
xlabel('\tau')
ylabel('\sigma^2(\tau)')
title('Allan Variance')
grid on

figure (2)
loglog(tau,adev,'-x', 'linewidth', 2)
set(gca, 'FontSize', 20)
xlabel('\tau')
ylabel('\sigma(\tau)')
title('Allan Deviation')
grid on


function [q1_2, q2_2] = getQs(mm, Fs, fo, tau_step, tau_max)
%GETQS Calculates the q1 and q2 variance parameters for a dataset.
% Inputs:
%   data: Complex data vector
%   Fs: Sampling frequency
%   fo: Center frequency (900e6 in allan5.m)
%   tau_step: Increment used in Allan variance calculation (50 in allan5.m)
%   tau_max: Maximum used in AV calculation (50000 in allan5.m)
% Outputs:
%   q1_2: Q1^2 variance parameter
%   q2_2: Q2^2 variance parameter

    [tau_v, sigma_2] = allanVar(mm, Fs, fo, tau_step, tau_max);
    
    sig2_tau = sigma_2 .* tau_v;
    
    p = polyfit(tau_v.^2, sig2_tau, 1);
    plot(tau_v, sig2_tau, tau_v, polyval(p, tau_v.^2));
    q1_2 = p(2);
    q2_2 = p(1)*3;
    
end