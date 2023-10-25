%% Detection figure
close all
clear all

data_folder = 'D:\Lower limb\data\all_data_March2022';
% data_folder = 'D:\Lower limb\data\Psychophysics_updated\Psychophysics';
fsigm = @(param,xval) param(1)+(param(2)-param(1))./(1+10.^(((param(3)-xval)*param(4))));

subject = {'LSP02b' , 'LSP05', 'LNP02'};
% col = hex2rgb(['#49A548'; '#266DA3'; '#7D679C']); old colors
col = [22 151 154;
    79 120 188;
    175 95 159]/256;

line_type = {':', '-'};

fineX = linspace(0, 7000, 10000);
Det_thres = nan(5,length(subject));
curve = {}; amp = {}; prop_correct = {}; unipolar = {};
figure
for s = 1:length(subject)

    load(fullfile(data_folder, [subject{s} '_Detection.mat']))
    Data = Detection;
    electrode_labels = unique({Data.electrodeLabel});
    if s==3
        electrode_labels(2)=[];
    end
    set_labels = unique({Data.Set_number});

    unipolar{s} = cellfun(@(x) contains(x, 'Unipolar'), electrode_labels, 'UniformOutput', true);
    
    int1 = [Data.Value_Interval1];
    int2 = [Data.Value_Interval2];
    dec = [Data.User_Answer];
    
    % pool sets within electrode
    for elec = 1:length(electrode_labels)
        elec_idx = strcmp({Data.electrodeLabel}, electrode_labels{elec}) ;
        sum(elec_idx)
        if sum(elec_idx)>0
            [prop, alt_range] = detection_with_rebin(int1(elec_idx), int2(elec_idx), dec(elec_idx), 150);
            alt_range = [alt_range -100];
            prop = [prop 0.5];
            amp{s}{elec} = alt_range;
            prop_correct{s}{elec} = prop;
   
  
            [estimated_params]=sigm_fit(alt_range,prop,[0.5 1 nan nan],[0.5 1 600 0.001], 0);
            fitted_curve = fsigm(estimated_params, fineX);
            curve{s}{elec} = fitted_curve;
            [~, I] = min(abs(curve{s}{elec}-0.75));
            Det_thres(elec, s) = fineX(I)/1000;
            
            subplot(1,2,2)
            hold on
            plot(fineX/1000, curve{s}{elec},line_type{unipolar{s}(elec)+1}, 'color', col(s,:), 'LineWidth', 2.4)
            plot(Det_thres(elec, s), 0.75, '.k', 'MarkerSize', 20)
% 
            plot([0.1 Det_thres(elec, s)], [0.75 0.75], ':k', 'LineWidth', 1.8)
            plot([Det_thres(elec, s) Det_thres(elec, s)], [0 0.75], ':k', 'LineWidth', 1.8)
%             plot(Det_thres(elec, s), 0.49, '.', 'color', col(s,:), 'MarkerSize', 20)
            xlim([0.15 8]);
            ylim([0.49 1]); 
            xlabel('Amplitude, mA')
            ylabel('Proportion correct')
            box off
        end
    end
end

set(gca, 'FontSize', 14, 'Ytick', 0.5:0.25:1,'Xtick', [0.5 1:4], 'YTickLabel', 0.5:0.25:1)
set(gca, 'XScale', 'log')

subplot(1,2,1)
s = 1; elec = 2;
% plot(amp{s}{elec}/1000, prop_correct{s}{elec},'.','color', col(s,:), 'MarkerSize', 18)
scatter(amp{s}{elec}/1000, prop_correct{s}{elec},'o','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',0.6, 'MarkerFaceColor', col(s,:),'MarkerEdgeColor', col(s,:))
hold on
plot(fineX/1000, curve{s}{elec}, line_type{unipolar{s}(elec)+1}, 'color', col(s,:), 'LineWidth', 2.4)
hold on
plot([0.1 Det_thres(elec, s)], [0.75 0.75], ':k', 'LineWidth', 1.8)
plot([Det_thres(elec, s) Det_thres(elec, s)], [0 0.75], ':k', 'LineWidth', 1.8)
plot(Det_thres(elec, s), 0.75, '.k', 'MarkerSize', 20)
xlims = xlim;
ylim([0.5 1]); xlim([0.2 6]);
xlabel('Amplitude, mA')
ylabel('Proportion correct')

box off
set(gca, 'FontSize', 14, 'Ytick', 0.5:0.25:1,'Xtick', [0.5 1:4], 'YTickLabel', 0.5:0.25:1)
set(gca, 'XScale', 'log')

fh = findall(0,'Type','Figure');
txt_obj = findall(fh,'Type','text');
set(txt_obj,'FontName','Calibri','FontSize',17);

