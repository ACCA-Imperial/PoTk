classdef domainEntire < poUnitTest.domainForTesting
%poUnitTest.domainEntire represents the entire complex plane domain.

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
    type = poUnitTest.domainType.Entire
    domainObject = planeDomain
    testPoints = [
        0.95751+0.95717i
        1.9298+0.97075i
        0.47284+2.4008i
        3.8824+0.56755i];
end

end
