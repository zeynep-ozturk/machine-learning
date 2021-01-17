clear
clc

[num text raw]=xlsread('Health.xlsx');
%converting gender column to binary
for i=2:length(text)
     x=strfind(text{i,2},'F');
    if x==2; %strfind returns 2 for females and [] for males
        raw{i,2}=1;       
    else
        raw{i,2}=0;
    end
   num(i-1,12)=raw{i,2}; %gender column is copied to 12th column to num which is created just now
end
%converting all the values except the categorical and binary ones to 
%numbers b/w 0 & 1
maxvalue=max(num(:,1:10));
minvalue=min(num(:,1:10));
for i=1:size(num,1)
    num(i,1:6)=(num(i,1:6)-minvalue(1,1:6))./(maxvalue(1,1:6)-minvalue(1,1:6));%binary columns smoker,car,employed and gender are not standardized
end
for i=1:size(num,1)
   num(i,10)=(num(i,10)-minvalue(1,10))./(maxvalue(1,10)-minvalue(1,10));%diabetes column is also not standardized since it will be a reference in the future
end
%partitioning 80%-20%
newnum=num;
for i=1:720
              z(i,1)=randi(900-i+1,1);
              training(i,:)=newnum(z(i,1),:);
              newnum(z(i,1),:)=[];
end
test=newnum;
%distance calculation for categorical data
for i=1:180
    for j=1:720
        distance1(i,j)=abs(test(i,9)-training(j,9))./2;
    end
end
%distance calculation for binary data
for i=1:180
    for j=1:720
            distance2(i,j)=abs(test(i,7)-training(j,7));
            distance2(i,j)=distance2(i,j)+abs(test(i,8)-training(j,8));
            distance2(i,j)=(distance2(i,j)+abs(test(i,12)-training(j,12)))./3;
    end
end
%euclidean distance calculation for numeric data in the range [0,1]
for i=1:180
    for j=1:720
        y=0;
            for k=1:6
                y=y+(test(i,k)-training(j,k)).^2;
            end
    y=y+(test(i,10)-training(j,10)).^2;
    distance3(i,j)=sqrt(y);
    end
end
%sum of all distances
for i=1:180
    for j=1:720
totaldistance(i,j)=distance1(i,j)+distance2(i,j)+distance3(i,j);
    end
end
%sorting and selecting first k smallest distances
for k=1:720
    for i=1:180
     [totaldistancesorted(i,:) index(i,:)] = sort(totaldistance(i,:));
     smallestk(i,1:k)= totaldistancesorted(i,1:k);
     smallestindex(i,1:k) = index(i,1:k);
     major(i,k)=mode(training(smallestindex(i,1:k),11)); %majority of diabetes attributes of the k smallest neighbors are chosen
    end
end
%error calculation
for k=1:720
    Error(k,2)=0;
    for i=1:180
    Error(k,2)=Error(k,2)+(abs(major(i,k)-test(i,11)))./2;
    end
    Error(k,1)=k; 
end
[C I]=min(Error(:,2));
bestk=I;
grid on
hold on
plot(Error(:,1),Error(:,2),'r')
xlabel('k values')
ylabel('error')






   