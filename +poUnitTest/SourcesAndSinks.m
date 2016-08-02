classdef SourcesAndSinks < poUnitTest.ParameterizedTestCase
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
    strengthOnePoint = 2
    entireOnePoint = 0.42176+0.65574i
    simpleOnePoint = 0.67894+0.52697i
    annulusOnePoint = 0.5+0.5i
    conn3OnePoint = 0.31137+0.11195i
    
    strengthThreePoints = [1; 3; -2]
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
    conn3ThreePoints = [
        0.21341+0.55277i
        -0.54227+0i
        -0.18542-0.67172i]
end

methods(Test)
    function checkOne(test)
        test.checkValues('OnePoint')
    end
    
    function checkOneDz(test)
        switch test.type
            case poUnitTest.domainType.Entire
                test.verifyFail('Bug submitted as issue #65.')
                return
        end
        test.checkDerivative('OnePoint')
    end
    
    function checkThree(test)
        test.checkValues('ThreePoints')
    end
    
    function checkThreeDz(test)
        switch test.type
            case poUnitTest.domainType.Entire
                test.verifyFail('Bug submitted as issue #65.')
                return
        end
        test.checkDerivative('ThreePoints')
    end
end

methods
    function [a, m] = getProperties(test, numString)
        a = test.dispatchTestProperty(numString);
        a = [a; -a];
        m = test.(['strength', numString]);
        m = [m; -m];
    end
    
    function checkValues(test, numString)
        [a, m] = test.getProperties(numString);
        W = potential(test.domainObject, sourcesAndSinks(a, m));
        ref = test.generateEvalReference(a, m);
        test.checkAtTestPoints(ref, W)
    end
    
    function checkDerivative(test, numString)
        [a, m] = test.getProperties(numString);
        W = potential(test.domainObject, sourcesAndSinks(a, m));
        dW = diff(W);
        ref = poUnitTest.FiniteDifference(@(z) W(z));
        test.checkAtTestPoints(ref, dW);
    end
    
    function ref = generateEvalReference(test, a, m)
        switch test.type
            case poUnitTest.domainType.Entire
                N = numel(a);
                ref = @(z) reshape(sum( cell2mat(...
                    arrayfun(@(k) m(k)*log(z(:) - a(k))/2/pi, 1:N, ...
                    'uniform', false)), 2), size(z));
                
            otherwise
                pf = test.primeFunctionReferenceForDomain;
                ref = test.primeFormReferenceFunction(pf, a, m);
        end
    end
end

methods(Static)
    function ref = primeFormReferenceFunction(pf, a, m)
        function v = refeval(z)
            v = arrayfun(...
                @(k) m(k)/2/pi*log( ...
                    pf(z(:), a(k)).*pf(z(:), 1/conj(a(k)))), ...
                1:numel(a), 'uniform', false);
            v = reshape(sum(cell2mat(v), 2), size(z));
        end
       
        ref = poUnitTest.ReferenceFunction(@refeval);
        if isa(pf, 'poUnitTest.ReferenceFunction')
            ref.tolerance = pf.tolerance;
        end
    end
end

end
