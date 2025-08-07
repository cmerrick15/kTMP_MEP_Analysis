
%% EXP3 MULTI-PARTICIPANT ANALYSIS (Using sub, session, condition)
cd('/Users/christinamerrick/Desktop/MT/kTMP_eLife_paper/data_to_publish/Exp3')

% cd('/Users/Desktop/MT/kTMP_eLife_paper/data_to_publish/Exp1')

% % Load your .csv file
% data = readtable('Exp3.csv');  % replace with actual filename


% Load data
opts = detectImportOptions('Exp3_v2.csv');
data = readtable('Exp3_v2.csv', opts);

data.session = regexprep(string(data.session), '[^\d]', '');
data.session = str2double(data.session);

participants = unique(data.sub);
conditions = unique(data.condition);
sessions = unique(data.session);

cutoff_emg = mean(data.emg_sd) + 2.5 * std(data.emg_sd);

results = [];

for p = 1:length(participants)
    for c = 1:length(conditions)
        for s = 1:length(sessions)
            % Filter to participant, condition, session
            mask = strcmp(data.sub, participants{p}) & ...
                   strcmp(data.condition, conditions{c}) & ...
                   data.session == sessions(s);
            session_data = data(mask, :);

            if height(session_data) == 0
                continue
            end

            % Get block labels
            blocks = unique(session_data.block);

            % Pre blocks: 'pre1' and 'pre2'
            has_pre1 = any(strcmp(blocks, 'pre1'));
            has_pre2 = any(strcmp(blocks, 'pre2'));
            pre_meps = [];

            if has_pre1
                pre1_mask = strcmp(session_data.block, 'pre1') & ...
                            session_data.mep > 0 & ...
                            session_data.emg_sd < cutoff_emg;
                pre_meps = [pre_meps; session_data.mep(pre1_mask) * 1000];
            end

            if has_pre2
                pre2_mask = strcmp(session_data.block, 'pre2') & ...
                            session_data.mep > 0 & ...
                            session_data.emg_sd < cutoff_emg;
                pre_meps = [pre_meps; session_data.mep(pre2_mask) * 1000];
            end

            if isempty(pre_meps)
                continue
            end

            pre_avg = exp(mean(log(pre_meps)));

            % Post blocks: post1, post2, post3
            post_blocks = {'pst1','pst2','pst3'};
            post_avgs = NaN(1, length(post_blocks));

            for pb = 1:length(post_blocks)
                if any(strcmp(blocks, post_blocks{pb}))
                    post_mask = strcmp(session_data.block, post_blocks{pb}) & ...
                                session_data.mep > 0 & ...
                                session_data.emg_sd < cutoff_emg;
                    post_meps = session_data.mep(post_mask) * 1000;

                    if ~isempty(post_meps)
                        post_avgs(pb) = exp(mean(log(post_meps)));
                    end
                end
            end

            % Compute percent change
            for pb = 1:length(post_blocks)
                if ~isnan(post_avgs(pb))
                    percent_change = (post_avgs(pb) - pre_avg) / pre_avg;
                    results = [results; {participants{p}, conditions{c}, sessions(s), post_blocks{pb}, percent_change}];
                end
            end

        end
    end
end

% Convert results to table
results_table = cell2table(results, 'VariableNames', {'sub','condition','session','post_block','percent_change'});

% Save results
writetable(results_table, 'mep_percent_change_results_v2.csv');
