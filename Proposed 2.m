% for t1=0:0.01:0.1
%     for t2=0:10:50
%         solve(t1,t2)
%     end
% end

% Please edit path as of your directory accordingly

solve(0.01,40);

function solve(ft,et)
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
        % Dividing the image into blocks of size 9X9 and storing the matrices in cell C
        [row,col]=size(c);
        C=cell(504*504,1);
        counter=1;

        for i=1:row-8
            for j=1:col-8
                C{counter}=a(i:i+8,j:j+8);
                counter=counter+1;
            end
        end

        D=cell(504*504,1);
        counter=1;

        for i=1:row-8
            for j=1:col-8
                P=C{counter};
                t1=0;
                t2=0;
                t3=0;
                t4=0;
                t5=0;

                for k=1:9
                    t1=t1+P(1,k);
                    t1=t1+P(9,k);
                    t1=t1+P(k,1);
                    t1=t1+P(k,9);
                end

                for k=2:8
                    t2=t2+P(2,k);
                    t2=t2+P(8,k);
                    t2=t2+P(k,2);
                    t2=t2+P(k,8);
                end

                for k=3:7
                    t2=t2+P(3,k);
                    t2=t2+P(7,k);
                    t2=t2+P(k,3);
                    t2=t2+P(k,7);
                end

                for k=4:6
                    t2=t2+P(4,k);
                    t2=t2+P(6,k);
                    t2=t2+P(k,4);
                    t2=t2+P(k,6);
                end

                t5=P(5,5);

                t1=t1/32.0;
                t2=t2/24.0;
                t3=t3/16.0;
                t4=t4/8.0;
                t5=t5/1.0;

                Q(1,1)=t1;
                Q(1,2)=t2;
                Q(1,3)=t3;
                Q(1,4)=t4;
                Q(1,5)=t5;

                D{counter}=Q;
                counter=counter+1;
            end
        end
        % Storing the values of leftmost corner coordinates for each block
        D_modify=cell(504*504,1);
        counter=1;
        for i=1:row-8
            for j=1:col-8
               P=D{counter};
               if mod(counter,504)==0
                  P(1,6)=counter/504;
                  P(1,7)=504;
               else
                  P(1,6)=floor(counter/504)+1;
                  P(1,7)=mod(counter,504);
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
        for i=1:254005
            P=D_sort{i};
            for j=i+1:i+10
                Q=D_sort{j};
                x=P(1,6)-Q(1,6);
                y=P(1,7)-Q(1,7);
                dist=sqrt(x*x+y*y);
                u=abs(P(1,1)-Q(1,1));
                z=abs(P(1,2)-Q(1,2));
                o=abs(P(1,3)-Q(1,3));
                p=abs(P(1,4)-Q(1,4));
                m=abs(P(1,5)-Q(1,5));
                s=u+z+o+p+m;
                if  s<ft && dist>et
                    R(1,1)=P(1,6);
                    R(1,2)=P(1,7);
                    R(1,3)=Q(1,6);
                    R(1,4)=Q(1,7);
                    G{counter}=R;
                    counter=counter+1;
                end
            end
        end

        Img=rgb2gray(I);
        for i=1:counter-1
            R=G{i};
            x1=R(1,1);
            y1=R(1,2);
            x2=R(1,3);
            y2=R(1,4);
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
        line=append(num2str(ft),'_');
        line=append(line,num2str(et));
        line=append(line,'_');
        line=append(line,FileNames)
        imwrite(Img,fullfile(OutputFolder,line));
    end
end
