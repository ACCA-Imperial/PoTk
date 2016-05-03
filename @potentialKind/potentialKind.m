classdef(Abstract) potentialKind
%potentialKind describes a type of contribution to the potential.
%
%Abstract class specifying interface for potential contributions.
%Subclasses (non-abstract) must implement two functions:
%
%  val = evalPotential(obj, z)
%    Given a set of points z in the bounded unit domain, return the set
%    val of potential values.
%
%  obj = setupPotential(obj, W)
%    Given a potential object, perform setup actions in anticipation of
%    calls to evalPotential later. The problem domain may be read from the
%    potential object W.
%
%See also potential, listKinds.

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

properties(Hidden)
    entirePotential = false
    domain
end

properties(Dependent,Hidden)
    okForPlane
end

methods(Hidden)
    val = evalPotential(pk, z)
    dpk = getDerivative(pk, W, n)
    pk = setupPotential(pk, W)
end

methods(Access=protected)
    function entireDerivative(pk, ~)
        error(PoTk.ErrorIdString.RuntimeError, ...
            'Derivatives for class "%s" not yet implemented in entire plane.', ...
            class(pk))
    end
    
    function bool = getOkForPlane(~)
        bool = false;
    end
end

methods
    function bool = get.okForPlane(pk)
        bool = getOkForPlane(pk);
    end
end

end
