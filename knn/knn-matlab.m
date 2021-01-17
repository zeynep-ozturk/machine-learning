clear
clc

dataset=xlsread('Cities.xlsx');
group=dataset(1:247,10);
newdata=dataset(:,1:9);
M=mean(newdata);
S=std(newdata);
%normalizing
for i=1:size(newdata,1)
    newdata(i,:)=(newdata(i,:)-M)./(S+(S==0));
end
%partitioning
for i=1:247
              x(i,1)=randi(329-i+1,1);
              training(i,:)=newdata(x(i,1),:);
              newdata(x(i,1),:)=[];
end
test=newdata;
count=zeros(2,247);
%knn for test data
for k=1:247
Classtest(:,k)=knnclassify(test, training, group, k);
for i=1:82
if dataset(i+247,10)~=Classtest(i,k);
count(1,k)=count(1,k)+1;
end
end
classerrortest(1,k)=count(1,k)/82*100;
end
[c i]=min(count(1,:));
mink=i;
%knn for training data
for k=1:247
Classtrain(:,k)=knnclassify(training, training, group, k);
for i=1:247
if dataset(i,10)~=Classtrain(i,k);
count(2,k)=count(2,k)+1;
end
end
classerrortrain(1,k)=count(2,k)/247*100;
end

[z t]=min(count(2,:));
minktrain=t;
plot(1:247, classerrortest, 'g');
hold on
plot(1:247, classerrortrain);
xlabel('k values');
ylabel('%error');
legend('test', 'training');
