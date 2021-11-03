%%
dat=zeros(1,5)
for a= 1:5
dat(1,a)=ThroughPut(a);
end
plot(dat,'LineWidth',2);
xlim([1 5]);ylim([.15 .35]);grid on; hold on;
stem(dat,'color','b');