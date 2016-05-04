%% Examples.
% This example file requires the conformal mapping toolkit (CMT).

clear


%%
% Unbounded circle domain. Let's also have a grid to plot off.

sv = [
    -0.48951-1.7395i
    -1.6608+1.4423i
    2.5874+0.16608i];
rv = [
    1.2457
    0.93902
    0.932];
Om = unboundedCircles(sv, rv);

zg = meshgrid(Om);

zp = 0.51331+2.3099i;


%%
% Equivalent bounded unit domain.

D = unitDomain(Om);
zeta = Om.mapToUnitDomain;


%%
% Circulation.

circ = circulation(2.2, -1);
circn = circulationNoNet(1, 2.2, -1);

% W = potential(Om, circ);
% W = potential(Om, circn);


%%
% Point vortices.

av = [
    0.25641+0.38313i
    -1.9915-0.58025i
    0.7488+2.5454i
    2.1618-1.3938i];
gv = [1, -1, 1, 1];

pv = pointVortex(av, gv);
pvn = pointVortexNoNet(av, gv);

% W = potential(Om, pv);
% W = potential(Om, pvn);
% W = potential(Om, pv, circ);
% W = potential(Om, pvn, circn);


%%
% Source/sink pair.

a = -2.6551+3.2733i;
b = 2.0119-3.7273i;
m = 1.2;
ss = sourceSinkPair(a, b, m);

% W = potential(Om, ss);


%%
% Source point.

a = av(1);
m = 1;
sp = source(a, m);

% W = potential(Om, sp);
% W = potential(Om, sp, pointVortex(a, -1));


%%
% Dipole.

zd = 0.70599 + 1.3893i;
dp = dipole(zd, 1, 0);
% dp = dipole(inf, 1, pi/4);

W = potential(Om, dp);


%%
% Uniform background flow.

uf = uniformFlow(.5, pi/4);

% W = potential(Om, uf);

% W = potential(Om, uf, circn, pv);


%%
% Check derivatives against finite difference.

h = 1e-6;
fdW = @(z) (W(z + h) - W(z - h))/2/h;

dW = diff(W);

disp(abs(fdW(zp) - dW(zp)))


%%
return
%%
% Plot streamlines.

wg = W(zg);

figure(2), clf
contour(real(zg), imag(zg), imag(wg), 20, ...
    'linecolor', [0.2081, 0.1663, 0.5292])
hold on
fill(inv(circleRegion(Om)))
plot(Om)
% plot(av, 'k.')
hold off
set(gca, 'dataaspectratio', [1, 1, 1])
