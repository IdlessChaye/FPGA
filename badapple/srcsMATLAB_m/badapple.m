%Obj=serial('com1','baudrate',115200,'parity','none','databits',8,'stopbits',1);%初始化串口
%Fopen（obj）；%打开串口对象
%Fwrite（obj，256）；%向串口发送握手信号0xff
delete(instrfindall)

%s=serial('com3','baudrate',115200,'parity','none','databits',8,'stopbits',1);%初始化串口
s=serial('com5','baudrate',115200,'parity','none','databits',8,'stopbits',1);%初始化串口

fopen(s);    %打开串口设备对象

[m,n] = size(raw_data);
zhenshu = 55;
yuansu = 1;
senddata = 0;

pause(1)

while true
    senddata = raw_data(zhenshu,yuansu);
   	pause(0.000008); %11520Hz 每一帧要这么多秒
    fwrite(s,senddata);
    if yuansu==n
        yuansu = 1;
        if zhenshu >= m
            break;
        else
            zhenshu = zhenshu + 2;
        end 
    else
        yuansu = yuansu + 1;
    end
end

