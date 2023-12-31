function analyzed = findSwitch_rel (matr,col, matsigma,ns,normalize)

%Date: 2019-02-18 Last Modification: 2019-03-19
%Author: M. Camponovo, D. Decastri
%
%   analyzed = findSwitch(matr,col,matSigma,ns,normalize)
%
%The program anlyzed the column 'col' of matrix 'matr' and collects switch
%events performing an anlysis on the variance of the data
%
%   matr: matrix with column data
%   col: an integer; index of column to be analyzed
%   matsigma: matrix with the value of the quantity and the correspondant
%             sigma on the coluns; the data have to be ordered form the 
%             greater to smaller one
%   ns: an integer; the number of sigma to consider the difference between
%       two adiaccent quantities a switch
%   normalize: if is true the program normalize the times (in the first 
%              column of matr with respect to the time of the first data.
%


s = size(matr,1);
z = zeros(s,1);

if normalize == true %MODIFICATO
    matr(:,1) = matr(:,1) - matr(1,1);
end

analyzed = [matr z z];

figure;
plot(matr(:,1),matr(:,col));
hold on;

       delta = diff(matr(:,col));
       rel = (delta./matr(1:end-1,col));
       
    for i=1:s - 1 %ho aggiunto il "-1"
        [mv,sv] = sigmaSelector(matr(i,col),matsigma);
        
        if abs(rel(i)) > ns*sv/mv %o sei nel bel mezzo di un evento, o alla fine
            if analyzed(i-1,end) ~= 0 %possono essere successe due cose: eventi distinti (spike), o no.
                if rel(i)*rel(i-1) > 0 %stesso evento
                    analyzed(i,end) = -1; %sei nel bel mezzo di un evento
                else
                    analyzed(i,end) = 1;
                    plot(matr(i,1), matr(i,col), 'or'); 
                end
            else %sei all'inizio di un nuovo evento
                plot(matr(i,1), matr(i,col), 'or');               
                analyzed(i,end) = 1;
            end
        else 
            if i > 1
                if analyzed(i-1,end) ~= 0
                    plot(matr(i,1), matr(i,col), 'or');   
                end
            end
        end
    end

%elimino transienti
analyzed(analyzed(:,end) == -1,:) = 0;   

hold off;            
end