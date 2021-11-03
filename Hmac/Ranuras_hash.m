function [outputArg1] = Ranuras_hash(N,cicl)

p=N;       %%Prime number
ranura=zeros(1,N);
while(isprime(p)==0) %%para satisfacer   p>=N
        p=p+1;
end 
rng(cicl);  %%SEMILLA
an=randi([1,p-1]);
bn=randi([1,p-1]);
for r= 1:N
    first=(an*r)+bn;
    ranura(r)=mod(first,p);


outputArg1 = ranura;

end

