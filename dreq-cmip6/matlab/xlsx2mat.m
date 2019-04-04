clear all 

PREFIX='CMIP6_data_request_v1.00.30beta1';
% read work sheets and concatenate
fid=fopen([PREFIX '.mat'],'r');
if fid<0
  a=dir('Data_xlsx/*xlsx'); 
  for n=1:numel(a) 
    fname=char(a(n).name); 
    ind=strfind(fname,'_'); 
    MIP=fname(ind(1)+1:ind(2)-1);
    EXP=fname(ind(2)+1:ind(3)-1); 
    [status,sheets]=xlsfinfo(['Data_xlsx/' fname]);
    ntable=numel(sheets)-1; 
    disp([MIP ' ' EXP]);
    for t=1:ntable
      [dummy,TXT]=xlsread(['Data_xlsx/' fname],t+1);
      [nrow,ncol]=size(TXT); 
      for m=1:nrow
        TXT{m,ncol+1}=sheets{t+1}; 
        TXT{m,ncol+2}=EXP; 
        TXT{m,ncol+3}=MIP; 
      end 
      if n==1 & t==1  
        head=TXT(1,:);  
        head{1,ncol+1}='Table';
        head{1,ncol+2}='Experiment';
        head{1,ncol+3}='MIP';
        data=TXT(2:end,:);
      else
        data=cat(1,data,TXT(2:end,:));
      end
    end 
  end 
  save([PREFIX '.mat'],'head','data');
else
  fclose(fid);
  load([PREFIX '.mat']);
end

