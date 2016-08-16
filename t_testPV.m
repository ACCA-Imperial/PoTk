%% point vortex simple domain check
clear


%%

test = poUnitTest.PointVortex;
test.domainTestObject = poUnitTest.domainSimple;

D = test.domainObject;
tp = test.domainTestObject.testPoints;
pvKind = @pointVortexNoNet;
pv = test.kindInstance(pvKind);


%%

W = potential(test.domainObject, pv);
% ref = test.generateReference(pv);
% % test.checkAtTestPoints(ref, W)

% err = ref(tp) - W(tp);
% disp(err)


%%
% Check circulation around vortices.

N = 128;
dt = 2*pi/N;
eit = exp(1i*dt*(0:N-1)');
Icirc = @(dW, c, r) 1i*dt*sum(dW(c + r*eit)*r.*eit);

dr = 1e-6;
dW = diff(W);
cv = nan(size(pv.strength));
for k = 1:numel(pv.location)
    cv(k) = real(Icirc(dW, pv.location(k), dr));
end

% err = pv.strength - cv;
% disp(max(abs(err)))


%%
% Check circulation around boundaries.

if isa(D, 'poUnitTest.domainEntire')
    return
end

bv = nan(D.m + 1, 1);
bv(1) = -real(Icirc(dW, 0, 1));
for j = 1:D.m
    bv(j+1) = real(Icirc(dW, D.dv(j), D.qv(j)));
end

disp(bv)























