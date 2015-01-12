classdef ixELMS < handle
    properties
        primary_order_;
        secondary_order_;
        references_;
        actuators_;
        sources_;
        inverse_delay_;
        fs_;
        xbuf_length_;
        alt_xbuf_length_;
        ebuf_length_;
        w_;
        s_;
        xbuf_;
        fxbuf_;
        errors_;
        ebuf_;
        alpha_;
        
        alpha_identification_;        
        normalization_;
        
        diag_plot_identification_;
        
        error_;
        identification_error_;
        
        identification_error_offset_;
        error_offset_;
        
        identification_signal_;
        identification_response_;
        
        h_noise_to_reference_;      % (reference, noise)
        h_noise_to_error_;          % (error, noise)
        h_actuator_to_reference_;   % (reference, actuator)
        h_actuator_to_error_;       % (error, actuator)
        
        noise_at_error_;
        noise_;
        
        actuator_buffer_;
    end
    
    methods
        function object = ixELMS(primary_order, secondary_order, inverse_delay, fs)
            % ELMS(primary_order, secondary_order, inverse_delay,
            % reference_filter_order, reference_filter_delay, fs)
            object.primary_order_ = primary_order;
            object.secondary_order_ = secondary_order;
            object.inverse_delay_ = inverse_delay;
            object.fs_ = fs;
            
            object.xbuf_length_ = primary_order;
            object.ebuf_length_ = secondary_order;
            
            object.alpha_identification_ = 1e-3;
            object.alpha_ = 1e-1;
            
            object.diag_plot_identification_ = true;
            object.normalization_ = true;
            
            object.identification_error_ = [];
            object.error_ = [];
            
            object.identification_error_offset_ = 0;
            object.error_offset_ = 0;
        end
        
        function SetSecondaryPath(this, h)
            this.h_actuator_to_error_ = h;
            
            this.ResetSecondaryFilter();
            this.ResetPrimaryFilter();
        end
        
        function AddReference(this, noise_to_ref, act_to_ref)
            this.h_noise_to_reference_   ( size(this.h_noise_to_reference_,    1) + 1, : ) = noise_to_ref;
            this.h_actuator_to_reference_( size(this.h_actuator_to_reference_, 1) + 1, : ) = act_to_ref;
            
            this.ResetPrimaryFilter();
        end
        
        function SetNoiseToError(this, noise_to_error)
            this.h_noise_to_error_ = noise_to_error;
        end
        
        function Identify(this, steps)
            if nargin == 1
                steps = 80000;
            end
            
            % aspect:diag
            h = waitbar(0,sprintf('Simulating %d steps', steps),'Name','Simulating identification phase...');
            % end:diag
            
            mu = this.alpha_identification_;
            
            % aspect:diag
            tic;
            % end:diag
            
            signal = bandnoise(1500, 1.0, this.fs_, steps);
            
            response = filter(this.h_actuator_to_error_,1,signal);
            
            this.identification_error_ = [this.identification_error_ zeros(1, steps - this.secondary_order_ - 1)];
            
            for n = this.secondary_order_+1:steps
                % aspect:diag
                if mod(n, 2000) == 0
                    t = toc;
                    t = (steps-n+this.secondary_order_) / 2000 * t;
                    t = ceil(t);
                    waitbar((n-this.secondary_order_)/steps, h, sprintf('Simulating %d steps - time remaining: %d:%02d', steps, floor(t/60), mod(t,60)));
                    tic;
                end
                % end:diag
                
                filtered_response = fliplr( response(n-this.secondary_order_+1:n) ) * this.s_';
                
                error = signal(n-this.inverse_delay_) - filtered_response;
                
                % aspect:diag
                this.identification_error_(n-this.secondary_order_+this.identification_error_offset_) = error;
                % end:diag
                
                this.s_ = this.s_ + mu * error * fliplr( response(n-this.secondary_order_+1:n) );
            end
            
            % aspect:diag
            close(h);
            if this.diag_plot_identification_
                this.PlotIdentificationResults(this.identification_error_, 'Error during secondary filter identification');
            end
            % end:diag
            this.identification_error_offset_ = this.identification_error_offset_ + n-this.secondary_order_;
        end
        
        function SetIndetificationSignal(this, signal)
            this.identification_signal_ = signal;
        end
        
        function SetIdentificationResponse(this, signal)
            this.identification_response_ = signal;
        end
        
        function Simulate(this, simulation_steps)
            % aspect:diag
            h = waitbar(0,sprintf('Simulating %d steps', simulation_steps),'Name','Simulating noise cancelling phase...');
            % end:diag
            
            this.xbuf_ = zeros( size(this.h_noise_to_reference_, 1), this.xbuf_length_ );
            this.fxbuf_= zeros( size(this.h_noise_to_reference_, 1), this.xbuf_length_ );
            this.ebuf_ = zeros( 1,                                   this.ebuf_length_ );

            noise = bandnoise(1000, 1.0, this.fs_, simulation_steps);       
            
            this.noise_at_error_ = filter(this.h_noise_to_error_, 1, noise);
            this.noise_ = noise;
            
            noise_at_reference = zeros( size(this.h_noise_to_reference_, 1), simulation_steps);
            for ix_reference = 1:size(this.h_noise_to_reference_, 1)
                noise_at_reference(ix_reference,:) = filter(this.h_noise_to_reference_(ix_reference,:), 1, noise);
            end
            
            % aspect:diag
            tic;
            % end:diag
            
            this.actuator_buffer_ = zeros(1, size(this.h_actuator_to_error_, 2));
            
            this.error_ = [this.error_ zeros(1, simulation_steps)];
            
            for n = 1:simulation_steps
                % aspect:diag
                if mod(n, 1000) == 0
                    t = toc;
                    t = (simulation_steps-n) / 1000 * t;
                    t = ceil(t);
                    waitbar((n-this.secondary_order_)/simulation_steps, h, sprintf('Simulating %d steps - time remaining: %d:%02d', simulation_steps, floor(t/60), mod(t,60)));
                    tic;
                    waitbar((n)/simulation_steps, h)
                end
                % end:diag

                reference_value = zeros(size(this.h_actuator_to_reference_, 1));
                
                for ix_reference = 1:size(this.h_actuator_to_reference_, 1)
                    reference_value(ix_reference) = noise_at_reference(ix_reference, n);
                    reference_value(ix_reference) = reference_value(ix_reference) + this.actuator_buffer_ * this.h_actuator_to_reference_(ix_reference, :)';
                end

                error_value = this.noise_at_error_(n) + ( this.actuator_buffer_ * this.h_actuator_to_error_' );
                
                % aspect:diag
                this.error_(n+this.error_offset_) = error_value;
                % end:aspect
                
                for ix = 1:size(this.h_noise_to_reference_, 1)
                    this.xbuf_(ix,:) = [reference_value(ix) this.xbuf_(ix, 1:end-1)];
% this.xbuf_(ix,:) = [ix this.xbuf_(ix, 1:end-1)];
                end
                
%                 this.ebuf_ = [error_value this.ebuf_(1:end-1)];
                
%                 fe = this.ebuf_ * this.s_';
                
                for ix = 1:size(this.h_noise_to_reference_, 1)
                    this.fxbuf_(ix,:) = [ this.xbuf_(ix,:)*this.s_' this.fxbuf_(ix,1:end-1) ];
                end
                
                y = 0;                
                for ix_reference = 1:size(this.h_noise_to_reference_, 1)
                    y = y + this.w_(ix_reference, :) * this.xbuf_( ix_reference, 1:size(this.w_, 2) )';
                end
                
%                 if (n <20)
%                     y
%                 end
                
                this.actuator_buffer_ = [-y this.actuator_buffer_(1:end-1)];
                
                for ix_reference = 1:size(this.h_noise_to_reference_, 1)
                    mu = this.alpha_;
                    if n > 500 && this.normalization_
                        mu = mu / (this.xbuf_(ix_reference,:) * this.xbuf_(ix_reference,:)');
                    end

                    this.w_(ix_reference, :) = this.w_(ix_reference, :) + mu * error_value * this.fxbuf_(ix_reference, :);
                end
                
            end
            % aspect:diag
            close(h);
            this.PlotIdentificationResults(this.error_, 'Error during noise cancellation');
            % end:diag
            this.error_offset_ = this.error_offset_ + n;
        end
        
        function SetOption(this, option, value)
            switch option
                case 'mu'
                    this.alpha_ = value;
                case 'mu_identification'
                    this.alpha_identification_ = value;
                case 'normalization'
                    this.normalization_ = value;
                case 'diag_plot_identification'
                    this.diag_plot_identification_ = value;
            end            
        end
        
        function option = GetOption(this, option)
            switch option
                case 'mu'
                    option = this.alpha_;
                case 'mu_identification'
                    option = this.alpha_identification_;
                case 'normalization'
                    option = this.normalization_;
            end      
        end
        
        function ResetPrimaryFilter(this)
            this.w_ = zeros(size(this.h_actuator_to_reference_, 1), this.primary_order_);
            this.error_offset_ = 0;
            this.error_ = [];
        end
        
        function ResetSecondaryFilter(this)
            this.s_ = zeros(1, this.secondary_order_);
            this.identification_error_offset_ = 0;
            this.identification_error_ = [];
        end
    end
    
    methods(Access = private)
        function PlotIdentificationResults(this, error, plot_title)
            num_errors = size(error, 1);
            
            if num_errors > 4
                ysize = 3;
            else
                ysize = 2;
            end
            
            figure;
            for k = 1:num_errors
                subplot(ysize, ceil(num_errors/ysize), k), plot(this.CalculateTimestamps(size(error, 2)), error(k,:));
                xlabel('Time [s]');
                title(sprintf('Error(%d) signal',k));
            end
            
            suptitle(plot_title);
        end
        
        function t = CalculateTimestamps(this, num_samples)
            t = [1:num_samples] / this.fs_;
        end
    end

end