%Author: Shijun Xiang, Ph.D in Sun yat-sen University, current with Korea
%University. Email: xiangshijun@gmail.com
%This code is shared for research purpose.
%More details, the reader can refer to the paper presented at IH 2006 or
%Published in LNCS 4431, pages 93-108. 

disp('Embedding');
% 40bits
w = [0,0,1,1,1,0,1,0,1,1,0,1,0,0,0,1,1,1,0,0,1,1,0,1,0,0,0,1,1,1,1,0,1,1,0,1,1,1,1,1];

% w = randint(1, 40);
fid = fopen('Wo.dat','w');
fprintf(fid,'%d\n',w);
fclose(fid);

nWL = length(w);
nBins=3*(nWL+1)+1;%The number of bins
dDelta=2.2; %control the embedding region 
T = 1.5;     %Embedding strength


%The first and last BIN
nBegin = 1;  
nEnd = nBins;    

%*********Read audio clip****************
[FileName,PathName] = uigetfile('*.wav','Select the host signal');
[yo,Fs,bits] = wavread(fullfile(PathName,FileName));

%*************16-bit signed audio***********************
NA = 2^(bits-1);    
yo = (yo)*NA;
nLength = length(yo);

%the modified mean value
dMean = mean(abs(yo));

%*************Calculate the embedding region***********************
dRange=ceil(dDelta*dMean);
% the bin width
nInterval= floor(2*dRange/nBins);

%****************Extract the embedding range********************

A=yo;
%sort
[B K]= sort(A);% A(K(i))= B(i) 
%Negative sample with maximum magnitude
nS1 = 1;
for i=1:nLength
    if B(i)>= -dRange
        nS1 = i;
        break;
    end
end
%Positive sample with maximum magnitude
nS2 = nLength;
for i=nLength:-1:1
    if  B(i)<= dRange
        nS2 = i;
        break;
    end
end

%Extract    
B1 = B(nS1:nS2); 
LL=length(B1);
A1= zeros(LL,1);
K1= zeros(LL,1);
j=1;
for i=1:nLength
    if (A(i)>=-dRange) & (A(i)<= dRange)
        A1(j)=A(i);
        K1(j)=i;
        j=j+1;
    end
end

%*************Compute the number of samples in the BINS*******************
A1 = A1+dRange+1; %Make all samples not less than 1 
nNum = zeros(nBins+10,1);  %init the array of bin
  
nLength1=LL;
for i=1:nLength1
    nNum(ceil(A1(i)/nInterval)) = nNum(ceil(A1(i)/nInterval)) + 1;
end

%*********Cumulation Histogram****************
nNumTotal = nNum;
for i = 2:1:nBins   
    nNumTotal(i) = nNumTotal(i)+nNumTotal(i-1);
end

%Make the samples in the bins in order
yTran = zeros(1,nLength1);   
nShift = zeros(1,nBins+10);   
for i = 1:nLength1  
    nTemp = ceil(A1(i)/nInterval);
    nShift(nTemp) = nShift(nTemp)+1;
    
    if nTemp~=1
        yTran(nNumTotal(nTemp-1)+nShift(nTemp)) = A1(i);
    else
        yTran(nShift(nTemp)) = A1(i);
    end
end

%***************Watermark Insertion****************************
for j = 1:nWL
    Mnum1 = 0;
    Mnum2 = 0;
    Mindex = [];
    Mindex1 = [];
    Mindex2 = [];
    if mod(j,2) == 1
        nIndex = nBegin+3*((j+1)/2-1);
    else
        nIndex = nEnd-3*(j/2)+1;
    end
     
    a = nNum(nIndex);
    b = nNum(nIndex+1);
    c = nNum(nIndex+2);

    dR(j) = (a+c)/(2*b);

    if w(j) == 1        %Embedding the bit '1'
        if (a + c)/(2*b) < T      %The samples in BIN1 and BIN3 are insufficient
            AA = ceil((2*T*b - a - c)/(1+2*T));
            for i = 1:1:ceil(AA*a/(a+c))
                yTran(nNumTotal(nIndex)+i) = yTran(nNumTotal(nIndex)+i) - (nInterval);    %Modify part of samples in BIN2 to BIN1
            end
            for i = 1:1:ceil(AA*c/(a+c))
                yTran(nNumTotal(nIndex+1)-i) = yTran(nNumTotal(nIndex+1)-i) + (nInterval);  %Modify part of samples in BIN2 to BIN3
            end
        end
    else                   %Embedding the bit '-1'
        if (a + c)/(2*b) > 1/T    %The samples in BIN2 are insufficient
            AA = ceil(((a + c)*T - 2*b)/(2+T));
            for i = 1:1:ceil(AA*a/(a+c))
                yTran(nNumTotal(nIndex)-i) = yTran(nNumTotal(nIndex)-i) + (nInterval);   %Modify part of samples in BIN1 to BIN2
            end
            for i = 1:1:ceil(AA*c/(a+c))
                yTran(nNumTotal(nIndex+1)+i) = yTran(nNumTotal(nIndex+1)+i) - (nInterval);  % %Modify part of samples in BIN3 to BIN2
            end
        end     
    end
end

%******************Recover the order of samples***********************
nShift = zeros(1,nBins+10);    
AW1 = A1;
for i = 1:nLength1  
    nTemp = ceil(A1(i)/nInterval);
    nShift(nTemp) = nShift(nTemp)+1;
    if nTemp~=1
        AW1(i)= yTran(nNumTotal(nTemp-1)+nShift(nTemp));
    else
        AW1(i)= yTran(nShift(nTemp));
    end
end

AW1 = AW1-dRange-1; %Recover the shift

A(K1)=AW1;

%**************Save the marked file*******************
yw = A/NA;
wavwrite(yw,Fs,bits,'wmed_signal.wav');