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
     FrameOut_Folder = '../Outputs/Grove_LK/part2/Frames';
     images = imageDatastore('../Inputs/eval-data-gray/Grove/*.png');
       
end

Video_obj = fullfile(VideoFolder,Video_name);
vidWriter=VideoWriter(Video_obj,'MPEG-4');
vidWriter.FrameRate = 5;
vidWriter.Quality = 98;

nfiles = size(images.Files,1); 
open(vidWriter);
opticFlow = opticalFlowFarneback( 'FilterSize',500,'NeighborhoodSize',15);

for k = 1: nfiles-1
    clc
    Current_name = ['Inbuilt_FBOFbw',num2str(k),'&',num2str(k+1),'.jpg'];
    disp(['Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
    fr1 = readimage(images,k);
    fr2 = readimage(images,k+1);
    
    flow = estimateFlow(opticFlow,fr1);
    imshow(fr1) 
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',25)
    title(['In-bulit FB Optical Flow between Frame No.: ',num2str(k),' and ',num2str(k+1)]);
    hold off 
    
    frame = gcf();
    Frame_name = fullfile(FrameOut_Folder,Current_name);
    saveas(frame,Frame_name)
    Current_image = imread(Frame_name);
    writeVideo(vidWriter,Current_image);

end

close(vidWriter);