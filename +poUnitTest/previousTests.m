classdef(Abstract) previousTests < matlab.unittest.TestCase % potentialTest < matlab.unittest.TestCase
%potentialTest test suite for potential.

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
    dv3 = [-0.2517+0.3129i, 0.2307-0.4667i];
    qv3 = [0.2377, 0.1557];
    
    simple3
end

methods(TestClassSetup)
    function simpleThree(test)
        test.simple3 = unitDomain(test.dv3, test.qv3, 0);
    end
end

methods(Test)
    function noPotential(test)
        W = potential(unitDomain(test.dv3, test.qv3));
        test.verifyEqual(W(0.5+0.1i), complex(0))
    end
    
    function circulation(test)
        cv = [1, 2, -1];
        
        c = circulation(cv(2:end));
        test.verifyInstanceOf(c, 'circulation')

        W = potential(test.simple3, c);
        test.verifyInstanceOf(W, 'potential');
        
        c = circulationNoNet(cv);
        test.verifyInstanceOf(c, 'circulationNoNet')
        
        W = potential(test.simple3, c);
        test.verifyInstanceOf(W, 'potential');
        
        import matlab.unittest.constraints.Throws
        test.verifyThat(@() potential(planeDomain, circulation), ...
            Throws('PoTk:InvalidArgument'))
        test.verifyThat(@() potential(planeDomain, circulationNoNet), ...
            Throws('PoTk:InvalidArgument'))
    end
    
    function dipole(test)
        dp = dipole(0, 1, pi/4);
        test.verifyInstanceOf(dp, 'dipole');
        test.verifyInstanceOf(potential(test.simple3, dp), 'potential');
        test.verifyInstanceOf(potential(planeDomain, dp), 'potential');
    end
    
    function pointVortices(test)
        av = [-0.27638-0.2309i; 0.63324+0.062974i];
        gv = [-2, 1];
        
        pv = pointVortex(av, gv);
        test.verifyInstanceOf(pv, 'pointVortex');
        test.verifyInstanceOf(potential(test.simple3, pv), 'potential');
        test.verifyInstanceOf(potential(planeDomain, pv), 'potential');

        pv = pointVortexNoNet(av, gv);
        test.verifyInstanceOf(pv, 'pointVortexNoNet');
        test.verifyInstanceOf(potential(test.simple3, pv), 'potential');
        test.verifyInstanceOf(potential(planeDomain, pv), 'potential');
    end
    
    function sourceSinkPair(test)
        a = -0.090472-0.20942i;
        b = 0.30524+0.24257i;
        m = 1.2;
        
        ss = sourceSinkPair(a, b, m);
        test.verifyInstanceOf(ss, 'sourceSinkPair');
        test.verifyInstanceOf(potential(test.simple3, ss), 'potential');
        test.verifyInstanceOf(potential(planeDomain, ss), 'potential');
    end
    
    function source(test)
        a = -0.27638-0.2309i;
        g = -2;
        
        sp = source(a, g);
        test.verifyInstanceOf(sp, 'source');
        test.verifyInstanceOf(potential(test.simple3, sp), 'potential');
        test.verifyInstanceOf(potential(planeDomain, sp), 'potential');
    end
    
    function uniformFlow(test)
        uf = uniformFlow(1, pi/4);
        test.verifyInstanceOf(uf, 'uniformFlow');
        test.verifyInstanceOf(potential(test.simple3, uf), 'potential');
        test.verifyInstanceOf(potential(planeDomain, uf), 'potential');
    end
    
    function kindListing(test)
        import matlab.unittest.constraints.EveryCellOf
        import matlab.unittest.constraints.IsInstanceOf
        s = listKinds();
        test.verifyThat(EveryCellOf(s), IsInstanceOf('char'))
    end
end

end
