function [nodes] = init_nodos(I,N)
nodes = struct('buffer',{});
for i=1:I
for n = 1:N
nodes(i,n).buffer = [];
end
end
end

