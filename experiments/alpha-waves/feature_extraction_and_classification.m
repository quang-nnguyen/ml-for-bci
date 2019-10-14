%% FEATURE EXTRACTION AND CLASSIFICATION OF ALPHA WAVES
% This script demonstrate feature extraction and classification of alpha
% waves
% 
% TODO: more details

%% Load data
clear all;
addpath '../../data/test alpha 5s'
ALLEEG = load('5sopen_close.mat').ALLEEG; % EEGLAB format
sig = ALLEEG.data;

%% Load tool
addpath '../../tools/spectral'

%% Visualize Events
events = ALLEEG.event;
Fs = ALLEEG.srate;          % sampling frequency
duration = Fs*5;            % duration of eacch event = 5 seconds
start = 700;                % avoid artifacts and the beginning of the recordings

% Plot spectrogram 
figure;
hax = subplot(1,1,1);
plot_spectrogram(sig, start, 1, hax); colorbar('Off'); colormap(jet(256));

% Plot event onset over the 
events_close = [];
events_open = [];
numevent = length(events); 
for i = 1:numevent
    event = events(i).latency;
    event_norm = (event - start)/Fs/60;     % offseted by start, normalized by Fs and minutes
    x = [event_norm, event_norm];
    y = [0, 35];
    if mod(i,2) == 0    % even = OPEN
        line(hax, x,y, 'Color', 'blue', 'LineWidth', 2)
        events_open = [events_open, event]; % TODO:handling better variable 
    else                % odd = CLOSE
        line(hax, x,y, 'Color', 'red', 'LineWidth', 2)
        events_close = [events_close, event];
    end
end

%% Feature extraction
n_samples = 100;                    % for each class
class1_feat = zeros(n_samples, 2);  % feature 1: max spectral power in 8-13Hz band, feature 2: corresponding SNR
class2_feat = zeros(n_samples, 2);
window_sec = 1;
window = window_sec*Fs;             % window if spectral feature = 1 second
band = [6, 35];
params.Fs = Fs;
params.band = band;

% Class 1: close eyes (alpha waves)
n_events_close = length(events_close) - 2;
n_events_open = length(events_open) - 2;

disp('Extracting features...')
for i = 1:n_samples
    event_close_chosen = events_close(randi(n_events_close));
    
    % select feature
    feat_range = event_close_chosen:(event_close_chosen+duration - window);
    
    % select starting point and the corresponding window
    feat_start = feat_range(randi(numel(feat_range)));
    feat_window = sig(feat_start:(feat_start + window - 1));
    
    % feature extraction    
    feat = feature_extraction(feat_window, params);
    
    class1_feat(i, :) = feat;
end 

% Class 2: open eyes
% TODO: Extract features of 2 classes in one loop.
for i = 1:n_samples 
    event_open_chosen = events_open(randi(n_events_open));
    
    % select feature
    feat_range = event_open_chosen:(event_open_chosen+duration - window);
    
    % select starting point and the corresponding window
    feat_start = feat_range(randi(numel(feat_range)));
    feat_window = sig(feat_start:(feat_start + window - 1));
    
    % feature extraction    
    feat = feature_extraction(feat_window, params);
    
    class2_feat(i, :) = feat;
end
disp('Done')

%% Visualize features
figure;
hold on;
scatter(class1_feat(:,1), class1_feat(:,2), 40, 'MarkerFaceColor', 'red')
scatter(class2_feat(:,1), class2_feat(:,2), 40, 'MarkerFaceColor', 'blue')
legend('close', 'open')
ylabel('Max(spectral)');
xlabel('Frequency at max(spectral)');
hold off;