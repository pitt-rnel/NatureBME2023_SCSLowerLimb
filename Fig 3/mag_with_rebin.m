function [stim_rebinned, mean_mag, se_mag] = mag_with_rebin(stim, mag, bin_size)
%     stim = round(stim/100)*100;

    % add the rebinning proceedure
%     [N,EDGES,BIN] = histcounts(stim, 500:500:3500)

%     bin_size = 1000;
    edges = 0:bin_size:(max(stim)+bin_size);

    alt_range_bin = discretize(stim, edges);

    alt_range_rebinned = []; mean_mag =[];
    k = 1;
    for b = unique(alt_range_bin)
        stim_in_range = (ismember(stim,stim(alt_range_bin==b)));
        if sum(stim_in_range)>5
        mean_mag(k) = mean(mag(stim_in_range));
        se_mag(k) = std(mag(stim_in_range))/sqrt(length(mag(stim_in_range)));
        stim_rebinned(k) = mean(stim(alt_range_bin==b));
        k=k+1;
        end
    end


    
  
end