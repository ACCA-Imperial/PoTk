%% Dipole check.
clear


%%

test = poUnitTest.Dipole;
test.domainTestObject = poUnitTest.domainEntire;

D = test.domainObject;
% alpha = test.dispatchTestProperty('Location');
alpha = 0.3 + 0.3i;


%%

U = 2;
chi = 0;
mu = U*exp(1i*chi);

if alpha == 0
    W = @(zeta) (-mu./zeta + conj(mu)*zeta)/2/pi;
    dW = @(zeta) (mu./zeta.^2 + conj(mu))/2/pi;
else
    W = @(zeta) (-mu./(zeta - alpha) ...
        + conj(mu)/conj(alpha)^2./(zeta - 1/conj(alpha)))/2/pi;
    dW = @(zeta) (mu./(zeta - alpha).^2 ...
        - conj(mu)/conj(alpha)^2./(zeta - 1/conj(alpha)).^2)/2/pi;
end


%%
% Circulation around unit circle.

Ic = real(poUnitTest.circleIntegral.forDifferential(dW, 0, 1));
disp(['Unit circulation: ', num2str(Ic)])


%%

% Point "near" dipole in the flow.
zp = alpha + 1e-6*exp(1i*chi);

disp(['Strength: ', num2str(abs(dW(zp)))])


plotfd(W, skpDomain(), 1.1)
