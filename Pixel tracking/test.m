filename = 'video4.avi';

hVideoSource = vision.VideoFileReader(filename, ...
                                      'ImageColorSpace', 'Intensity',...
                                      'VideoOutputDataType', 'double');
									  
									  
hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                            'BestMatchNeighborhoodOutputPort', true);

hVideoOut = vision.VideoPlayer('Name', 'Video Stabilization');
hVideoOut.Position(1) = round(0.4*hVideoOut.Position(1));
%hVideoOut.Position(2) = round(1.5*(hVideoOut.Position(2)));
%hVideoOut.Position(3:4) = [650 350];							

pos.template_orig = [194 79]; % [x y] upper left corner
pos.template_size = [50 69];   % [width height]
pos.search_border = [28 17];   % max horizontal and vertical displacement
pos.template_center = floor((pos.template_size - 1)/2);
pos.template_center_pos = (pos.template_orig + pos.template_center -1 );
fileInfo = info(hVideoSource);
W = fileInfo.VideoSize(1); % Width in pixels
H = fileInfo.VideoSize(2); % Height in pixels
BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
sz = fileInfo.VideoSize;
TargetRowIndices = ...
  pos.template_orig(2)-1:pos.template_orig(2)+pos.template_size(2)-2;
TargetColIndices = ...
  pos.template_orig(1)-1:pos.template_orig(1)+pos.template_size(1)-2;
SearchRegion = pos.template_orig - pos.search_border - 1;
Offset = [0 0];
Target = zeros(18,22);
firstTime = true;


while ~isDone(hVideoSource)
    input = step(hVideoSource);

    % Find location of Target in the input video frame
    if firstTime
      Idx = int32(pos.template_center_pos);
      Midx = Idx;
      Kidx = Idx;
      MotionVector = [0 0];
      
      kalmanFilter = configureKalmanFilter('ConstantAcceleration',...
          Idx, ones(1, 3), [100, 100, 10], 25);
      
      firstTime = false;
    else
      IdxPrev = Idx;
      
      ROI = [SearchRegion, pos.template_size+2*pos.search_border]; 
      Idx = step(hTM, input, Target, ROI);
      Midx = [Midx;Idx];
      %kalman filter correction
      predict(kalmanFilter);
      Idx = int32(correct(kalmanFilter, Idx));
      %Kidx = [Kidx;Idx];
      MotionVector = double(Idx-IdxPrev);
    end

    [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
        SearchRegion, Offset, pos);

    % Translate video frame to offset the camera motion
    Stabilized = imtranslate(input, Offset, 'linear');

    Target = Stabilized(TargetRowIndices, TargetColIndices); % Mesured target
     
    %[TargetRowIndices, TargetColIndices] = FindRect(Idx,int32(pos.template_size));
    
    %Target = input(TargetRowIndices, TargetColIndices);
    % Add black border for display
    Stabilized(:, BorderCols) = 0;
    Stabilized(BorderRows, :) = 0;

    TargetRect = [pos.template_orig-Offset, pos.template_size];
    
    SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];
    imshow(input)
	hold on;
	plot(Idx(1),Idx(2),'r.','MarkerSize',20)
	
    % Draw rectangles on input to show target and search region
    input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                        'Color', 'white');
    % Display the offset (displacement) values on the input image
    txt = sprintf('(%+05.1f,%+05.1f)', Offset);
    input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, ...
                    'TextColor', 'white', 'BoxOpacity', 0);
    % Display video
    %step(hVideoOut, [input(:,:,1) Stabilized]);
    step(hVideoOut,input(:,:,1));
    %waitfor(msgbox(sprintf('Taget pos: %d %d\nOffset %d %d\n Continue',Idx(1),Idx(2),Offset(1),Offset(2))));
end

hold off;