function x = generate_ksi(size, length)
    ai = size-length;
    xi = [size-length:size];
    absorber = 8000*( abs(xi-ai)/length - sin(2*pi*abs(xi-ai)/length)/(2*pi) );
    x = zeros(1,size);
    x(end-length+1:end) = absorber(end-length+1:end);
    x(1:length) = fliplr(absorber(end-length+1:end));
end