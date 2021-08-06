function createSpectrogramVideoFromAudio(wavFileName, numScreens, chartTitle, resolution)

%
% function createSpectrumVideoFromAudio()
%
% This function reads a .wav audio file and creates an animated .mp4: in each
% frame of the video file, a seperate audio window is presented, along with
% the corresponding spectrogram.
%
% ARGUMENTS:
% wavFileName: the name of the .wav file to read
% numScreens: optional. default 1. the number of windows/screens to be plotted in the videofile
% chartTitle: optional. default 'Spectrogram'. title of the chart
% resolution: optional. default 1920x1080 video size. must be either 1920 or 1280.
%
%
% EXAMPLE:
% The following line will read b.wav, will split the file into 2
% windows/screens (non-overlapping), name the video "Bird Spectrogram
% and will create a video file (of 1280x720 pixels):
%
% >> createSpectrogramVideoFromAudio('b.wav',2,'Bird Spectrogram',1280);
% 
% I started with gif animation code by: Theodoros Giannakopoulos
% http://www.di.uoa.gr/~tyiannak
% createAnimatedGifFromWav();
% found at: https://www.mathworks.com/matlabcentral/fileexchange/19933-generate-animated-gif-files-for-plotting-audio-data
%
% Updated code to video output with vars by:
%  ----------------------------------
% | Jon Bellona                      |
% | https://jpbellona.com            |
%  ----------------------------------

% NOTE: the function simply generates a 'gif' like .mp4 video of spectrogram charts that match the length of the audio file. 
% the function does NOT embed audio to the video, nor provide a scrolling
% playback bar/line. I created a template in Adobe Premiere to serve my use of
% audio sync and playback barline. Since the video file is the same length
% as the audio file, a video editor uses basic snap alignment to sync.



% screen output resolution of video
% optional fourth argument
% only works with 1920 and 1280. anything else doesn't resize.
if nargin < 4
    resolution = 1920;
end

% embed a title 
% optional third argument
if nargin < 3
    chartTitle = 'Spectrogram';
end

% default pages/screens to 1.
% optional second argument
if nargin < 2
    numScreens = 1;
end

% initial index of audio data:
I = 1;

% read audio data:
[x,fs] = audioread(wavFileName);
% get length in seconds and use as window length
lenInSec = length(x)/fs;

% pages/screens based upon variable. default is 1
windowLength = lenInSec / numScreens

% convert window value from time to samples:
%VARS UPDATE
win = (windowLength * fs) - 2; %need two samples less so you can run the while loop

% set frames per second of pages/screens in video to match window length
framesPerSec = 1/windowLength; 

% frame time interval: gif only
% framesT = 1/framesPerSec;


% initialize figure:
h = figure;
Loop = {'LoopCount',Inf};
count = 0;

% total number of audio windows (and corresponding frames in video file):
% total = floor((length(x)-win) / (win));
total = numScreens;


% NEW bellona create video
outputVideo = VideoWriter('animated_SpectrumVideo.mp4','MPEG-4');
outputVideo.FrameRate = framesPerSec;
open(outputVideo)

% main loop:
while (I+win<length(x)) % while reading audio data:
    
    % get current audio data:
    tempX = x(floor(I):floor(I+win)); %use floor so integers are used with colon operator
        
    
%   plot the spectrogram in full screen
    pspectrum(tempX,fs,'spectrogram','FrequencyLimits',[100 10000],'TimeResolution',0.05,'MinThreshold',-80);
    
    
% rescale the data to fit window
%      axis tight
       ax = gca;
        ax.PlotBoxAspectRatioMode = 'manual';
        ax.PlotBoxAspectRatio = [ 3 1 1 ];
        ax.DataAspectRatioMode = 'manual';
        ax.DataAspectRatio = [ 3 1 1 ];
      
% log scale frequency
       ax.YScale = 'log';
       yticks([0.125, 0.25, 0.5, 1, 2, 4, 8, 10]);
       yticklabels({'125','250','500','1k','2k','4k','8k','10k'})

    %waterfall view with spectrogram
%   view(-45,65)'
    
    %colormap change if desired
%   colormap bone;

    title(chartTitle)
    ylabel('frequency');
    
    % base the xlabel upon length of the audio file
    if windowLength > 1
        xlabel('seconds');
    
        % use windowLength to create xticks that match based upon windowLength
        prefix = count-1; %start at 0
        labels = 1:windowLength+1; %numeric array you'll turn to strings later
        xticks(1:windowLength+1);

        % loop and populate array of labels as numbers (use floor to get ints on
        %uneven length audio files
        for i = 1:floor(windowLength)
            labels(1,i) = prefix*floor(windowLength)+i;
        end

        labels = string(labels); %convert to string array
        xticklabels(labels);     %update the xticklabels

    else
        xlabel('milliseconds');
        
        %get labels and update based upon which page/screen
        prefix = count-1; %start at 0
        j = floor(windowLength * 10); %number of ticks based upon window
        labels = (prefix*j) + floor(windowLength * 10);
        
        % loop for each page
        for i = 1:j
            xl = xticklabels;
            xcl = str2num(cell2mat(xl));
            xcl = (labels*100) + xcl;
            xcl = num2str(xcl);
            xl = cellstr(xcl);
        end
        
        xticklabels(xl); %update labels
    
    end


      %limit with spectrogram
%      ylim(ax, [0.1,5]); %kHz
    
%   resize to HD video
    fig = gcf;

    if resolution == 1280
      %resize to produce 1280x720 HD video, odd use of points
      fig.PaperUnits = 'points';
      fig.PaperPosition = [100 100 614 345];
    elseif resolution == 1920
      %this actually produces 1920x1080p video 
      fig.OuterPosition = [200 200 921 591]; 
    end        

    % update window position:
    I = I + win;
    
    % save current figure in temporary jpeg file...
    saveas(h,'imageTemp', 'jpg');
    
    count = count + 1
    fprintf('Saving Image %d of %d\n',count, total);
    
    % ... and get image data:
    RGB = imread('imageTemp.jpg'); 
   
    % convert to indexed image (256 colors used):
%      [ind,map]=rgb2ind(RGB,256);

    % add image to video sequence
    writeVideo(outputVideo,RGB);
end




