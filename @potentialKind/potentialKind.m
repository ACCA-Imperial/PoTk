classdef(Abstract) potentialKind
%potentialKind describes a type of contribution to the potential.
%
%Abstract class specifying interface for potential contributions.
%Subclasses (non-abstract) must implement three functions:
%
%  val = evalPotential(obj, z)
%    Given a set of points z in the bounded unit domain, return the set
%    val of potential values.
%
%  dkp = getDerivative(pd, domain)
%    Return a function handle to evaluate the potential derivative.
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
    textName
    okForPlane
end

methods(Hidden)
    val = evalPotential(pk, z)
    dpk = getDerivative(pk)
    pk = setupPotential(pk, W)
    
    function str = latexExpression(pk)
        str = ['\mathrm{no\; expression\; given}\quad\mathrm{(', ...
            pk.textName, ')}'];
    end
    
    function terms = docTerms(~)
        %returns cell array of term keys used in potential definition.
        
        terms = {};
    end
    
    function termLatexToDoc(pk, term, do)
        try
            feval([term, 'TermLatexToDoc'], pk, do)
        catch err
            if ~strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                rethrow(err)
            end
            try
                feval(['PoDoc.DefinedTerms.', term], do)
            catch err
                if ~strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                    rethrow(err)
                end
                warning(PoTk.ErrorIdString.UndefinedState, ...
                    'Unable to find document term ''%s''', term)
            end
        end
    end
end

methods(Access=protected)
    function entireDerivative(pk, ~)
        error(PoTk.ErrorIdString.RuntimeError, ...
            'Derivatives for class "%s" not yet implemented in entire plane.', ...
            class(pk))
    end
    
    function str = getTextName(pk)
        str = class(pk);
    end
    
    function bool = getOkForPlane(~)
        bool = false;
    end
end

methods
    function str = get.textName(pk)
        str = getTextName(pk);
    end
    
    function bool = get.okForPlane(pk)
        bool = getOkForPlane(pk);
    end
end

end
