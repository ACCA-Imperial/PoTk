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
    simpleOnePoint = 0.67894+0.52697i
    annulusOnePoint = 0.5+0.5i
    
    strength3 = [1; 3; -2]
    entireThreePoints = [
        1.8315+0.071423i
        2.3766+2.5474i
        3.838+3.736i]
    simpleThreePoints = [
        0.75483+0.081284i
        0.10582+0.23208i
        0.76115+0.45573i]
    annulusThreePoints = [
        -0.16443+0.49679i
        0.42332-0.16793i
        -0.02449-0.53878i]
end

methods(Test)
    function checkOne(test)
        test.dispatchTestMethod('one')
    end
    
    function checkThree(test)
        test.dispatchTestMethod('three')
    end
end

methods
    function entireOne(test)
        test.setAndCheckOne('entire')
    end
    
    function entireThree(test)
        test.setAndCheckThree('entire')
    end
    
    function simpleOne(test)
        test.setAndCheckOne('simple')
    end
    
    function simpleThree(test)
        test.setAndCheckThree('simple')
    end
    
    function annulusOne(test)
        test.setAndCheckOne('annulus')
    end
    
    function annulusThree(test)
        test.setAndCheckThree('annulus')
    end
    
    function setAndCheckOne(test, label)
        a = test.([label, 'OnePoint']);
        m = test.strength1;
        test.checkEval(a, m)
    end
    
    function setAndCheckThree(test, label)
        a = test.([label, 'ThreePoints']);
        m = test.strength3;
        test.checkEval(a, m)
    end
    
    function checkEval(test, a, m)
        a = [a; -a];
        m = [m; -m];
        
        S = sourcesAndSinks(a, m);
        W = potential(test.domainObject, S);
        
        ref = test.generateEvalReference(a, m);
        
        test.checkAtTestPoints(ref, W)
    end
    
    function ref = generateEvalReference(test, a, m)
        label = test.domainTestObject.label;
        switch label
            case 'entire'
                N = numel(a);
                ref = @(z) reshape(sum( cell2mat(...
                    arrayfun(@(k) m(k)*log(z(:) - a(k))/2/pi, 1:N, ...
                    'uniform', false)), 2), size(z));
                
            case 'simple'
                pf = @(z,a) (z - a);
                ref = test.genericReferenceFunction(pf, a, m);
                
            case 'annulus'
                pf = test.primeFunctionFromPFunction;
                ref = test.genericReferenceFunction(pf, a, m);
                
            otherwise
                test.assertFail(...
                    sprintf('Case %s not implemented yet!', label))
        end
    end
end

methods(Static)
    function ref = genericReferenceFunction(pf, a, m)
        function v = refeval(z)
            v = arrayfun(...
                @(k) m(k)/2/pi*log( ...
                    pf(z(:), a(k)).*pf(z(:), 1/conj(a(k)))), ...
                1:numel(a), 'uniform', false);
            v = reshape(sum(cell2mat(v), 2), size(z));
        end
        
        ref = @refeval;
    end
end

end
