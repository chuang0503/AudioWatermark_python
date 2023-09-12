%Author: Shijun Xiang, Ph.D in Sun yat-sen University, current with Korea
%University. Email: xiangshijun@gmail.com
%This code is shared for research purpose.
%More details, the reader can refer to the paper presented at IH 2006 or
%Published in LNCS 4431, pages 93-108. 

disp('Detection');
% load file   
wmed_signal = wavread('wmed_signal')';  

% Read watermark
fid = fopen('Wo.dat','r');
w = fscanf(fid,'%d\n');
fclose(fid);

nWL = length(w);
nBins= 3*(nWL+1)+1;
dDelta=2.2;%control the amplitude range
dSearch= 0.06;
%the search step size in practice. The ideal one is 1/dDelta, referred to
%the paper
dStep =1; 
nBegin = 1;   
nEnd = nBins;  

dBERs=1;

%*************Resolution***********************
bits = 16;
NA = 2^(bits-1);    
A= wmed_signal*NA;
nLength = length(A);

% the markded mean
dMeanW = mean(abs(A));

%sort
[B K]= sort(A);% A(K(i))= B(i)


% ****Searching****
sTimes=2*dSearch*dMeanW/dStep;%search times 
for t= 1:sTimes
    
    if mod(t,2)==0
        tMean=dMeanW - (t/2)*dStep;
    else
        tMean=dMeanW+ (t-1)/2*dStep;
    end
    
    %*************Selecting of Embedding Region***************
    dRange = ceil(dDelta*tMean);
    nInterval= floor(2*dRange/nBins);
    
    if nInterval < 1
        dBERs=3;
        break;
    end
    
    %The minimum sample
    nS1 = 1;
    for i=1:nLength
        if round(B(i))>=-dRange
            nS1 = i;
            break;
        end
    end
    %The maximum sample
    nS2 = nLength;
    for i=nLength:-1:1
        if  round(B(i))<=dRange
            nS2 = i;
            break;
        end
    end
    
    %Extract
    B1 = B(nS1:nS2);
    nLength1=length(B1);
    
    A1=B1+dRange+1;%Shift for the histogram extraction
    
    nNum2 = zeros(nBins+10,1);
    for i=1:nLength1
        nNum2(ceil(A1(i)/nInterval)) = nNum2(ceil(A1(i)/nInterval)) + 1;
    end
    
    %%*********Watermark recovery***************%
    for j = 1:nWL
        if mod(j,2) == 1
            nIndex = nBegin+3*((j+1)/2-1);
        else
            nIndex = nEnd-3*(j/2)+1;
        end
        a = nNum2(nIndex);
        b = nNum2(nIndex+1);
        c = nNum2(nIndex+2);
        if b==0
            w1(j) = 1;
        else 
            dRela(j)=(a + c)/(2*b);
            if dRela(j) >= 1     
                w1(j) = 1;
            else       
                w1(j) = 0;     
            end
        end
    end
    
    %%*********BER***************%
    dBer =0;
    for j=1:nWL
        if w1(j) ~= w(j);
            dBer =dBer + 1;
        end
    end
    dBer =dBer/nWL;
    
    %Save the better BER always
    if dBERs> dBer
        dBERs = dBer;
        
        xMean=tMean;
        nNumX=nNum2;
        dRelaGood= dRela;
        nW=w1;
    end
    
    %The search is over once the BER value is zero
    if dBERs==0
        break ;
    end
end
fprintf('BER = %.2f%\n',dBERs);
fprintf('\n');