%% Check derivative functionality.
clear


%%

sv = [
    -0.48951-1.7395i
    -1.6608+1.4423i
    2.5874+0.16608i];
rv = [
    1.2457
    0.93902
    0.932];
circ = 2*[1, -1, 1];

av = [
    -2.0557-0.36617i;
    -0.00048952+2.0958i
    1.4767-1.094i
    2.8468-2.3785i];
st = 2*[-1, 1, -1, 1];

zp = -0.064715+2.631i;


%%

Om = unboundedCircles(sv, rv);
zeta = Om.mapToUnitDomain;
D = unitDomain(Om);

zp = zeta(zp);


%%

N = numel(av);
g0v = cell(1, N);
for k = 1:N
    g0v{k} = greensC0(zeta(av(k)), skpDomain(D));
end
W = @(z) (st.*arrayfun(@(k) g0v{k}(z), 1:N));

% g0v = greensC0(zeta(av), skpDomain(D));
% W = @(z) st*g0v(z);

% pv = pointVortex(zeta(av), st);
% % cf = circulationNoNet(circ);
% 
% W = potential(D, pv);


%%
% Finite difference version.

h = 1e-6;
hdW = @(z) (W(z + 1i*h) - W(z - 1i*h))/2i/h;


%%

dg0v = cell(size(g0v));
for k = 1:N
    dg0v{k} = diff(g0v{k});
end
dW = @(z) (st.*arrayfun(@(k) dg0v{k}(z), 1:N));

% dg0v = diff(g0v);
% dW = @(z) st*dg0v(z);

% dW = diff(W);

disp(abs(hdW(zp) - dW(zp)))
































