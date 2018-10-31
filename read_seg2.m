function [vz,dt,dx,fileinfo]=read_seg2(pathname,filename)
segFile=fullfile(pathname,filename);
fid=fopen(segFile,'r','l');
%% 读取描述块
describe=fread(fid,4, 'uint16');
%1-2 3A55H 炮头标识
%3-4 版本号
%5-6 道头指针尺寸
%7-8 道数
fileinfo.daoshu=describe(4);
%% 读取道指针地址
fseek(fid,32,'bof');
Y1=fread(fid,fileinfo.daoshu,'uint');
%% 读取道描述块
for i=1:fileinfo.daoshu
    fseek(fid,Y1(i),'bof');
    data1=fread(fid,2,'uint16');
    data2=fread(fid,2,'uint');
    format=fread(fid,1,'uint16');
    %1-2 道头标识 4422H
    %3-4 道头尺寸
    %5-8 数据段长度
    %9-12 样点数/道
    %13 数据格式
    Y2(i)=data1(2);
    fileinfo.yangdianshu=data2(2);
end
%% 读取两道信息
fseek(fid,Y1(1)+32,'bof');
Y3(1,:)=fread(fid,Y2(1)-32,'char*1')';
Y3_1=char(Y3(1,:));
fseek(fid,Y1(2)+32,'bof');
Y3(2,:)=fread(fid,Y2(2)-32,'char*1')';
Y3_2=char(Y3(2,:));
%% 读取采样率
goal_arr_char1='SAMPLE_INTERVAL';
index_star1=strfind(Y3_1,goal_arr_char1);
index_stop1=index_star1+length(goal_arr_char1)-1;
fseek(fid,Y1(1)+32+index_stop1,'bof');
dtt=fread(fid,10,'char*1')';
dt1=char(dtt);
dt=str2num(dt1);
fileinfo.dt=dt;
%% 读取道间距
goal_arr_char2='RECEIVER_LOCATION';
index_star2_1=strfind(Y3_1,goal_arr_char2);
index_stop2_1=index_star2_1+length(goal_arr_char2)-1;
fseek(fid,Y1(1)+32+index_stop2_1,'bof');
x_1=fread(fid,10,'char*1')';
x_1=char(x_1);
x_1=str2num(x_1);
index_star2_2=strfind(Y3_2,goal_arr_char2);
index_stop2_2=index_star2_2+length(goal_arr_char2)-1;
fseek(fid,Y1(2)+32+index_stop2_2,'bof');
x_2=fread(fid,10,'char*1')';
x_2=char(x_2);
x_2=str2num(x_2);
dx=x_2-x_1;
fileinfo.daojianju=dx;
fileinfo.daoqishi=x_1;
%% 读取每道数据
for i=1:fileinfo.daoshu
    fseek(fid,Y1(i)+Y2(i),'bof');
    tracedata=fread(fid,fileinfo.yangdianshu,'int32');%读每道数据
    vz(:,i)=tracedata;
end
fclose(fid);
