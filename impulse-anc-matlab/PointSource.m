classdef PointSource < handle
    % A general pointsource in 2D space.
    
    properties
        position_
        signal_
        fs_
    end
    
    methods
        
        % Constructor
        %   position: [array]
        %   signal: [array]
        %   fs: sampling frequency [scalar]
        function this = PointSource(position, signal, fs)
            this.position_ = position;
            this.signal_ = signal;
            this.fs_ = fs;
        end
        
        % Replace the signal contained within the source
        %   signal: [array]
        function set_signal(this, signal)
            this.signal_ = signal;
        end
        
        % Concatenate signal with the one contained within the source
        %   signal: [array]
        function ConcatenateSignal(this, signal)
            this.signal_ = [this.signal_, signal];
        end
        
        % Get the signal observed at a given position
        %   position: [Vector2D]
        function signal = GetSignal(this, position)
            distance = norm(this.position_ - position);
            delay = distance / 340 * this.fs_;
            attenuation = 2 * sqrt(pi) * distance;
            
            [integral_delay, b, a] = FdFilterDesign(delay);
            
            % No fractional delay component
            if isempty(b)
                signal = [zeros(1,integral_delay) this.signal_] / attenuation;
            else
                signal = [zeros(1,integral_delay) filter(b, a, [this.signal_ zeros(1,integral_delay)]) / attenuation];
            end
        end
        
        function value = GetValue(this, position, time)
            % This function does not delay the whole signal, only a
            % relevant chunk of it.
            chunk_size = 10;
            
            distance = norm(this.position_ - position);
            delay = distance / 340 * this.fs_;
            attenuation = 2 * sqrt(pi) * distance;
            
            [integral_delay, b, a] = FdFilterDesign(delay);
            
            end_index = time - integral_delay;
            beginning_index = end_index - chunk_size;
            
            pre_padding = 0;
            if beginning_index < 1
                pre_padding = 1 + abs(beginning_index);
                beginning_index = 1;
            end
            
            post_padding = 0;
            if end_index > length(this.signal_)
                post_padding = end_index - length(this.signal_);
                end_index = length(this.signal_);
            end
            
            if end_index < 1
                end_index = 0;
            end
            
            % No fractional delay component
            if isempty(b)
                signal = [zeros(1, pre_padding) this.signal_(beginning_index:end_index) zeros(1, post_padding)];
                value = signal(end) / attenuation;
            else                
                signal = filter(b, a, [zeros(1, pre_padding) this.signal_(beginning_index:end_index) zeros(1, post_padding)]);
                value = signal(end) / attenuation;
            end
        end
        
        function Append(this, values)
            this.signal_ = [this.signal_ values];
        end
        
    end
    
end

