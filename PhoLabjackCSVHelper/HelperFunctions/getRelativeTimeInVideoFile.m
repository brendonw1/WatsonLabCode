function videoRelativeTimestamp = getRelativeTimeInVideoFile(videoFile,absoluteDateTime)
%getRelativeTimeInVideoFile gets the amount of time into the video file
%from an absolute (wall-time) timestamp
    if (isbetween(absoluteDateTime,videoFile.parsedDateTime,videoFile.parsedEndDateTime))
        videoRelativeTimestamp = absoluteDateTime - videoFile.parsedDateTime;
    else
       videoRelativeTimestamp = NaN; 
    end
end