clear

%% Solve for map parameters

syms as betas shift rhos

S = solve(as/(1i*rhos-1i*betas)+1i*shift == 3i, ...
          as/(-1i*rhos-1i*betas)+1i*shift == i, ...
          as/(1i-1i*betas)+1i*shift == -3i, ...
          as/(-1i-1i*betas)+1i*shift == -i);
      
a = double(S.as(1));
beta = double(S.betas(1))*1i;
s = double(S.shift(1))*1i;
rho = double(S.rhos(1));

dv = [0.0];
qv = [rho];

map = @(zeta) a./(zeta-beta)+s;
imap = @(z) a./(z-s)+beta;
dz = @(zeta) -a./(zeta-beta).^2;

D = unitDomain(dv,qv);

uinf = 1.0;
kai = 0.0;
uf = uniformFlow(beta,uinf,kai,a);

w = potential(D,uf);
dw = diff(w);

U = @(zeta) dw(zeta)./dz(zeta);

nbt = 200;
theta = [0:nbt-1]/nbt*2*pi;
tpres = 10e-12;

ut1 = real(U(imap(-1000000+10i)));
if (ut1 < uinf-tpres) | (ut1 > uinf+tpres)
    error('uniform flow calculated incorrectly')
end

ut2 = real(U(imap(1000000+10i)));
if (ut2 < uinf-tpres) | (ut2 > uinf+tpres)
    error('uniform flow calculated incorrectly')
end

ut3 = imag(U(imap(0)));
if ut3 > tpres
    error('uniform flow calculated incorrectly')
end

c0 = exp(1i*theta(:));
c1 = rho*c0;

w0 = w(c0);
if max(imag(w0)) > tpres
    error('uniform flow calculated incorrectly')
end

w1 = w(c1);
if max(imag(w1)-imag(w1(1))) > tpres
    error('uniform flow calculated incorrectly')
end

clear