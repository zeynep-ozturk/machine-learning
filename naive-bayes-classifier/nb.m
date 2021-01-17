clear
clc

[num text raw]=xlsread('ToyotaCorolla.xlsx');
newraw=raw(2:end,:);
num(find(num(:,13)==16000), 13)=1600;

%converting class column to numeric values
for i=1:length(newraw)
     x=strfind(newraw{i,3},'H');
     y=strfind(newraw{i,3},'L');
    if x==1 %strfind returns 1 for high and [] for others
        num(i,3)=0;    
    elseif y==1 %%strfind returns 1 for low and [] for others
        num(i,3)=1;
    else
       num(i,3)=2; %moderate
    end
end

%converting fuel column to numeric values
for i=1:length(newraw)
     x=strfind(newraw{i,8},'P');
     y=strfind(newraw{i,8},'D');
    if x==1 %strfind returns 1 for petrol and [] for others
        num(i,8)=0;    
    elseif y==1 %%strfind returns 1 for diesel and [] for others
        num(i,8)=1;
    else
       num(i,8)=2; %CNG
    end
end

%converting color column to numeric values
for i=1:length(newraw)
     x=strfind(newraw{i,11},'B');
     u=strfind(newraw{i,11},'G');
    if x==1 %strfind returns 1 for blue, black, beige and [] for others
        num(i,11)=0;    
    elseif u==1 %%strfind returns 1 for grey, green and [] for others
        num(i,11)=1;
    else
       num(i,11)=2; %white,yellow, red, violet
    end
end

%binning of age
for i=1:1436
    if num(i,4)<=40
        num(i,4)=0;
    elseif num(i,4)>40 && num(i,4)<=60;
        num(i,4)=1;
    else 
        num(i,4)=2;    
    end
end

%binning of manufacturing month
for i=1:1436
    if num(i,5)<=2;
        num(i,5)=0;
    elseif num(i,5)>2 && num(i,5)<=5;
        num(i,5)=1;
    elseif num(i,5)>5 && num(i,5)<=9;
        num(i,5)=2;    
    else
        num(i,5)=3;
    end
end

%binning of distance travelled in km
for i=1:1436
    if num(i,7)<=50000;
        num(i,7)=0;
    elseif num(i,7)>50000 && num(i,7)<=100000;
        num(i,7)=1;
    else
        num(i,7)=2;    
    end
end

%binning of hp
for i=1:1436
    if num(i,9)<=86;
        num(i,9)=0;
    elseif num(i,9)==110
        num(i,9)=1;
    else 
        num(i,9)=2;    
    end
end

%binning of number of cylinders after getting a variation error
k=randperm(1436);
k=k';
for i=1:round(1436*0.25)
    num(k(i,1),15)=0;
    num(k(i+round(1436*0.25),1),15)=1;
    num(k(i+2*round(1436*0.25),1),15)=2;
    num(k(i+3*round(1436*0.25),1),15)=3;
end

%binning of tax
for i=1:1436
    if num(i,17)<=80;
        num(i,17)=0;
    elseif num(i,17)>80 && num(i,17)<=99;
        num(i,17)=1;
    else
        num(i,17)=2;
    end
end

%binning of weight
for i=1:1436
    if num(i,18)<=1045;
        num(i,18)=0;
    elseif num(i,18)>1045 && num(i,18)<=1110;
        num(i,18)=1;
    else
        num(i,18)=2;
    end
end

%moving class column to the end
a(:,1)=num(:,3);
for i=3:37
num(:,i)=num(:,i+1);
end
num(:,38)=a(:,1);

%deleting id and model columns
num(:,1)=[];
num=num(:,2:37);

newnum=num;
%partitioning 80%-20%
for i=1:1150
              z(i,1)=randi(1436-i+1,1);
              trainingset(i,1:35)=num(z(i,1),1:35);
              trainingclass(i,1)=newnum(z(i,1),36);
              newnum(z(i,1),:)=[];
            
end
testset(:,1:35)=newnum(:,1:35);
testclass(:,1)=newnum(:,36);

nb=NaiveBayes.fit(trainingset, trainingclass);
Prediction=predict(nb,testset);

Error1=0;
for i=1:286
if Prediction(i,1)~=testclass(i,1);
Error1=Error1+1;
end
end
Error1=Error1/286*100;

Error2=0;
for i=1:286
    Error2=Error2+abs((Prediction(i,:)-testclass(i,:))./2);
end

Error2


