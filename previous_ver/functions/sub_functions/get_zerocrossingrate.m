function zero_crossing=get_zerocrossingrate(p,Tw)
% get zero_crossing
idx_zero_crossing=zeros(Tw,1);
idx_zero_or_maybe_edge=zeros(Tw,1); 
for k=2:Tw
idx_zero_crossing(k-1)=p(k)* p(k-1)<0;
idx_zero_or_maybe_edge(k-1)=p(k)* p(k-1)==0;          
end
% get zero_crssing
check_edge_zero_crossing=find(idx_zero_crossing==1);
zero_crossing= length(check_edge_zero_crossing);
%delete edge
check_edge= length(find(diff(find(idx_zero_or_maybe_edge==1))~=1));
if check_edge>1
zero_crossing=idx_zero_crossing+ (check_edge-1); % 중간에 지나친게 아니라 정말 0이 나왔을 경우 더해줌
end
end