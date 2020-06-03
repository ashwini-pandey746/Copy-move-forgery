
% Please edit path as of your directory accordingly
OutputFolder='C:\\Users\\rites\\Desktop\\ProjectSubmit\\RO';

Files=dir('C:\\Users\\rites\\Desktop\\ProjectSubmit\\RI');
for k=3:length(Files)
    FileNames=Files(k).name;
    IMG = fullfile('C:\\Users\\rites\\Desktop\\ProjectSubmit\\RI',FileNames);
    I=imread(IMG);
    b=rgb2ycbcr(I);
    y=b(:,:,1);
    [a,h,v,d]=swt2(y,3,'db1');
    c=a(:,:,3);
    % Dividing the image into blocks of size 8X8 and storing the matrices in cell C
    [row,col]=size(c);
    C=cell(505*505,1);
    counter=1;
    
    for i=1:row-7
        for j=1:col-7
            C{counter}=a(i:i+7,j:j+7);
            counter=counter+1;
        end
    end
    
    D=cell(505*505,1);
    counter=1;
    
    for i=1:row-7
        for j=1:col-7
            P=C{counter};
            t1=0;t2=0;t3=0;t4=0;
            for k=1:8
                 t1=t1+P(1,k);
                 t2=t2+P(k,1);
                 t3=t3+P(8,k);
                 t4=t4+P(k,8);
            end
            for k=2:7
                t1=t1+P(2,k);
                t2=t2+P(k,2);
                t3=t3+P(7,k);
                t4=t4+P(k,7);
            end
            for k=3:6
                  t1=t1+P(3,k);
                  t2=t2+P(k,3);
                  t3=t3+P(6,k);
                  t4=t4+P(k,6);
            end
            for k=4:5
                 t1=t1+P(4,k);
                 t2=t2+P(k,4);
                 t3=t3+P(5,k);
                 t4=t4+P(k,5);
            end

            t1=t1/20.0;
            t2=t2/20.0;
            t3=t3/20.0;
            t4=t4/20.0;
            Q(1,1)=t1; Q(1,2)=t2;Q(1,3)=t3;Q(1,4)=t4;
            D{counter}=Q;
            counter=counter+1;
        end
    end
    % Storing the values of leftmost corner coordinates for each block
    D_modify=cell(505*505,1);
    counter=1;
    for i=1:row-7
        for j=1:col-7
           P=D{counter};
           if mod(counter,505)==0
              P(1,5)=counter/505;
              P(1,6)=505;
           else
              P(1,5)=floor(counter/505)+1;
              P(1,6)=mod(counter,505);
           end
           D_modify{counter}=P;
           counter=counter+1;
        end
    end


    % Applying lexicographic sorting on the blocks 
    E=cellfun(@num2str,D_modify,'UniformOutput',false);
    F=sortrows(E);
    D_sort=cellfun(@str2num,F,'UniformOutput',false);

    counter=1;
    for i=1:255015
        P=D_sort{i};
        for j=i+1:i+10
            Q=D_sort{j};
            x=P(1,5)-Q(1,5);
            y=P(1,6)-Q(1,6);
            dist=sqrt(x*x+y*y);
            u=P(1,1)-Q(1,1);
            z=P(1,2)-Q(1,2);
            o=P(1,3)-Q(1,3);
            p=P(1,4)-Q(1,4);
            s=sqrt(u*u+z*z+o*o+p*p);
            if  s<0.0015 && dist>40
                R(1,1)=P(1,5);
                R(1,2)=P(1,6);
                R(1,3)=Q(1,5);
                R(1,4)=Q(1,6);
                G{counter}=R;
                counter=counter+1;
            end
        end
    end

    Img=rgb2gray(I);
    for i=1:counter-1
        R=G{i};
        x1=R(1,1);y1=R(1,2);x2=R(1,3);y2=R(1,4);
        for k=0:7
            for l=0:7
                Img(x1+k,y1+l)=255;
                Img(x2+k,y2+l)=255;
            end
        end
    end

    for i=1:512
        for j=1:512
            if Img(i,j)<255
                Img(i,j)=0;
            end
        end
    end
    imwrite(Img,fullfile(OutputFolder,FileNames));
end