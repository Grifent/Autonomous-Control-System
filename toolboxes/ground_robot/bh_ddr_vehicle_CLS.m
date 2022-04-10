classdef bh_ddr_vehicle_CLS
%==========================================================================
% EXAMPLE USAGE:    
% 
%     OBJ = bh_ddr_vehicle_CLS('init_xytheta',    [1,2,-pi/4], ...
%                              'scale_factor',    0.5, ...
%                              'color',           [0,1,0], ...
%                              'road_z',          1, ...
%                              'veh_ID_str',      'BRADS_CAR', ...
%                              'tgt_tag_ax_name', 'TAG_AX_ARENA');
% 
%     %OBJ.plot_init()
% 
%     % animate the vehicle
%     xx_list = linspace(1,5,20);
%     th_list = linspace(0,2*pi,20);
% 
%     for kk=1:length(xx_list)
%         xx = xx_list(kk);
%         tt = th_list(kk);
% 
%         OBJ.plot(xx,2,tt)
% 
%         pause(0.1);
%         fprintf('\n ... xx=%6.2f',xx);
%     end    
%==========================================================================
properties
    scale_factor    = [];
    tgt_tag_ax_name = '';
    color           = [];
    road_z          = [];
    veh_ID_str      = [];
    init_xytheta         = [];
end

properties (SetAccess=private)
%     PXY_birth_unscaled = [ 0.5,  -0.5  -0.25, -0.5;
%                            0,     0.5,  0,    -0.5 ]'; % arrow shape
                       
    PXY_birth_unscaled = [ 0.5,  0.5,  0.10, -0.50, -0.50, 0.10, 0.5;
                           0  ,  0.5,  0.50,  0.20, -0.20, -0.5, -0.5]';
    patch_tag_name = '';
    line_tag_name  = '';
end
%==========================================================================
methods
    function OBJ = bh_ddr_vehicle_CLS(varargin)
           out_T = LOC_parse_inputs(varargin{:});
           
           OBJ.scale_factor    = out_T.scale_factor;
           OBJ.tgt_tag_ax_name = out_T.tgt_tag_ax_name;
           OBJ.color           = out_T.color;
           OBJ.road_z          = out_T.road_z;
           OBJ.veh_ID_str      = out_T.veh_ID_str;
           OBJ.init_xytheta    = out_T.init_xytheta;
           
           OBJ.patch_tag_name = ['TAG_PATCH_DDR_VEHICLE_',OBJ.veh_ID_str];
           OBJ.line_tag_name  = ['TAG_LINE_DDR_VEHICLE_',OBJ.veh_ID_str];
           
    end
%--------------------------------------------------------------------------
function hax = get_tgt_ax_handle(OBJ)
    hax = [];
    h   = findobj('Type','Axes','Tag',OBJ.tgt_tag_ax_name);
    
    assert(length(h)<=1, 'ERR: only 1 target axes is allowed');
    if(~isempty(h))
       hax = h;
    end
end
%--------------------------------------------------------------------------
function hp = get_veh_handle(OBJ)
    hp  = [];
    h   = findobj('Type','patch', 'Tag', OBJ.patch_tag_name);
    
    assert(length(h)<=1, 'ERR: only 1 patch allowed with name ---> <%s>',OBJ.patch_tag_name);
    if(~isempty(h))
       hp = h;
    end
end
%--------------------------------------------------------------------------
function hL = get_line_handle(OBJ)
    hL  = [];
    h   = findobj('Type','animatedline', 'Tag', OBJ.line_tag_name);
    
    assert(length(h)<=1, 'ERR: only 1 animatedline allowed with name ---> <%s>',OBJ.line_tag_name);
    if(~isempty(h))
       hL = h;
    end
end
%--------------------------------------------------------------------------
function [X,Y,Z] = get_birth_XYZ(OBJ)
    % ATTENTION:
    %  Birth config will have the patch with centroid at origin and
    %  theta=0
    X = (OBJ.PXY_birth_unscaled(:,1) * OBJ.scale_factor); 
    Y = (OBJ.PXY_birth_unscaled(:,2) * OBJ.scale_factor); 
    Z = OBJ.road_z * ones(size(X));
end
%--------------------------------------------------------------------------
function plot(OBJ, xc, yc, theta_rad)
    
    % we will NOT plot unless our target axes exists
    hax = OBJ.get_tgt_ax_handle();
    if(isempty(hax))
        return
    end
    
    % get the patch
    hp = OBJ.get_veh_handle();

    if(isempty(hp))
        hp = OBJ.plot_birth();
    end
    
    [Xb,Yb,Zb] = OBJ.get_birth_XYZ();
    [X,Y,Z]    = LOC_rotate_patch(Xb,Yb,Zb,theta_rad);

    % now update the patch
    hp.XData   = X + xc;
    hp.YData   = Y + yc;
    hp.ZData   = OBJ.road_z*ones(size(X));
    
    % get the line
    hL = OBJ.get_line_handle();
    
    if(isempty(hL))
        hL = animatedline('Tag',       OBJ.line_tag_name, ...
                          'Parent',    hax, ...
                          'LineStyle', '-',...
                          'LineWidth', 2,...
                          'Color',     OBJ.color);
    end
    % now update the line
    zc = OBJ.road_z;
    
    addpoints(hL, xc, yc, zc );
    
    drawnow;
end
%--------------------------------------------------------------------------
function [varargout] = plot_birth(OBJ)
    hax = OBJ.get_tgt_ax_handle();
    if(isempty(hax))
        hax = axes('Tag',OBJ.tgt_tag_ax_name);
    end
    
    [Xb,Yb,Zb] = OBJ.get_birth_XYZ();
    
    hp = patch(hax, Xb,Yb,Zb, ...
               'FaceColor', OBJ.color, ...
               'Tag'     ,  OBJ.patch_tag_name ); 
           
    if(1==nargout)
        varargout{1} = hp;
    end
end
%--------------------------------------------------------------------------
function [varargout] = plot_init(OBJ)
    
    hp       = OBJ.plot_birth();
    
    xi       = hp.XData;
    yi       = hp.YData;
    zi       = hp.ZData;
    
    theta    = OBJ.init_xytheta(3);
    
    [X,Y,Z]  = LOC_rotate_patch(xi,yi,zi,theta);
    
    hp.XData = X + OBJ.init_xytheta(1);
    hp.YData = Y + OBJ.init_xytheta(2);
    hp.ZData = OBJ.road_z*ones(size(X));

    
    if(1==nargout)
        varargout{1} = hp;
    end
end
%--------------------------------------------------------------------------
function clear(OBJ)
   hL = OBJ.get_line_handle();
   hp = OBJ.get_veh_handle();
   
   if(~isempty(hp))
       delete(hp);
   end
   
   if(~isempty(hL))
       delete(hL);
   end
end
%--------------------------------------------------------------------------
end % methods
%==========================================================================
end %classdef
%==========================================================================
function out_T = LOC_parse_inputs(varargin)

p = inputParser;
p.FunctionName = mfilename();

% Inputs added with addParameter are not positional, so you can pass values 
% for height before or after values for width. However, parameter value 
% inputs require that you pass the input name ('height' or 'width') along 
% with the value of the input.

def_color            = [0,1,0];
def_road_z           = 1;
def_scale_factor     = 1;
%def_veh_ID_str      = 'TAG_PATCH_DDR_VEHICLE';
def_veh_ID_str      = 'xxx';

def_tgt_tag_ax_name  = 'xxx';
def_init_xytheta     = [0,0,0];

fh_checkColor       = @(x) validateattributes(x,{'numeric'}, {'vector', 'numel',3});
fh_checkRoadZ       = @(x) validateattributes(x,{'numeric'}, {'scalar'});
fh_checkScaleFactor = @(x) validateattributes(x,{'numeric'}, {'scalar'});
fh_checkName        = @(x) validateattributes(x,{'char'},    {'row'});
fh_checkINITXYTHETA = @(x) validateattributes(x,{'numeric'}, {'vector', 'numel',3});

addParameter(p,'color',          def_color,           fh_checkColor);
addParameter(p,'road_z',         def_road_z,          fh_checkRoadZ );
addParameter(p,'scale_factor',   def_scale_factor,    fh_checkScaleFactor);
addParameter(p,'veh_ID_str',     def_veh_ID_str,      fh_checkName );
addParameter(p,'tgt_tag_ax_name',def_tgt_tag_ax_name, fh_checkName );
addParameter(p,'init_xytheta',   def_init_xytheta,    fh_checkINITXYTHETA);

% Within your function, call the parse method. Pass the values of all of 
% the function inputs.
parse(p, varargin{:} )

% Access parsed inputs using these properties of the inputParser object:
% 
% Results ? Structure array with names and values of all inputs in the scheme.
% Unmatched ? Structure array with parameter names and values that are 
%             passed to the function, but are not in the scheme 
%             (when KeepUnmatched is true).
% UsingDefaults ? Cell array with names of optional inputs that are assigned 
%                 their default values because they are not passed to the function.

out_T = p.Results;

end
%==========================================================================
function [X,Y,Z] = LOC_rotate_patch(xi,yi,zi,theta)

 xi = xi(:);
 yi = yi(:);
 zi = zi(:);
 
 R = [ cos(theta), -sin(theta);
       sin(theta),  cos(theta); ];
 
 bP = [ xi.';
        yi.'; ];
    
    
 gP = R * bP;   
 
  X =  gP(1,:).';
  Y =  gP(2,:).';
  Z = zi;
end
%==========================================================================



