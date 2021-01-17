clear
clc

[num txt raw]=xlsread('ToyotaCorolla.xls');
num=num(:,3:38); %model and id column are deleted
raw=raw(2:end,:); %title raw is deleted
num(find(num(:,11)==16000), 13)=1600; %an outlier is corrected
[r c]=size(num);

%converting class column to numeric values
for i=1:length(raw)
     x=strfind(raw{i,3},'H');
     y=strfind(raw{i,3},'L');
    if x==1 %strfind returns 1 for high and [] for others
        num(i,1)=0;    
    elseif y==1 %%strfind returns 1 for low and [] for others
        num(i,1)=1;
    else
       num(i,1)=2; %moderate
    end
end

%converting fuel column to numeric values
for i=1:length(raw)
     e=strfind(raw{i,8},'P');
     f=strfind(raw{i,8},'D');
    if e==1 %strfind returns 1 for petrol and [] for others
        num(i,6)=0;    
    elseif f==1 %%strfind returns 1 for diesel and [] for others
        num(i,6)=1;
    else
       num(i,6)=2; %CNG
    end
end

%converting color column to numeric values
for i=1:length(raw)
     h=strfind(raw{i,11},'Blu');
     g=strfind(raw{i,11},'Bla');
     z=strfind(raw{i,11},'Be');
     t=strfind(raw{i,11},'Grey');
     u=strfind(raw{i,11},'Green');
     v=strfind(raw{i,11},'W');
     k=strfind(raw{i,11},'Y');
     d=strfind(raw{i,11},'R');
     b=strfind(raw{i,11},'V');
    if h==1; %strfind returns 1 for blue and [] for others
        num(i,9)=0;    
    elseif g==1; %%strfind returns 1 for black and [] for others
        num(i,9)=1;
    elseif z==1; %%strfind returns 1 for beige and [] for others
        num(i,9)=2;
    elseif t==1; %%strfind returns 1 for grey and [] for others
        num(i,9)=3;
    elseif u==1; %%strfind returns 1 for green and [] for others
        num(i,9)=4;
    elseif v==1; %%strfind returns 1 for white and [] for others
        num(i,9)=5;
    elseif k==1; %%strfind returns 1 for yellow and [] for others
        num(i,9)=6;
    elseif d==1; %%strfind returns 1 for red and [] for others
        num(i,9)=7;
    elseif b==1; %%strfind returns 1 for violet and [] for others
        num(i,9)=8;
    else
       num(i,9)=9; %others
    end
end

%moving class column to the end
a(:,1)=num(:,1);
for i=1:35
num(:,i)=num(:,i+1);
end
num(:,36)=a(:,1);

newdata=num;
%partitioning 80%-20%
for i=1:round(r*0.8)
              z(i,1)=randi(r-i+1,1);
              trainattribute(i,1:c-1)=newdata(z(i,1),1:c-1);
              traintarget(i,1)=newdata(z(i,1),c);
              newdata(z(i,1),:)=[];
            
end
testattribute(:,1:c-1)=newdata(:,1:c-1);
testtarget(:,1)=newdata(:,c);

ctree=classregtree(trainattribute, traintarget, 'method', 'classification'); %categorical variables, thus we used classification instead of regression
maxprune=max(ctree.prunelist);
view(ctree)

ctreetest=classregtree(testattribute, testtarget, 'method', 'classification'); %categorical variables, thus we used classification instead of regression
maxprune2=max(ctreetest.prunelist);
view(ctreetest)

%percentange error calculation for train set
for k=1:maxprune+1 %k represents the pruning level
    traincount=0;
    ptree=prune(ctree, 'level', k-1); %pruning the tree one by one
    trainprediction(:,k)=ptree(trainattribute);  %prediction with the tree pruned by prunning level i, note that the prediction is string type hence we need to first concatenate and then convert to numeric values
    for i=1:round(r*0.8)
       if  str2num(cell2mat(trainprediction(i,k)))~=traintarget(i); %firstly, cell arrays of different predictions are concatenated into single matrix, then string values are converted to numeric values
       traincount=traincount+1;
       end
    end
    TrainError(k,1)=traincount/round(r*0.8)*100;
end

%percentange error calculation for test set
for k=1:maxprune+1 %k represents the pruning level
    testcount=0;
    ptree=prune(ctree, 'level', k-1);  %pruning the tree one by one
    testprediction(:,k)=ptree(testattribute); %prediction with the tree pruned by prunning level i, note that the prediction is string type hence we need to first concatenate and then convert to numeric values
    for i=1:round(r*0.2)
       if  str2num(cell2mat(testprediction(i,k)))~=testtarget(i); %firstly, cell arrays of different predictions are concatenated into single matrix, then string values are converted to numeric values
         testcount=testcount+1;
       end
    end
  TestError(k,1)=testcount/round(r*0.2)*100;
end                                                                           
%for both train and test sets, error increases each time we prune the tree
%since we lose information and thus make worse predictions
%we see that the maximimum error is around 67% which was the error we have
%obtained with naive rule, we can concluded that prunning all the branches
%gives us the naive rule prediction
%test error is greater than training error because of overfitting

%min error values and corresponding prunining levels for both training and
%test sets
[mintrainerror mintrainerrorloc]=min(TrainError(:,1));
mintrainerrorloc=mintrainerrorloc-1;
[mintesterror mintesterrorloc]=min(TestError(:,1));
mintesterrorloc=mintesterrorloc-1;

figure
plot(0:maxprune, TrainError(:,1));
hold on
grid on
plot(0:maxprune, TestError(:,1), 'g');
xlabel('Pruning Level');
ylabel('%Error');
legend('TrainError', 'TestError');

%best pruned tree
[cost,stderror,nodes,bestlevel]=test(ctree,'cross',trainattribute,traintarget) %nodes=number of nodes, stderror=standard deviation of cost

%plotting pruning level vs. number of nodes 
figure
 plot(1:maxprune+1,nodes)
 xlabel('PruningLevel')
 ylabel('no of terminal nodes')
 
%best pruned tree
tbest=prune(ctree, 'level', bestlevel);
view(tbest)

%cost and nb of terminal nodes of minimum error trees
[mincost, minloc]=min(cost);
minerrorcost=cost(minloc);
minerrornode=nodes(minloc+1);

%cost and nb of terminal nodes of best pruned tree
bestprunedcost=cost(bestlevel);
bestprunednode=nodes(bestlevel+1);

%cost vs nb of nodes
figure
plot(nodes,cost,'b-o', ...
     nodes(bestlevel+1),cost(bestlevel+1), 'bs', ...
     nodes,(mincost+stderror(minloc))*ones(size(nodes)), 'k--')
xlabel('nodes')
ylabel('cost')

%min cost tree
ptree=prune(ctree, minloc)
view(ptree)

%confusion matrix for training set
C1 = confusionmat(traintarget,str2num(cell2mat(trainprediction(:,bestlevel+1))));

%confusion matrix for test set
C2 = confusionmat(testtarget,str2num(cell2mat(testprediction(:,bestlevel+1))));