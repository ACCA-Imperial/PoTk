classdef mainWin < handle
%mainWin is the PoTk GUI.

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
    circles = {}
    circulation
    vortices
    strength
    potentialObject
    flowStrength = 0.1
    flowAngle = 0
end % Domain settings

properties(Access=protected)
    figureHandle
    axesHandle
    
    buttonPanel
    plotPanel
    controlPanel
    
    axisButton
    resetButton
    deleteButton
    moveButton
    importButton
    exportButton
    plotButton
    streamCheck
    velocityCheck
    
    editXmin
    editXmax
    editYmin
    editYmax
    
    flowPanel
    editFlowStrength
    textFlowStrength
    editFlowAngle
    textFlowAngle
    
    islandTable
    vortexTable
    
    axisDialog
end % GUI components

properties(Access=protected, Constant)
    eit = exp(2i*pi*(0:200)'/200)

    uiBgColor = {'backgroundcolor', 'white'}
    uiFontName = {'fontname', 'default'};
    uiFontSize = {'fontsize', 12};
    uiButh = 2.5;

    uNorm = 'normalized';
    uPixel = 'pixels';
    uChar = 'characters';
end

properties(Access=private)
    dirtyDomain = true
    opState = PoG.opStates.none
    
    tmpCenter
    tmpChandle
    tmpXhandle
    tmpSelection = {}
end % State and temporary

methods
    function pg = mainWin(state, adomain)
        if ~nargin
            return
        end
        
        if strcmp(state, 'run')
            createFigureAndAxes(pg)
            createButtons(pg)
            createFlowPanel(pg)
            createIslandPanel(pg)
            createVortexPanel(pg)
            postCreateSetup(pg)
            
            if nargin > 1
                if ~isa(adomain, 'potentialDomain')
                    error(PoTk.ErrorTypeString.InvalidArgument, ...
                        ['Expected a potentialDomain object, ' ...
                        'got a "%s" object instead.'], class(adomain))
                end
                readInputDomain(pg, adomain)
            end
        end
    end
    
    function disp(~)
        fprintf(['\n  <a href="matlab:helpPopup mainWin">' ...
            'mainWin</a> is the potential toolkit GUI class.\n\n'])
    end
end

methods(Access=protected)
    %---------------------------------------
    function addCircle(pg, newCircle)
        pg.circles{end+1} = newCircle;
        pg.circulation(end+1) = 0;
        updateIslandTable(pg)
        pg.dirtyDomain = true;
        redrawDomain(pg)
    end
    
    function beginAddingCircle(pg, c)
        pg.opState = PoG.opStates.addingCircle;
        set(pg.figureHandle, ...
            'windowbuttonmotionfcn', @(h,e) onMouseMove(pg, h, e))
        pg.tmpXhandle = ...
            line(real(c), imag(c), 'marker', 'x', 'color', 'k');
        pg.tmpCenter = c;
    end
    
    function stopAddingCircle(pg, c)
        % Finish adding circle.
        pg.opState = PoG.opStates.none;
        set(pg.figureHandle, 'windowbuttonmotionfcn', '')
        
        if nargin > 1
            r = abs(pg.tmpCenter - c);
            if r > 0
                addCircle(pg, circle(pg.tmpCenter, r));
            end
        end
        
        if ishandle(pg.tmpChandle)
            delete(pg.tmpChandle)
            pg.tmpChandle = [];
        end
        if ishandle(pg.tmpXhandle)
            delete(pg.tmpXhandle)
            pg.tmpXhandle = [];
        end
    end
    
    %---------------------------------------
    function addVortex(pg, newVortex)
        % Add vortex.                    
        pg.vortices(end+1) = newVortex;
        pg.strength(end+1) = 1;
        updateVortexTable(pg)
        pg.dirtyDomain = true;
        redrawDomain(pg)
    end
    
    %---------------------------------------
    function deleteThing(pg, c)
        selectThing(pg, c)
        
        if isempty(pg.tmpSelection)
            return
        end
        
        switch pg.tmpSelection{1}
            case 'c'
                j = pg.tmpSelection{2};
                L = true(size(pg.circles));
                L(j) = false;
                pg.circles = pg.circles(L);
                pg.circulation = pg.circulation(L);
                updateIslandTable(pg)
                pg.dirtyDomain = true;
                
            case 'v'
                k = pg.tmpSelection{2};
                L = true(size(pg.vortices));
                L(k) = false;
                pg.vortices = pg.vortices(L);
                pg.strength = pg.strength(L);
                updateVortexTable(pg)
                pg.dirtyDomain = true;
        end        
        if pg.dirtyDomain
            pg.tmpSelection = {};
            redrawDomain(pg)
        end
        
        stopDeleting(pg)
    end
    
    function stopDeleting(pg)
        pg.opState = PoG.opStates.none;
        setMouseCursorToNormal(pg)
    end    
    
    %---------------------------------------
    function beginMovingThing(pg)
        if isempty(pg.tmpSelection)
            return
        end
        
        set(pg.figureHandle, ...
            'windowbuttonmotionfcn', @(h,e) onMouseMove(pg, h, e), ...
            'windowbuttonupfcn', @(h,e) onMouseButtonUp(pg, h, e))
    end
    
    function moveThing(pg, z)
        if isempty(pg.tmpSelection)
            return
        end
        
        j = pg.tmpSelection{2};
        switch pg.tmpSelection{1}
            case 'c'
                dz = z - pg.tmpSelection{3};
                newc = pg.circles{j}.center + dz;
                pg.circles{j} = circle(newc, pg.circles{j}.radius);
                pg.tmpSelection{3} = z;
                updateIslandTable(pg)
                
            case 'v'
                pg.vortices(j) = z;
                updateVortexTable(pg)
        end
        pg.dirtyDomain = true;
        redrawDomain(pg)
    end
    
    function selectThing(pg, c)
        C = circleRegion(pg.circles, 'noCheck');
        if ~isempty(pg.circles)
            d = C.centers;
            r = C.radii;
            [cdist, j] = min(abs(c - d) - r);
            cdist = abs(cdist);
        else
            cdist = inf;
            j = 0;
        end
        if any(pg.vortices)
            [vdist, k] = min(abs(c - pg.vortices(:)));
        else
            vdist = inf;
            k = 0;
        end
        
        % Select threshold. 
        thresh = axis(pg.axesHandle);
        thresh = 0.075*max(diff(thresh([1,2])), diff(thresh([3,4])));        
        function clickMsg()
            msgbox(['Click near a circle boundary or point vortex ' ...
                'location to select.'])
        end
        
        if cdist < vdist
            if cdist > thresh
                clickMsg()
                return
            end
            pg.tmpSelection = {'c', j, c};
        elseif vdist < cdist
            if vdist > thresh
                clickMsg()
                return
            end
            pg.tmpSelection = {'v', k};
        end
    end
    
    function stopMoving(pg)
        set(pg.figureHandle, ...
            'windowbuttonmotionfcn', [], ...
            'windowbuttonupfcn', [])
        pg.tmpSelection = {};
        pg.opState = PoG.opStates.none;
        setMouseCursorToNormal(pg)
    end
    
    %---------------------------------------
    function createFigureAndAxes(pg)
        ssz = pg.getInUnit(0, pg.uPixel, 'screensize');
        figwh = [985, 620];
        fpos = [(ssz(3:4) - figwh)/2, figwh];
        fh = figure('color', 'white', ...
            'name', 'Potential Toolkit GUI', ...
            'numbertitle', 'off', 'visible', 'off', ...
            'windowbuttondownfcn', @(h,e) onMouseClick(pg, h, e), ...
            'windowkeypressfcn', @(h,e) onKeyPress(pg, h, e), ...
            'deletefcn', @(h, e) onDeleteFigure(pg, h, e));        
        pg.setInUnit(fh, pg.uPixel, 'position', fpos)
        pg.figureHandle = fh;
        guidata(fh, pg);
        
        ah = axes('parent', fh, 'fontsize', 14, ...
            'box', 'on', 'dataaspectratio', [1 1 1]);
        pg.setInUnit(ah, pg.uNorm, ...
            'outerposition', [0, 0, 0.700, 0.900])
        grid(ah, 'on')
        axis(ah, PoG.axisDialog.defaultAxis);
        pg.axesHandle = ah;

        pg.buttonPanel = uipanel(...
            'parent', pg.figureHandle, ...
            'bordertype', 'none', 'title', [], ...
            'units', pg.uChar, pg.uiBgColor{:});
        pg.plotPanel = uipanel(...
            'parent', pg.figureHandle, ...
            'bordertype', 'none', 'title', [], ...
            'units', pg.uChar, pg.uiBgColor{:});
        pg.controlPanel = uipanel(...
            'parent', pg.figureHandle, ...
            'bordertype', 'none', 'title', [], ...
            'units', pg.uChar, pg.uiBgColor{:});
    end
    
    function createButtons(pg)
        pg.axisButton = uicontrol(...
            'parent', pg.buttonPanel, 'style', 'pushbutton', ...
            'string', 'Axis', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h, e) onClickAxisButton(pg, h, e));
        pg.resetButton = uicontrol(...
            'parent', pg.buttonPanel, 'style', 'pushbutton', ...
            'string', 'Reset', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h,e) onClickReset(pg, h, e));
        pg.deleteButton = uicontrol(...
            'parent', pg.buttonPanel, 'style', 'pushbutton', ...
            'string', 'Delete', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h, e) onClickDelete(pg, h, e));
        pg.moveButton = uicontrol(...
            'parent', pg.buttonPanel, 'style', 'pushbutton', ...
            'string', 'Move', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h,e) onClickMove(pg, h, e));
        pg.exportButton = uicontrol(...
            'parent', pg.buttonPanel, 'style', 'pushbutton', ...
            'string', 'Export', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h,e) onClickExport(pg, h, e));
        pg.importButton = uicontrol(...
            'parent', pg.buttonPanel, 'style', 'pushbutton', ...
            'string', 'Import', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h,e) onClickImport(pg, h, e));
        pg.plotButton = uicontrol(...
            'parent', pg.plotPanel, 'style', 'pushbutton', ...
            'string', 'Plot', pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'callback', @(h,e) onClickPlot(pg, h, e));
        pg.streamCheck = uicontrol(...
            'parent', pg.plotPanel, 'style', 'checkbox', ...
            'string', 'Stream lines', ...
            'max', 1, 'min', 0, 'value', 1, ...
            pg.uiFontName{:}, pg.uiFontSize{:}, pg.uiBgColor{:});
        pg.velocityCheck = uicontrol(...
            'parent', pg.plotPanel, 'style', 'checkbox', ...
            'string', 'Velocity field', ...
            'max', 1, 'min', 0, 'value', 0, ...
            pg.uiFontName{:}, pg.uiFontSize{:}, pg.uiBgColor{:});
    end
    
    function createIslandPanel(pg)
        islandPanel = uipanel('parent', pg.controlPanel, ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'title', 'Islands');
        pg.setInUnit(islandPanel, pg.uNorm, ...
            'position', [0, 3/8, 1, 3/8])
        pg.islandTable = uitable('parent', islandPanel, ...
            'units', pg.uNorm, 'position', [0, 0, 1, 0.95], ...
            'celleditcallback', @(h,e) onEditIsland(pg, h, e));
        set(pg.islandTable,...
            'columnname', {'Circulation', 'Center', 'Radius'}, ...
            'columnformat', {'numeric', 'numeric', 'numeric'}, ...
            'columneditable', [true, true, true]);        
    end
    
    function createVortexPanel(pg)
        vortexPanel = uipanel('parent', pg.controlPanel, ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'title', 'Vortices');
        pg.setInUnit(vortexPanel, pg.uNorm, ...
            'position', [0, 0, 1, 3/8])
        pg.vortexTable = uitable('parent', vortexPanel, ...
            'units', pg.uNorm, 'position', [0, 0, 1, 0.95], ...
            'celleditcallback', @(h,e) onEditVortex(pg, h, e));
        set(pg.vortexTable,...
            'columnname', {'Strength', 'Location'}, ...
            'columnformat', {'numeric', 'numeric'}, ...
            'columneditable', [true, true])
    end
        
    function createFlowPanel(pg)
        fph = uipanel('parent', pg.controlPanel, ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'title', 'Background flow');
        pg.flowPanel = fph;
        pg.setInUnit(fph, pg.uNorm, ...
            'position', [1/8, 3/4, 3/4, 1/4])
        pg.editFlowStrength = uicontrol(...
            'style', 'edit', 'parent', fph, ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'string', sprintf('%.3g', pg.flowStrength), ...
            'callback', @(h, e) onEditFlowStrength(pg, h, e));
        pg.textFlowStrength = uicontrol(...
            'style', 'text', 'parent', fph, ...
            'string', 'Strength', ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'horizontalalignment', 'right');
        pg.editFlowAngle = uicontrol(...
            'style', 'edit', 'parent', fph, ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'string', sprintf('%.3g*pi', pg.flowAngle), ...
            'callback', @(h, e) onEditFlowAngle(pg, h, e));
        pg.textFlowAngle = uicontrol(...
            'style', 'text', 'parent', fph, ...
            'string', 'Angle', ...
            pg.uiBgColor{:}, pg.uiFontName{:}, pg.uiFontSize{:}, ...
            'horizontalalignment', 'right');
    end
    
    function postCreateSetup(pg)
        set(pg.flowPanel, ...
            'resizefcn', @(h, e) onResizeFlowPanel(pg, h, e))
        set(pg.buttonPanel, ...
            'resizefcn', @(h, e) onResizeButtonPanel(pg, h, e))
        set(pg.plotPanel, ...
            'resizefcn', @(h, e) onResizePlotPanel(pg, h, e))
        set(pg.figureHandle, ...
            'resizefcn', @(h, e) onResizeWindow(pg, h, e))
        set(pg.figureHandle, 'toolbar', 'figure', 'visible', 'on')
        drawnow
    end
    
    %---------------------------------------
    function onClickAxisButton(pg, ~, ~)
        ad = pg.axisDialog;
        if isempty(ad) || ~isActive(ad)
            pg.axisDialog = PoG.axisDialog(pg.axesHandle);
        else
            figure(ad.figureHandle)
        end
    end
    
    function onClickDelete(pg, ~, ~)
        resetOpState(pg) 
        if isempty(pg.circles) && isempty(pg.vortices)
            return
        end
        
        pg.opState = PoG.opStates.deleting;
        setMouseCursorToDelete(pg)
    end
    
    function onClickExport(pg, ~, ~)
        resetOpState(pg)
        
        prompt = {'Flow region variable', 'Potential object variable'};
        dtitle = 'Export variables to workspace.';
        defs = {'Df', 'W'};
        answer = inputdlg(prompt, dtitle, 1, defs);
        if isempty(answer)
            return
        end

        pd = setPhysicalDomain(pg);
        assignin('base', answer{1}, pd);
        updatePotential(pg)
        assignin('base', answer{2}, pg.potentialObject);
    end
    
    function onClickImport(pg, ~, ~)
        resetOpState(pg)
        
        prompt = {'Flow region variable'};
        dtitle = 'Import variable from workspace.';
        defs = {'Df'};
        answer = inputdlg(prompt, dtitle, 1, defs);
        if isempty(answer)
            return
        end
        
        try
            physdom = evalin('base', answer{1});
        catch err
            msg = sprintf(...
                'Variable not imported, error detected:\n%s', err.message);
            uiwait(msgbox(msg, 'Variable import error', 'error'))
            return
        end
        readPhysicalDomain(pg, physdom);
    end
    
    function onClickMove(pg, ~, ~)
        resetOpState(pg)
        if isempty(pg.circles) && isempty(pg.vortices)
            return
        end
        
        pg.opState = PoG.opStates.moving;
        setMouseCursorToMove(pg)
    end
    
    function onClickReset(pg, ~, ~)
        resetOpState(pg)
        
        pg.circles = {};
        pg.circulation = [];
        pg.vortices = [];
        pg.strength = [];
        pg.flowStrength = 1;
        pg.flowAngle = 0;
        pg.dirtyDomain = true;
        
        update(pg)
        
        cla
        axis(pg.axesHandle, PoG.axisDialog.defaultAxis)
        grid on
    end
    
    function onClickPlot(pg, ~, ~)
        resetOpState(pg)
        
        whichPlot = ...
            get(pg.streamCheck, 'value') + 2*get(pg.velocityCheck, 'value');
        if ~whichPlot
            return
        end
        
        updatePotential(pg)
        W = pg.potentialObject;
        if isempty(W)
            return
        end
        
        cla
        grid off
        hold on
        % Appropriate plot here.
        switch whichPlot
            case 1 % streamlines only
                plotStreamLines(W)
            case 2 % velocity field only
                plotVelocityField(W, 'noStreamLines')
            case 3 % both
                plotVelocityField(W)
        end
        numberIslandsAndVortices(pg)
        hold off
    end
    
    function onDeleteFigure(pg, ~, ~)
        ad = pg.axisDialog;
        if ~isempty(ad) && isActive(ad)
            close(ad.figureHandle)
        end
    end
    
    function onEditFlowAngle(pg, objh, ~)
        resetOpState(pg)
        
        try
            value = eval(get(objh, 'string'));
            if numel(value) == 1 && isfinite(value) && imag(value) == 0
                pg.flowAngle = mod(value, 2*pi);
                if pg.flowStrength ~= 0
                    pg.dirtyDomain = true;
                    redrawDomain(pg)
                end
            end
        catch
            % Ignore. Probably bad value given to eval.
        end
        updateFlowAngleEdit(pg)
    end
    
    function onEditFlowStrength(pg, objh, ~)
        resetOpState(pg)
        
        try
            value = eval(get(objh, 'string'));
            if numel(value) && isfinite(value)
                pg.flowStrength = value;                
                pg.dirtyDomain = true;
                redrawDomain(pg)
            end
        catch
            % Just ignore errors. Assume eval was given bad value.
        end
        updateFlowStrengthEdit(pg)
    end
    
    function onEditIsland(pg, ~, edata)
        resetOpState(pg)
        
        dat = edata.NewData;
        j = edata.Indices(1);
        k = edata.Indices(2);
        changed = false;
        
        if isfinite(dat)
            if k == 1
                if isfinite(dat) && imag(dat) == 0
                    pg.circulation(j) = dat;
                    changed = true;
                end
            else
                circ = pg.circles{j};
                switch k
                    case 2
                        circ = circle(dat, circ.radius);
                        changed = true;
                        
                    case 3
                        if dat > 0
                            circ = circle(circ.center, dat);
                            changed = true;
                        end
                end
                pg.circles{j} = circ;
            end
        end
        
        if changed
            pg.dirtyDomain = true;
            redrawDomain(pg)
        else
            updateIslandTable(pg)
        end
    end
    
    function onEditVortex(pg, ~, edata)
        resetOpState(pg)
        
        dat = edata.NewData;
        k = edata.Indices(1);
        changed = false;
        
        if isfinite(dat)
            if edata.Indices(2) == 1
                pg.strength(k) = dat;
                changed = true;
            else
                pg.vortices(k) = dat;
                changed = true;
            end
        end
        
        if changed
            pg.dirtyDomain = true;
            redrawDomain(pg)
        else
            updateVortexTable(pg)
        end
    end
    
    function onKeyPress(pg, ~, edata)
        switch edata.Key
            case 'escape'
                resetOpState(pg)
                
            case 'f5'
                uicontrol(pg.plotButton)
                drawnow
                onClickPlot(pg)
        end
    end
    
    function onMouseClick(pg, ~, ~)
        pt = get(pg.axesHandle, 'currentpoint');
        x = pt(1,1);
        y = pt(1,2);
        axlim = axis(pg.axesHandle);
        if x < axlim(1) || axlim(2) < x || y < axlim(3) || axlim(4) < y
            % Not in axis.
            return
        end
        c = complex(x, y);
        
        switch pg.opState
            case PoG.opStates.none
                switch get(pg.figureHandle, 'selectiontype')
                    case 'normal'
                        beginAddingCircle(pg, c)
                        
                    case 'extend' % shift-key pressed
                        addVortex(pg, c)
                end

            case PoG.opStates.addingCircle
                stopAddingCircle(pg, c)
                
            case PoG.opStates.deleting
                deleteThing(pg, c)
                
            case PoG.opStates.moving
                selectThing(pg, c)
                beginMovingThing(pg)
        end
    end    
    
    function onMouseMove(pg, ~, ~)
        pt = get(pg.axesHandle, 'currentpoint');
        z = complex(pt(1,1), pt(1,2));
        
        switch pg.opState
            case PoG.opStates.addingCircle
                if ~isempty(pg.tmpChandle) && ishandle(pg.tmpChandle)
                    delete(pg.tmpChandle)
                end
                
                r = abs(pg.tmpCenter - z);
                circ = pg.tmpCenter + r*pg.eit;
                pg.tmpChandle = line(real(circ), imag(circ), ...
                    'color', 'r', 'linestyle', '-');
                
            case PoG.opStates.moving
                moveThing(pg, z)
                
            otherwise
                set(pg.figureHandle, 'windowbuttonmotionfcn', '')
                return
        end 
    end
    
    function onMouseButtonUp(pg, ~, ~)
        stopMoving(pg)
    end
    
    function onResizeButtonPanel(pg, ~, ~)
        pos = [0, 0, 10, pg.uiButh];
        pg.setInUnit(pg.axisButton, pg.uChar, 'position', pos)
        pos = [sum(pos([1,3]))+2, pos(2:4)];
        pg.setInUnit(pg.resetButton, pg.uChar, 'position', pos)
        pos = [sum(pos([1,3]))+2, pos(2:4)];
        pg.setInUnit(pg.deleteButton, pg.uChar, 'position', pos)
        pos = [sum(pos([1,3]))+2, pos(2:4)];
        pg.setInUnit(pg.moveButton, pg.uChar, 'position', pos)
        
        pos = pg.getInUnit(pg.buttonPanel, pg.uChar, 'position');
        pos = [pos(3)-11, 0, 11, pg.uiButh];
        pg.setInUnit(pg.exportButton, pg.uChar, 'position', pos)
        pos = [pos(1)-13, pos(2:4)];
        pg.setInUnit(pg.importButton, pg.uChar, 'position', pos)
    end
    
    function onResizeFlowPanel(pg, ~, ~)
        ew = 10;
        eh = 5/3;
        tw = 8;
        panelPos = pg.getInUnit(pg.flowPanel, pg.uChar, 'position');
        offx = (panelPos(3) - tw - ew)/3;
        offy = (panelPos(4) - 2*eh)/3;
        
        pg.setInUnit(pg.textFlowAngle, pg.uChar, ...
            'position', [offx, offy, tw, eh])
        pg.setInUnit(pg.editFlowAngle, pg.uChar, ...
            'position', [2*offx+tw, offy, ew, eh])
        pg.setInUnit(pg.textFlowStrength, pg.uChar, ...
            'position', [offx, 2*offy+eh, tw, eh])
        pg.setInUnit(pg.editFlowStrength, pg.uChar, ...
            'position', [2*offx+tw, 2*offy+eh, ew, eh])
    end
    
    function onResizePlotPanel(pg, ~, ~)
        ppos = pg.getInUnit(pg.plotPanel, pg.uChar, 'position');
        twid = 10 + 4 + 20;
        
        pos = (ppos(3) - twid)/2;
        pos = [pos, (ppos(4)-pg.uiButh)/2, 10, pg.uiButh];
        pg.setInUnit(pg.plotButton, pg.uChar, 'position', pos)
        
        pos = [pos(1)+14, pg.uiButh/2, 20, pos(4)];
        pg.setInUnit(pg.velocityCheck, pg.uChar, 'position', pos)
        
        pos = [pos(1), pos(2)+pg.uiButh, 20, pos(4)];
        pg.setInUnit(pg.streamCheck, pg.uChar, 'position', pos)
    end
    
    function onResizeWindow(pg, ~, ~)
        fpos = pg.getInUnit(pg.figureHandle, pg.uChar, 'position');
        aipos = pg.getInUnit(pg.axesHandle, pg.uChar, 'position');
        
        pos = [aipos(1)-3, fpos(4)-5, aipos(3)+3, 5];
        pg.setInUnit(pg.buttonPanel, pg.uChar, 'position', pos)
        
        xpos = aipos(1)+aipos(3)+6.5;
        pos = [xpos, pos(2)-pg.uiButh, fpos(3)-xpos-6.5, 5+pg.uiButh];
        pg.setInUnit(pg.plotPanel, pg.uChar, 'position', pos)

        pos = [pos(1), aipos(2)-1, pos(3), aipos(4)+1];
        pg.setInUnit(pg.controlPanel, pg.uChar, 'position', pos)
    end

    function setMouseCursorToDelete(pg)
        set(pg.figureHandle, 'pointer', 'custom', ...
            'pointershapecdata', pg.makeXPointer(), ...
            'pointershapehotspot', [9, 9])
    end
    
    function setMouseCursorToMove(pg)
        set(pg.figureHandle, 'pointer', 'hand')
    end
    
    function setMouseCursorToNormal(pg)
        set(pg.figureHandle, 'pointer', 'arrow')
    end
    
    %---------------------------------------
    function update(pg)
        updateFlowStrengthEdit(pg)
        updateFlowAngleEdit(pg)
        updateIslandTable(pg)
        updateVortexTable(pg)
    end
    
    function updateFlowAngleEdit(pg, value)
        if nargin < 2
            value = pg.flowAngle;
        end
        set(pg.editFlowAngle, 'string', sprintf('%.3g*pi', value/pi))
    end
    
    function updateFlowStrengthEdit(pg, value)
        if nargin < 2
            value = pg.flowStrength;
        end
        set(pg.editFlowStrength, 'string', sprintf('%.3g', value))
    end
    
    function updateIslandTable(pg)
        m = numel(pg.circles);
        islandData = cell(m, 3);
        for j = 1:m
            islandData(j,:) = {pg.circulation(j), ...
                pg.circles{j}.center, pg.circles{j}.radius};
        end
        set(pg.islandTable, 'data', islandData)
    end

    function updatePotential(pg)
        if ~pg.dirtyDomain
            return
        end
        if isempty(pg.circles) && isempty(pg.vortices) && ~pg.flowStrength
            pg.potentialObject = [];
            return
        end
        physDomain = setPhysicalDomain(pg);
        if isempty(physDomain)
            pg.potentialObject = [];
            return
        end
        pg.potentialObject = potential(physDomain, 'useWaitBar', true);
        pg.dirtyDomain = false;
    end
    
    function updateVortexTable(pg)
        n = numel(pg.vortices);
        vortexData = cell(n, 2);
        for k = 1:n
            vortexData(k,:) = {pg.strength(k), pg.vortices(k)};
        end
        set(pg.vortexTable, 'data', vortexData)
    end
    
    %---------------------------------------
    function redrawDomain(pg)
        cla
        hold on
        for j = 1:numel(pg.circles)
            plot(pg.circles{j})
        end
        for k = 1:numel(pg.vortices)
            v = pg.vortices(k);
            plot(real(v), imag(v), 'k.', 'markersize', 18)
        end
        numberIslandsAndVortices(pg)
        hold off
        grid on
    end
    
    function numberIslandsAndVortices(pg)
        C = circleRegion(pg.circles{:});
        fd = regionExt(...
            C.centers, ...
            C.radii, ...
            zeros(1, numel(pg.circles)), ...
            pg.vortices, ...
            zeros(1, numel(pg.vortices)));
        numberBoundaries(fd)
    end
    
    function readInputDomain(pg, ~)
        %Read input domain, fill out proper information.
%         pg.circles = boundary(circleRegion(physdom));
%         pg.circulation = physdom.circulation;
%         pg.vortices = physdom.singularities;
%         pg.strength = physdom.singStrength;
%         pg.flowStrength = physdom.uniformStrength;
%         pg.flowAngle = physdom.uniformAngle;
%         pg.dirtyDomain = true;
        
        update(pg)
        redrawDomain(pg)
    end
    
    function resetOpState(pg)
        switch pg.opState
            case PoG.opStates.addingCircle
                stopAddingCircle(pg)
                
            case PoG.opStates.deleting
                stopDeleting(pg)
                
            case PoG.opStates.moving
                stopMoving(pg)
        end
        pg.opState = PoG.opStates.none;
    end
    
    function pd = setPhysicalDomain(pg)
        try
            C = circleRegion(pg.circles);
            pd = regionExt(...
                C.centers, C.radii, pg.circulation, ...
                pg.vortices, pg.strength, pg.flowStrength, pg.flowAngle);
        catch err
            switch err.identifier
                case {PoTk.ErrorTypeString.UndefinedState, ...
                        'CMT:InvalidArgument'}
                    uiwait(msgbox(err.message, 'Invalid domain', 'error'))
                    pd = [];
                    return
                otherwise
                    rethrow(err)
            end
        end
    end
end

methods(Static,Hidden)
    function out = getInUnit(objh, units, prop)
        out = PoG.mainWin.doInUnit(objh, units, @() get(objh, prop));
    end
    
    function setInUnit(objh, units, prop, value)
        PoG.mainWin.doInUnit(objh, units, @() set(objh, prop, value))
    end
    
    function out = doInUnit(objh, units, dofunh)
        oldUnit = get(objh, 'units');
        if strcmp(oldUnit, units)
            sameUnits = true;
        else
            sameUnits = false;
        end
        
        if ~sameUnits
            set(objh, 'units', units)
        end
        
        if nargout
            out = dofunh();
        else
            dofunh();
        end
        
        if ~sameUnits
            set(objh, 'units', oldUnit)
        end
    end
    
    %---------------------------------------
    function ptr = makeXPointer()
        ptr = diag(ones(15,1), -1) + diag(ones(16,1)) + diag(ones(15,1), 1);
        ptr = double(ptr | fliplr(ptr));
        ptr(ptr == 0) = nan;
    end
end

end
