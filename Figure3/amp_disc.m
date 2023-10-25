function [prop, alt_range, alt_range_perc] = amp_disc(ref, int1, int2, dec)

    % dec - 1/2 interval of choice
    idx1 = (int1>=int2) & dec==1;
    idx2 = (int1<int2) & dec==2;
    outcome = zeros(size(dec));
    outcome(idx1 | idx2) = 1;

    alt_range = unique([int1; int2])';
    
    prop=[]; num_obs =[]; perc1 = []; k=1;
    for d = alt_range

       if d==ref
           idx = find(int1==d & int2==d);
       else
           idx = find(int1==d | int2==d);
       end

       if d<ref
           prop(k) = 1 - sum(outcome(idx))/length(idx);   
       else
           prop(k) = sum(outcome(idx))/length(idx);
       end

       num_obs(k) = length(idx);
       perc1(k) = length(find(int1(idx)==ref))/length(idx);
       k=k+1;
    end
    
    min_num_obs = 5;
    idx_nans=find(num_obs < min_num_obs);
    alt_range(idx_nans)=[];
    prop(idx_nans)=[];
    perc1(idx_nans)=[];
    num_obs(idx_nans)=[];
    
    targets = [0.25, 0.5, 0.75];
    weights = ones(1,length(alt_range)); 
    % Fit for neutral background
    [coeffs, ~, threshold] = ...
        FitPsycheCurveLogit(alt_range, prop, weights, targets);
    fineX = linspace(min(alt_range)-1000,max(alt_range)+1000,numel(alt_range)*100);
    % Generate curve from fit
    curve = glmval(coeffs, fineX, 'logit');

    alt_range_perc = alt_range/ref;

end