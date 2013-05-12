% demo.m
%
% demo the Motion Segmentation algorithm
%
% created on April 30, 2013
% written by Richard Lange

%% DEMO INITIALIZATION

clear all; close all; clc;

if exist('DGradient', 'file') ~= 3
    startup;
end

mosegParams = structMosegParams('../data/Youtube/10class/penguin/03.avi', 1, 30);

I = imread('../objectness/002053.jpg');
I = double(I) / 255;

thresh = [0.5 1 2];

i = 1;
for t = thresh
    fprintf('doing initialization for threshold = %f\n', t);
    mosegParams.init_threshold = t;
    traj_array = initializeTrajectories(I, mosegParams);
    I_pts{i} = drawTrackFrame(I, traj_array, 1);
    i = i+1;
end

try
    figure();
    subplot(2,2,1);
    imshow(I);
    title('original image');
    subplot(2,2,2);
    imshow(I_pts{1});
    title(sprintf('Initialization with threshold %f', thresh(1)));
    subplot(2,2,3);
    imshow(I_pts{2});
    title(sprintf('Initialization with threshold %f', thresh(2)));
    subplot(2,2,4);
    imshow(I_pts{3});
    title(sprintf('Initialization with threshold %f', thresh(3)));
catch
    fprintf('cant display results\n');
end
%% DEMO COMPUTE-TRAJECTORIES

clear all; close all; clc;

if exist('DGradient', 'file') ~= 3
    startup;
end

mosegParams = structMosegParams();

[traj_array, fflows, bflows] = computeTrajectories(mosegParams);
save('demo.mat');

%% Visualize trajectories by start frame

V = VideoReader(mosegParams.video_file);

% make animation showing tracked points colored by when they were  initialized
try
    h = figure();
    startframes = unique([traj_array.startframe]);
    colors = hsv(length(startframes));
    movie_frame = 1;
    for f=mosegParams.startframe : mosegParams.endframe
        base_img = read(V, f);
        for cluster = startframes(startframes <= f)
            selected_trajectories = traj_array(...
                ([traj_array.startframe] == cluster) & ...
                ([traj_array.endframe] >= f));
            base_img = drawTrackFrame(base_img, selected_trajectories, f, ...
                colors(startframes == cluster,:));
        end
        imshow(base_img);
        mov(movie_frame) = getframe(h);
        movie_frame = movie_frame+1;
    end
    close(h);
    
    movie(mov, 5);
    
catch
    disp('cannot display results. saved to demo.mat');
end

%% Visualize trajectories by duration

V = VideoReader(mosegParams.video_file);

% make animation showing tracked points colored by their duration
try
    h = figure();
    durations = unique([traj_array.duration]);
    colors = [linspace(1,0,length(durations))', ...
        zeros(1,length(durations))', ...
        linspace(0,1,length(durations))'];
    movie_frame = 1;
    for f=mosegParams.startframe : mosegParams.endframe
        base_img = read(V, f);
        for cluster = durations
            selected_trajectories = traj_array(...
                ([traj_array.startframe] + cluster == f));
            base_img = drawTrackFrame(base_img, selected_trajectories, f, ...
                colors(durations == cluster,:));
        end
        imshow(base_img);
        mov(movie_frame) = getframe(h);
        movie_frame = movie_frame+1;
    end
    close(h);
    
    movie(mov, 5);
    
catch
    disp('cannot display results. saved to demo.mat');
end

%% Visualize trajectories in 3D space

try
    h = figure();
    hold on;
    for t=1:length(traj_array)
        points = traj_array(t).points;
        range = traj_array(t).startframe : traj_array(t).endframe;
        plot3(points(2,:), range, points(1,:), '-o');
    end
    hold off;
    set(gca, 'ZDir', 'reverse');
    xlabel('x');
    ylabel('frame');
    zlabel('y');
catch
    disp('cannot display results.');
end

%% Full motion segmentation demo

clear all; close all; clc;

if exist('DGradient', 'file') ~= 3
    startup;
end

mosegParams = structMosegParams();

[traj_array, fflows, bflows] = computeTrajectories(mosegParams);
traj_array = mosegByTrajectories(traj_array, fflows, mosegParams);