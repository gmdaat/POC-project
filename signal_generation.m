clear all;
close all;
clc;

cnt=0;

for abc=1:100
% signal generation;如果想要进行100组独立的测试，可以建立100次循环，产生100组独立的数据
for j = 1:1  % bit per symbol: 1. PSK; 2. QPSK; 3.8QAM; 4. 16QAM; 5. 32QAM; 6.64QAM...
System.BitPerSymbol = j;
snr = 12:15;  %SNR信噪比的设置，单位dB
for snrIndex= 1:length(snr)

Tx.SampleRate = 32e9; %symbol Rate，信号的码元速率，可以自行定义
Tx.Linewidth = 0;%发射信号的载波的线宽，一般与信号的相位噪声有关，大小可自行设置，这里暂时设置为0
Tx.Carrier = 0;%发射信号的载波频率，可自行设置，这里暂设为0
M = 64;

Tx.DataSymbol = randi([0 M-1],1,10000);%每一次随机产生的数据量，这里暂时设为数据点个数为10000个

%数据的不同调制方式产生：这里把2^3（8QAM）的形式单独拿出来设置，是为了实现最优的星型8QAM星座图
if M ~= 8;
    h = modem.qammod('M', M, 'SymbolOrder', 'Gray');
    Tx.DataConstel = modulate(h,Tx.DataSymbol);
else
    tmp = Tx.DataSymbol;
    tmp2  = zeros(1,length(Tx.DataSymbol));
    for kk = 1:length(Tx.DataSymbol)

        switch tmp(kk)
            case 0
                tmp2(kk) = 1 + 1i;
            case 1
                tmp2(kk) = -1 + 1i;
            case 2
                tmp2(kk) = -1 - 1i;
            case 3
                tmp2(kk) = 1 - 1i;
            case 4
                tmp2(kk) = 1+sqrt(3);
            case 5
                tmp2(kk) = 0 + 1i .* (1+sqrt(3));
            case 6
                tmp2(kk) = 0 - 1i .* (1+sqrt(3));
            case 7
                tmp2(kk) = -1-sqrt(3);
        end
    end
    Tx.DataConstel = tmp2;
    clear tmp tmp2;
end


Tx.Signal = Tx.DataConstel;

%数据的载波加载，考虑到相位噪声等
N = length(Tx.Signal);
dt = 1/Tx.SampleRate;
t = dt*(0:N-1);
Phase1 = [0, cumsum(normrnd(0,sqrt(2*pi*Tx.Linewidth/(Tx.SampleRate)), 1, N-1))];
carrier1 = exp(1i*(2*pi*t*Tx.Carrier + Phase1));
Tx.Signal = Tx.Signal.*carrier1;


Rx.Signal = awgn(Tx.Signal,snr(snrIndex),'measured');%数据在AWGN信道下的接收

CMAOUT = Rx.Signal;

%normalization接收信号功率归一化
CMAOUT=CMAOUT/sqrt(mean(abs(CMAOUT).^2));

% subplot(1,7,snrIndex);
% plot(Rx.Signal,'.');


end
end
HOCMC(Rx.Signal)
% if (HOCMC(Rx.Signal)=='8PSK')
%     cnt=cnt+1;
%end

end
cnt

%HOCMC(Rx.Signal)    


