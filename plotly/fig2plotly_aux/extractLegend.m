function legend = extractLegend(a,ah)
% extractLegend - create a legend struct
%   [legend] = extractLegend(a)
%       a - a data struct from matlab describing an axis used as a legend
%       legend - a plotly legend struct
%
% For full documentation and examples, see https://plot.ly/api

legend = {};

%try to find the legend peered to the the current axes
try
    cf = get(gcf);
    for i = 1:length(cf.Children)
        legTemp = getappdata(double(cf.Children(i)),'LegendPeerHandle'); 
        if (double(legTemp) == double(ah)) %check to see if the LegendPeerHandle for that axis is the Legend axis
            leg = legTemp; 
        end
    end
    hl = handle(leg);
    showLegend = isequal(hl.ContentsVisible,'on');
catch
    showLegend = strcmp(a.Visible, 'on');
end

if showLegend
     
    %legend.traceorder = 'reversed';
    %POSITION
    x_ref = a.Position(1)+a.Position(3)/2;
    y_ref = a.Position(2)+a.Position(4)/2;
    if x_ref>0.333
        if x_ref>0.666
            legend.x = a.Position(1)+a.Position(3);
            legend.xanchor = 'right';
        else
            legend.x = a.Position(1)+a.Position(3)/2;
            legend.xanchor = 'middle';
        end
    else
        legend.x = a.Position(1);
        legend.xanchor = 'left';
    end
    
    if y_ref>0.333
        if y_ref>0.666
            legend.y = a.Position(2)+a.Position(4);
            legend.yanchor = 'top';
        else
            legend.y = a.Position(2)+a.Position(4)/2;
            legend.yanchor = 'middle';
        end
    else
        legend.y = a.Position(2);
        legend.yanchor = 'bottom';
    end
    
    if (strcmp(a.Box,'on')&&strcmp(a.Visible, 'on'))
        %LEGEND BORDER SIZE
        legend.borderwidth = a.LineWidth;
        %LEGEND BORDER COLOR
        legend.bordercolor = parseColor(a.EdgeColor);
        %LEGEND COLOR
        legend.bgcolor = parseColor(a.Color);
    end
    
    %anchor the legend to the appropriate axis
    
    
end
end