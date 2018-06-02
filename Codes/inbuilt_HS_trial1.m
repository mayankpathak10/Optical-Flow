close all
clear all

% Wooden = 1, Groove = 2
Current_Dataset = 2;
if Current_Dataset == 1
    VideoFolder = '../Outputs/Wooden_LK/Part2';
    Video_name = 'Inbuilt_Wooden_LK.mp4';
    FrameOut_Folder = '../Outputs/Wooden_LK/Part2/Frames';
    images = imageDatastore('../Inputs/eval-data-gray/Wooden/*.png');  
else
     VideoFolder = '../Outputs/Grove_LK/Part2';
     Video_name = 'Inbuilt_Grove_LK.mp4';
     FrameOut_Folder = '../Outputs/Grove_LK/Part2/Frames';
     images = imageDatastore('../Inputs/eval-data-gray/Grove/*.png');
       
end

Video_obj = fullfile(VideoFolder,Video_name);
vidWriter=VideoWriter(Video_obj,'MPEG-4');
vidWriter.FrameRate = 5;
vidWriter.Quality = 98;

nfiles = size(images.Files,1); 
open(vidWriter);
opticFlow = opticalFlowHS;

for k = 1: nfiles-1
    clc
    Current_name = ['Inbuilt_HSOFbw',num2str(k),'&',num2str(k+1),'.jpg'];
    disp(['Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
    fr1 = readimage(images,k);
    fr2 = readimage(images,k+1);

    
    flow = estimateFlow(opticFlow,fr1);
    imshow(fr1) 
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',25)
    title(['In-built HS Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
%     hold off 
% 
%     % downsize u and v
%     u_deci = u(1:10:end, 1:10:end);
%     v_deci = v(1:10:end, 1:10:end);
%     % get coordinate for u and v in the original frame
%     [m, n] = size(im1t);
%     [X,Y] = meshgrid(1:n, 1:m);
%     X_deci = X(1:20:end, 1:20:end);
%     Y_deci = Y(1:20:end, 1:20:end);
% 
%     imshow(fr2);
%     hold on;
%     % draw the velocity vectors
%     quiver(X_deci, Y_deci, u_deci,v_deci, 'y')
%     title(['Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
%     
    frame = gcf();
    Frame_name = fullfile(FrameOut_Folder,Current_name);
    saveas(frame,Frame_name)
    Current_image = imread(Frame_name);
    writeVideo(vidWriter,Current_image);
    hold off
end

close(vidWriter);