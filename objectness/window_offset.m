

function offset = window_offset(w, theta, direction, imwidth, imheight)

offset = w;
xmin = w(:,1);
ymin = w(:,2);
xmax = w(:,3);
ymax = w(:,4);

switch(direction)
    case 'in'
        % shrink window by factor of theta. if w had dimensions (x,y),
        % offset will have dimensions (x*theta, y*theta), centered at the
        % same point
        xmaxInner = round((xmax*(200+theta)/(theta+100) + xmin*theta/(theta+100)+100/(theta+100)-1)/2);
        xminInner  = round(xmax + xmin - xmaxInner);
        ymaxInner = round((ymax*(200+theta)/(theta+100) + ymin*theta/(theta+100)+100/(theta+100)-1) /2);
        yminInner  = round(ymax + ymin - ymaxInner);
        offset = [xminInner, yminInner, xmaxInner, ymaxInner];
    case 'out'
        % expand window by factor of theta. if w had dimensions (x,y),
        % offset will have dimensions (x/theta, y/theta), centered at the
        % same point
        offsetWidth  = (w(:,3)-w(:,1)+1) * theta / 200;
        offsetHeight = (w(:,4)-w(:,2)+1) * theta / 200;
        xminSurr=round(max(xmin-offsetWidth,1));
        xmaxSurr=round(min(xmax+offsetWidth,imwidth));
        yminSurr=round(max(ymin-offsetHeight,1));
        ymaxSurr=round(min(ymax+offsetHeight,imheight));
        offset = [xminSurr, yminSurr, xmaxSurr, ymaxSurr];
end
end