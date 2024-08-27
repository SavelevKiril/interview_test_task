clear all;
close all;
clc;

%% Experiments parameters
expParams = struct;
expParams.channelLengthList = 1:5;
expParams.blockLength = 128;
expParams.expCount = 100;
expParams.snrDbRange = -10:1:11;

%% Run experiments
fig = figure;
legendList = [];
% Iterate over channel lenghts
for channelLengthIdx = 1:length(expParams.channelLengthList)
    channelLength = expParams.channelLengthList(channelLengthIdx);
    
    % Initialize equalizer
    equalizer = mlse(channelLength, expParams.blockLength);
    
    % Initialize matrix for BER
    berSnrExp = zeros(length(expParams.snrDbRange), expParams.expCount);
    
    % Iterate over seed
    for expIdx = 1:expParams.expCount
        rng(expIdx);
        
        % Rayleigh channel - CIR from CN(0,1)
        cir = 1/sqrt(2) * (randn(channelLength,1) + 1j * randn(channelLength,1));
        
        % Tx bits
        txBits = randi([0 1], expParams.blockLength, 1);
        
        % Modulate
        txSignal = 2*txBits-1;
        
        % Generate noise
        unitPowerNoise = 1/sqrt(2) * (randn(expParams.blockLength+channelLength-1,1) + 1j * randn(expParams.blockLength+channelLength-1,1));
        
        % Iterate over SNR
        for snrIdx = 1:length(expParams.snrDbRange)
            snrDb = expParams.snrDbRange(snrIdx);
            
            % Received signal model
            rxSignal = conv(txSignal, cir) + unitPowerNoise * db2mag(-snrDb);
            
            % Run equalizer
            equalized = equalizer.run(rxSignal, cir);
            
            % Demodulate
            rxBits = double(equalized > 0);
            
            % Calculate BER
            berSnrExp(snrIdx, expIdx) = mean(rxBits ~= txBits);
        end
    end
    
    % Plot graph
    semilogy(expParams.snrDbRange, mean(berSnrExp, 2)); hold on;
    
    % Accumulate legend
    legendList = [legendList; "MLSE, CIR length = "+string(channelLength)];
end

%% Visualize results
% Calculate BPSK AWGN BER for comparison
awgnBer = berawgn(expParams.snrDbRange, 'psk', 2, 'nondiff');

% Put on plot
semilogy(expParams.snrDbRange, awgnBer);

% Accumulate legend
legendList = [legendList; "AWGN BER"];

% Put legend, apply limits, specify axis
legend(legendList); grid on; ylim([1e-5 1])
xlabel("SNR, dB"); ylabel("BER");

% Save figure
saveas(fig, "results.png");

