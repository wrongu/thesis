function new_point = track_point(point, flows)
% track_point(point, flows)
%
% track the given point according to the vector fields 'flows'.

new_point = point;

for i = 1:length(flows)
    flow = flows{i};
    dx = interp2(flow(:,:,1), new_point(2), new_point(1));
    dy = interp2(flow(:,:,2), new_point(2), new_point(1));
    new_point = new_point + [dy; dx];
end

end