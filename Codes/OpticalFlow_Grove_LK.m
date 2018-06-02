close all
clear



% Wooden = 1, Groove = 2
Current_Dataset = 2;
if Current_Dataset == 1
    VideoFolder = '../Outputs/Wooden_LK/Part1';
    Video_name = 'Inbuilt_Wooden_LK.mp4';
    FrameOut_Folder = '../Outputs/Wooden_LK/Part1/Frames';
    images = imageDatastore('../Inputs/eval-data-gray/Wooden/*.png');  
else
     VideoFolder = '../Outputs/Grove_LK/Part1';
     Video_name = 'Inbuilt_Grove_LK.mp4';
     FrameOut_Folder = '../Outputs/Grove_LK/Part1/Frames';
     images = imageDatastore('../Inputs/eval-data-gray/Grove/*.png');
       
end

%% Initializing Video writing Variables
Video_obj = fullfile(VideoFolder,Video_name);
vidWriter=VideoWriter(Video_obj,'MPEG-4');
vidWriter.FrameRate = 5;
vidWriter.Quality = 98;

%% For reading image stores
nfiles = size(images.Files,1); 
open(vidWriter);

%% loop to Read Images, and estimate Flow
for k = 1: nfiles-1
    clc
    Current_name = ['OFbw',num2str(k),'&',num2str(k+1),'.jpg'];
    disp(['Tr1Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
    frame1 = readimage(images,k);
    frame2 = readimage(images,k+1);

    Doubled_1 = im2double(frame1);
    img1 = imresize(Doubled_1, 0.5);

    Doubled_2 = im2double(frame2);
    img2 = imresize(Doubled_2, 0.5);

    window_width = 50;        % wimdow size for neighborhood pixels
    w = round(window_width/2);

    % Calculating dx, dy and dz.
    
    dx_m = conv2(img1,[-1 1; -1 1], 'valid'); % partial on x
    dy_m = conv2(img1, [-1 -1; 1 1], 'valid'); % partial on y
    dt_m = conv2(img1, ones(2), 'valid') + conv2(img2, -ones(2), 'valid'); % partial on t
    u = zeros(size(img1));
    v = zeros(size(img2));

    % within window ww * ww
    for i = w+1:size(dx_m,1)-w
       for j = w+1:size(dx_m,2)-w
          Ix = dx_m(i-w:i+w, j-w:j+w);
          Iy = dy_m(i-w:i+w, j-w:j+w);
          It = dt_m(i-w:i+w, j-w:j+w);

          Ix = Ix(:);
          Iy = Iy(:);
          b = -It(:); % get b here

          A = [Ix Iy]; % get A here
          
          nu = pinv(A)*b; % get velocity here

          u(i,j)=nu(1);
          v(i,j)=nu(2);
       end
    end

    % downsizing u and v
    u_deci = u(1:10:end, 1:10:end);
    v_deci = v(1:10:end, 1:10:end);
    % get coordinate for u and v in the original frame
    [m, n] = size(Doubled_1);
    [X,Y] = meshgrid(1:n, 1:m);
    X_deci = X(1:20:end, 1:20:end);
    Y_deci = Y(1:20:end, 1:20:end);

    imshow(frame2);
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