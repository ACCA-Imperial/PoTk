%% vj-Gj equivalence
clear

j = 1;
N = 100;

dt = 2*pi/N;
t = (0:N-1)'*dt;


%%

dv = [
  -0.2517+0.3129i
   0.2307-0.4667i];
qv = [
  0.2377
  0.1557];
D = skpDomain(dv, qv);

beta = 0.57726+0.16793i;

sv = [-2, -1, 3];
uD = unitDomain(dv, qv, beta);


%%

zcn = @(c, r, tn) c + r*exp(1i*tn);
circ = @(dw, c, r) 1i*dt*sum(dw(zcn(c, r, t)).*(zcn(c, r, t) - c));


%%

g{1} = greensC0(beta, D);
g{2} = greensCj(beta, 1, D);
g{3} = greensCj(beta, 2, D);

dg{1} = diff(g{1});
dg{2} = diff(g{2});
dg{3} = diff(g{3});

% Should be "no net" circulation. (C0 circ specified, beta has non-zero
% circulation.)
dWno = @(z) sv(1)*dg{1}(z) - sv(2)*dg{2}(z) - sv(3)*dg{3}(z);

% This should be "net" circulation. (C0 has the "extra" circulation, beta
% has no circulation.)
dWnet = @(z) -(sv(2)*dg{2}(z) + sv(3)*dg{3}(z)) + sum(sv(2:3))*dg{1}(z);


%%

dW = dWnet;
[d, q, m] = domainDataB(D);
for j = 1:m+1
    cval = real(circ(dW, d(j), q(j)));
    fprintf('Circle %d has circulation %.4f\n', j-1, cval)
end
fprintf('Point beta has circulation %.4f\n', real(circ(dW, beta, 1e-6)))




























