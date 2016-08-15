%% point vortex simple domain check
clear


%%

test = poUnitTest.PointVortex;
test.domainTestObject = poUnitTest.domainSimple;

D = test.domainObject;
tp = test.domainTestObject.testPoints;
pvKind = @pointVortex;
pv = test.kindInstance(pvKind);


%%
% Check circulation around vortices.




%%

% n = numel(pv.location);
% 
% g0v = cell(n, 1);
% for k = find(pv.strength(:) ~= 0)'
%     g0v{k} = greensC0(pv.location(k), skpDomain(D));
% end
% 
% W = @(z) reshape(sum(cell2mat( ...
%     arrayfun(@(k) pv.strength(k)*g0v{k}(z(:)), find(pv.strength(:) ~= 0)', ...
%     'uniform', false)), 2), size(z));


%%

% pf = test.primeFunctionReferenceForDomain;
% g0 = poUnitTest.PrimeFormGreens(pf, 0, test.domainTestObject);
% 
% 
% return


%%

W = potential(test.domainObject, pv);
ref = test.generateReference(pv);
% % test.checkAtTestPoints(ref, W)

err = ref(tp) - W(tp);
disp(err)
























