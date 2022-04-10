function [waypoints] = genWaypoints(num, logical_map, obstacles)
% Create random set of n waypoints in 52x41m area. 
% Call before simulation with genWaypoints(n).
waypoints = zeros(num,2);
%trigger = 1;
    for j = 1:num
        trigger = 1;
        waypoints_x_gen = 3;
        waypoints_y_gen = 3;
        while ((logical_map(waypoints_x_gen, waypoints_y_gen) == 1) || trigger == 1)
            waypoints_x_gen = randi([1,52],1,1); 
            waypoints_y_gen = randi([1,41],1,1); 
            trigger = 0;
            for i = 1:size(obstacles,1)
                if ((obstacles(i,1) < waypoints_x_gen+0.5 && obstacles(i,1) > waypoints_x_gen-0.5) && (obstacles(i,2) < waypoints_y_gen+0.5 && obstacles(i,2) > waypoints_y_gen-0.5)) ...
                        || (obstacles(i,1) == waypoints_x_gen && obstacles(i,2) == waypoints_y_gen)
                    trigger = 1;
                    break
                end
            end
        end
        waypoints(j,:) = [waypoints_x_gen, waypoints_y_gen];
    end
end