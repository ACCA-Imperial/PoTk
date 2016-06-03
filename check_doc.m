%% Check doc printing.
clear


%%

dv = [
  -0.2517+0.3129i
   0.2307-0.4667i];
qv = [
  0.2377
  0.1557];
D = unitDomain(dv, qv, 0);

% av = [
%     -0.087464-0.62274i
%     0.32536+0.50379i
%     -0.42332+0.74169i];
% pv = pointVortexNoNet(av, ones(size(av)));
% pv = pointVortexNoNet(0.7, 1);

% uf = uniformFlow(1, 0);

C = circulationNoNet([1, 1, -1]);
% C = circulation([1, -1]);


%%

W = potential(D, C);
podoc(W)
