classdef axisDialog < handle
%axisDialog is the PoTk GUI axis dialog window.

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

properties(Constant)
    defaultAxis = [-6, 6, -5, 5]
end

properties(SetAccess=protected)
    figureHandle
    axisHandle
end

properties(Access=protected)
    thisAxisHandle
    buttonPanel
    xPanel
    yPanel
    
    defaultButton
    applyButton
    closeButton
    
    xminEdit
    xminText
    xmaxEdit
    xmaxText
    yminEdit
    yminText
    ymaxEdit
    ymaxText
end % GUI components

properties(Access=protected,Constant)
    uiChar = {'units', 'characters'}
    uiNorm = {'units', 'normalized'}
    uiFonts = {'fontname', 'default', 'fontsize', 12}
    uiBgColor = {'backgroundcolor', 'white'}
    
    winWidth = 72.5
    winHeight = 38.25
    
    edw = 10
    edh = 5/3
    
    butw = 9
    buth = 2.5
end % GUI constants

properties(Access=private)
    amActive = true
end % State

methods
    function ad = axisDialog(axisHandle)
        if ~nargin
            return
        end
        
        ad.axisHandle = axisHandle;
        
        createFigure(ad)
        createPanels(ad)
        createButtons(ad)
        createEdits(ad)
    end
    
    function tf = isActive(ad)
        tf = ad.amActive;
    end
end

methods(Access=protected)
    function limh = axisEditHandles(ad)
        limh = [ad.xminEdit, ad.xmaxEdit, ad.yminEdit, ad.ymaxEdit];
    end
    
    function createButtons(ad)
        parent = {'parent', ad.buttonPanel};
        uistuff = [ad.uiFonts, ad.uiChar];
        ad.applyButton = uicontrol(parent{:}, ...
            'style', 'pushbutton', uistuff{:}, ...
            'string', 'Apply', ...
            'callback', @(h,e) clickApplyButton(ad, h, e));
        ad.closeButton = uicontrol(parent{:}, ...
            'style', 'pushbutton', uistuff{:}, ...
            'string', 'Close', ...
            'callback', @(h,e) clickCloseButton(ad, h, e));
        ad.defaultButton = uicontrol(parent{:}, ...
            'style', 'pushbutton', uistuff{:}, ...
            'string', 'Default', ...
            'callback', @(h,e) clickDefaultButton(ad, h, e));
        resizeButtonPanel(ad)
    end
    
    function createEdits(ad)
        axlim = axis(ad.axisHandle);
        
        parent = {'parent', ad.xPanel};
        uistuff = [ad.uiFonts, ad.uiBgColor, ad.uiChar];
        ad.xminEdit = uicontrol(parent{:}, ...
            'style', 'edit', uistuff{:}, ...
            'tag', 'xmin', ...
            'string', num2str(axlim(1)), ...
            'callback', @(h,e) editAxisValue(ad, h, e));
        ad.xminText = uicontrol(parent{:}, ...
            'style', 'text', uistuff{:}, ...
            'string', 'xmin');
        ad.xmaxEdit = uicontrol(parent{:}, ...
            'style', 'edit', uistuff{:}, ...
            'tag', 'xmax', ...
            'string', num2str(axlim(2)), ...
            'callback', @(h,e) editAxisValue(ad, h, e));
        ad.xmaxText = uicontrol(parent{:}, ...
            'style', 'text', uistuff{:}, ...
            'string', 'xmax');
        
        parent = {'parent', ad.yPanel};
        ad.yminEdit = uicontrol(parent{:}, ...
            'style', 'edit', uistuff{:}, ...
            'tag', 'ymin', ...
            'string', num2str(axlim(3)), ...
            'callback', @(h,e) editAxisValue(ad, h, e));
        ad.yminText = uicontrol(parent{:}, ...
            'style', 'text', uistuff{:}, ...
            'string', 'ymin');
        ad.ymaxEdit = uicontrol(parent{:}, ...
            'style', 'edit', uistuff{:}, ...
            'tag', 'ymax', ...
            'string', num2str(axlim(4)), ...
            'callback', @(h,e) editAxisValue(ad, h, e));
        ad.ymaxText = uicontrol(parent{:}, ...
            'style', 'text', uistuff{:}, ...
            'string', 'ymax');
        
        resizeXPanel(ad)
        resizeYPanel(ad)
    end
    
    function createFigure(ad)
        units = get(0, 'units');
        set(0, ad.uiChar{:})
        ssz = get(0, 'screensize');
        set(0, 'units', units)        
        figwh = [ad.winWidth, ad.winHeight];
        fpos = [(ssz(3:4) - figwh)/2, figwh];
        
        fh = figure('color', 'white', ...
            'name', 'Axis limits', 'numbertitle', 'off', ...
            'menubar', 'none', 'toolbar', 'none', 'resize', 'off', ...
            ad.uiChar{:}, 'position', fpos, ...
            'deletefcn', @(h, e) deleteFigure(ad, h, e), ...
            'keypressfcn', @(h, e) onKeyPress(ad, h, e));

        ad.figureHandle = fh;
        guidata(fh, ad)
    end
    
    function createPanels(ad)
        parent = {'parent', ad.figureHandle};
        uiset = [ad.uiNorm, ad.uiFonts, ad.uiBgColor];
        
        ah = axes(parent{:}, ...
            ad.uiNorm{:}, ...
            'outerposition', [0.2, 0.271, 0.8, 0.729]);
        ad.thisAxisHandle = ah;
        axis(ah, axis(ad.axisHandle))
        apos = get(ah, 'position');
        
        ad.xPanel = uipanel(parent{:}, uiset{:}, ...
            'title', [], 'bordertype', 'none', ...
            'position', [apos(1), 0.161, apos(3), 0.105]);
        ad.yPanel = uipanel(parent{:}, uiset{:}, ...
            'title', [], 'bordertype', 'none', ...
            'position', [0.032, apos(2), 0.182, apos(4)]);
        ad.buttonPanel = uipanel(parent{:}, uiset{:}, ...
            'title', [], 'bordertype', 'none', ...
            'position', [0, 0, 1, 0.142]);
    end
    
    function clickApplyButton(ad, ~, ~)
        oldax = axis(ad.axisHandle);
        eh = axisEditHandles(ad);
        axlim = 1:4;
        try
            for j = 1:4
                axlim(j) = str2double(get(eh(j), 'string'));
            end
            axis(ad.axisHandle, axlim)
        catch
            for j = 1:4
                set(eh(j), sprintf('%.3g', oldax(j)))
            end
        end
    end
    
    function clickCloseButton(ad, ~, ~)
        close(ad.figureHandle)
    end
    
    function clickDefaultButton(ad, ~, ~)
        axlim = ad.defaultAxis;
        axis(ad.thisAxisHandle, axlim)
        eh = axisEditHandles(ad);
        for j = 1:4
            set(eh(j), 'string', sprintf('%.3g', axlim(j)))
        end
    end
    
    function deleteFigure(ad, ~, ~)
        ad.amActive = false;
    end
    
    function editAxisValue(ad, objh, ~)
        switch get(objh, 'tag')
            case 'xmin'
                j = 1;
            case 'xmax'
                j = 2;
            case 'ymin'
                j = 3;
            case 'ymax'
                j = 4;
        end
        ah = ad.thisAxisHandle;
        oldax = axis(ah);
        newax = oldax;
        limh = axisEditHandles(ad);
        try
            value = str2double(get(limh(j), 'string'));
            newax(j) = value;
            axis(ah, newax)
        catch
            axis(ah, oldax)
            set(limh(j), 'string', sprintf('%.3g', oldax(j)))
        end
    end
    
    function onKeyPress(ad, ~, evt)
        switch evt.Key
            case 'escape'
                ad.amActive = false;
                close(ad.figureHandle)
        end
    end
    
    function resizeButtonPanel(ad, ~, ~)
        ppos = PoG.mainWin.getInUnit(...
            ad.buttonPanel, 'characters', 'position');
        bpos = get(ad.closeButton, 'position');
        bpos = [ppos(3)-5-bpos(3), (ppos(4)-bpos(4))/2, ad.butw, ad.buth];
        set(ad.closeButton, 'position', bpos)
        bpos = [bpos(1)-4-bpos(3), bpos(2:4)];
        set(ad.applyButton, 'position', bpos)
        bpos = [bpos(1)-4-bpos(3), bpos(2:4)];
        set(ad.defaultButton, 'position', bpos)
    end
    
    function resizeXPanel(ad, ~, ~)
        ppos = PoG.mainWin.getInUnit(...
            ad.xPanel, 'characters', 'position');
        epos = get(ad.xminEdit, 'position');
        tpos = get(ad.xminText, 'position');
        
        epos = [0, ppos(4)-epos(4), ad.edw, ad.edh];
        set(ad.xminEdit, 'position', epos)
        tpos = [(epos(3)-tpos(3))/2, epos(2)-tpos(4), tpos(3:4)];
        set(ad.xminText, 'position', tpos)
        
        epos = [ppos(3)-epos(3), epos(2:4)];
        set(ad.xmaxEdit, 'position', epos)
        tpos = [epos(1)+(epos(3)-tpos(3))/2, tpos(2:4)];
        set(ad.xmaxText, 'position', tpos)
    end
    
    function resizeYPanel(ad, ~, ~)
        ppos = PoG.mainWin.getInUnit(...
            ad.yPanel, 'characters', 'position');
        epos = get(ad.yminEdit, 'position');
        tpos = get(ad.yminText, 'position');
        
        epos = [(ppos(3)-epos(3))/2, 0, ad.edw, ad.edh];
        set(ad.yminEdit, 'position', epos)
        tpos = [epos(1)+(epos(3)-tpos(3))/2, epos(2)+epos(4), tpos(3:4)];
        set(ad.yminText, 'position', tpos)
        
        epos = [epos(1), ppos(4)-epos(4), epos(3:4)];
        set(ad.ymaxEdit, 'position', epos)
        tpos = [tpos(1), epos(2)-tpos(4), tpos(3:4)];
        set(ad.ymaxText, 'position', tpos)
    end
end

end
