function exp_array=expand_array(node_x,node_y,hn,xTarget,yTarget,CLOSED,MAX_X,MAX_Y)
    %This function takes a node and returns the expanded list
    %of successors,with the calculated fn values.
    
    exp_array=[];
    coder.varsize('exp_array');
    exp_count=1;
    c2=size(CLOSED,1);%Number of elements in CLOSED including the zeros
    for k= 1:-1:-1
        for j= 1:-1:-1
            if (k~=j || k~=0)  %The node itself is not its successor
                s_x = node_x+k;
                s_y = node_y+j;
                if( (s_x >0 && s_x <=MAX_X) && (s_y >0 && s_y <=MAX_Y))%node within array bound
                    flag=1;                    
                    for c1=1:c2
                        %Check if its a node clocated in closed
                        if(s_x == CLOSED(c1,1) && s_y == CLOSED(c1,2))
                            flag=0;
                            break
                        end
                        %If node is not the centre spot (itself)
                        if (k~=0 && j~=0)
                            if (s_x-k == CLOSED(c1,1) && s_y == CLOSED(c1,2)) && ((s_x-k >0 && s_x-k <=MAX_X) && (s_y >0 && s_y <=MAX_Y))
                                flag=0;
                                break
                            elseif (s_x == CLOSED(c1,1) && s_y-j == CLOSED(c1,2)) && ((s_x >0 && s_x <=MAX_X) && (s_y-j >0 && s_y-j <=MAX_Y))
                                flag=0;
                                break
                            end
                        end
                    end%End of for loop to check if a successor is on closed list.
                    if (flag == 1)
                        exp_array = [exp_array; zeros(1,5)];
                        exp_array(exp_count,1) = s_x;
                        exp_array(exp_count,2) = s_y;
                        exp_array(exp_count,3) = hn+distance(node_x,node_y,s_x,s_y);%cost of travelling to node
                        exp_array(exp_count,4) = distance(xTarget,yTarget,s_x,s_y);%distance between node and goal
                        exp_array(exp_count,5) = exp_array(exp_count,3)+exp_array(exp_count,4);%fn
                        exp_count=exp_count+1;
                    end
                end
            end
        end
    end   
end
    
    
    
    
    
    
   
    
    
    
    
    
    