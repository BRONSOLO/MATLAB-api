function data = extractTitle(than,d, xa, ya, strip_style)
% extractTitle - create an annotation struct for plot titles
%   [data] = extractTitle(d, xa, ya)
%       xa,ya - reference axis structs
%       d - a data struct from matlab describing an annotation
%       data - a plotly annotation struct
%
% For full documentation and examples, see https://plot.ly/api

data = {};

%TEXT
if(numel(d.String) > 0)
    %data.text = parseText(d.String);
    data.text = parseLatex(d.String,d);
    %data.text = d.String;
else
    if(isappdata(than,'MWBYPASS_title'))
        ad = getappdata(than,'MWBYPASS_title');
        try
            adAx = get(ad{2});
            m_title.String = adAx.Title;
            data.text = m_title.String;
        catch 
            return
        end
    else
        return;
    end
end

% set reference axis
data.xref = 'paper';
data.yref = 'paper';

if ~strip_style
    if strcmp(d.FontUnits, 'points')
        data.font.size = 1.3*d.FontSize;
    end
    data.font.color = parseColor(d.Color);
    
    %FONT TYPE
    try
        data.font.family = extractFont(d.FontName);
    catch
        display(['We could not find the font family you specified.',...
                    'The default font: Open Sans, sans-serif will be used',...
                    'See https://www.plot.ly/matlab for more information.']); 
        data.font.family = 'Open Sans, sans-serif';
    end
    
end

%POSITION
xd_range = xa.domain(2) - xa.domain(1);
xr_range = xa.range(2) - xa.range(1);
if strcmp('linear', xa.type) || strcmp('date', xa.type)
    data.x = xa.domain(1)+ (d.Extent(1) - xa.range(1))*xd_range / xr_range;
    data.x = xa.domain(1)+ 0.5*xd_range;
end
if strcmp('log', xa.type)
    data.x = xa.domain(1)+ 0.5*xd_range;
end
yd_range = ya.domain(2) - ya.domain(1);
yr_range = ya.range(2) - ya.range(1);
if strcmp('linear', ya.type)
    data.y = ya.domain(1)+ (d.Extent(2) - ya.range(1))*yd_range / yr_range;
    data.y = ya.domain(2)+ 0.04;
end
if strcmp('log', ya.type)
    data.y = ya.domain(2)+ 0.04;
end

data.align = d.HorizontalAlignment;
data.xanchor = 'center';
data.yanchor = 'middle';

%ARROW
data.showarrow = false;



end