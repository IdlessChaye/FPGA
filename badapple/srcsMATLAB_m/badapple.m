%Obj=serial('com1','baudrate',115200,'parity','none','databits',8,'stopbits',1);%��ʼ������
%Fopen��obj����%�򿪴��ڶ���
%Fwrite��obj��256����%�򴮿ڷ��������ź�0xff
delete(instrfindall)

%s=serial('com3','baudrate',115200,'parity','none','databits',8,'stopbits',1);%��ʼ������
s=serial('com5','baudrate',115200,'parity','none','databits',8,'stopbits',1);%��ʼ������

fopen(s);    %�򿪴����豸����

[m,n] = size(raw_data);
zhenshu = 55;
yuansu = 1;
senddata = 0;

pause(1)

while true
    senddata = raw_data(zhenshu,yuansu);
   	pause(0.000008); %11520Hz ÿһ֡Ҫ��ô����
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

