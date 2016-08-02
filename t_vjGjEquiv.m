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

% g1 = greensCj(beta, 1, D);
% dg1 = diff(g1);
% 
% circ1 = circ(dg1, dv(1), qv(1));
% disp(circ1)
% 
% circb = circ(dg1, beta, 1e-6);
% disp(circb)


%%

g{1} = greensC0(beta, D);
g{2} = greensCj(beta, 1, D);
g{3} = greensCj(beta, 2, D);

dg{1} = diff(g{1});
dg{2} = diff(g{2});
dg{3} = diff(g{3});

dW = @(z) reshape(sum(cell2mat( ...
    arrayfun(@(i) sv(i)*dg{i}(z(:)), 1:3, 'uniform', false)), 2), size(z));


%%

[d, q, m] = domainDataB(D);
for j = 1:m+1
    cval = real(circ(dW, d(j), q(j)));
    fprintf('Circle %d has circulation %.4f\n', j-1, cval)
end
fprintf('Point beta has circulation %.4f\n', real(circ(dW, beta, 1e-6)))




























