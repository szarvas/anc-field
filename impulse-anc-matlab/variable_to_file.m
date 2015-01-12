function variable_to_file(location, data)
    file = fopen(location, 'w');
    
    if file ~= -1
        for ix=1:length(data)
            fprintf(file,'%1.17f', data(ix));
			if ix ~= length(data)
				fprintf(file,'\n');
			end
        end
    end
    
    fclose(file);
end