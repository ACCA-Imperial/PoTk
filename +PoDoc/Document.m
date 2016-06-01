classdef Document < handle
%PoDoc.Document is the PoTk document class.

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
    ieqOpen = '\('
    ieqClose = '\)'
    deqOpen = '\['
    deqClose = '\]'
end

properties(Access=protected)
    buffer = {}
end

methods
    function addln(do, str)
        do.buffer = [do.buffer(:), str];
    end
    
    function str = deqLine(do, istr)
        str = [do.deqOpen, istr, do.deqClose];
    end
    
    function str = ieqInline(do, istr, varargin)
        str = [do.ieqOpen, istr, do.ieqClose];
    end
    
    function publish(do)
        %publish and display buffer.
        
        tpath = tempname(PoTk.tempdir);
        
        % m-file version
        mkdir(tpath)
        tname = [tpath, '/podoc.m'];
        fid = fopen(tname, 'w');
        fprintf(fid, bufferToPublish(do));
        fclose(fid);
        
        mxdom = [fileparts(mfilename('fullpath')), '/mxdom2html.xsl'];
        hname = publish(tname, 'stylesheet', mxdom, 'outputDir', tpath, ...
            'evalCode', false);
        open(hname)
    end
end

methods(Access=protected)
    function out = bufferToPublish(do)
        out = sprintf('%s\n', '%%%%');
        for i = 1:numel(do.buffer)
            out = [out, sprintf('%s %s\n', '%%', ...
                PoDoc.Document.protectBS(do.buffer{i}))]; %#ok<AGROW>
        end
    end
end

methods(Static)
    function out = protectBS(str)
        out = strrep(str, '\', '\\');
    end
end

end
