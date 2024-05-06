function compareConduction(step1, step2)

str1 = '_axis_Tgroove_a-b_3-6';
str2 = '_axis_Tgroove_b-c_3-8';
str3 = '_axis_Tgroove_c-a_2-8';

cd(step1)

fname = pwd;
listing = dir(fname);

for k = 1:length(listing)
   
    str_complete = listing(k).name;

    find1 = strfind(str_complete,str1);
    find2 = strfind(str_complete,str2);
    find3 = strfind(str_complete,str3);

    if size(find1,1) ~= 0
        step1_Tgroove1 = load(str_complete);
        step1_Tgroove1 = step1_Tgroove1.Groove1;
    elseif size(find2,1) ~= 0
        step1_Tgroove2 = load(str_complete);
        step1_Tgroove2 = step1_Tgroove2.Groove2;
    elseif size(find3,1) ~= 0
        step1_Tgroove3 = load(str_complete);
        step1_Tgroove3 = step1_Tgroove3.Groove3;
    end
end

cd ..
cd(step2)

fname = pwd;
listing = dir(fname);

for k = 1:length(listing)
    
    str_complete = listing(k).name;

    find1 = strfind(str_complete,str1);
    find2 = strfind(str_complete,str2);
    find3 = strfind(str_complete,str3);

    if size(find1,1) ~= 0
        step2_Tgroove1 = load(str_complete);
        step2_Tgroove1 = step2_Tgroove1.Groove1;
    elseif size(find2,1) ~= 0
        step2_Tgroove2 = load(str_complete);
        step2_Tgroove2 = step2_Tgroove2.Groove2;
    elseif size(find3,1) ~= 0
        step2_Tgroove3 = load(str_complete);
        step2_Tgroove3 = step2_Tgroove3.Groove3;
    end
end

cd ..

figure('Position',[300 300 1500 500])

subplot(1,3,1)
x1 = linspace(1,size(step1_Tgroove1,1),size(step1_Tgroove1,1));
plot(x1,step1_Tgroove1)
hold on
plot(x1,step2_Tgroove1)
legend(append('reading ',step1),append('reading ',step2));
title('temperature variation in a-b/3-6 groove')
grid on

subplot(1,3,2)
x2 = linspace(1,size(step1_Tgroove2,1),size(step1_Tgroove2,1));
plot(x2,step1_Tgroove2)
hold on
plot(x2,step2_Tgroove2)
title('temperature variation in b-c/3-8 groove')
legend(append('reading ',step1),append('reading ',step2));
grid on

subplot(1,3,3)
x3 = linspace(1,size(step1_Tgroove3,1),size(step1_Tgroove3,1));
plot(x3,step1_Tgroove3)
hold on
plot(x3,step2_Tgroove3)
title('temperature variation in c-a/2-8 groove')
legend(append('reading ',step1),append('reading ',step2));
grid on

hold off

end