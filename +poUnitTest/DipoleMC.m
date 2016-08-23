classdef DipoleMC < poUnitTest.Dipole
%poUnitTest.DipoleMC checks multiply connected domains.

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

properties(ClassSetupParameter)
    domain = poUnitTest.domainParameterStructure.multiplyConnectedSubset
end

methods(Test)
    function checkCirc(test)
        [loc, m, chi, b] = getParameters(test);
        d = dipole(loc, m, chi, b);
        D = test.domainObject;
        W = potential(D, d);
        dW = diff(W);
        dv = [0; D.dv(:)];
        qv = [1; D.qv(:)];
        for j = 1:numel(dv)
            Ic = real(poUnitTest. ...
                circleIntegral.forDifferential(dW, dv(j), qv(j)));
            test.verifyLessThan(abs(Ic), test.defaultTolerance, ...
                sprintf('Circle %d has non-zero circulation.', j-1))
        end
    end
    
    function checkAngle(test)
        [loc, m, chi, b] = getParameters(test);
        W = potential(test.domainObject, dipole(loc, m, chi, b));
        dW = diff(W);
        zp = loc + 1e-6*exp(1i*chi);
        test.verifyLessThan(abs(chi - angle(dW(zp))), ...
            test.defaultTolerance*10)
    end
end

end
