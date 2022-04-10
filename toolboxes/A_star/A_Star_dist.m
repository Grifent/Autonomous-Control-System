function [optimal_steps] = A_Star_dist(MAP, target, robotPos)
%DEFINE THE 2-D MAP ARRAY
MAX_X=52;
MAX_Y=41;

MAP = double(MAP);

xTarget=target(1);%X Coordinate of the Target
yTarget=target(2);%Y Coordinate of the Target

%Starting position of robot
xStart=robotPos(1);%Starting Position
yStart=robotPos(2);%Starting Position
if xStart <= 2
    xStart=3;
    yStart=3;
end

%CLOSED LIST STRUCTURE (nodes that are unvisitable)
%--------------
%X val | Y val |
%--------------
% CLOSED=zeros(MAX_VAL,2);
CLOSED = [];%zeros(2000,2);%sum(MAP == 1,'all'),2);
coder.varsize('CLOSED');

%Put all obstacles on the Closed list
k=1;%Counter
for i=1:MAX_X
    for j=1:MAX_Y
        if(MAP(i,j) == 1)
            CLOSED = [CLOSED;[i,j]];  %(k,1)=i; 
            %CLOSED(k,2)=j; 
            k=k+1;
% % %             plot(i+.5,j+.5,'ro');
        end
    end
end
CLOSED_COUNT=size(CLOSED,1);

%OPEN LIST STRUCTURE (nodes that are avalible to explore)
%--------------------------------------------------------------------------
%IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
%--------------------------------------------------------------------------
OPEN=[];%zeros(2000,8);
coder.varsize('OPEN');

%Setup for inital node (starting point)
xNode=xStart;
yNode=yStart;
OPEN_COUNT=1;
path_cost=0;
goal_distance=distance(xNode,yNode,xTarget,yTarget);
%OPEN(OPEN_COUNT,:)=insert_open(xNode,yNode,xNode,yNode,path_cost,goal_distance,goal_distance);
OPEN=[OPEN;insert_open(xNode,yNode,xNode,yNode,path_cost,goal_distance,goal_distance)];
OPEN(OPEN_COUNT,1)=0;
CLOSED = [CLOSED;[0 0]];
CLOSED_COUNT=CLOSED_COUNT+1;
CLOSED(CLOSED_COUNT,1)=xNode;
CLOSED(CLOSED_COUNT,2)=yNode;
NoPath=1;

%%%%%%%%%%%%%%%%%% START ALGORITHM %%%%%%%%%%%%%%%%%%%%%%%

% Find avalible neighbour nodes around current point
while((xNode ~= xTarget || yNode ~= yTarget) && NoPath == 1)
 %EXPANDED ARRAY FORMAT
 %--------------------------------
 %|X val |Y val ||h(n) |g(n)|f(n)|
 %--------------------------------
 %Get current neighbour nodes avalible
 exp_array=expand_array(xNode,yNode,path_cost,xTarget,yTarget,CLOSED,MAX_X,MAX_Y);
 exp_count=size(exp_array,1);
 
 %UPDATE LIST OPEN WITH THE SUCCESSOR NODES
 for i=1:exp_count
    flag=0;
    for j=1:OPEN_COUNT
        if(exp_array(i,1) == OPEN(j,2) && exp_array(i,2) == OPEN(j,3) ) %Node check
            OPEN(j,8)=min(OPEN(j,8),exp_array(i,5));
            if OPEN(j,8)== exp_array(i,5) %Minimum fn check
                %UPDATE PARENTS,gn,hn
                OPEN(j,4)=xNode;
                OPEN(j,5)=yNode;
                OPEN(j,6)=exp_array(i,3);
                OPEN(j,7)=exp_array(i,4);
            end
            flag=1;
        end
    end
    %Insert new element into the OPEN list if not alread in list
    if flag == 0
        OPEN_COUNT = OPEN_COUNT+1;
        OPEN = [OPEN; zeros(1,8)];
        OPEN(OPEN_COUNT,:)=insert_open(exp_array(i,1),exp_array(i,2),xNode,yNode,exp_array(i,3),exp_array(i,4),exp_array(i,5));
    end
 end

 
 %Find the node with the smallest fn 
  index_min_node = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget);
  if (index_min_node ~= -1) %index_min_node check 
      %Set xNode and yNode to the node with minimum fn
      xNode=OPEN(index_min_node,2);
      yNode=OPEN(index_min_node,3);
      %Update the cost of reaching the parent node
      path_cost=OPEN(index_min_node,6);
      %Move the Node to list CLOSED
      CLOSED_COUNT=CLOSED_COUNT+1;
      CLOSED = [CLOSED;[0 0]];
      CLOSED(CLOSED_COUNT,1)=xNode;
      CLOSED(CLOSED_COUNT,2)=yNode;
      %set on OPEN list to false (shows it been explored)
      OPEN(index_min_node,1)=0;
  else
      %No path exists to the Target
      NoPath=0;
  end
end

%Once algorithm has run The optimal path is generated by starting of at the
%last node(if it is the target node) and then identifying its parent node
%until it reaches the start node.This is the optimal path

i=size(CLOSED,1);
Optimal_path=[];
coder.varsize('Optimal_path');
xval=CLOSED(i,1);
yval=CLOSED(i,2);
i=1;
Optimal_path = [Optimal_path;[0 0]];
Optimal_path(i,1)=xval;
Optimal_path(i,2)=yval;
i=i+1;

if ( (xval == xTarget) && (yval == yTarget))
   inode=0;
   %Traverse OPEN and determine the parent nodes
   parent_x=OPEN(node_index(OPEN,xval,yval),4);%node_index returns the index of the node
   parent_y=OPEN(node_index(OPEN,xval,yval),5);
   
   while( parent_x ~= xStart || parent_y ~= yStart)
           Optimal_path = [Optimal_path;[0 0]];
           Optimal_path(i,1) = parent_x;
           Optimal_path(i,2) = parent_y;
           %Get the grandparents:-)
           inode=node_index(OPEN,parent_x,parent_y);
           parent_x=OPEN(inode,4);%node_index returns the index of the node
           parent_y=OPEN(inode,5);
           i=i+1;
   end
end

%Convert the optimal path into the essential subwaypoint (where the corners
%are)
%Convert the optimal path into the essential subwaypoint (where the corners
%are)
optimalPathWP = [];
coder.varsize('optimalPathWP');
currentx = xStart;
currenty = yStart;
pastKJ = [0,0]; %[k,j]
optimal_steps = size(Optimal_path,1);
counter = 0;
for i  = 0:optimal_steps-1
    flag = 0;
    for k= 1:-1:-1
        for j= 1:-1:-1
            if (k~=j || k~=0)  %The node itself is not its successor
                nextNodeX = currentx + k;
                nextNodeY = currenty + j;
                % if the indexed neighbour is the same as the next step in
                % the optimal path
                if all(Optimal_path(end-i,:) == [nextNodeX, nextNodeY])
                    % if the next step isnt on the same trajectory as the
                    % last then there is a corner (no longer stright or
                    % diagonal)
                    if (~all(pastKJ==[0,0]) && ~all(pastKJ==[k,j]))
                        counter = counter+1;
                        optimalPathWP = [optimalPathWP;[0 0]];
                        optimalPathWP(counter,:) = [currentx,currenty];
                    end
                    %Make sure to add in the target as the last subWP
                    if i == optimal_steps-1
                        counter = counter+1;
                        optimalPathWP = [optimalPathWP;[0 0]];
                        optimalPathWP(counter,:) = Optimal_path(end-i,:);
                    end
                    % update the next step's value to be the current step
                    pastKJ(1) = k;
                    pastKJ(2) = j;
                    currentx = nextNodeX;
                    currenty = nextNodeY;
                    flag = 1;
                end
            end
            if flag == 1
              break
            end
        end
        if flag == 1
              break
        end
    end
end

end