[num2 text2 raw2]=xlsread('Health.xlsx',2);
%converting gender column to binary
for i=2:length(text2)
     x=strfind(text2{i,2},'F');
    if x==2; %strfind returns 2 for females and [] for males
        raw2{i,2}=1;       
    else
        raw2{i,2}=0;
    end
   num2(i-1,12)=raw2{i,2}; %gender column is copied to 12th column to num which is created just now
end
%converting all the values except the categorical and binary ones to 
%numbers b/w 0 & 1
maxvalue2=max(num2(:,1:10));
minvalue2=min(num2(:,1:10));
for i=1:size(num2,1)
    num2(i,1:6)=(num2(i,1:6)-minvalue2(1,1:6))./(maxvalue2(1,1:6)-minvalue2(1,1:6));%binary columns smoker,car,employed and gender are not standardized
end
for i=1:size(num2,1)
   num2(i,10)=(num2(i,10)-minvalue2(1,10))./(maxvalue2(1,10)-minvalue2(1,10));%diabetes column is also not standardized since it will be a reference in the future
end
%distance calculation for categorical data
for i=1:138
    for j=1:900
        distance21(i,j)=abs(num2(i,9)-num(j,9))./2;
    end
end
%distance calculation for binary data
for i=1:138
    for j=1:900
            distance22(i,j)=abs(num2(i,7)-num(j,7));
            distance22(i,j)=distance22(i,j)+abs(num2(i,8)-num(j,8));
            distance22(i,j)=(distance22(i,j)+abs(num2(i,12)-num(j,12)))./3;
    end
end
%euclidean distance calculation for numeric data in the range [0,1]
for i=1:138
    for j=1:900
        y=0;
            for k=1:6
                y=y+(num2(i,k)-num(j,k)).^2;
            end
    y=y+(num2(i,10)-num(j,10)).^2;
    distance23(i,j)=sqrt(y);
    end
end
%sum of all distances
for i=1:138
    for j=1:900
totaldistance2(i,j)=distance21(i,j)+distance22(i,j)+distance23(i,j);
    end
end
%sorting and selecting first bestk smallest distances

    for i=1:138
     [totaldistancesorted2(i,:) index2(i,:)] = sort(totaldistance2(i,:));
     smallestk2(i,:)= totaldistancesorted2(i,1:bestk);
     smallestindex2(i,:) = index2(i,1:bestk);
     major2(i)=mode(num(smallestindex2(i,:),11)); %majority of diabetes attributes of the bestk smallest neighbors are chosen
    end
   major2= major2.';

  
xlswrite('Health.xlsx', major2, 2, 'M2:M139')


