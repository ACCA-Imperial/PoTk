classdef SourcesAndSinks < poUnitTest.TestCase
%poUnitTest.SourcesAndSinks checks the potential from a collection of
%sources and sinks.

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
    strength1 = 2
    entireOnePoint = 0.42176+0.65574i
    
    strength3 = [1; 3; -2]
    entireThreePoints = [
        1.8315+0.071423i
        2.3766+2.5474i
        3.838+3.736i]
end

methods(Test)
    function checkOne(test)
        test.dispatchTestMethod('one')
    end
    
    function checkThree(test)
        test.dispatchTestMethod('three')
    end
    
    function checkError(test)
        test.dispatchTestMethod('error')
    end
end

methods
    function entireError(test)
        a = test.entireThreePoints;
        m = test.strength3;
        
        test.verifyError(@() sourcesAndSinks(a, m), ...
            PoTk.ErrorIdString.RuntimeError)
    end
    
    function entireOne(test)
        a = test.entireOnePoint;
        m = test.strength1;
        test.entireAnalytic(a, m)
    end
    
    function entireThree(test)
        a = test.entireThreePoints;
        m = test.strength3;
        test.entireAnalytic(a, m)
    end
    
    function entireAnalytic(test, a, m)
        a = [a; -a];
        m = [m; -m];
        
        S = sourcesAndSinks(a, m);
        W = potential(test.domainObject, S);

        N = numel(a);
        ref = @(z) reshape(sum( cell2mat(...
            arrayfun(@(k) m(k)*log(z(:) - a(k))/2/pi, 1:N, ...
            'uniform', false)), 2), size(z));
        
        test.checkAtTestPoints(ref, W)
    end
end

end
