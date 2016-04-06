%% Examples.
clear


%%
% A bounded unit domain to work with.

dv = [
    -0.2517+0.3129i
    0.2307-0.4667i];
qv = [
    0.2377
    0.1557];

D = unitDomain(dv, qv);


%%

W = potential(D);
