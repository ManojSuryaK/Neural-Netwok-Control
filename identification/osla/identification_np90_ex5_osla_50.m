%%%% IDENTIFICATION EXAMPLE 5 OSLA

%%%%%%%%%%%%% IDENTIFICATION PROCESS
clc;clear;
allVAF1=zeros(1,50);
allVAF2=zeros(1,50);
allrmse1=zeros(1,50);
allrmse2=zeros(1,50);
for q=1:50
    q

k=1:50000;
f1=@(x,y)(x/(1+y^2));
f2=@(x,y)(x*y/(1+y^2));

yp=[zeros(2,1) zeros(2,length(k))];
yphat=[zeros(2,1) zeros(2,length(k))];
u=-1+2*randn(2,length(k)+1);

NN_1class=[2 250 1];
NN_2class=[2 250 1];
in_1=NN_1class(1);n1_1=NN_1class(2);out_1=NN_1class(3);
in_2=NN_2class(1);n1_2=NN_2class(2);out_2=NN_2class(3);

W1_1=randn(in_1+1,n1_1);
W2_1=zeros(n1_1+1,out_1);

W1_2=randn(in_2+1,n1_2);
W2_2=zeros(n1_2+1,out_2);

lambda=1e-05;
P_1=(1/lambda)*eye(n1_1+1);
P_2=(1/lambda)*eye(n1_2+1);

for i=2:length(k)+1
    f1x=f1(yp(1,i-1),yp(2,i-1));
    f2x=f2(yp(1,i-1),yp(2,i-1));
    yp(:,i)=[ f1x ; f2x]+u(:,i-1);
    
    A1_1=[1 yp(1,i-1) yp(2,i-1)]*W1_1;
    y1_1=tanh(A1_1);
    v1_1=[1 y1_1];
    A2_1=v1_1*W2_1;
    N_1=A2_1;
    
    A1_2=[1 yp(1,i-1) yp(2,i-1)]*W1_2;
    y1_2=tanh(A1_2);
    v1_2=[1 y1_2];
    A2_2=v1_2*W2_2;
    N_2=A2_2;
    
    e_1= -(N_1 - f1x);
    e_2= -(N_2 - f2x);
    
    P_1=P_1 - ((P_1*(v1_1')*v1_1*P_1)./(1+v1_1*P_1*v1_1'));
    W2_1=W2_1+e_1*P_1*v1_1';
    
    P_2=P_2 - ((P_2*(v1_2')*v1_2*P_2)./(1+v1_2*P_2*v1_2'));
    W2_2=W2_2+e_2*P_2*v1_2';
    
    yphat(:,i)=[N_1; N_2]+u(:,i-1);
end
%%
k=1:10000;
yp=[zeros(2,1) zeros(2,length(k))];
yphat=[zeros(2,1) zeros(2,length(k))];
u=[sin((2*pi).*k./25);cos((2*pi).*k./25)];
error_1_test=zeros(1,length(k));
error_2_test=zeros(1,length(k));
for i=2:length(k)+1
    f1x=f1(yp(1,i-1),yp(2,i-1));
    f2x=f2(yp(1,i-1),yp(2,i-1));
    yp(:,i)=[ f1x ; f2x]+u(:,i-1);
    
    A1_1=[1 yphat(1,i-1) yphat(2,i-1)]*W1_1;
    y1_1=tanh(A1_1);
    A2_1=[1 y1_1]*W2_1;
    N_1=A2_1;
    
    A1_2=[1 yphat(1,i-1) yphat(2,i-1)]*W1_2;
    y1_2=tanh(A1_2);
    A2_2=[1 y1_2]*W2_2;
    N_2=A2_2;
    
    e_1= -(N_1 - f1x);
    e_2= -(N_2 - f2x);
    
    yphat(:,i)=[N_1; N_2]+u(:,i-1);
    
    error_1_test(i-1)=e_1;
    error_2_test(i-1)=e_2;
end
rmse_1=rms(error_1_test);
rmse_2=rms(error_2_test);
VAF1=(1-var(yp(1,:)-yphat(1,:))/var(yp(1,:)))*100;
VAF2=(1-var(yp(2,:)-yphat(2,:))/var(yp(2,:)))*100;
allVAF1(q)=VAF1;
allVAF2(q)=VAF2;
allrmse1(q)=rmse_1;
allrmse2(q)=rmse_2;
end
%%
avgVAF1=mean(allVAF1)
avgVAF2=mean(allVAF2)
avgrmse1=mean(allrmse1)
avgrmse2=mean(allrmse2)
stdrmse1=std(allrmse1)
stdrmse2=std(allrmse2)