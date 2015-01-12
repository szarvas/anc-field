classdef Vector2D < handle
    %VECTOR2D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        y
    end
    
    methods
        function this = Vector2D(x, y, mod)
            if nargin==2
                this.x = x;
                this.y = y;
            else
                this.x = x * cos(y);
                this.y = x * sin(y);
            end
        end
        
        function ph = getFieldValue(this, field)
            ph = field.getValue(this.x, this.y);
        end
        
        function c = minus(a,b)
            c = Vector2D(a.x-b.x, a.y-b.y);
        end
    end
    
end

