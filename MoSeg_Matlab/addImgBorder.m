% addImgBorder
%
% created on April 30, 2013
% written by Richard Lange
%
% This function can do two types of image border extrapolation. The new
% image will have size (h + 2*border) x (w + 2*border). The possible
% extrapolation types are:
%   'blank' - leave it black
%   'extend' - extend the edge pixels into the border with simple
%              repetition

function img_buffered = addImgBorder(img, border_width, extrapolation)

[h, w, d] = size(img);

if isa(img, 'uint8')
    img = double(img) / 255;
end

if nargin < 3
    extrapolation = 'blank';
end

img_buffered = zeros(h + 2*border_width, w + 2*border_width, d);
img_buffered(...
    border_width+1 : border_width+h, ...
    border_width+1 : border_width+w, : ) = img;

if strcmp(extrapolation, 'blank')
    % do nothing - already blank border!
elseif strcmp(extrapolation, 'extend')
    % fill in border with repeated edge of image
    % top row
    img_buffered(1:border_width, border_width+1 : border_width+w, :) = ...
        repmat(img(1,:,:), [border_width, 1, 1]);
    % bottom row
    img_buffered(h+border_width+1:h+2*border_width, border_width+1 : border_width+w, :) = ...
        repmat(img(end,:, :), [border_width, 1, 1]);
    % left column
    img_buffered(border_width+1 : border_width+h, 1:border_width, :) = ...
        repmat(img(:,1, :), [1, border_width, 1]);
    % right column
    img_buffered(border_width+1 : border_width+h, w+border_width+1 : w+2*border_width, :) = ...
        repmat(img(:,end, :), [1, border_width, 1]);
    % fill in corners of buffered image with corner value from img
    img_buffered(1:border_width, 1:border_width,:) = repmat(img(1,1,:), border_width, border_width);
    img_buffered(1:border_width, w+border_width+1:w+2*border_width,:) = repmat(img(1,w,:), border_width, border_width);
    img_buffered(h+border_width+1:h+2*border_width, 1:border_width,:) = repmat(img(h,1,:), border_width, border_width);
    img_buffered(h+border_width+1:h+2*border_width, w+border_width+1:w+2*border_width,:) = repmat(img(h,w,:), border_width, border_width);
    
end
end