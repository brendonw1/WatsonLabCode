function readNlxVTTests(filename)

%load epoch_limits
% luminance mask
VREC_LU_MASK = uint32(hex2dec('8000')); % the only one needed here...
% raw masks
VREC_RR_MASK = uint32(hex2dec('4000'));
VREC_RG_MASK = uint32(hex2dec('2000'));
VREC_RB_MASK = uint32(hex2dec('1000'));
% pure masks
VREC_PR_MASK = uint32(hex2dec('40000000')); %PR: Pure Red
VREC_PG_MASK = uint32(hex2dec('20000000'));
VREC_PB_MASK = uint32(hex2dec('10000000'));

VREC_X_MASK = uint32(hex2dec('00000FFF'));
VREC_Y_MASK = uint32(hex2dec('0FFF0000'));
VREC_Y_SHFT = 16;

fh = fopen(filename);

vdir = dir(filename);
nTotFrames = ceil((vdir.bytes-16384)/1828);

% read header
header = fread(fh, 16384, 'int8=>char');


frame = int8(fread(fh, 1828, 'int8'));


n_frame = 1;
n_frameAll = 1;
n_points = zeros(nTotFrames, 1);
Xextr = zeros(nTotFrames, 1);
Yextr = zeros(nTotFrames, 1);
times = zeros(nTotFrames, 1);
timesAll = zeros(nTotFrames, 1);

while ~isempty(frame) 
    swstx = typecast(frame(1:2), 'uint16');
    swid = typecast(frame(3:4), 'uint16');
    swdata_size = typecast(frame(5:6), 'uint16');
    tstamp = typecast(frame(7:14), 'uint64');
    dwPoints = typecast(frame(15:1614), 'uint32'); %400 points, thresholding on luminosity
    sncrc = typecast(frame(1615:1616), 'int16');
    dnextracted_x = typecast(frame(1617:1620), 'int32'); % Cheeta tries to exctract position X
    dnextracted_y = typecast(frame(1621:1624), 'int32'); % and Y
    dnextracted_angle = typecast(frame(1625:1628), 'int32');
    dntargets = typecast(frame(1629:1828), 'uint32');
    
    % the 400 points which changed, form 0 to 1 or opposite. If more, the
    % system overloads.
    X = bitand(dwPoints, VREC_X_MASK);
    Y = bitshift(bitand(dwPoints, VREC_Y_MASK), -VREC_Y_SHFT);
    lu = bitand(dwPoints, VREC_LU_MASK) > 0;
    rr = bitand(dwPoints, VREC_RR_MASK) > 0;
    rg = bitand(dwPoints, VREC_RG_MASK) > 0;
    rb = bitand(dwPoints, VREC_RB_MASK) > 0;
    pr = bitand(dwPoints, VREC_PR_MASK) > 0;
    pg = bitand(dwPoints, VREC_PG_MASK) > 0;
    pb = bitand(dwPoints, VREC_PB_MASK) > 0;
    all_r = [pr(1:2) pg(1:2) pb(1:2) rr(1:2) rg(1:2) rb(1:2) lu(1:2)];
   
    n_points(n_frame) = sum(X> 0);
    timesAll(n_frameAll) = tstamp;
    n_frameAll = n_frameAll + 1;
    if dnextracted_x > 10 % 0 if cheeta failed, 10 as threshold...
        n_points(n_frame) = sum(X> 0);
        Xextr(n_frame) = dnextracted_x;
        Yextr(n_frame) = dnextracted_y;
        times(n_frame) = tstamp;
        n_frame = n_frame + 1;
    end
    
%     if any(all_r(:) > 0)
%         keyboard
%     end

  
    
    if mod(n_frame, 10000) == 0
        display(n_frame);
    end
    frame = int8(fread(fh, 1828, 'int8'));
end

Xextr = Xextr(1:(n_frame-1));
Yextr = Yextr(1:(n_frame-1));
times = times(1:(n_frame-1))/100;
timesAll = timesAll/100;
n_points = n_points(1:(n_frame-1));

Xall = interp1(times, Xextr, timesAll);
Yall = interp1(times, Yextr, timesAll);

center_maze_X = (min(Xextr)+max(Xextr))/2;
center_maze_Y = (min(Yextr)+max(Yextr))/2;
phiExtr = atan2(Yextr-center_maze_Y, Xextr-center_maze_X);
phiAll = interp1(times, phiExtr, timesAll);

X = tsd(timesAll, Xall);
Y = tsd(timesAll, Yall);
phi = tsd(timesAll, phiAll);

save n_points n_points Xextr Yextr X Y phi times
