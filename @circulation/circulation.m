classdef circulation < potentialKind
%circulation is a vector of boundary circulation values.
%
%  C = circulation(c1, c2, ..., cm)
%  C = circulation([c1, c2, ..., cm])
%    Creates a circulation object which describes the potential
%    contribution due to circulation around m >= 1 inner boundaries in a
%    unitDomain. For j = 1:m, each cj is a real scalar value signifying
%    the circulation strength on boundary j. The unit circle then has a
%    net circulation of -sum([c1, c2, ..., cm]); in other words, all of
%    the "extra" circulation has been placed there.
%
%See also potential, unitDomain, circulationNoNet.

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

properties(SetAccess=protected)
    circVector
end

properties(Access=protected)
    firstKindIntegrals
    equivalenceConstants
    infImage
    isSimplyConnected = false
end

methods
    function C = circulation(varargin)
        if ~nargin
            data = [];
        elseif nargin == 1
            data = varargin{1};
        else
            data = cell2mat(varargin);
        end
        
        if any(imag(data(:)) ~= 0)
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Circulation values must be real scalars.')
        end
        C.circVector = data(:)';
    end
    
    function disp(C)
        %Display instance as double.
        
        disp(double(C))
    end
    
    function c = double(C)
        %Convert to double.
        
        c = C.circVector;
    end
        
    function out = subsref(C, S)
        %Provide double type indexing access to circulation values.
        
        if strcmp(S(1).type, '()')
            out = subsref(double(C), S);
        else
            if nargout
                out = builtin('subsref', C, S);
            else
                builtin('subsref', C, S)
            end
        end
    end
end

methods(Hidden)
    function val = evalPotential(C, z)
        val = complex(zeros(size(z)));
        cv = C.circVector;
        vj = C.firstKindIntegrals;
        K = C.equivalenceConstants;
        
        if C.isSimplyConnected
            beta = C.infImage;
            if beta == 0
                val = -cv*log(z)./2i/pi;
            else
                val = -cv*log((z - beta)./(z - 1/conj(beta))/abs(beta))/2i/pi;
            end
            return
        end
        
        for j = find(cv(:) ~= 0)'
            val = val + cv(j)*(vj{j}(z) - K{j});
        end
    end
    
    function dc = getDerivative(C)
        circ = C.circVector;
        if C.isSimplyConnected
            beta = C.infImage;
            if beta == 0
                dc = @(z) -circ*(1./(z - beta) - 1./(z - 1/conj(beta)))/2i/pi;
            else
                dc = @(z) -circ./z/2i/pi;
            end
            return
        end
        
        cv = find(circ(:)' ~= 0);
        vj = C.firstKindIntegrals;
        dvj = cell(size(vj));
        for k = cv
            dvj{k} = diff(vj{k});
        end
        
        function v = deval(z)
            v = 0;
            for i = cv
                v = v + circ(i)*dvj{i}(z);
            end
        end
        
        dc = @deval;
    end
    
    function C = setupPotential(C, W)
        D = W.unitDomain;
        circ = C.circVector;
        
        if D.m == 0 && numel(circ) ~= 1
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Must specify a single circulation value.')
        end
        if (D.m > 0 && numel(circ) ~= D.m) || (D.m == 1 && numel(circ) ~= 1)
            error(PoTk.ErrorIdString.RuntimeError, ...
                ['The number of circulation values and inner circles ' ...
                'must match.'])
        end
        
        if isempty(D.infImage)
            error(PoTk.ErrorIdString.InvalidValue, ...
                ['The "image at infinity" must be defined in the ', ...
                'unit domain for constant equivalence. ', ...
                'See the "beta" argument for "unitDomain".'])
        end
        C.infImage = D.infImage;
        
        if D.m == 0
            C.isSimplyConnected = true;
            return
        end
        
        D = skpDomain(D);
        dv = domainData(D);
        beta = C.infImage;
        vj = cell(1, numel(circ));
        K = vj;
        for j = find(circ(:) ~= 0)'
            vj{j} = vjFirstKind(j, D);
            K{j} = conj(vj{j}(beta)) + vj{j}.taujj/2 ...
                + angle(beta/(beta - dv(j)))/2/pi;
        end
        C.firstKindIntegrals = vj;
        C.equivalenceConstants = K;
    end
end

methods(Hidden) % Documentation
    function terms = docTerms(~)
        terms = {'skprime', 'greensC0', 'greensCj', 'circulation'};
    end
    
    function str = latexExpression(C)
        if numel(C.circVector) == 1
            str = ['\Gamma_1 \left(G_0(\zeta,\beta,\overline{\beta}) ' ...
                '- G_j(\zeta,\beta,\overline{\beta})\right)'];
        else
            str = ['\sum_{j=1}^m \Gamma_j ' ...
                '\left(G_0(\zeta,\beta,\overline{\beta}) - ' ...
                'G_j(\zeta,\beta,\overline{\beta})\right)'];
        end
        str = [str, ' \qquad\mathrm{(circulation)}'];
    end
    
    function circulationTermLatexToDoc(C, do)
        if numel(C.circVector) == 1
            do.addln(...
                ['the circulation strength given by ', ...
                do.eqInline('\Gamma_1'), ' on circle ', ...
                do.eqInline('C_1')])
        else
            do.addln(...
                ['the circulation strengths given by ', ...
                do.eqInline('\Gamma_j'), ...
                ' on each circle ', do.eqInline('C_j')])
        end
    end
end

end
