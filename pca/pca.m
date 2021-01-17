clear
clc

dataset=xlsread('Q2_1743012.xlsx');
M=mean(dataset);
S=std(dataset);

for i=1:size(dataset,1)
    dataset(i,:)=(dataset(i,:)-M)./(S+(S==0));
end

for i=1:450
              x(i,1)=randi(563-i+1,1);
              training(i,:)=dataset(x(i,1),:)
              dataset(x(i,1),:)=[];
end

test=dataset
[coeff,score,latent]= pca(training)
totalvar=sum(latent);
cumvar=(cumsum(latent./totalvar)*100);
for i=1:10
    if  cumvar(i)>95
    suff=i
    break
    end
end

transformed=test*coeff(:,1:6)
save transformed

        