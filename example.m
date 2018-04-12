%% Examples.
% This example file requires the conformal mapping toolkit (CMT).

clear


%%
% Bounded circle domain. Let's also have a grid to plot off.

dv = [
    0.052448+0.36539i
    -0.27972-0.12762i
    0.48252-0.28147i];
qv = [
    0.15197
    0.17955
    0.20956];
beta = -0.6i;

D = unitDomain(dv,qv,beta);

res = 200;
[xg, yg] = meshgrid(linspace(-1, 1, res));
zg = complex(xg, yg);
zg(abs(zg) > 1) = nan;
for j = 1:numel(dv)
    zg(abs(zg - dv(j)) <= qv(j) + eps(2)) = nan;
end

zp = 0.43032 + 0.22391i;


%%
% Circulation.

circ = circulation(2.2, -1);
circn = circulationNoNet(1, 2.2, -1);

% W = potential(D, circ);
% W = potential(D, circn);


%%
% Point vortices.

av = [
    -0.43032+0.43382i
    -0.0034985+0.083965i
    0.26939+0.062974i
    0.56327+0.062974i
];
gv = [1, -1, 1, 1];

pv = pointVortex(av, gv);
pvn = pointVortexNoNet(av, gv);

% W = potential(D, pv);
% W = potential(D, pvn);
% W = potential(D, pv, circ);
% W = potential(D, pvn, circn);


%%
% Source/sink pair.

a = -0.4793+0.32886i;
b = 0.59125+0.04898i;
m = 1.2;
ss = sourceSinkPair(a, b, m);

% W = potential(D, ss);


%%
% Source point.

a = av(1);
m = 1;
sp = source(a, m);

% W = potential(D, sp);
% W = potential(D, sp, pointVortex(a, -1));


%%
% Dipole.

zd = -0.4863+0.40583i;
dp = dipole(zd, 1, 0);
% dp = dipole(beta, 1, pi/4);

W = potential(D, dp);


%%
% Uniform background flow.

uf = uniformFlow(.4, pi/4);

% W = potential(D, uf);

% W = potential(D, uf, circn, pv);


%%
% Check derivatives against finite difference.

% h = 1e-6;
% fdW = @(z) (W(z + h) - W(z - h))/2/h;
% 
% dW = diff(W);
% 
% disp(fdW(zp) - dW(zp));


%%
return
%%
% Plot streamlines.

wg = W(zg);

figure(1), clf
contour(real(zg), imag(zg), imag(wg), 20, ...
    'linecolor', [0.2081, 0.1663, 0.5292])
set(gca, 'dataaspectratio', [1, 1, 1])
