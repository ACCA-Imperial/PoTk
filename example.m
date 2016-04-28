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

% Om = circleRegion(sv, rv);

% ax = plotbox(Om, 1.2);
% res = 100;
% [zg, zeta] = meshgrid(linspace(ax(1), ax(2), res), ...
%     linspace(ax(3), ax(4), res));
% zg = complex(zg, zeta);
% for j = 1:numel(sv)
%     zg(abs(zg - sv(j)) <= rv(j)+eps(max(abs(sv)))) = nan;
% end


%%
% Equivalent bounded unit domain.

D = unitDomain(Om);
zeta = Om.mapToUnitDomain;

% zeta = mobius(0, rv(1), 1, -sv(1));
% D = zeta(Om);
% dv = D.centers(2:end);
% qv = D.radii(2:end);
% beta = pole(inv(zeta));
% 
% D = unitDomain(dv, qv, beta);


%%
% Circulation.

circ = circulation(2, -1);
circn = circulationNoNet(1, 2, -1);

% W = potential(D, circ);
% W = potential(D, circn);


%%
% Point vortices.

av = [
    0.25641+0.38313i
    -1.9915-0.58025i
    0.7488+2.5454i
    2.1618-1.3938i];
gv = [1, -1, 1, 1];

pv = pointVortex(zeta(av), gv);
pvn = pointVortexNoNet(zeta(av), gv);

% W = potential(D, pv);
% W = potential(D, pvn);
% W = potential(D, pv, circ);
% W = potential(D, pvn, circn);


%%
% Source/sink pair.

a = -2.6551+3.2733i;
b = 2.0119-3.7273i;
m = 1.2;
ss = sourceSinkPair(zeta(a), zeta(b), m);

W = potential(D, ss);


%%
% Source point.

a = av(1);
m = 1;
sp = source(zeta(a), m);

% W = potential(D, sp);
% W = potential(D, sp, pointVortex(zeta(a), -1));


%%
% Dipole.

zd = 0.70599 + 1.3893i;
dp = dipole(zeta(zd), 1, 0);
% dp = dipole(beta, 1, pi/4);

% W = potential(D, dp);


%%
% Uniform background flow.

uf = uniformFlow(1, pi/4);

% W = potential(D, uf);


%%
% Plot streamlines.

wg = W(zeta(zg));

figure(1), clf
contour(real(zg), imag(zg), imag(wg), 20, ...
    'linecolor', [0.2081, 0.1663, 0.5292])
hold on
fill(inv(circleRegion(Om)))
plot(Om)
% plot(av, 'k.')
hold off
set(gca, 'dataaspectratio', [1, 1, 1])
