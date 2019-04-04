clear all 

% read data request 
PREFIX='CMIP6_data_request_v1.00.30beta1';
load(['Exp_data/' PREFIX '.mat']);

% create lists of properties 
% components 
if true % split dual entries
  for n=1:size(data,1)
    ind=strfind(data{n,13},' '); 
    if ~isempty(ind)
      data{n,13}=data{n,13}(1:ind-1);
    end 
  end 
end
CMPS=unique(sort(data(:,13)));
NCMP=numel(CMPS); 
% fields
FLDS=unique(sort(data(:,6)));
NFLD=numel(FLDS);
% frequencies
%FRQS=unique(sort(data(:,14)));
FRQS={'fx','monC','yr','yrPt','mon','monPt','day','6hr','6hrPt','3hr','3hrPt','1hr','1hrPt','1hrCM','subhrPt'};
NFRQ=numel(FRQS);
% tables
TBLS=unique(sort(data(:,33)));
NTBL=numel(TBLS);
% experiments
EXPS=unique(sort(data(:,34)));
NEXP=numel(EXPS);
% MIPs (move CMIP first)
MIPS=unique(sort(data(:,35)));
NMIP=numel(MIPS);
MIPS(2:5)=MIPS(1:4);
MIPS{1}='CMIP';
% experiments per MIP 
for mip=1:NMIP 
  ind=find(strcmp(data(:,35),MIPS{mip}));
  if isempty(ind)
    MIPEXPS{mip}=[];
    NMIPEXP(mip)=0;
  else 
    MIPEXPS{mip}=unique(sort(data(ind,34)));
    NMIPEXP(mip)=numel(MIPEXPS{mip});
  end 
end

% create worksheet
worksheet={'Table','Freq.','Realm','CMIP name','NorESM name','NorESM activation','CMOR support',...
           'Description'}; 
coloffset=9;
for mip=1:NMIP
  worksheet{1,coloffset}=MIPS{mip};
  coloffset=coloffset+1;
end 

count=0;

% filter tables
for tbl=1:NTBL
  datatbl=data(find(strcmp(data(:,33),TBLS{tbl})),:); 
  
  % filter frequencies
  for frq=1:NFRQ
    ind=find(strcmp(datatbl(:,14),FRQS{frq}));
    if isempty(ind)  
      continue;
    end 
    datafrq=datatbl(ind,:);
   
    % filter components 
    for cmp=1:NCMP
      ind=find(strcmp(datafrq(:,13),CMPS{cmp}));
      if isempty(ind)  
        continue;
      end 
      datacmp=datafrq(ind,:);
    

      % filter fields
      for fld=1:NFLD 
        ind=find(strcmp(datacmp(:,6),FLDS{fld}));
        if isempty(ind)  
          continue;
        end 
        datafld=datacmp(ind,:);  

        % write to worksheet
        count=count+1;

        % write Table  
        worksheet{count+1,1}=TBLS{tbl};

        % write Frequency
        worksheet{count+1,2}=FRQS{frq};
    
        % write Realm
        worksheet{count+1,3}=datafld{1,13};

        % write CMIP field name 
        worksheet{count+1,4}=FLDS{fld};

        % write Field information (combination of properties) 
        str=datafld{1,2};
        str=[str ' (' datafld{1,3} ')'];  
        if length(datafld{1,4})>0 
          str=[str '. ' datafld{1,4}]; 
        end 
        if length(datafld{1,5})>0 
          str=[str '; comment=' datafld{1,5}];
        end 
        if length(datafld{1,9})>0 
          str=[str '; positive=' datafld{1,9}];
        end 
        str=[str '; dimensions=' datafld{1,11}]; 
        if ~isempty(datafld{1,15})
          str=[str '; cell_methods=' datafld{1,15}]; 
        end
        worksheet{count+1,8}=str;

        % loop over MIPS 
        coloffset=9;
        for mip=1:NMIP 
        
          ind=find(strcmp(datafld(:,35),MIPS{mip})); 
          if isempty(ind) 
             worksheet{count+1,coloffset}='-'; 
          else 
             for n=1:numel(ind) 
               if n>1 
                 str=[str '; '];
               else 
                 str='Y '; 
               end 
               str=[str datafld{ind(n),34} ]; 
               % add priority 
               str=[str ' ' datafld{ind(n),1}]; 
               % prepare years string 
               if length(datafld{ind(n),31})==0
                 str=[str ' ' datafld{ind(n),29}];
               else 
                 a=datafld{ind(n),31};
                 if all(ismember(a(2:5),'0123456789')) & all(ismember(a(end-4:end-1),'0123456789')) 
                   str=[str ' ' a(2:5) '-' a(end-4:end-1)];
                 else
                   str=[str ' ' a];
                 end 
               end
             end 
             worksheet{count+1,coloffset}=str; 
          end 

        % end loop over MIPS 
        coloffset=coloffset+1;
        end  

      % end filter over fields
      end 

    % end filter over components
    end 

  % end filter over frequencies
  end 

% end filter over tables
end

% write text-file
t=array2table(worksheet);
writetable(t,[PREFIX '_v4.txt'],'delimiter','|','WriteVariableNames',false);

