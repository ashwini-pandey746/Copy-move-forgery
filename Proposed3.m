OutputFolder='C:\Users\ASHWINI\Desktop\7th_sem_project';
 dinfo=dir('*.png');
 for z=1:length(dinfo)
    IMG=dinfo(z).name;
%%
%Read the image, apply slic segmentation and find the centroid of each
%Superpixel
tic
I=imread(IMG);
[L,N] = superpixels(I,100);
C=regionprops(L, 'PixelList');
figure
BW = boundarymask(L);
imshow(imoverlay(I,BW,'cyan'),'InitialMagnification',67)
CENTR=cell(N,1);
for l=1:N
[r c]=size(C(l).PixelList);
%disp(r);
cx=0;cy=0;
for i=1:r
    cx=cx+C(l).PixelList(r,1);
    cy=cy+C(l).PixelList(r,2);
end
cx=floor(cx/r);
cy=floor(cy/r);
f(1,1)=cx;
f(1,2)=cy;
CENTR{l,1}=f;
end

%%
%Obtain the WLD histogram for each Superpixel
D=cell(N,1);
for i=1:N
mask=L==i;
D{i} = bsxfun(@times, I, cast(mask, 'like', I));
end

hist=cell(N,1);
q=cell(N,1);
for i=1:N
    [hist{i},q{i}]=desc_mWLD(D{i});
end


r=cell(N,N);
for i=1:N
    for j=1:N
        if i~=j
            P=hist{i,1};
            Q=hist{j,1};
            sum=0;
           for k=1:32
               sum=sum+abs(P(1,k)-Q(1,k));
           end
           %R=hist{i,1}*hist{j,1}';
           %val=((sum/R)*power(10,8));
           sum=sum/power(10,5);
           S(1,1)=sum;
           S(1,2)=j;
           r{i,j}=S;
    else
        r{i,j}=[0,0];
        end
    end
end
%disp(r{23,52});
%disp(r{23,83});
%%
%Find similarity between WLD histogram of Superpixel
P=cell(N,1);
D_sort=cell(N,1);
for i=1:N
    for j=1:N
        P{j,1}=r{i,j};
    end
    E=cellfun(@num2str,P,'UniformOutput',false);
    F=sortrows(E);
    D_sort{i}=cellfun(@str2num,F,'UniformOutput',false);    
    end
    
c=1;
count=cell(N);
for i=1:N
    P=D_sort{i,1};
    count{i}=0;
    for j=2:3
    R=P{j,1};
       if R(1,1)<0.0155
           count{i}=count{i}+1;
       end 
        end
end
%%
%Obtain hu's moment for each Superpixel
for i=1:512
    for j=1:512
        xgrid1(i,j)=-257+i;
    end
end
for i=1:512
    for j=1:512
        ygrid1(i,j)=-257+j;
    end
end
M=cell(N,1);
for i=1:N
image=rgb2gray(D{i});
image=im2double(image);
[height, width] = size(D{i});
%xgrid = repmat((-floor(height/2):1:ceil(height/2)-1)',1,width);
%ygrid = repmat(-floor(width/2):1:ceil(width/2)-1,height,1);


[x_bar, y_bar] = centerOfMass(image,xgrid1,ygrid1);

% normalize coordinate system by subtracting mean
xnorm = x_bar - xgrid1;
ynorm = y_bar - ygrid1;

% central moments
mu_11 = central_moments( image ,xnorm,ynorm,1,1);
mu_20 = central_moments( image,xnorm,ynorm,2,0);
mu_02 = central_moments( image ,xnorm,ynorm,0,2);
mu_21 = central_moments(image,xnorm,ynorm,2,1);
mu_12 = central_moments( image ,xnorm,ynorm,1,2);
mu_03 = central_moments( image,xnorm,ynorm,0,3);
mu_30 = central_moments( image,xnorm,ynorm,3,0);

%calculate first 8 hu moments of order 3
I_one   = mu_20 + mu_02;
I_two   = (mu_20 - mu_02)^2 + 4*(mu_11)^2;
I_three = (mu_30 - 3*mu_12)^2 + (mu_03 - 3*mu_21)^2;
I_four  = (mu_30 + mu_12)^2 + (mu_03 + mu_21)^2;
I_five  = (mu_30 - 3*mu_12)*(mu_30 + mu_12)*((mu_30 + mu_12)^2 - 3*(mu_21 + mu_03)^2) + (3*mu_21 - mu_03)*(mu_21 + mu_03)*(3*(mu_30 + mu_12)^2 - (mu_03 + mu_21)^2);
I_six   = (mu_20 - mu_02)*((mu_30 + mu_12)^2 - (mu_21 + mu_03)^2) + 4*mu_11*(mu_30 + mu_12)*(mu_21 + mu_03);
I_seven = (3*mu_21 - mu_03)*(mu_30 + mu_12)*((mu_30 + mu_12)^2 - 3*(mu_21 + mu_03)^2) + (mu_30 - 3*mu_12)*(mu_21 + mu_03)*(3*(mu_30 + mu_12)^2 - (mu_03 + mu_21)^2);
I_eight = mu_11*(mu_30 + mu_12)^2 - (mu_03 + mu_21)^2 - (mu_20 - mu_02)*(mu_30 + mu_12)*(mu_21 + mu_03);

%hu_moments_vector = [I_one, I_two, I_three,I_four,I_five,I_six,I_seven,I_eight];
hu_moments_vector = [I_one, I_two, I_three,I_four,I_five,I_six,I_seven,I_eight];
hu_moments_vector_norm= -sign(hu_moments_vector).*(log10(abs(hu_moments_vector)));
hu_moments_vector_norm = abs(hu_moments_vector_norm)*100;
hu_moments_vector_norm= round(hu_moments_vector_norm);


%Now place all the produced Hu's invariant moments in a new matrix where moments for each block are placed as a row in the matrix.
P=hu_moments_vector_norm;
P(1,9)=i;
M{i}=P;
end
%%
%Group Superpixels on the basis of similarity of their hu moments and
%euclidean distance
res=zeros(1,100);
counter=1;
for i=1:N
    l=0;
    P=D_sort{i,1};
    O=M{i};
    count1{i}=0;
    if count{i}==0
        continue;
    else
        for j=1:count{i}
            R=P{j+1,1};
            a=R(1,2);
            Q=M{i};
            W=M{a};
            ans=0;
            for k=1:8
                ans=ans+abs(Q(1,k)-W(1,k));
            end
            if ans<=650
                Z=CENTR{i,1};
X=CENTR{a,1};
%V=CENTR{83,1};
m=Z(1,1)-X(1,1);
n=Z(1,2)-X(1,2);
h=sqrt(m*m+n*n);
                if h<=200
                count1{i}=count1{i}+1;
            O(1,10+l)=a;
            res(1,counter)=a;
            counter=counter+1;
            l=l+1;
                end
            end
        end
    end
    M{i}=O;
end
%%
L1=zeros(512);
res=unique(res);
[row c]=size(res);
img=rgb2gray(I);
for i=1:c
    j=res(1,i);
    if j~=0
    for k=1:512
        for l=1:512
            if L(k,l)==j
                img(k,l)=255;
                
            end
        end
    end
    end
end
for k=1:512
    for l=1:512
        if img(k,l)~=255
            img(k,l)=0;
        end
    end
end
imshow(img);
%%
I2=imread('041_B.png');
tp=0;tn=0;fp=0;fn=0;
for i=1:512
    for j=1:512
        if I2(i,j)==255 && img(i,j)==255
            tp=tp+1;
        else if I2(i,j)==255 && img(i,j)==0
                fn=fn+1;
        else if I2(i,j)==0 && img(i,j)==255
                fp=fp+1;
        else if I2(i,j)==0 && img(i,j)==0
                tn=tn+1;
        end
        end
        end
        end
    end
end
accu=(tp+tn)/(tp+tn+fp+fn);
precision=(tp)/(tp+fp);
recall=(tp)/(tp+fn);
f=2*((precision*recall)/(precision+recall));
disp(accu);
disp(precision);
disp(recall);
disp(f);
toc
 imwrite(img,fullfile(OutputFolder,IMG));
end

%%
