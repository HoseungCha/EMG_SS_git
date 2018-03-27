classdef circlequeue <handle
    %CIRCLEQUEUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        length = 0 %maximm datalength
        dimension = 0;
        data = [];
        index_start = 0;
        index_end = 0;
        
        datasize = 0; %datalength which are inserted
    end
    
    methods
        function obj = circlequeue(len,dim)
            obj.length = len;
            obj.dimension = dim;
            obj.data = zeros(len,dim);
        end
        
        function obj = add(obj, new_data)
            obj.index_end = mod(obj.index_end,obj.length)+1;
            obj.data(obj.index_end,:) = new_data;
            if obj.index_start==0
                obj.datasize = obj.datasize+1;
                obj.index_start = mod(obj.index_start,obj.length)+1;
            elseif obj.datasize<obj.length
                obj.datasize = obj.datasize+1;
            else
                obj.index_start = mod(obj.index_start,obj.length)+1;
            end
            
        end
        
        function d = get(obj, index)
            if index>obj.length ||index<1
                d = [];
                return;
            end
            idx = mod(obj.index_start-1 + index-1, obj.length)+1;
            d = obj.data(idx,:);
        end
        function d = getLast(obj)
            d = obj.data(obj.index_end,:);
        end
        
        function d = get_fromEnd(obj, index)
            if index>obj.length ||index<1
                d = [];
                return;
            end
            idx = mod(obj.index_end-1 - index+1, obj.length)+1;
            d = obj.data(idx,:);
        end
        
        function d = pop(obj)
            if obj.datasize==0
                d=[];
                return;
            end
            d = obj.data(obj.index_end,:);
            obj.index_end = mod(obj.index_end -1-1, obj.length)+1;
            obj.datasize = obj.datasize -1;
        end
        
        function d = pop_fromBeginning(obj)
            if obj.datasize==0
                d=[];
                return;
            end
            d = obj.data(obj.index_start,:);
            obj.index_start = mod(obj.index_start -1+1, obj.length)+1;
            obj.datasize = obj.datasize -1;
        end
    end
    
end

