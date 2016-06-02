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

properties(SetAccess=protected)
    buffer = {}
end

methods
    function do = Document(buffer)
        if ~nargin
            return
        end
        
        if ~all(cellfun(@ischar, buffer(:)))
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Buffer must be cell array of strings.')
        end
        do.buffer = buffer;
    end
    
    function addln(do, str)
        %add unformatted line to document.
        
        if nargin < 2 || isempty(str)
            str = ' ';
        end
        
        do.buffer = [do.buffer(:); str];
    end
    
    function insertIntoLastLineFront(do, str)
        %insert string at beginning of last line in buffer.
        
        do.buffer{end} = [str, do.buffer{end}];
    end
    
    function deleteLastLine(do)
        %deletes last line in buffer.
        
        do.buffer(end) = '';
    end
    
    function str = deqLine(do, istr)
        %display equation mode.
        
        str = [do.deqOpen, istr, do.deqClose];
    end
    
    function str = ieqInline(do, istr)
        %inline equation mode.
        
        str = [do.ieqOpen, istr, do.ieqClose];
    end
    
    function publish(do)
        %publish and display buffer.
        
        tpath = tempname(PoTk.tempdir);
        
        % m-file version
        mkdir(tpath)
        mname = [tpath, '/podoc.m'];
        fid = fopen(mname, 'w');
        fprintf(fid, bufferToPublish(do));
        fclose(fid);
        
        % convert to html and display
        mxdom = [fileparts(mfilename('fullpath')), '/mxdom2html.xsl'];
        hname = publish(mname, 'stylesheet', mxdom, 'outputDir', tpath, ...
            'evalCode', false);
        open(hname)
    end
    
    function do3 = vertcat(do1, do2)
        %Vertical concatenation.
        
        if ~(isa(do1, 'PoDoc.Document') && isa(do2, 'PoDoc.Document'))
            error(PoTk.ErrorIdString.InvalidArgument, ...
                ['Cannot concatenate a PoDoc.Document object with a ', ...
                'non-Document object.'])
        end
        do3 = PoDoc.Document([do1.buffer; do2.buffer]);
    end
end

methods(Access=protected)
    function out = bufferToPublish(do)
        %translate buffer to publish input.
        
        out = sprintf('%s\n', '%%%%');
        for i = 1:numel(do.buffer)
            out = [out, sprintf('%s %s\n', '%%', ...
                do.protectBS(do.buffer{i}))]; %#ok<AGROW>
        end
    end
end

methods(Static)
    function out = protectBS(str)
        out = strrep(str, '\', '\\');
    end
end

end
