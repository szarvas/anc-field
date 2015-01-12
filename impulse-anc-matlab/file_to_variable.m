function data = file_to_variable(location)
    file = fopen(location, 'r');
    
    data = fscanf(file, '%f\n');
    
    fclose(file);
    
    data = data';
end