function h_axis = createFigAxes(h_fig)
%
% USAGE: h_axis = createFigAxes(h_fig)
%
% function to return an axis handle that encompasses the entire current
% figure. This is useful for placing text in the figure but outside child
% axes.
%
% INPUTS:
%   h_fig - parent figure handle
%
% OUTPUTS:
%   h_axis - axis handle for new axes that encompass the full figure

prev_fig = gcf;
figure(h_fig);

figPos = get(h_fig,'position');
units =  get(h_fig, 'units');
h_axis = axes('units', units, ...
              'position', [0 0 figPos(3) figPos(4)], ...
              'visible', 'off');
          
figure(prev_fig);