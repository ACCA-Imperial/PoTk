classdef DefinedTerms
%DefinedTerms is a dictionary list of defined terms.

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

properties(Constant)
    keys = {...
        'skprime', ...
        'greensC0', ...
        }
end

methods(Static,Hidden)
    % Operate on document objects.
    
    function skprime(do)
        do.addln(['the Schottky-Klein prime function as ', ...
            do.eqInline('\omega(\zeta,\alpha)')])
    end
    
    function greensC0(do)
        do.addln(...
            ['the modified Green''s function with respect to circle ', ...
            do.eqInline('C_0'), ' as'])
        do.addln(do.eqDisplay(...
            ['G_0(\zeta,\alpha,\overline{\alpha}) = ' ...
            '\frac{1}{2\pi\mathrm{i}}\log \left[ ' ...
            '\frac{\omega(\zeta,\alpha)}{|a|' ...
            '\omega(\zeta,1/\overline{\alpha})} \right]']))
    end
end

end
