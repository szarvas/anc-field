function supression = CalculateSupression(elms, interval)
    if nargin==1
        interval = 0.5;
    end
    nmax = length(elms.error_(1,:));
    nmin = nmax - elms.fs_*interval;
    
    noise = zeros(1,nmax-nmin+1);
    antinoise = zeros(1,nmax-nmin+1);
    
    supression = zeros(1,length(elms.error_positions_));
    
    for k=1:length(elms.error_positions_)
        for s=1:length(elms.sources_)
            sig = elms.sources_(s).GetSignal(elms.error_positions_(k));
            nmin
            nmax
            noise = noise + sig(nmin:nmax);
        end

        for s=1:length(elms.actuators_)
            sig = elms.actuators_(s).GetSignal(elms.error_positions_(k));
            antinoise = antinoise + sig(nmin:nmax);
        end
        
        supression(k) = 10*log10((noise+antinoise)*(noise+antinoise)' / (noise * noise'));
    end
    
end