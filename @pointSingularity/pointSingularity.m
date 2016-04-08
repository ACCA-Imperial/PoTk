classdef(Abstract) pointSingularity < potentialKind
%pointSingularity is the potential from a point singularity.
%
%Abstract class, meant to be subclassed. Provides basic structure
%conversion and display functionality for any type of point singularity.
%Sublasses should overload the struct method if they add (or remove access
%to) properties.
%
%See also potentialKind, listKinds.

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
