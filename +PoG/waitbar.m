classdef waitbar < PoG.barInterface
%poWaitbar specialises waitbar for PoTk

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
    current = 0             % Current position.
    wHandle                 % Waitbar handle.
end

methods
    function b = waitbar(name, msg)
        if ~nargin
            return
        end
        
        if nargin < 2
            msg = '';
        end
        b.wHandle = waitbar(0, msg, 'name', name);
    end
    
    function tf = goodBar(b)
        %goodBar returns true if the handle is good.
        
        tf = ~isempty(b.wHandle) & ishghandle(b.wHandle);
    end
    
    function update(b, x, msg)
        %Update waitbar with x and optional msg.
        
        if ~goodBar(b)
            return
        end
        
        if nargin < 3
            msg = [];
        end
        waitbar(x, b.wHandle, msg)
        b.current = x;
    end
    
    function release(b)
        %Closes waitbar via handle delete.
        
        if ~goodBar(b)
            return
        end
        delete(b.wHandle)
        b.wHandle = [];
    end
end

end
