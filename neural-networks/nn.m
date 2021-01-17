clear
clc

data=xlsread('bodyfat.xlsx');

%checking existence of outliers
for i=1:14
    figure
    hist(data(i,:))
end

%finding outliers
[Imax2 cmax2]= max(data(2,:));
[Imin3 cmin3]= min(data(3,:));
[Imax7 cmax7]= max(data(7,:));
[out10loc]=find(data(10,:)>32);

data(:,out10loc(2))=[];
data(:,out10loc(1))=[];
data(:,cmax2)=[];
data(:,cmin3)=[];

[r c ]=size(data);

%scaling of data to range (0,1)
for i=1:r
    maxvalues(i,1)=max(data(i,:));
    minvalues(i,1)=min(data(i,:));
    for j=1:c
        data(i,j)=(data(i,j)-minvalues(i,1))/(maxvalues(i,1)-minvalues(i,1));
    end
end

attributes=data(1:13,:);
target=data(14,:);

%scaling of predictions
predictions=xlsread('bodyfat.xlsx','Newcomers');
[r2 c2]=size(predictions);

for i=1:r2
    maxvalues(i,1)=max(predictions(i,:));
    minvalues(i,1)=min(predictions(i,:));
    for j=1:c2
        data(i,j)=(predictions(i,j)-minvalues(i,1))/(maxvalues(i,1)-minvalues(i,1));
    end
end

%converting the predicted values to their original scales
x=[0.66887 0.66887 0.66887 0.90333 0.66887 0.66887 0.66887 0.66887 0.66887 0.66887];
x=x'
    for j=1:c2
        x(j)=x(j)*(maxvalues(i,1)-minvalues(i,1))+minvalues(i,1);
    end




