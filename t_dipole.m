%% Dipole check.
clear


%%

test = poUnitTest.DipoleMC;
test.domainTestObject = poUnitTest.domainConn3;

D = test.domainObject;
% alpha = test.dispatchTestProperty('Location');
alpha = 0.42332+0.41983i;


%%

U = test.strength;
chi = test.angle;
a = test.scale;

d = dipole(alpha, U, chi, a);
W = potential(test.domainObject, d);
dW = diff(W);


%%
% Circulation around unit circle.

dv = [0; D.dv(:)];
qv = [1; D.qv(:)];
for j = 1:numel(dv)
    Ic = real(poUnitTest. ...
        circleIntegral.forDifferential(dW, dv(j), qv(j)));
    fprintf('circle %d circulation: %s\n', j-1, num2str(abs(Ic)))
end


%%

% Point "near" dipole in the flow.
zp = alpha + 1e-6*exp(1i*chi);
zp2 = alpha + 1e-6*exp(1i*(chi + pi/2));

disp(chi - angle(conj(dW(zp))))



























