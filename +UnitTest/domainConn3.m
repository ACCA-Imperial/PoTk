classdef domainConn3 < UnitTest.domainForTesting
%UnitTest.domainConn3 represents a 3-connected circle domain.

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
    type = UnitTest.domainType.Conn3
    domainObject = unitDomain(...
        [-0.2517+0.3129i, 0.2307-0.4667i], ...
        [0.2377, 0.1557], ...
        0)
    testPoints = [
        -0.46531-0.44082i
        0.15044-0.062974i
        0.44431+0.55277i
        -0.031487+0.79067i]
    betaLocations = struct(...
        'origin', 0, ...
        'inside', 0.52128+0.069971i, ...
        'circle0', -1)
end

end
