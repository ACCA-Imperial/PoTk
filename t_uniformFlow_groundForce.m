% A rough ground force test - needs to be updated to be compared with the
% semi-analytic results at some point
%% Clear the workspace
clear

%%

% The conformal map
a = 1.0; % Multiplication factor
map = @(zeta) a*1i*(1-zeta)./(1+zeta);
% Its inverse
imap = @(z) (a*i-z)./(a*i+z);
% Its derivative dz/dzeta
dz = @(zeta) -2i*a./(1+zeta).^2;

% Radius of the 'internal' disk
rho = 0.2;

% check where some points are mapped to!
% disp([map(1) map(1i) map(-1) map(-1i)]) 
% disp([map(rho) map(rho*i) map(-rho) map(-rho*i)])

% Centre (D) and radius (Q) of the disk in the upper half plane
Dc = 0.5*(map(rho)+map(-rho));
Qc = 0.5*abs(map(rho)-map(-rho));

% disp([D Q])

% Task: Work out how 'Dc' and 'Qc' are related to 'a' and 'rho'

%%
% Domain and Potential objects

% These four lines form the domain we want (don't worry too much about these)
dv = [0.0];
qv = [rho];
beta = -1.0; 
D = unitDomain(dv, qv, beta);

% Create a uniform flow
uinf=1.0; % Speed of the uniform flow.
anorm=2.0*a*1i;
uf = uniformFlow(uinf, 0.0, anorm);
% Tip: look at how this changing uinf modifies the value of U(zeta) at
% different points (U(zeta) defined below).
% i.e. After running 'ground_force' try typing U(imap(Dc+i*Qc)) and U(imap(100i))
% in the command line. What happens as we move far away from the cylinder?

% Create a circulation around the cylinder
gamma0 = 0; % keep this set to zero
gamma1 = 0; % play around with this. A positive circulation is defined in the
            % anti-clockwise direction
C = circulationNoNet(gamma0, gamma1);

% Create the complex potential
W = potential(D, uf, C);
% And its derivative with respect to zeta: dW/dzeta
dW = diff(W);

% Create the velocity field u-iv = dW/dz = dW/dzeta * dzeta/dz
U = @(zeta) dW(zeta).*1./dz(zeta);

% Work out the force on the cylinder (using the "Blasius Formula")
% Numerical integration using the trapezoidal rule:
% https://en.wikipedia.org/wiki/Trapezoidal_rule
nbt = 200; % number of boundary points
theta = [0:nbt-1]/nbt*2*pi; % Angles of the boundary points
zb = Dc + Qc*exp(1i*theta(:)); % Define the curve along which we are integrating.
                               % These are the points our function U needs
                               % to be evaluated at.

% The 'complex' force F = Fx - i*Fy;
F = -Qc*pi/nbt*sum(U(imap(zb)).^2.*exp(1i.*theta(:)));

% The horizontal force component
Fx = real(F);
% The vertical force component
Fy = -imag(F);

if Fy > 0
    error('ground force calculation error')
end

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

w0 = W(c0);
if max(imag(w0)) > tpres
    error('uniform flow calculated incorrectly')
end

w1 = W(c1);
if max(imag(w1)-imag(w1(1))) > tpres
    error('uniform flow calculated incorrectly')
end

% clear
