function box = scale_box(V, a_box, a_width, a_height)
% annotations in data folder may have annotations scaled at a different
% image size. this converts them back.

vdata = get(V, {'Width', 'Height'});
w = vdata{1};
h = vdata{2};
box = a_box;
box([1 3]) = round(box([1 3]) * w / a_width);
box([2 4]) = round(box([2 4]) * h / a_height);

end