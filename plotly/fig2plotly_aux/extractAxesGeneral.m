function [xaxes, yaxes] = extractAxesGeneral(axhan, a, layout, xaxes, yaxes, strip_style)
% extractAxesGeneral - copy general axes struct attributes
%   [xaxes, yaxes] = extractAxesGeneral(a, layout, xaxes, yaxes)
%       a - a data struct from matlab describing an axes
%       layout - a plotly layout strcut
%       x_axis, y_axis - axis objects
%
% For full documentation and examples, see https://plot.ly/api

%POSITION

%small domain offsets due to top margin (needed for title) 
deltaYT = onePlot(get(a.Parent))*(layout.margin.t)/layout.height;

%assumes units are normalized!
xaxes.domain = [a.Position(1) a.Position(1)+a.Position(3)]; 
yaxes.domain = [a.Position(2) a.Position(2)+a.Position(4)+deltaYT];

if yaxes.domain(1)>1
    yaxes.domain(1)=1;
end
if yaxes.domain(2)>1
    yaxes.domain(2)=1;
end
xaxes.side = a.XAxisLocation;
yaxes.side = a.YAxisLocation;

if ~strip_style
    xaxes.showline = true;
    yaxes.showline = true;
    %TICKS
    if strcmp(a.TickDir, 'in')
        xaxes.ticks = 'inside';
        yaxes.ticks = 'inside';
    else
        xaxes.ticks = 'outside';
        yaxes.ticks = 'outside';
    end
    total_length = max(layout.height*(yaxes.domain(2)-yaxes.domain(1)), ...
        layout.width*(xaxes.domain(2)-xaxes.domain(1)))*a.TickLength(1);
    xaxes.ticklen = total_length;
    yaxes.ticklen = total_length;
    if strcmp(a.Box,'on')
        xaxes.mirror = 'ticks';
        yaxes.mirror = 'ticks';
    else
        xaxes.mirror = false;
        yaxes.mirror = false;
    end
    
    
    if strcmp(a.FontUnits, 'points')
        xaxes.tickfont.size = a.FontSize;
        yaxes.tickfont.size = a.FontSize;
    end
    
    %LINES
    if strcmp(a.XGrid, 'on') || strcmp(a.XMinorGrid, 'on')
        xaxes.showgrid = true;
    else
        xaxes.showgrid = false;
    end
    if strcmp(a.YGrid, 'on') || strcmp(a.YMinorGrid, 'on')
        yaxes.showgrid = true;
    else
        yaxes.showgrid = false;
    end
    xaxes.zeroline = false;
    yaxes.zeroline = false;
    
    %COLORS
    xaxes.linecolor = parseColor(a.XColor);
    xaxes.tickcolor = parseColor(a.XColor);
    xaxes.tickfont.color = parseColor(a.XColor);
    yaxes.linecolor = parseColor(a.YColor);
    yaxes.tickcolor = parseColor(a.YColor);
    yaxes.tickfont.color = parseColor(a.YColor);
    
end

%SCALE
xaxes.type = a.XScale;
yaxes.type = a.YScale;
xaxes.range = a.XLim;
yaxes.range = a.YLim;
if strcmp(a.XDir, 'reverse')
    xaxes.range = [a.XLim(2) a.XLim(1)];
end
if strcmp(a.YDir, 'reverse')
    yaxes.range = [a.YLim(2) a.YLim(1)];
end

if strcmp('log', xaxes.type)
    xaxes.range = log10(xaxes.range);
end
if strcmp('log', yaxes.type)
    yaxes.range = log10(yaxes.range);
end
if strcmp('linear', xaxes.type)
    if numel(a.XTick)>1
        xaxes.tick0 = a.XTick(1);
        xaxes.dtick = a.XTick(2)-a.XTick(1);
        xaxes.autotick = false;
        
        try
            ah = axhan;
            xtl = get(ah,'XTickLabel');
            if(strcmp(get(ah,'XTickLabelMode'),'manual'))
                if(iscell(xtl))
                    xaxes.tick0 = str2double(xtl{1});
                    xaxes.dtick = str2double(xtl{2})-str2double(xtl{1});
                end
                if(ischar(xtl))
                    xaxes.tick0 = str2double(xtl(1,:));
                    xaxes.dtick = str2double(xtl(2,:))- str2double(xtl(1,:));
                end
                xaxes.autotick = false;
                xaxes.autorange = true;
            end
        end
        
    else
        xaxes.autotick = true;
    end
end
if strcmp('linear', yaxes.type)
    if numel(a.YTick)>1
        yaxes.tick0 = a.YTick(1);
        yaxes.dtick = a.YTick(2)-a.YTick(1);
        yaxes.autotick = false;
    else
        yaxes.autotick = true;
    end
end
%TOIMPROVE: check if the axis is a datetime. There is no implementatin for
%type category yet.
if numel(a.XTickLabel)>0
    try datenum(a.XTickLabel);
        [start, finish, t0, tstep] = extractDateTicks(a.XTickLabel, a.XTick);
        if numel(start)>0
            xaxes.type = 'date';
            xaxes.range = [start, finish];
            xaxes.tick0 = t0;
            xaxes.dtick = tstep;
            xaxes.autotick = true;
        end
    catch
        %it was not a date...
    end
end
if numel(a.YTickLabel)>0
    try datenum(a.YTickLabel);
        [start, finish, t0, tstep] = extractDateTicks(a.YTickLabel, a.YTick);
        if numel(start)>0
            yaxes.type = 'date';
            yaxes.range = [start, finish];
            yaxes.tick0 = t0;
            yaxes.dtick = tstep;
            yaxes.autotick = true;
        end
    catch
        %it was not a date...
    end
end

%LABELS
if numel(a.XLabel)==1
    
    m_title = get(a.XLabel);
    if numel(m_title.String)>0
        xaxes.title = parseLatex(m_title.String,m_title);
        %xaxes.title = parseText(m_title.String);
        if ~strip_style
            if strcmp(m_title.FontUnits, 'points')
                xaxes.titlefont.size = 1.3*m_title.FontSize;
            end
            xaxes.titlefont.color = parseColor(m_title.Color);
            
            %FONT TYPE
            try
                data.font.family = extractFont(m_title.FontName);
            catch
                display(['We could not find the font family you specified.',...
                    'The default font: Open Sans, sans-serif will be used',...
                    'See https://www.plot.ly/matlab for more information.']);
                data.font.family = 'Open Sans, sans-serif';
            end
        end
    else
        if(isappdata(axhan,'MWBYPASS_xlabel')) %look for bypass
            ad = getappdata(axhan,'MWBYPASS_ylabel');
            try
                adAx = get(ad{2});
                m_title.String = adAx.XLabel;
                xaxes.title = parseLatex(m_title.String,m_title);
            catch exception
                disp('Had trouble locating XLabel');
                return
            end
        end
        
    end
    
    if numel(a.YLabel)==1
        
        m_title = get(a.YLabel);
    end
    if numel(m_title.String)>0
        yaxes.title = parseLatex(m_title.String,m_title);
        % yaxes.title = parseText(m_title.String);
        if ~strip_style
            if strcmp(m_title.FontUnits, 'points')
                yaxes.titlefont.size = 1.3*m_title.FontSize;
            end
            yaxes.titlefont.color = parseColor(m_title.Color);
            
            %FONT TYPE
            try
                data.font.family = extractFont(m_title.FontName);
            catch
                display(['We could not find the font family you specified.',...
                    'The default font: Open Sans, sans-serif will be used',...
                    'See https://www.plot.ly/matlab for more information.']);
                data.font.family = 'Open Sans, sans-serif';
            end
            
        end
    else
        if(isappdata(axhan,'MWBYPASS_ylabel'))
            ad = getappdata(axhan,'MWBYPASS_ylabel');
            try
                adAx = get(ad{2});
                m_title.String = adAx.YLabel;
                yaxes.title = parseLatex(m_title.String,m_title);
            catch exception
                disp('Had trouble locating YLabel');
                return
            end
        end
    end
    
    
end