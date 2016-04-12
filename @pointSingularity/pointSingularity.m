classdef(Abstract) pointSingularity < potentialKind
%pointSingularity is the potential from a point singularity.
%
%Abstract class, meant to be subclassed. Provides basic structure
%conversion and display functionality for any type of point singularity.
%Sublasses should overload the struct method if they add (or remove access
%to) properties.
%
%See also potentialKind, listKinds.

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
    location
    strength
end    

methods
    function disp(ps)
        %Display instance as structure.
        
        disp(struct(ps))
    end
    
    function ps = struct(ps)
        %Convert instance to a structure.
        
        ps = struct('location', ps.location, ...
            'strength', ps.strength);
    end
end

end
