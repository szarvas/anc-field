classdef ELMS < handle
    properties
        primary_order_;
        secondary_order_;
        references_;
        actuators_;
        sources_;
        reference_positions_;
        error_positions_;
        actuator_positions_;
        inverse_delay_;
        fs_;
        xbuf_length_;
        alt_xbuf_length_;
        ebuf_length_;
        w_;
        s_;
        t_;
        xbuf_;
        alt_xbuf_;
        errors_;
        ebuf_;
        alpha_;
        reference_filtering_;
        decorrelation_order_;
        decorrelation_delay_;
        
        alpha_identification_;
        alpha_reference_filter_identification_;
        
        normalization_;
        
        diag_plot_identification_;
        
        error_;
        identification_error_;
        reference_filter_identification_error_;
        
        reference_filter_identification_error_offset_;
        identification_error_offset_;
        error_offset_;
        
        identification_signal_;
        identification_response_;
        
        h_noise_to_reference_;      % (reference, noise)
        h_noise_to_error_;          % (error, noise)
        h_actuator_to_reference_;   % (reference, actuator)
        h_actuator_to_error_;       % (error, actuator)
        
        error_signal_source;
    end
    
    methods
        function object = ELMS(primary_order, secondary_order, inverse_delay, reference_filter_order, reference_filter_delay, fs)
            % ELMS(primary_order, secondary_order, inverse_delay,
            % reference_filter_order, reference_filter_delay, fs)
            object.primary_order_ = primary_order;
            object.secondary_order_ = secondary_order;
            object.inverse_delay_ = inverse_delay;
            object.decorrelation_order_ = reference_filter_order;
            object.decorrelation_delay_ = reference_filter_delay;
            object.fs_ = fs;
            
            object.xbuf_length_ = primary_order + inverse_delay;
            object.ebuf_length_ = secondary_order;
            object.alt_xbuf_length_ = reference_filter_order;
            
            object.alpha_ = 1e-1;
            
            object.diag_plot_identification_ = true;
            object.sources_ = [];
            
            object.reference_filtering_ = true;
            
            object.alpha_identification_ = 1e-3;
            object.alpha_reference_filter_identification_ = 1e-1;
            
            object.normalization_ = true;
            
            object.reference_filter_identification_error_ = [];
            object.identification_error_ = [];
            object.error_ = [];
            
            object.reference_filter_identification_error_offset_ = 0;
            object.identification_error_offset_ = 0;
            object.error_offset_ = 0;
        end
        
        function SetReferencePositions(this, positions)
            this.reference_positions_ = positions;
            this.ResetReferenceFilter();
            this.ResetSecondaryFilter();
            this.ResetPrimaryFilter();
        end
        
        function SetErrorPositions(this, positions)
            this.error_positions_ = positions;
            this.ResetReferenceFilter();
            this.ResetSecondaryFilter();
            this.ResetPrimaryFilter();
        end
        
        function SetActuatorPositions(this, positions)
            this.actuator_positions_ = positions;
            this.ResetReferenceFilter();
            this.ResetSecondaryFilter();
            this.ResetPrimaryFilter();
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
            
            this.identification_error_ = [this.identification_error_ zeros(size(this.actuator_positions_,1), steps - this.secondary_order_ - 1)];
            for n = this.secondary_order_+1:steps
                % aspect:diag
                if mod(n, 1000) == 0
                    t = toc;
                    t = (steps-n+this.secondary_order_) / 1000 * t;
                    t = ceil(t);
                    waitbar((n-this.secondary_order_)/steps, h, sprintf('Simulating %d steps - time remaining: %d:%02d', steps, floor(t/60), mod(t,60)));
                    tic;
                end
                % end:diag
                
                estimated_response = zeros(1, size(this.error_positions_,1));
                estimation_error = zeros(1, size(this.error_positions_,1));
                
                % applying inverse filter to system response
                for ix_actuator = 1:size(this.actuator_positions_,1)
                    for ix_error = 1:size(this.error_positions_,1)
                        ix_s = (ix_actuator-1) * size(this.error_positions_,1) + ix_error;
                        estimated_response(ix_actuator) = estimated_response(ix_actuator) ...
                            + fliplr( this.identification_response_(ix_error, n-this.secondary_order_+1:n) ) * this.s_(ix_s, :)';
                    end
                end
                
                % calculating the error
                for ix_actuator = 1:size(this.actuator_positions_,1)
                    estimation_error(ix_actuator) = this.identification_signal_(ix_actuator, n-this.inverse_delay_) - estimated_response(ix_actuator);
                    % aspect:diag
                    this.identification_error_(ix_actuator, n-this.secondary_order_+this.identification_error_offset_) = estimation_error(ix_actuator);
                    % end:diag
                end
                
                % updating the secondary filter
                for ix_actuator = 1:size(this.actuator_positions_,1)
                    for ix_error = 1:size(this.error_positions_,1)
                        ix_s = (ix_actuator-1) * size(this.error_positions_,1) + ix_error;
                        this.s_(ix_s, :) = this.s_(ix_s, :) + mu * estimation_error(ix_actuator) * fliplr( this.identification_response_(ix_error, n-this.secondary_order_+1:n) );
                    end
                end
            end
            
            % aspect:diag
            close(h);
            if this.diag_plot_identification_
                this.PlotIdentificationResults(this.identification_error_, 'Error during secondary filter identification');
            end
            % end:diag
            this.identification_error_offset_ = this.identification_error_offset_ + n-this.secondary_order_;
        end
        
        function AddSources(this, sources)
            this.sources_ = [this.sources_ sources];
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
            this.xbuf_ = zeros(size(this.reference_positions_,1), this.xbuf_length_);
            this.alt_xbuf_ = zeros(size(this.reference_positions_,1), this.alt_xbuf_length_);
            this.ebuf_ = zeros(size(this.error_positions_,1), this.ebuf_length_);
            
            random_series = zeros(size(this.h_noise_to_error_,1), simulation_steps);
            for ix_source = 1:size(this.h_noise_to_error_,1)
                random_series(ix_source,:) = bandnoise(1000, 1.0, this.fs_, simulation_steps);
            end
            
            this.error_signal_source = zeros(size(this.error_positions_,1), simulation_steps);
            for ix_error = 1:size(this.error_positions_,1)
                signal = [];
                for ix_source = 1:length(this.sources_)
                    ix_noise_to_error = (ix_error-1) * length(this.sources_) + ix_source;
                    signal = AddSignal(signal, conv(this.h_noise_to_error_(ix_noise_to_error,:), random_series(ix_source,:)));
                end
                this.error_signal_source(ix_error, :) = signal(1:simulation_steps);
            end
            %error_signal_source = 0.1*[zeros(1,50) random_series(1:end-50)];
            
            reference_signal_source = zeros(size(this.reference_positions_,1), simulation_steps);
            for ix_reference = 1:size(this.reference_positions_,1)
                signal = [];
                for ix_source = 1:length(this.sources_)
                    ix_noise_to_reference = (ix_reference-1) * length(this.sources_) + ix_source;
                    signal = AddSignal(signal, conv(this.h_noise_to_reference_(ix_noise_to_reference,:), random_series(ix_source,:)));
                end
                reference_signal_source(ix_reference, :) = signal(1:simulation_steps);
            end
            %reference_signal_source = random_series;
            
            % aspect:diag
            tic;
            % end:diag
            
            % todo: generalize function for more than 1 actuator
            actuator_buffer = zeros(1,size(this.h_actuator_to_error_,2));
            this.error_ = [this.error_ zeros(size(this.error_positions_,1), simulation_steps)];
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

                reference_value = zeros(size(this.reference_positions_,1));
                for ix_reference = 1:size(this.reference_positions_,1)
                    reference_value(ix_reference) = reference_signal_source(ix_reference, n);
                    for ix_actuator = 1:length(this.actuators_)
                        ix_actuator_to_reference = ix_reference;
                        reference_value(ix_reference) = reference_value(ix_reference) + this.h_actuator_to_reference_(ix_actuator_to_reference,:) * actuator_buffer';
                    end
                end
                
                error_value = zeros(size(this.error_positions_,1));
                for ix_error = 1:size(this.error_positions_,1)
                    error_value(ix_error) = this.error_signal_source(ix_error, n);
                    for ix_actuator = 1:length(this.actuators_)
                        ix_actuator_to_error = ix_error;                        
                        error_value(ix_error) = error_value(ix_error) + this.h_actuator_to_error_(ix_actuator_to_error,:) * actuator_buffer';
                        % aspect:diag
                        this.error_(ix_error, n+this.error_offset_) = error_value(ix_error);
                        % end:aspect
                    end
                end
                
                for ix = 1:size(this.reference_positions_,1)
                    this.xbuf_(ix,:) = [reference_value(ix) this.xbuf_(ix, 1:end-1)];
                end
                
                for ix = 1:size(this.error_positions_,1)
                    this.ebuf_(ix,:) = [error_value(ix) this.ebuf_(ix, 1:end-1)];
                end
                
                fe = zeros(size(this.error_positions_,1)*size(this.actuator_positions_,1),1);
                for ix_error = 1:size(this.error_positions_,1)
                    for ix_actuator = 1:size(this.actuators_,1)
                        ix_s = (ix_actuator-1) * size(this.error_positions_,1) + ix_error;
                        fe(ix_s) = this.s_(ix_s,:) * this.ebuf_(ix_error,:)';
                    end
                end             
                
                for ix_actuator = 1:size(this.actuator_positions_,1)
                    y = 0;
                    for ix_reference = 1:size(this.reference_positions_,1)
                        ix_w = (ix_reference-1) * size(this.actuator_positions_,1) + ix_actuator;
                        y = y + this.w_(ix_w,:) * this.xbuf_(ix_reference,1:size(this.w_, 2))';
                    end
                    this.actuators_(ix_actuator).Append(-y);
                    actuator_buffer = [-y actuator_buffer(1:end-1)];
                end
                
                for ix_reference = 1:size(this.reference_positions_,1)
                    for ix_actuator = 1:size(this.actuator_positions_,1)
                        for ix_error = 1:size(this.error_positions_,1)
                            ix_s = (ix_actuator-1) * size(this.error_positions_,1) + ix_error;
                            ix_w = (ix_reference-1) * size(this.actuator_positions_,1) + ix_actuator;
                            
                            mu = this.alpha_;
                            if n > 500 && this.normalization_
                                mu = mu / (this.xbuf_(ix_reference,:) * this.xbuf_(ix_reference,:)');
                            end
                            
                            this.w_(ix_w,:) = this.w_(ix_w,:) + mu * fe(ix_s) * this.xbuf_(ix_reference, this.inverse_delay_+1:end);
                        end
                    end
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
                case 'mu_reference_filter_identification'
                    this.alpha_reference_filter_identification_ = value;
                case 'normalization'
                    this.normalization_ = value;
                case 'reference_filtering'
                    this.reference_filtering_ = value;
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
                case 'mu_reference_filter_identification'
                    option = this.alpha_reference_filter_identification_;
                case 'normalization'
                    option = this.normalization_;
                case 'reference_filtering'
                    option = this.reference_filtering_;
            end      
        end
        
        function ResetPrimaryFilter(this)
            this.w_ = zeros(size(this.reference_positions_,1)*size(this.actuator_positions_,1), this.primary_order_);
            this.error_offset_ = 0;
            this.error_ = [];
            
            this.actuators_ = [];
            for ix = 1:size(this.actuator_positions_,1)
                this.actuators_ = [this.actuators_ PointSource(this.actuator_positions_(ix,:), [], this.fs_)];
            end
        end
        
        function ResetSecondaryFilter(this)
            this.s_ = zeros(size(this.actuator_positions_,1)*size(this.error_positions_,1), this.secondary_order_);
            this.identification_error_offset_ = 0;
            this.identification_error_ = [];
        end
        
        function ResetReferenceFilter(this)
            this.t_ = zeros(size(this.reference_positions_,1)*size(this.reference_positions_,1), this.decorrelation_order_);
            this.reference_filter_identification_error_offset_ = 0;
            this.reference_filter_identification_error_ = [];
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