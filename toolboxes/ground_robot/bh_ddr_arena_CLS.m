classdef bh_ddr_arena_CLS
%==========================================================================
% EXAMPLE USAGE:    
% 
%         % define some test waypoint (x,y) data
%         W   = [  0, 0;
%                  1, 0;
%                  1, 0.5;
%                  0, 0.5;
%                  0, 1;
%                  1, 1;
%                ];
% 
%         % create an instance of the ARENA class.
%         OBJ = bh_ddr_arena_CLS( W(:,1), W(:,2) )  ;
% 
%         % plot the arena
%         OBJ.plot_arena()
% 
%         % get axes handle and path height for drawing vehicles
%         hax = OBJ.get_ax()
%         z   = OBJ.get_path_height()    
%==========================================================================    
    properties
        marker_X_col  = [];
        marker_Y_col  = [];
        marker_Z_col  = [];
        marker_radius = 1;
        N             = 0;
        TAG_AX        = 'TAG_AX_DDR_ARENA';
        path_linspec  = '--r';
    end
    
    properties
       hax 
    end
%==========================================================================
methods
function OBJ = bh_ddr_arena_CLS(xC, yC, zC)
% Usage:
%   OBJ = bh_ddr_arena_CLS(xC, yC, zC)
%   OBJ = bh_ddr_arena_CLS(xC, yC)
    
if(2==nargin)
    zC = zeros(size(xC));
end

OBJ.marker_X_col = xC(:);
OBJ.marker_Y_col = yC(:);
OBJ.marker_Z_col = zC(:);
OBJ.N            = length(xC);
OBJ.marker_radius = LOC_calc_markersize(OBJ)

end % bh_ddr_arena_CLS
%--------------------------------------------------------------------------
function plot_arena(OBJ, hax)
    if(1==nargin)
        hax = axes;
    end
    
    % set the Tag - very important. Used for finding the axes
    set(hax, 'Tag',OBJ.TAG_AX)
    axis(hax, 'equal')   
    hold(hax,'on') % important 
    
    for kk=1:OBJ.N
        xc = OBJ.marker_X_col(kk);
        yc = OBJ.marker_Y_col(kk);
        zc = OBJ.marker_Z_col(kk);
        R  = OBJ.marker_radius;
        hs = LOC_plot_sphere(hax, xc,yc,zc,R);
        
        switch(kk)
            case {1}
                         hs.FaceColor = 'yellow';
            case {OBJ.N}
                         hs.FaceColor = 'red';
            otherwise
                         hs.FaceColor = 'blue';
        end
    end
    
    xmin = min(OBJ.marker_X_col) - 3*OBJ.marker_radius;
    xmax = max(OBJ.marker_X_col) + 3*OBJ.marker_radius;
    ymin = min(OBJ.marker_Y_col) - 3*OBJ.marker_radius;
    ymax = max(OBJ.marker_Y_col) + 3*OBJ.marker_radius;
    zmin = min(OBJ.marker_Z_col) - 3*OBJ.marker_radius;
    zmax = max(OBJ.marker_Z_col) + 3*OBJ.marker_radius;
    
    xlim(hax,[xmin,xmax]);
    ylim(hax,[ymin,ymax]);
    zlim(hax,[zmin,zmax]);
    
    hL(1) = light('Position',[xmin, ymin, zmax]);   
    hL(2) = light('Position',[xmax, ymin, zmax]); 
    hL(3) = light('Position',[xmax, ymax, zmax]);
    hL(4) = light('Position',[xmin, ymax, zmax]); 

    set(hL,'Style','local')
        
    % now draw path
    plot3(hax, OBJ.marker_X_col, ...
               OBJ.marker_Y_col, ...
               OBJ.marker_Z_col, ...
               OBJ.path_linspec,  'LineWidth',3);
           
   % put on some annotations
   grid(hax,'on');
   xlabel('X (m)', 'FontSize',14,'FontWeight','Bold');
   ylabel('Y (m)', 'FontSize',14,'FontWeight','Bold');
    
end % plot_markers
%--------------------------------------------------------------------------
function hax = get_ax(OBJ)
    hax = [];
    h   = findobj('Type','Axes','Tag',OBJ.TAG_AX);
    
    assert(length(h)<=1, 'ERR: only 1 DDR ARENA axes is allowed');
    
    if(~isempty(h))
       hax = h;
    end
end
%--------------------------------------------------------------------------
function z = get_path_height(OBJ)
         z = max(OBJ.marker_Z_col) + 1*OBJ.marker_radius;
end
%--------------------------------------------------------------------------

end % methods
%==========================================================================

end % classdef
%==========================================================================
function hs = LOC_plot_sphere(hax,xc,yc,zc,R)
[x,y,z] = sphere(hax,20);

% scale
x = x*R;
y = y*R;
z = z*R;
% position center
x = x + xc;
y = y + yc;
z = z + zc;


hs = surf(hax,x,y,z);
set(hs,'FaceLighting','gouraud',...
       'FaceColor',[1 0 0], ...
       'EdgeColor','none');
end
%==========================================================================
function R = LOC_calc_markersize(OBJ)

    xdiff = diff(OBJ.marker_X_col);
    ydiff = diff(OBJ.marker_Y_col);

    m = max([xdiff(:); ydiff(:)]);
    
    R = m/50;
    
end
%==========================================================================
