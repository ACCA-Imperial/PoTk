function s = listKinds()
%listKinds lists potentialKind objects.
%
%  listKinds()
%    Lists all objects of class "potentialKind" in PoTk to the command
%    window.
%
%See also potential, potentialKind.

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

podir = fileparts(mfilename('fullpath'));
curdir = pwd;

quiet = logical(nargout);
function faprintf(varargin)
    if quiet
        return
    end
    fprintf(varargin{:})
end

cd(podir)

if nargout
    s = {};
end
dinfo = what;
faprintf('\nKinds of potential contributions in PoTk:\n\n')
for i = 1:numel(dinfo.classes)
    cname = dinfo.classes{i};
    if meta.class.fromName(cname).Abstract
        continue
    end
    obj = eval(cname);
    if isa(obj, 'potentialKind')
        if ~nargout
            fprintf('  %s\n', cname)
        else
            s = [s; {cname}]; %#ok<AGROW>
        end
    end
end
faprintf('\nSee help text for each for details.\n\n')

cd(curdir)

end