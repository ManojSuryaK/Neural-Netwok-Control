%%%% IDENTIFICATION EXAMPLE 6
clc;clear;
%%%%%%%%%%%%% IDENTIFICATION PROCESS
k=[1:50000];

a=0;b=0;
yp=[b a zeros(1,length(k))];        %%%% plant trajectory 
yphat=[b a zeros(1,length(k))];     %%%% identification model trajectory

NNclass=[1 20 10 1];
in=NNclass(1);n1=NNclass(2);n2=NNclass(3);out=NNclass(4);

W1=randn(in+1,n1);          %%%% Weight initialization
W2=randn(n1+1,n2);
W3=zeros(n2+1,out);

eta=0.1;                           %%%%%%%%%% HOLY SHIT

u=(-1+2*rand(1,length(k)+2));       %%%% Input to the systems

f=@(u)((u-0.8)*u*(u+0.5));          %%%% function to be approximated
error_train=zeros(1,length(k));
difftanh=@(x)(sech(x).^2);
for i=3:length(k)+2
    yp(i)=0.8*yp(i-1)+f(u(i-1));
    %%%% NEURAL NETWORK(i suck at this shit)
    %Forward Pass
    A1=[1 u(i-1)]*W1;
    y1=tanh(A1);
    A2=[1 y1]*W2;
    y2=tanh(A2);
    A3=[1 y2]*W3;
    N=A3;
    %Identification model output
    yphat(i)=0.8*yphat(i-1)+N;
    e=-(yphat(i)-yp(i));            %%%% error
    %Backward Pass
    del3=e;
    del2=difftanh(A2).*(del3*W3(2:end,:)');
    del1=difftanh(A1).*(del2*W2(2:end,:)');
    Jw3=[1 y2]'*del3;               %%%% These are not gradients, these are cray-dients
    Jw2=[1 y1]'*del2;
    Jw1=[1 u(i-1)]'*del1;
    %Weight Update
    W3=W3+eta*Jw3;
    W2=W2+eta*Jw2;
    W1=W1+eta*Jw1;
    error_train(i-2)=e;
end
plot(yp)
hold on
plot(yphat)
xlim([1 500])
title('response of actual plant and identification model(training)');
legend('actual plant output','identification model output');
%saveas(gcf,'C:/Users/tarun/Documents/id/figs/ex6/bpa2/train1.png')
%%
%plot different time step
figure;
plot(yp)
hold on;
plot(yphat)
xlim([41000 41500])
title('response of actual plant and identification model (at a different time step)');
legend('actual plant output','identification model output');
%saveas(gcf,'C:/Users/tarun/Documents/id/figs/ex6/bpa2/train2.png')
%%
%Performance Measures (Training)
figure;
plot(error_train)
title('Training error')
rmse1=rms(error_train(1:10000));
rmse2=rms(error_train(10001:end));
fprintf('Training RMS error 1 = %f\n',rmse1);
fprintf('Training RMS error 2 = %f\n\n',rmse2);
disp('Variance Accounted For (training)');
VAF=(1-var(yp-yphat)/var(yp))*100;
disp(VAF);
%saveas(gcf,'C:/Users/tarun/Documents/id/figs/ex6/bpa2/error_train.png')
%%
%saving weights
save('WeightsH2_NP90_ex6','W1','W2','W3');
disp('saved');
%%
%loading weights
load('WeightsH2_NP90_ex6');
disp('loaded');
%%
%response of identification model(hopefully identified system) to different input
k=[1:5000];
f=@(u)((u-0.8)*u*(u+0.5));
b=0; a=0;
yp=[b a zeros(1,length(k))];
yphat=[b a zeros(1,length(k))];
u=@(k)(sin((2*pi).*k./25));
error_test=zeros(1,length(k));
for i=3:length(k)+2
    yp(i)=0.8*yp(i-1)+f(u(i-1)); %%%% Plant output
    %Forward Pass
    A1=[1 u(i-1)]*W1;
    y1=tanh(A1);
    A2=[1 y1]*W2;
    y2=tanh(A2);
    A3=[1 y2]*W3;
    N=A3;
    yphat(i)=0.8*yphat(i-1)+N;   %%%% INDEPENDENT identfication model output
    e=-(yphat(i)-yp(i));
    error_test(i-2)=e;
end
%%
%Performance Measures
figure;
plot(error_test)
title('Testing error');
rmse1=rms(error_test(1:1000));
rmse2=rms(error_test(1001:end));
fprintf('Testing RMS error 1 = %f\n',rmse1);
fprintf('Testing RMS error 2 = %f\n\n',rmse2);
disp('Variance Accounted For (testing)');
VAF=(1-var(yp-yphat)/var(yp))*100;
disp(VAF);
%saveas(gcf,'C:/Users/tarun/Documents/id/figs/ex6/bpa2/error_test.png')
%%
figure;
plot(yp);
hold on;
plot(yphat);
xlim([1 200])
title('response of actual plant and identified model to a different input(testing)')
legend('actual plant output','identification model output');
%saveas(gcf,'C:/Users/tarun/Documents/id/figs/ex6/bpa2/test.png')