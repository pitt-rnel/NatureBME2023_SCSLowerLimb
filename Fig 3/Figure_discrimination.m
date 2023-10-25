%% Amplitude discrimination
% Plot example psychophysics curve
% Compute and plot JND distributions

% close all
clear all
% data location
data_folder = 'D:\Lower limb\data\Psychophysics_updated\Psychophysics';
% percentiles for JND
targets = [0.25, 0.5, 0.75];
subject = {'LSP02b' , 'LSP05', 'LNP02'};
% col = hex2rgb(['#49A548'; '#266DA3'; '#7D679C']); old colors
col = [22 151 154;
    79 120 188;
    175 95 159]/256;
min_reps = 5;

info = struct(); unipolar = {};
Thres = {}; Ref = {}; JND = {}; fineX = {}; curve = {}; Weber = {};
amp={}; prop_correct = {};
for subj=1:length(subject)

    load(fullfile(data_folder, [subject{subj} '_Discrimination.mat']))
    Data = Discrimination;

    % sessions
    session = {Data.Session_number};
    all_sessions = unique(session);

    % dates (most likely equivalent to session num
    date = cellfun(@(x) x(1:10), {Data.Date},'UniformOutput', false);
    all_dates = unique(date);

    % amplitude or frequency
    type = {Data.varyingParameterType};
    all_types = unique(type);

    % all electrodes
    electrode = {Data.electrodeLabel};
    all_electrodes = unique(electrode);
    electrode_labels = cellfun(@(x) strrep(x, '_', ''), all_electrodes, 'UniformOutput', false);
    unipolar{subj} = cellfun(@(x) contains(x, 'Unipolar'), electrode_labels, 'UniformOutput', true);

    % set
    set = {Data.Set_number};
    all_sets = unique(set);
    set_labels = cellfun(@(x) strrep(x, '_', ''), all_sets, 'UniformOutput', false);

    % intervals and decisions
    int1 = [Data.Value_Interval1];
    int2 = [Data.Value_Interval2];
    dec = [Data.User_Answer];

    % pick parying parameters (likely amplitude)
    idx_type = strcmp(type, 'Amplitude');

    % rearrange data according to date, set and reference amplitude
    k = 1;
    for elec = 1:length(all_electrodes)
        elec_idx = idx_type & strcmp(electrode, all_electrodes{elec});
        % find on what dates this electrode was tested
        elec_dates = unique(date(elec_idx));

        % for each day, find set numbers
        for d = 1:length(elec_dates)
            elec_date_idx = elec_idx & strcmp(date, elec_dates{d});
            elec_date_sets = unique(set(elec_date_idx));
            % for each set 
            for s =  1:length(elec_date_sets)
                elec_date_set_idx = elec_date_idx & strcmp(set, elec_date_sets{s});
                if sum(elec_date_set_idx)>min_reps
                    info(subj).date(k) = d;
                    info(subj).set(k) = s;
                    info(subj).elec(k) = elec;
                    info(subj).ref(k) = mode([int1(elec_date_set_idx) int2(elec_date_set_idx)]);
                    info(subj).idx{k} = elec_date_set_idx;
                    k = k+1;
                end
            end
        end
    end

    % for each electrode, group sets with the same reference and plot psych curves
    for elec = 1:length(all_electrodes)
        figure
        % all references for this electrode
        all_ref = unique(info(subj).ref(info(subj).elec == elec));
        for rv=1:length(all_ref)
            ref_sets = (info(subj).ref == all_ref(rv)) & (info(subj).elec == elec);
            trial_ref_idx = logical(sum(cell2mat(info(subj).idx(ref_sets)'),1));

            [prop, alt_range, alt_range_perc] = amp_disc(all_ref(rv), int1(trial_ref_idx), int2(trial_ref_idx), dec(trial_ref_idx));
            amp{subj}{elec}{rv} = alt_range;
            prop_correct{subj}{elec}{rv} = prop';

            weights = ones(1,length(alt_range)); 
            % Fit for neutral background
            [coeffs, ~, threshold] = ...
                FitPsycheCurveLogit(alt_range, prop, weights, targets);
            Thres{subj}{elec}(rv,:) = threshold/1000;
            JND{subj}{elec}(rv) = (threshold(3)-threshold(1))/2000;
            Weber{subj}{elec}(rv) = JND{subj}{elec}(rv)/all_ref(rv);
            Ref{subj}{elec}(rv) = all_ref(rv)/1000;
            fineX{subj}{elec}{rv} = linspace(all_ref(rv)*0.4,all_ref(rv)*1.6,numel(alt_range)*100);
            % Generate curve from fit
            curve{subj}{elec}{rv} = glmval(coeffs, fineX{subj}{elec}{rv}, 'logit');

            subplot(2,round(length(all_ref)/2), rv)
            plot(alt_range/all_ref(rv), prop,'.','color', col(subj,:), 'MarkerSize', 20)
            hold on
            plot(fineX{subj}{elec}{rv}/all_ref(rv), curve{subj}{elec}{rv}, 'k', 'LineWidth', 1.8)
            xlims = xlim;
            ylim([0 1]); xlim([0.5 1.5]);
            title(['Ref ' num2str(all_ref(rv))])
            sgtitle([electrode_labels{elec}])
            box off
            xlabel('% Reference amplitude')
            ylabel('Proportion correct')

        end
    end
end

%% Figure for paper
%% Example psych curve (C)
marker_type = {'diamond', 'o'};

clear set
figure
subplot(1,2,1)
s = 3; elec = 2; ref = 1;
y_loc = [-0.01 -0.03 -0.02];
for s =  3
    scatter((amp{s}{elec}{ref}/1000), prop_correct{s}{elec}{ref},marker_type{unipolar{s}(elec)+1},'MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.6, 'MarkerFaceColor', col(s,:),'MarkerEdgeColor', col(s,:))
    hold on
    plot((fineX{s}{elec}{ref}/1000), curve{s}{elec}{ref}, 'color', col(s,:), 'LineWidth', 2.4)
    plot([0.1 Thres{s}{elec}(ref,1)], [0.25 0.25], ':k', 'LineWidth', 1.8)
    plot([0.1 Thres{s}{elec}(ref,3)], [0.75 0.75], ':k', 'LineWidth', 1.8)
    plot([Thres{s}{elec}(ref,1) Thres{s}{elec}(ref,1)], [y_loc(s) 0.25], ':', 'color', col(s,:), 'LineWidth', 1.8)
    plot([Thres{s}{elec}(ref,3) Thres{s}{elec}(ref,3)], [y_loc(s) 0.75], ':', 'color', col(s,:), 'LineWidth', 1.8)
    plot([Thres{s}{elec}(ref,1) Thres{s}{elec}(ref,3)], ...
        [y_loc(s) y_loc(s)], 'color', col(s,:), 'LineWidth', 2.5)
end
ylim([-0.035 1]); 
xlim([0.8 3]);
xlabel('Amplitude, mA')
ylabel('P (judged stronger)')
clear set
set(gca, 'Ytick', 0:0.25:1, 'YTickLabel', 0:0.25:1)

box off
set(gca, 'FontSize', 14)


%% Pool all JNDs and plot (D)

subplot(1,2,2)
hold on
for s = 1:3
    for pol = [0 1]
       tmp = cell2mat(JND{s}(unipolar{s}==pol));
       tmp(tmp>1) = [];
       SymphonicBeeSwarm(s, tmp, col(s,:), 40, 'MarkerType', marker_type{pol+1}, 'DistributionWidth', 0.15, 'CenterMethod', 'none', 'DistributionMethod','Histogram')
       hold on
    end
end
hold on
ylim([0 .4]); xlim([0.3 3.7])
ylabel('JND, mA')
xlabel('Subject')
h = gca;
set(gca, 'FontSize', 14)
set(gca, 'Ytick', 0:.1:0.4, 'YTickLabel', 0:.1:0.4, 'Xtick', 1:3, 'XTickLabel',1:3)

fh = findall(0,'Type','Figure');
txt_obj = findall(fh,'Type','text');
set(txt_obj,'FontName','Calibri','FontSize',17);



