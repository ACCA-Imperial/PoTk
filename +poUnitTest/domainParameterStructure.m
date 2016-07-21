function dps = domainParameterStructure()

domainList = {'domainEntire', 'domainSimple'};
dps = struct();

for i = 1:numel(domainList)
    object = poUnitTest.(domainList{i})();
    dps.(object.label) = object;
end
