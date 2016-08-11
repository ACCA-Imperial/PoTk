classdef(Abstract) domainParameterStructure
%poUnitTest.domainParameterStructure provides the parameter structure for
%the unit test framework.
%
%See also poUnitTest.TestCaseParamDomain

% Everett Kropf, 2016
% 
% This file is part of the Potential Toolkit (PoTk).
% 
% PoTk is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% PoTk is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PoTk.  If not, see <http://www.gnu.org/licenses/>.

properties(Constant)
    domainList = {'domainEntire', 'domainSimple', 'domainAnnulus', ...
        'domainConn3'};
end

methods(Static)
    function dps = defaults()
        domainList = poUnitTest. ...
            domainParameterStructure.domainList;
        dps = poUnitTest. ...
            domainParameterStructure.generateParameterStructure(domainList);
    end
    
    function dps = simplyConnectedSubset()
        domainList = poUnitTest. ...
            domainParameterStructure.domainList(1:2);
        dps = poUnitTest. ...
            domainParameterStructure.generateParameterStructure(domainList);
    end
    
    function dps = multiplyConnectedSubset()
        domainList = poUnitTest. ...
            domainParameterStructure.domainList(3:4);
        dps = poUnitTest. ...
            domainParameterStructure.generateParameterStructure(domainList);
    end
    
    function dps = generateParameterStructure(domainList)
        dps = struct();        
        for i = 1:numel(domainList)
            object = poUnitTest.(domainList{i})();
            dps.(object.label) = object;
        end
    end
end

end
