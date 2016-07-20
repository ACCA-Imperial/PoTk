classdef SourceSinkPair < poUnitTest.TestCase
%poUnitTest.SourceSinkPair checks the source/sink pair potential.

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
    entireLocation = 0.95751+0.95717i
    
    strength = 2
end

methods(Test)
    function checkPair(test)
        test.dispatchTestMethod('pair')
    end
end

methods
    function entirePair(test)
        a = test.entireLocation;
        o = conj(a);
        m = test.strength;
        
        S = sourceSinkPair(a, o, m);
        W = potential(test.domainObject, S);
        
        ref = @(z) m*log((z - a)./(z - o))/2/pi;
        
        test.checkAtTestPoints(ref, W);
    end
end

end
