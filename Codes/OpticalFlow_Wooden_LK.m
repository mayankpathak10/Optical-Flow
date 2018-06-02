close all
clear all

%% Initializing Video writing Variables
VideoFolder = '../Outputs/Wooden_LK';
Video_name = 'grove_LKF3.mp4';
Video_obj = fullfile(VideoFolder,Video_name);
vidWriter=VideoWriter(Video_obj,'MPEG-4');
vidWriter.FrameRate = 3;
vidWriter.Quality = 98;

%% For Frame Writing
FrameOut_Folder = '../Outputs/Wooden_LK/Frames';

images = imageDatastore('../Inputs/eval-data-gray/Wooden/*.png');  
nfiles = size(images.Files,1); 
open(vidWriter);

%% loop to Read Images, and estimate Flow
for k = 1: nfiles-1
    clc
    Current_name = ['OFbw',num2str(k),'&',num2str(k+1),'.jpg'];
    disp(['Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
    fr1 = readimage(images,k);
    fr2 = readimage(images,k+1);



    im1t = im2double(fr1);
%     imshow(im1t);
    im1 = imresize(im1t, 0.5); % downsize to half
%     imshow(im1);

    im2t = im2double(fr2);
    im2 = imresize(im2t, 0.5); % downsize to half

    window_width = 50;        % wimdow size for neighborhood pixels
    w = round(window_width/2);

    % Calculating dx, dy and dz.
    Ix_m = conv2(im1,[-1 1; -1 1], 'valid'); % partial on x
    Iy_m = conv2(im1, [-1 -1; 1 1], 'valid'); % partial on y
    It_m = conv2(im1, ones(2), 'valid') + conv2(im2, -ones(2), 'valid'); % partial on t
    u = zeros(size(im1));
    v = zeros(size(im2));

    % within window ww * ww
    for i = w+1:size(Ix_m,1)-w
       for j = w+1:size(Ix_m,2)-w
          Ix = Ix_m(i-w:i+w, j-w:j+w);
          Iy = Iy_m(i-w:i+w, j-w:j+w);
          It = It_m(i-w:i+w, j-w:j+w);

          Ix = Ix(:);
          Iy = Iy(:);
          b = -It(:); % get b here

          A = [Ix Iy]; % get A here
          nu = pinv(A)*b; % get velocity here

          u(i,j)=nu(1);
          v(i,j)=nu(2);
       end
    end

    % downsize u and v
    u_deci = u(1:10:end, 1:10:end);
    v_deci = v(1:10:end, 1:10:end);
    % get coordinate for u and v in the original frame
    [m, n] = size(im1t);
    [X,Y] = meshgrid(1:n, 1:m);
    X_deci = X(1:20:end, 1:20:end);
    Y_deci = Y(1:20:end, 1:20:end);

    imshow(fr2);
    hold on;
    % draw the velocity vectors
    quiver(X_deci, Y_deci, u_deci,v_deci, 'y')
    title(['Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
    
    frame = gcf();
    Frame_name = fullfile(FrameOut_Folder,Current_name);
    saveas(frame,Frame_name)
    Current_image = imread(Frame_name);
    writeVideo(vidWriter,Current_image);

end

close(vidWriter);
