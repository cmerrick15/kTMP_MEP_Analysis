% Set the root directory where all participant folders are located
rootDir = '/Users/christinamerrick/Desktop/MT/kTMP_eLife_paper/data_to_publish/Exp2/data';  % <-- CHANGE THIS

% Define the 22-column structure
columnNames = ktmp_trials.Properties.VariableNames;

% Define the corresponding column types (adjust as needed)
columnTypes = {'string', 'string', 'string', 'string', ...
               'double', 'double', 'double', 'double', 'double', 'double', ...
               'double', 'double', 'double', ...
               'double', 'double', 'double', 'double', ...
               'double', 'double', 'double', 'double', 'double'};

% Create an empty table with 22 columns
% templateTable = table('Size', [0, length(columnNames)], ...
%                       'VariableTypes', columnTypes, ...
%                       'VariableNames', columnNames);
templateTable = ktmp_trials;

% Initialize the master table
allData = templateTable;

% Get list of participant folders
participants = dir(rootDir);
participants = participants([participants.isdir] & ~startsWith({participants.name}, '.'));

for p = 1:length(participants)
    participantPath = fullfile(rootDir, participants(p).name);
    
    % List .mat files in the participant folder
    matFiles = dir(fullfile(participantPath, '*.mat'));
    
    for m = 1:length(matFiles)
        matFilePath = fullfile(participantPath, matFiles(m).name);
        dataStruct = load(matFilePath);
        
        % Get table (assume only one variable)
        tableVar = fieldnames(dataStruct);
        dataTable = dataStruct.(tableVar{1});
        
        % Match table to template structure
        % Add missing columns
        for col = 1:length(columnNames)
            if ~ismember(columnNames{col}, dataTable.Properties.VariableNames)
                defaultValue = 0;
                dataTable.(columnNames{col}) = repmat(defaultValue(1), height(dataTable), 1);
            end
        end
        
        dataTable.condition = string(dataTable.condition);
        dataTable.emg_sd = double(dataTable.emg_sd);


        
        % Reorder columns to match the template
        dataTable = dataTable(:, columnNames);
        
        % Append to master table
        allData = [allData; dataTable];
    end
end

% dataTable.condition = string(dataTable.condition);
allData.condition = "C_" + string(allData.condition);  % Makes sure they?re not mistaken for numbers


% Write to CSV
writetable(allData, fullfile(rootDir, 'consolidated_data.csv'));

disp('CSV export complete!');