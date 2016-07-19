classdef PointVortex < poUnitTest.TestCase
%poUnitTest.PointVortex tests the point vortex potential.

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
    entireVortexLocations = [
        0.42176+0.65574i
        1.8315+0.071423i
        2.3766+2.5474i
        3.838+3.736i];
    vortexStrengths = [-1, 1, -1, 1];
end

methods(Test)
    function checkNet(test)
        dispatchTestMethod(test, 'net')
    end
    
    function checkNoNet(test)
        dispatchTestMethod(test, 'noNet')
    end
end

methods
    function entireNet(test)
        av = test.entireVortexLocations;
        pv = pointVortex(av, test.vortexStrengths);
        test.checkEitherPV(pv)
    end
    
    function entireNoNet(test)
        av = test.entireVortexLocations;
        pv = pointVortexNoNet(av, test.vortexStrengths);
        test.checkEitherPV(pv)
    end
    
    function checkEitherPV(test, pv)
        W = potential(test.domainObject, pv);
        N = numel(pv.location);
        ref = @(z) reshape(sum(cell2mat(...
            arrayfun(@(k) log(z(:) - pv.location(k)), ...
            1:N, 'uniform', false)), 2), size(z))/2i/pi;
        test.checkAtTestPoints(ref, W, test.defaultTolerance)
    end
end

end
