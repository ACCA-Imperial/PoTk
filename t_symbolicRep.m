%% Symbolic variable things.
clear


%%

D = unitDomain(0, 0.25, -0.75);
% D = planeDomain();
pv = pointVortex(0.7, 1);
uf = uniformFlow(1, 0);
W = potential(D, pv, uf);


%%
return
%%

syms w(z,a) b C_k

G_0(z,a,b) = log(w(z,a)/sqrt(a*conj(a))/w(z,b))/2i/pi;

daG0 = diff(G_0, a);
dbG0 = diff(G_0, b);

pretty(daG0(z,a,1/conj(a)))
pretty(dbG0(z,a,1/conj(a)))
