function [prop, alt_range_rebinned, num_obs, perc1] = detection_with_rebin(int1, int2, dec, bin_size)

    % dec - 1/2 interval of choice
    ref = 0;

    alt_range = setdiff(unique([int1; int2])',ref);

%     bin_size = 100;
    edges = 0:bin_size:(max(alt_range)+bin_size);

    alt_range_bin = discretize(alt_range, edges);

    alt_range_rebinned = []; idx1_rebinned = nan(size(int1)); idx1_rebinned = nan(size(int2));
    k = 1;
    for b = unique(alt_range_bin)
        idx_in_range1 = (ismember(int1,alt_range(alt_range_bin==b)));
        idx_in_range2 = (ismember(int2,alt_range(alt_range_bin==b)));
        alt_range_rebinned(k) = round(mean([int1(idx_in_range1) int2(idx_in_range2)]));
        idx1_rebinned(idx_in_range1) = alt_range_rebinned(k);
        idx2_rebinned(idx_in_range2) = alt_range_rebinned(k);
        k=k+1;
    end
    idx1_rebinned(int1==ref) = ref;
    idx2_rebinned(int2==ref) = ref;

    idx1 = (idx1_rebinned>=idx2_rebinned) & dec==1;
    idx2 = (idx1_rebinned<idx2_rebinned) & dec==2;
    outcome = zeros(size(dec));
    outcome(idx1 | idx2) = 1;

    prop=[]; num_obs =[]; perc1 = []; k=1;

    for d = alt_range_rebinned

       if d==ref
           idx = find(idx1_rebinned==d & idx2_rebinned==d);
       else
           idx = find(idx1_rebinned==d | idx2_rebinned==d);
       end

       if d<ref
           prop(k) = 1 - sum(outcome(idx))/length(idx);   
       else
           prop(k) = sum(outcome(idx))/length(idx);
       end

       num_obs(k) = length(idx);
       perc1(k) = length(find(idx1_rebinned(idx)==ref))/length(idx);
       k=k+1;
    end
    
    min_num_obs = 5;
    idx_nans=find(num_obs < min_num_obs); % & abs(0.5-perc1)>0.2);
    alt_range_rebinned(idx_nans)=[];
    prop(idx_nans)=[];
    perc1(idx_nans)=[];
    num_obs(idx_nans)=[];
    
%     targets = [0.25, 0.5, 0.75];
%     weights = ones(1,length(alt_range_rebinned)); 
%     % Fit for neutral background
%     [coeffs, ~, threshold] = ...
%         FitPsycheCurveLogit(alt_range_rebinned, prop, weights, targets);
%     fineX = linspace(min(alt_range_rebinned)-1000,max(alt_range_rebinned)+1000,numel(alt_range_rebinned)*100);
%     % Generate curve from fit
%     curve = glmval(coeffs, fineX, 'logit');
 

   

end