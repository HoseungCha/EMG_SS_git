% Class for Circle Queue
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
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

        function obj = addArray(obj, new_data)
            %add 함수와 동일하지만 new_data의 길이가 1 이상인 경우
            %new_data의 길이는 queue 의 길이보다 짧다고 가정한다.
            nRowNew = size(new_data,1);
            p_new_start = mod(obj.index_end,obj.length)+1;
            p_new_end   = p_new_start+nRowNew-1;
            if p_new_end <= obj.length
                obj.index_end = p_new_end;
                obj.data(p_new_start:p_new_end,:) = new_data;
            else
                nFirstPart = obj.length - obj.index_end;
                nLeftPart  = nRowNew - nFirstPart;
                obj.data(p_new_start:obj.length,:) = new_data(1:nFirstPart,:);
                obj.data(1:nLeftPart,:) = new_data(nFirstPart+1:nRowNew,:);
                
                obj.index_end = p_new_end - obj.length;
            end
            
            if obj.index_start==0
                obj.datasize = obj.datasize+nRowNew;
                obj.index_start = 1;
            elseif obj.datasize+nRowNew <= obj.length
                obj.datasize = obj.datasize+nRowNew;
            else
                obj.datasize = obj.length;
                obj.index_start = mod(obj.index_end,obj.length)+1;

            end
        end
        
        function d = get(obj, index,dim)
            if nargin <3
                dim = 1:size(obj.data,2);
            end
            if index>obj.length ||index<1
                d = [];
                return;
            end
            idx = mod(obj.index_start-1 + index-1, obj.length)+1;
            d = obj.data(idx,dim);
        end
        
        function d = getLast(obj)
            d = obj.data(obj.index_end,:);
        end
        
        %get last n data 
        function d = getLastN(obj,n)
            if obj.datasize<n
                idxStart = obj.index_start;
                idxEnd   = obj.index_end;
            else
                idxStart = obj.getOrignalIdx(obj.datasize-n+1);
                idxEnd   = obj.index_end;
            end

            if idxEnd>=idxStart
                d = obj.data(idxStart:idxEnd,:);
            else
                mid = obj.length-idxStart+1;
                d= zeros(n,obj.dimension);
                d(1:mid,:) = obj.data(idxStart:obj.length,:);
                d(mid+1:n,:) = obj.data(1:idxEnd,:);
            end

        end
        
        function d = get_fromEnd(obj, index,dim)
            if nargin<3
                dim = 1:size(obj.data,2);
            end
            if index>obj.length ||index<1
                d = [];
                return;
            end
            idx = mod(obj.index_end-1 - index+1, obj.length)+1;  %뒤쪽에서 한바퀴 이상 도는 경우 문제 발생가능할 듯. check 필요. (2014.11.13)
            d = obj.data(idx,dim);
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
        
        function idxArray = getOrignalIdx(obj, idxQueue)
            %convert index on the circlequeue into the index on the array
            idxArray = obj.index_start + idxQueue - 1;
            if idxArray>obj.length
                idxArray = idxArray - obj.length;
            end
        end
        
        function set(obj,range_start, range_end, value, dim)
            if nargin <5
                dim = 1:size(obj.data,2);
            end
            idxStart = obj.getOrignalIdx(range_start);
            idxEnd   = obj.getOrignalIdx(range_end);
            if idxEnd>=idxStart
                obj.data(idxStart:idxEnd,dim) = value;
            else
                nTotalData = size(value,1);
                if nTotalData>1
                    nFirstPart = obj.length-idxStart+1;
                    obj.data(idxStart:obj.length,dim) = value(1:nFirstPart,:);
                    obj.data(1:idxEnd,dim) = value(nFirstPart+1:nTotalData,:);
                else
                    obj.data(idxStart:obj.length,dim) = value;
                    obj.data(1:idxEnd,dim) = value;
                end
            end
        end
        function d = getArray(obj,range_start, range_end, dim)
            if nargin <4
                dim = 1:size(obj.data,2);
            end
            idxStart = obj.getOrignalIdx(range_start);
            idxEnd   = obj.getOrignalIdx(range_end);
            
            if idxEnd>=idxStart
                d=obj.data(idxStart:idxEnd,dim);
            else
    
                d1=obj.data(idxStart:obj.length,dim);
                d2=obj.data(1:idxEnd,dim);
                d= [d1;d2];
            end
        end

    end
    
end

