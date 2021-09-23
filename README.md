# spectrogram-video-from-audio
Matlab function code to generate a spectrogram .mp4 video 'gif' from audio files.

This function reads a .wav audio file and creates an animated .mp4: in each frame of the video file, a seperate audio window is presented, along with the corresponding spectrogram.

Please note, the function simply generates a 'gif' like .mp4 video of spectrogram charts that match the length of the audio file. The function does NOT embed audio to the video, nor provide a scrolling playbar bar. I created a template in Adobe Premiere to serve my use of audio sync and playback barline. Since the video file is the same length as the audio file, a video editor uses basic snap alignment to sync.

<hr>
Article describing this code and it's use: https://blogs.uoregon.edu/soundscapesofsocioecologicalsuccession/2021/08/05/spectrogram-videos-of-audio-files/ <br/>
Project this code was used for: https://blogs.uoregon.edu/soundscapesofsocioecologicalsuccession/
