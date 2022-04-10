function orderedPath = organiseWP(waypoints, logical_map)
    waypoints = [[3,3]; waypoints];
    indexes = ones(1, size(waypoints,1));
    for i = 1:size(waypoints,1)
        indexes(i) = indexes(i)*i;
    end
    node1 = [];
    node2 = [];
    cost = [];
    cost2 = [];

    for i = 1:6
        tempIndexes = indexes;
        tempIndexes(i) = [];
        for j = tempIndexes
            [~, dist] = A_Star(logical_map, waypoints(j, :), waypoints(i,:)); %uses A* to measure distance
            node1 = [node1,i];
            node2 = [node2,j];
            cost = [cost, dist];
        end
    end
    DG = sparse(node1, node2, round(cost));
    g = graph(DG);
    
    % Construct all possible ways that we could traverse all nodes, starting at
    % node 1 and ending at node 6:
    paths = perms(2:6);
    paths = [ones(size(paths, 1), 1) paths];
    % Check if a path is feasible (edges exist between all node pairs), and how
    % long it is
    dist = NaN(size(paths, 1), 1);
    for ii=1:size(paths, 1)
          path = paths(ii, :);
          edgeID = findedge(g, path(1:end-1), path(2:end));
          if all(edgeID ~= 0)
              dist(ii) = sum(g.Edges.Weight(edgeID));
          end
      end
    [~, id] = min(dist);
    pathOrder = paths(id, :);
    p = plot(g, 'EdgeLabel', g.Edges.Weight);
    highlight(p, paths(id, :), 'EdgeColor', 'red')

    orderedPath = [];
    for i = pathOrder
        orderedPath = [orderedPath; waypoints(i,:)];
    end
    orderedPath(1,:) = [];
end


