%% Amplitude discrimination
% close all
clear all
data_folder = 'P:\analysis\human\uh3_stim\Sensory Analysis\Psychophysics\Psychophysics\Psychophysics';
%% Example
% separate amplitude and frequency
targets = [0.25, 0.5, 0.75];
subject = {'LSP02b' , 'LSP05', 'LNP02'};
col = hex2rgb(['#49A548'; '#266DA3'; '#7D679C']);
% col = rand(3,3);

info = struct(); %'elec',[], 'set', [],  'date', [], 'ref', [], 'idx', {}
Thres = {}; Ref = {}; JND = {}; fineX = {}; curve = {}; Weber = {};
amp={}; prop_correct = {};
for subj=1:3

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
                if sum(elec_date_set_idx)>6
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
        % all references for this electrode
        all_ref = unique(info(subj).ref(info(subj).elec == elec));
        for rv=1:length(all_ref)
            ref_sets = (info(subj).ref == all_ref(rv)) & (info(subj).elec == elec);
            trial_ref_idx = logical(sum(cell2mat(info(subj).idx(ref_sets)'),1));

            [prop, alt_range, alt_range_perc] = amp_disc(all_ref(rv), int1(trial_ref_idx), int2(trial_ref_idx), dec(trial_ref_idx));
            amp{subj}{elec}{rv} = alt_range;
            prop_correct{subj}{elec}{rv} = prop';
            alt_range = [alt_range min(alt_range)-500 max(alt_range)+1000];
            prop = [prop 0 1];

            weights = ones(1,length(alt_range)); 

            [coeffs, ~, threshold] = ...
                FitPsycheCurveLogit(alt_range, prop, weights, targets);
            Thres{subj}{elec}(rv,:) = threshold/1000;
            JND{subj}{elec}(rv) = (threshold(3)-threshold(1))/2000;
            Weber{subj}{elec}(rv) = JND{subj}{elec}(rv)/(all_ref(rv)/1000);
            Ref{subj}{elec}(rv) = all_ref(rv)/1000;
            fineX{subj}{elec}{rv} = linspace(all_ref(rv)*0.4,all_ref(rv)*1.6,numel(alt_range)*100);
            curve{subj}{elec}{rv} = glmval(coeffs, fineX{subj}{elec}{rv}, 'logit');

        end
    end
end



%% Suplementary figure 6
%% Weber fraction (A)
figure
subplot(2,1,1)
plot(Ref{1}{1}, Weber{1}{1},'o-', 'LineWidth', 2, 'Color', col(1,:), 'MarkerFaceColor', col(1,:))
hold on
plot(Ref{2}{3}, Weber{2}{3},'o-', 'LineWidth', 2, 'Color', col(2,:), 'MarkerFaceColor', col(2,:))
ylim([0 0.2])
ylabel('Weber fraction')
xlabel('Reference amplitude, mA')
box off
% set(gca, 'FontSize', 14)


%% JND (B)
subplot(2,1,2)
plot(Ref{1}{1}, JND{1}{1},'o-', 'LineWidth', 2, 'Color', col(1,:), 'MarkerFaceColor', col(1,:))
hold on
plot(Ref{2}{3}, JND{2}{3},'o-', 'LineWidth', 2, 'Color', col(2,:), 'MarkerFaceColor', col(2,:))
ylim([0 0.4])
ylabel('JND, mA')
xlabel('Reference amplitude, mA')
box off
% set(gca, 'FontSize', 14)
