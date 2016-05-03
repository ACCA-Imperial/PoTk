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
D = unboundedCircles(sv, rv);

circ = [1, -1, 1];

av = [
    -2.0557-0.36617i
    -0.00048952+2.0958i
    1.4767-1.094i
    2.8468-2.3785i];
st = [-1, 1, -1, 1];


%%

pv = pointVortexNoNet(av, st);
cf = circulationNoNet(circ);

W = potential(D, cf, pv);
dW = diff(W);
