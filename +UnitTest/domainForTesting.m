classdef(Abstract) domainForTesting
%UnitTest.domainForTesting is the abstract base class for test domains.

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

properties(Abstract)
    type                    % UnitTest.domainType enumeration
    domainObject
    testPoints
end

properties(Dependent)
    label
end
methods % get/set
    function s = get.label(obj)
        s = label(obj.type); %#ok<CPROP>
    end
end

end
