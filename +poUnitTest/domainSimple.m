classdef domainSimple < poUnitTest.domainForTesting
%poUnitTest.domainSimple represents a simply connected domain (unit disk).

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

properties
    label = 'simple'
    domainObject = unitDomain([], [], 0)
    testPoints = [
        0.67874+0.65548i
        0.75774+0.17119i
        0.74313+0.70605i
        0.39223+0.031833i];
end

end
