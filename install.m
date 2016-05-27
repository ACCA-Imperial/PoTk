function install(arg)
%install puts PoTk in search path.
%
% Installation is defined simply to be the addition of the PoTk
% directory to MATLAB's search path. Uninstall removes this directory from
% the search path.
%
% install
%   performs installation operations for PoTk.
% install -u
%   performs uninstall operations for PoTk.

% Everett Kropf, 2016
% 
% This file is part of PoTk.
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

if exist('./@potential/potential.m', 'file') ~= 2 || ...
        exist('./@potentialKind/potentialKind.m', 'file') ~= 2
    error(PoTk.ErrorIdString.RuntimeError, ...
        'This utility must be run from the PoTk directory.')
end
podir = pwd;

if nargin && strcmp(arg, '-u')
    uninstall(podir)
    return
end

fprintf('Adding directory "%s" to your MATLAB search path ... ', podir)
try
    addpath(podir)
    savepath
catch me
    fprintf('FAIL\n')
    rethrow(me)
end
fprintf('OK\n')

fprintf('PoTk install complete. Try "example.m" now.\n')

end

function uninstall(podir)

fprintf('Removing directory "%s" from your MATLAB search path ... ', podir)
try
    rmpath(podir)
    savepath
catch me
    fprintf('FAIL\n')
    rethrow(me)
end
fprintf('OK\n')

fprintf('PoTk uninstall complete. This directory may be safely deleted.\n')

end
