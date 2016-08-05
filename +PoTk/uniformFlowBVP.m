classdef uniformFlowBVP < bvpFun
% Boundary value problem for a uniform flow.

% Everett Kropf, 2016
% Rhodri Nelson, 2016
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

properties(SetAccess=protected)
    parameter
        
    ufa
    singCorrFact
    normConstant = 0
end

methods
    function guf = uniformFlowBVP(beta, U, kai, a, D)
        if ~nargin
            sargs = {};
        else
            if nargin > 5
                sargs = {D, N};
            else
                sargs = {D};
            end
        end
        
        guf = guf@bvpFun(sargs{:});
        if ~nargin
            return
        end
  
        guf.parameter = skpParameter(beta, guf.domain);
        beta = guf.parameter;
        if ~beta.inUnitDomain
            error('SKPrime:InvalidArgument', ...
                'Parameter must have magnitude <= 1.')
        end

        if ~isempty(beta.ison) && beta.ison == 0
            % Beta on the unit circle means.
            ufb = @(z) ...
                0.5*U*(a*exp(-1i*kai)*(1./(z-beta)+0.5./beta) ...
                -conj(a)*exp(1i*kai)*(1./(conj(beta)^2*(z-1./conj(beta)))+0.5./conj(beta)));
        elseif ~isempty(beta.ison) && beta.ison > 0
            error('not coded')
        elseif beta == 0
            error('Also (still) need to code this case up')
        else
            ufb = @(z) ...
                U*(a*exp(-1i*kai)*(1./(z-beta)+0.5./beta) ...
                -conj(a)*exp(1i*kai)*(1./(conj(beta)^2*(z-1./conj(beta)))+0.5./conj(beta)));
        end
        guf.ufa = ufb;
        
        if guf.domain.m == 0
            % Nothing more to do.
            return
        end
        
        % Known part on the boundary.   
        if ~isempty(beta.ison) && beta.ison == 0
            f0 = @(z) 0.0;
            f1 = @(z) -imag(ufb(z));
            % Note the boundary function that comes back takes care of deciding if a
            % given point is on a boundary or not, and what boundary it is on. (Really
            % handled in the skpDomain class code.)
            ha = PoTk.boundaryPartMake(D, f0, f1);  
        else
            ha = @(z) -imag(ufb(z));
        end
               
        % Solve for unknown part on the boundary.
        % TO DO: Add case when beta is on aboundary
        guf.phiFun = solve(guf.phiFun, ha);
        
        % Boundary function and Cauchy interpolant.
        guf.boundaryFunction = @(z) guf.phiFun(z) + 1i*ha(z);
        guf.continuedFunction = SKP.bmcCauchy(...
            guf.boundaryFunction, guf.domain, 2*guf.truncation);
        
    end
    
    function dgufh = diffh(guf,n)
    
        if nargin < 2
            n = 1;
        end
        
        dgufh = dftDerivative(guf, @guf.hat, n);
    
    end
    
    function v = feval(guf, z)
        %provides function evaluation for the Green's function.
        
        v = guf.ufa(z) + guf.hat(z);
    end
    
    function v = hat(guf, z)
        %evaluate the "analytic" part of the function.
        
        if guf.domain.m == 0
            v = complex(zeros(size(z)));
            return
        end
        
        v = bvpEval(guf, z);
    end
end

end
