function new_point = track_point(point, flows, width, height)
% track_point(point, flows)
%
% track the given point according to the vector fields 'flows'.

new_point = point;

for i = 1:length(flows)
    flow = flows{i};
    if all(new_point >= [1 1]' & new_point <= [height width]')
        dx = interp2(flow(:,:,1), new_point(2), new_point(1));
        dy = interp2(flow(:,:,2), new_point(2), new_point(1));
        new_point = new_point + [dy; dx];
    end
end

end
