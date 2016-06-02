%% Check doc printing.
clear


%%

D = unitDomain(0, 0.25, -0.75);
pv = pointVortex(0.7, 1);
uf = uniformFlow(1, 0);

W = potential(D, pv, uf);


%%

podoc(W)
