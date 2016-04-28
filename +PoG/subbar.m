classdef subbar < PoG.barInterface
%poSubBar is a sublength of poWaitbar

% Everett Kropf, 2015
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
    current = 0             % Current sublength position in [0,1].
    length = 0              % Subbar length (0 < length <= remaining).
    origin = 0              % Parent bar starting position.
    fullbar                 % Full waitbar object.
end

methods
    function b = subbar(wbar, len)
        if ~nargin
            return
        end
        
        if ~isa(wbar, 'PoG.waitbar')
            error(PoTk.ErrorTypeString.InvalidArgument, ...
                'Expected a `PoG.waitbar` object.')
        end
        
        b.fullbar = wbar;
        b.origin = wbar.current;
        b.length = len;
    end
    
    function update(b, x, msg)
        %Update the sub-interval.
        
        if nargin < 3
            msg = [];
        end
        b.current = x;
        x = b.origin + x*b.length;
        update(b.fullbar, x, msg)
    end
    
    function release(~)
    	%Required by interface. Do nothing
    end
end

end
