function AllSpkWaveform(basename,Nshank,nChan)


% Based on code 'PyrInterneurons_step1' by Alfonso Renart & Artur Luczak
%
% ----Alfonso's commnets;
% This function goes over all the dat file FileN and makes 
% a 3D array (SpkWvform_all) whose 1st dimension is cluster
% identity, 2nd ch number and 3rd time (in samples) across 
% the waveform. Currently, all clusters in all clu files are 
% examined throught the whole duration of the dat file. This 
% program should be used along with PryInterneurons_step2 to 
% cluster waveforms into E or I.

FileN = [basename '.']; %basename

w = 60; % window around spike (w=60==3ms at 20kHz)

ij = 1;

for i_shank = 1:Nshank % 9    <---------------- make sure it is correct ---

    % --- find times of spikes    
    shank = num2str( i_shank ); % shank number
    clu = LoadClu([FileN 'clu.' shank ] );%
    Fp = fopen([FileN 'res.' shank ], 'r'); 
    res = fscanf(Fp, '%d');  
    fclose(Fp);   % read spike times    

    step = 1e5; % number of data points to be read from file on each chunk
    Par.nChannels = nChan; %63;   % define number of channels if no par file

    Fp = fopen([FileN 'dat'], 'r'); % open dat file

    spk_wf = zeros(max(clu),Par.nChannels,w*2+1); % array with spike waveforms
    % 1st dimension: cluster identity
    % 2nd dimention: number of channels
    % 3rd dimension: samples within the waveform

    i = 1; % i=50==41min of 20kHz data 
    lfp = 1;
    while ~isempty( lfp ) % read .dat file 

        lfp = fread(Fp, [Par.nChannels step],'int16');  % take chunk of LFP of size = step 
        % fread reads incrementally, so next time it's called it starts
        % from the previous position + 1.
        % With this syntax, the data read (lfp) is a matrix of dim nChan x step 
        if size(lfp,2)<step;continue;end                                                    %% shige

        v = (i-1)*step+1:i*step; % current set of samples to be considered
        f_res = find( res > v(1)+w & res < v(end)-w) ; %find spikes from all cells
        % within current chunk. each element of f_res is a time in samples

       %  [i_shank i size(lfp)]

        % --- take lfp around spike time
        for j = 1:size(f_res,1)-2 % each j corresponds to a single waveform
            if max(clu)>=2                                                  %% shige added 100709
              c = clu( f_res( j )); % find cluster to which waveform belongs
              if c > 1        % exclude clusters: 0, 1
                  spk_wf(c,:,:) =  squeeze( spk_wf( c,:,:)) + ...
                  lfp( :,res(f_res( j ))-w-v(1):res(f_res( j ))+w-v(1)); 
                  % each succesive spike from each cluster is added onto
                % spk_wf, for all channels in the record.
              end
            end
        end
        i=i+1;
    end
    fclose(Fp);

    if size(spk_wf,1)>=2                             %% This part is the only deferrence from Alfonso's
      for n =2:size(spk_wf,1) % loop over clusters   %% original code. clu==1 is excluded here.
          SpkWvform_all(ij,:,:) = spk_wf( n, :,:);   %%
          SpkWvform_idx(ij,:)   = [ij,i_shank,n];    %% = spikeph
          ij=ij+1;
      end
    end

    disp(['done with shank ' num2str(i_shank)])
end

save( ['AllSpikeWavs_' FileN 'mat'],'SpkWvform_all', 'SpkWvform_idx');

return
