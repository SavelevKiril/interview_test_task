classdef mlse
    % MLSE equalizer
    
    properties
        channelLength
        blockLength
    end
    
    methods
        function this = mlse(channelLength, blockLength)
            this.channelLength = channelLength;
            this.blockLength = blockLength;
        end
        
        function equalized = run(this, receivedSignal, estimatedCir)
            assert(iscolumn(receivedSignal), "Input signal must be column vector");
            assert(iscolumn(estimatedCir), "Estimated CIR must be column vector");
            assert(length(receivedSignal) == this.channelLength + this.blockLength - 1, "Input signal has wrong size");
            assert(length(estimatedCir) == this.channelLength, "Estimated CIR has wrong size");
            
            equalized = receivedSignal(1:this.blockLength);
            warning("MLSE is not implemented yet");
        end
    end
end

