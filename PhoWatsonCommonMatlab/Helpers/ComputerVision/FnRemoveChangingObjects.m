function [frameResult] = FnRemoveChangingObjects(frameA, frameB, inter_frame_change_min_change, should_debug_print_intermediates, should_normalize)
%% FnRemoveChangingObjects Takes two frames where the mouse is in different, non-overlapping regions, but everything else remains the same.
	
    if ~exist('inter_frame_change_min_change', 'var')
        inter_frame_change_min_change = 8;
    end
    
    if ~exist('should_debug_print_intermediates','var')
        should_debug_print_intermediates = false;
    end
    
    if ~exist('should_normalize','var')
        should_normalize = true;
    end
    
    if should_debug_print_intermediates
        imshow(frameA)
        imshow(frameB)
    end
    
    % Process the difference between the frames:
    if should_normalize
        [inter_frame_change, ~] = FnComputeNormalizedDifferenceFromBaseline(frameB, frameA);
    else
        inter_frame_change = abs(frameA - frameB);
    end
    
    
    if should_debug_print_intermediates
        % Inter-frame change Plot:
        h2 = imagesc(inter_frame_change);
        set(gca,'xtick',[])
        set(gca,'xticklabel',[])
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
        set(gca,'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[320,256,1]);
        title('inter frame change')
        colorbar
    end
    
    
    inter_frame_change_mask = (inter_frame_change > inter_frame_change_min_change);
    if should_debug_print_intermediates
        imshow(inter_frame_change_mask)
        title('inter_frame_change_mask')
    end
    % Uses the mask to replace the pixels in frameA that changed between the two frames with the pixels in frameB (which don't have the mouse)
    frameA(inter_frame_change_mask) = frameB(inter_frame_change_mask);
    frameResult = imcomplement(frameA);

end

