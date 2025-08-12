%% EXP3 MULTI-PARTICIPANT ANALYSIS (Using sub, session, condition)
cd('../data/raw')

% Load data
opts = detectImportOptions('Exp2.csv');
data = readtable('Exp2.csv', opts);

data.session = regexprep(string(data.session), '[^\d]', '');
data.session = str2double(data.session);

participants = unique(data.sub);
conditions = unique(data.condition);
sessions = unique(data.session);
protocols = [0, 3, 10];  % 0 = SP, 3 = SICI, 10 = ICF

results = [];

for p = 1:length(participants)
    for c = 1:length(conditions)
        for s = 1:length(sessions)
            % Filter data for current participant, condition, session
            session_data = data(strcmp(data.sub, participants{p}) & ...
                                strcmp(data.condition, conditions{c}) & ...
                                data.session == sessions(s), :);

            if height(session_data) == 0
                continue
            end

            cutoff_emg = mean(session_data.emg_sd) + 2.5 * std(session_data.emg_sd);
            if size(unique(session_data.block),1) == 5
                blocks = {'pre1', 'pre2', 'pst1', 'pst2', 'pst3'};
            elseif size(unique(session_data.block),1) == 4 && ~sum(contains(unique(session_data.block), 'pre2'))
                blocks = {'pre1', 'pst1','pst2', 'pst3'};
            elseif size(unique(session_data.block),1) == 4 && ~sum(contains(unique(session_data.block), 'pst1'))
                blocks = {'pre1', 'pre2', 'pst2', 'pst3'};
            elseif size(unique(session_data.block),1) == 4 && ~sum(contains(unique(session_data.block), 'pst3'))
                blocks = {'pre1', 'pre2','pst1', 'pst2'};                
            end
            
            % Compute log-transformed geometric means for all protocol/block combos
            log_means = struct();
            for b = 1:length(blocks)
                block_name = blocks{b};
                for protocol = protocols
                    
                    current_block = session_data(strcmp(session_data.block, block_name) & session_data.tms_protocol == protocol,:);
                    mean_mep = mean(current_block.mep);
                    sd_mep = std(current_block.mep);
                    
                    if current_block.code(1) == 0
                                mask = strcmp(session_data.block, block_name) & ...
                                             session_data.tms_protocol == protocol & ...
                                             session_data.mep > 0 & ...
                                             session_data.mep > (mean_mep - 2.5 * sd_mep) & ...
                                             session_data.mep < (mean_mep + 2.5 * sd_mep);
                                         
                    elseif current_block.code(1) == 1          
                                 mask = strcmp(session_data.block, block_name) & ...
                                             session_data.tms_protocol == protocol & ...
                                             session_data.mep > 0 & ...
                                             session_data.emg_sd < cutoff_emg & ...
                                             session_data.mep > (mean_mep - 2.5 * sd_mep) & ...
                                             session_data.mep < (mean_mep + 2.5 * sd_mep);
                            
                    elseif current_block.code(1) == 2          
                                 mask = strcmp(session_data.block, block_name) & ...
                                             session_data.tms_protocol == protocol & ...
                                             session_data.mep > 0 & ...
                                             session_data.emg_sd < cutoff_emg & ...
                                             session_data.mep > (mean_mep - 2.5 * sd_mep) & ...
                                             session_data.mep < (mean_mep + 2.5 * sd_mep) & ...
                                             session_data.target_error < 3 & session_data.target_error > -3 & ...
                                             session_data.angular_error < 5 & session_data.angular_error > -5 & ...
                                             session_data.twist_error < 5 & session_data.twist_error > -5;
                    end
                   
                    block_meps = session_data.mep(mask);

                    if ~isempty(block_meps)
                        log_means.(block_name).(sprintf('protocol_%d', protocol)) = exp(mean(log(block_meps * 1000)));
                        log_data.(block_name).(sprintf('protocol_%d', protocol)) = log(block_meps *1000);
                    else
                        log_means.(block_name).(sprintf('protocol_%d', protocol)) = NaN;
                    end
                end
            end

            %% --- Compute Ratios for SICI and ICF ---
            paired_protocols = [3, 10]; % SICI and ICF
            paired_ratios = struct();

            for b = 1:length(blocks)
                block_name = blocks{b};
                for protocol = paired_protocols
                    sp_val = log_means.(block_name).protocol_0;
                    paired_val = log_means.(block_name).(sprintf('protocol_%d', protocol));
                    if ~isnan(sp_val) && ~isnan(paired_val) && sp_val ~= 0
                        paired_ratios.(block_name).(sprintf('protocol_%d', protocol)) = paired_val / sp_val;
                    else
                        paired_ratios.(block_name).(sprintf('protocol_%d', protocol)) = NaN;
                    end
                end
            end

            %% --- Compute Pre Averages ---
            % SP pre average (geometric mean)
            sp_pre_trials = [];
            if sum(contains(blocks, 'pre2'))
            
                % Loop through pre1 and pre2 blocks
                for b = {'pre1', 'pre2'}
                    block_name = b{1};

                    % Check if block exists in log_data and has protocol_0 (SP) trials
                    if isfield(log_data, block_name) && isfield(log_data.(block_name), 'protocol_0')
                        val = log_data.(block_name).protocol_0;

                        % If not empty, append trials to the growing list
                        if ~isempty(val)
                            sp_pre_trials = [sp_pre_trials; val(:)];  % Ensure column vector
                        end
                    end
                end
                
                sp_pre_avg = exp(mean(sp_pre_trials));

            else
                
                sp_pre_avg = log_means.pre1.protocol_0;
                
            end

            % SICI and ICF ratio pre averages
            ratio_pre_avg = struct();
            val = [];
            
            for protocol = paired_protocols
                ratio_vals = [];
                
                if sum(contains(blocks, 'pre2'))
                    for b = {'pre1', 'pre2'}
                        
                        val = paired_ratios.(b{1}).(sprintf('protocol_%d', protocol));

                        % If not empty, append trials to the growing list
                        if ~isempty(val)
                            ratio_vals = [ratio_vals; val(:)];  % Ensure column vector
                        end
                    end

                    ratio_pre_avg.(sprintf('protocol_%d', protocol)) = mean(ratio_vals);

                else

                    ratio_pre_avg.(sprintf('protocol_%d', protocol)) = log_means.pre1.(sprintf('protocol_%d', protocol));

                end
            end
                        
                        
            %% --- Compute Percent Change for Post Blocks ---
            
            for pb = blocks(contains(blocks,'pst'))
                block = pb{1};

                % Protocol 0: standard percent change
                sp_post_val = log_means.(block).protocol_0;
                if ~isnan(sp_post_val)
                    percent_change = (sp_post_val - sp_pre_avg) / sp_pre_avg;
                    results = [results; {participants{p}, conditions{c}, sessions(s), 0, block, percent_change}];
                end

                % Paired-pulse protocols: percent change from ratio
                for protocol = paired_protocols
                    fieldname = sprintf('protocol_%d', protocol);
 
                    ratio_pre = ratio_pre_avg.(fieldname);
                    ratio_post = paired_ratios.(block).(fieldname);

                    percent_change = (ratio_post - ratio_pre) / ratio_pre;
                    results = [results; {participants{p}, conditions{c}, sessions(s), protocol, block, percent_change}];
                end
            end
        end
    end
end

% === Set output directory relative to script location ===

% Get path to project root
this_file_path = mfilename('fullpath');
[script_folder, ~, ~] = fileparts(this_file_path);
project_root = fileparts(script_folder);

% Now set output path
output_dir = fullfile(project_root, 'data', 'processed');

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


% Convert to table and save
results_table = cell2table(results, ...
    'VariableNames', {'sub','condition','session','tms_protocol','post_block','percent_change'});

writetable(results_table, [output_dir '/' 'mep_percent_change_Exp2.csv']);