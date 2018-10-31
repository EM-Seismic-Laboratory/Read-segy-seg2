function  [vz,dx,dt,fileinfo]=read_sgy1(segFile)
     fileinfo.daojianju=0;
     fileinfo.daoqishi=0;
     fid=fopen(segFile,'r');
     fseek(fid, 3224, 'bof');
     fileinfo.dataformat=fread(fid, 1, 'uint16');%数据格式
     if fileinfo.dataformat>10
        fclose(fid);
        fid=fopen(segFile,'r','b');
        fseek(fid, 3224, 'bof');
        fileinfo.dataformat=fread(fid, 1, 'uint16');%数据格式
     end
      fileinfo.dataformat=5;  
  switch fileinfo.dataformat
      case 1
         fseek(fid, 3226, 'bof');
         fileinfo.daoshu=fread(fid, 1, 'uint16');%道数

         fseek(fid, 3220, 'bof'); 
         fileinfo.yangdianshu=fread(fid, 1, 'uint16');%样点数

         fseek(fid, 3216, 'bof');
         timeinterval=fread(fid, 1, 'uint16');%采样间隔
         fileinfo.timeinterval=timeinterval/1000;%单位为毫秒

         fseek(fid, 0, 'bof');
         position1=ftell(fid);
         fseek(fid, 0, 'eof'); 
         position2=ftell(fid);
         fileinfo.daoshu=(position2-position1-3600)/(fileinfo.yangdianshu*4+240);
         for i=1:fileinfo.daoshu
             offset=3600+(240+4*fileinfo.yangdianshu)*(i-1);
              fseek(fid, offset+36, 'bof');
             xoffset(i)=fread(fid, 1, 'uint16');%偏移距道数;
             fseek(fid, offset+240, 'bof');
             tracedata=fread(fid, fileinfo.yangdianshu, 'float32');%读每道数据
             tracedata=ibm2num(uint32(tracedata));
             vz(i,:)=tracedata;
         end
      case 5
         fseek(fid, 3226, 'bof');
         fileinfo.daoshu=fread(fid, 1, 'uint16');%道数

         fseek(fid, 3220, 'bof'); 
         fileinfo.yangdianshu=fread(fid, 1, 'uint16');%样点数

         fseek(fid, 3216, 'bof');
         timeinterval=fread(fid, 1, 'uint16');%采样间隔
         fileinfo.timeinterval=timeinterval/1000;%单位为毫秒

         fseek(fid, 0, 'bof');
         position1=ftell(fid);
         fseek(fid, 0, 'eof'); 
         position2=ftell(fid);
         fileinfo.daoshu=(position2-position1-3600)/(fileinfo.yangdianshu*4+240);
         for i=1:fileinfo.daoshu
             offset=3600+(240+4*fileinfo.yangdianshu)*(i-1);
              fseek(fid, offset+36, 'bof');
             xoffset(i)=fread(fid, 1, 'uint16');%偏移距道数;
             fseek(fid, offset+240, 'bof');
             vz(i,:)=fread(fid, fileinfo.yangdianshu, 'float32');%读每道数据
         end
  end
          
      dt=fileinfo.timeinterval/1000;%%单位为秒
      dx=(xoffset(3)-xoffset(2));
      vz=vz';
      fileinfo.dt=dt;
     fclose(fid);
end
