%% Combine all sessions across days
%% Magnitude estimation
close all
clear all
data_folder = '';

discard = {'2018-10-23Set01', '2020-02-05Set015'};

subject = {'LSP02b' , 'LSP05', 'LNP02'};
col = [22 151 154;
    79 120 188;
    175 95 159]/256;

fineX = {};
stim = {}; mean_mag = {}; se_mag = {};
mag_tbl = [];
for s = 1:length(subject)

    [~,~,MagEst]=xlsread(fullfile(data_folder, [subject{s} '_MagEst.xlsx']));
    
    Data = MagEst;
    Data=cell2struct(Data',{'Date','Session_number','Set_number','electrodeLabel','varyingParameterType','ReportedMagnitude','varyingParameterValue'});
    electrode_labels = unique({Data.electrodeLabel});
    unipolar{s} = cellfun(@(x) contains(x, 'Unipolar'), electrode_labels, 'UniformOutput', true);

    set_labels = unique({Data.Set_number});
    set_number = cellfun(@(x) strrep(x, '_', ''), {Data.Set_number}, 'UniformOutput', false);
    stim_values = [Data.varyingParameterValue];
    mag_values = [Data.ReportedMagnitude];
    dates = cellfun(@(x) x(1:10), {Data.Date},'UniformOutput', false);
    length(unique(dates))

    for elec = 1:length(electrode_labels)
        elec_idx = find(strcmp({Data.electrodeLabel}, electrode_labels{elec}));
        set_labels = unique(set_number(elec_idx));
        date_labels = unique(dates(elec_idx));
        norm_mag_values = []; pooled_stim_values = []; legend_names = {}; k=1;
        for d = 1:length(date_labels)
            norm_mag_values = []; pooled_stim_values = []; 
            for st = 1:length(set_labels)
                % find samples for each set and electrode
                trial_idx = strcmp({Data.electrodeLabel}, electrode_labels{elec}) & strcmp(set_number, set_labels{st}) & strcmp(dates, date_labels{d});
                if sum(trial_idx)>15 && ~any(strcmp(discard,[date_labels{d} set_labels{st}]))
                    norm_mag_values = [norm_mag_values mag_values(trial_idx)/mean(mag_values(trial_idx))];
                    pooled_stim_values = [pooled_stim_values stim_values(trial_idx)];
                end
            end
%             norm_mag_values = norm_mag_values/median(norm_mag_values);
%             legend_names{k} = date_labels{d};
         
        end


%         norm_mag_values = (norm_mag_values-min(norm_mag_values))/(max(norm_mag_values)-min(norm_mag_values));
%         [stim, mean_mag, se_mag] = plot_mag_est(pooled_stim_values, norm_mag_values, electrode_labels{elec}, 0);
        [stim{s}{elec}, mean_mag{s}{elec}, se_mag{s}{elec}] = mag_with_rebin(pooled_stim_values, norm_mag_values, 250);

                %some stats
        mag_tbl = [mag_tbl; ...
            s elec length(date_labels) length(set_labels) length(pooled_stim_values) length(mean_mag{s}{elec})];

        fineX{s}{elec} = linspace(min(pooled_stim_values)-50 , max(pooled_stim_values)+50, 1000);
        % fit a line
        P = polyfit(pooled_stim_values, norm_mag_values, 1);
        curve{s}{elec} = P(1)*fineX{s}{elec}+P(2);

        mean_mag_est{s}{elec} = P(1)*stim{s}{elec}+P(2);

    end
end

subplot(1,2,1)
s = 2; elec = 4;
% plot(amp{s}{elec}/1000, prop_correct{s}{elec},'.','color', col(s,:), 'MarkerSize', 18)
errorbar(stim{s}{elec}/1000, mean_mag{s}{elec}, se_mag{s}{elec}, '.k','LineWidth', 1.8)
hold on
plot(fineX{s}{elec}/1000, curve{s}{elec}, 'color', col(s,:), 'LineWidth', 2.4)
xlims = xlim;
% ylim([0.5 1]); xlim([0 4]);
xlabel('Amplitude, mA')
ylabel('Normalized rating')
box off
xlim([1 7])
ylim([ 0 2.5])
set(gca, 'FontSize', 14)

fh = findall(0,'Type','Figure');
txt_obj = findall(fh,'Type','text');
set(txt_obj,'FontName','Calibri','FontSize',17);

%% predicted vs actual magnitude
marker_type = {'diamond', 'o'};

subplot(1,2,2)
for s = 1:length(subject)
    for elec = 1:length(mean_mag{s})
        hold on
        scatter(mean_mag{s}{elec}, mean_mag_est{s}{elec},marker_type{unipolar{s}(elec)+1}, 'MarkerFaceAlpha',0.45,'MarkerEdgeAlpha',0.8, 'MarkerFaceColor', col(s,:),'MarkerEdgeColor', col(s,:), 'SizeData',40)

    end
end
plot([-0.5 3], [-0.5 3], ':k')
xlabel('Reported magnitude')
ylabel('Predicted magnitude')
box off
set(gca, 'FontSize', 14, 'Ytick', 0:3, 'YTickLabel', 0:3, 'Xtick', 0:3, 'XTickLabel', 0:3)
xlim([-0.5 3])
ylim([-0.5 3])

fh = findall(0,'Type','Figure');
txt_obj = findall(fh,'Type','text');
set(txt_obj,'FontName','Calibri','FontSize',17);

%% Get Rsq
for s = 1:length(subject)
    x = cell2mat(mean_mag{s});
    x_fit = cell2mat(mean_mag_est{s});
    Rsq(s) = get_Rsq(x,x_fit)
end

