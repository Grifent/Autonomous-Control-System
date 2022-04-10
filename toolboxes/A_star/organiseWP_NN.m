function y = organiseWP(waypoints)
%organises a set of waypoints into the shortest path to travel to each one
%(ie origin, closest to origin (WP 1), closest to WP 1 (WP 2), ect)

waypoints_full = [[2,2]; waypoints];
waypoints_temp = waypoints;
remaining = ones(1,size(waypoints,1));
for i = 1:size(waypoints,1)
    remaining(i) = i;
end
waypoints_organised = zeros(1,2);
current = 1;
for i = 1:5
    if i > 1
        current = closest(1)+1;
    end
    closest = [-1,10000]; %index,
    for next = remaining%1:size(remaining,2)
        dist = distance(waypoints_full(current,1),waypoints_full(current,2),waypoints_temp(next,1),waypoints_temp(next,2));
        if dist < closest(2)
            closest = [next, dist];
        end
    end
        waypoints_organised(end+1,:) = waypoints_temp(closest(1),:);
        waypoints_temp(closest(1),:) = [1000,1000];
        remaining(find(remaining==closest(1))) = [];
end
waypoints_organised(1,:) = [];
y = waypoints_organised;
end