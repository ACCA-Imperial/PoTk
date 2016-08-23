classdef SKProdCheck < poUnitTest.TestCase
%poUnitTest.SKProdCheck verification tests for the prime product forumla.

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
    domainTestObject = poUnitTest.domainConn3
    testPoints = [
        -0.63324-0.013994i
        0.33236+0.10496i
        0.066472+0.67872i
        0.78017-0.16793i]

    alpha = -0.42332-0.41283i 
    
    prodTolerance = 1e-6
end

methods(Test)
    function valueVsBVP(test)
        dv = test.domainObject.dv;
        qv = test.domainObject.qv;
        a = test.alpha;
        
        w = skprime(a, dv, qv);
        wp = test.primeFunctionReferenceForDomain;
        ref = @(z) wp(z, a);
        
        test.perTestTolerance = test.prodTolerance;
        test.checkAtTestPoints(w, ref)
    end
end

end
