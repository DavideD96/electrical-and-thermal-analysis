function checkGrooves()

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

str1 = 'groove_a-b_3-6';
str2 = 'groove_b-c_3-8';
str3 = 'groove_c-a_2-8';
strCAF = 'CAF_coordinates';

fname = pwd;
listing = dir(fname);

for k = 1:length(listing)
   
    str_complete = listing(k).name;

    find1 = strfind(str_complete,str1);
    find2 = strfind(str_complete,str2);
    find3 = strfind(str_complete,str3);

    if size(find1,1) ~= 0
        Tgroove1 = load(str_complete);
        Tgroove1 = Tgroove1.groove1_coordinates;
    elseif size(find2,1) ~= 0
        Tgroove2 = load(str_complete);
        Tgroove2 = Tgroove2.groove2_coordinates;
    elseif size(find3,1) ~= 0
        Tgroove3 = load(str_complete);
        Tgroove3 = Tgroove3.groove3_coordinates;
    end
end

cd termoFiles_mat\
mh = load('hotMean.mat');
mh = mh.hotMean;
mc = load('coldMean.mat');
mc = mc.coldMean;

m = mh - mc;

figure
imagesc(m)
hold on
plot([Tgroove1(1,1)-0.5,Tgroove1(2,1)+0.5,Tgroove1(3,1)+0.5,Tgroove1(1,1)-0.5,Tgroove1(1,1)-0.5], ...
    [Tgroove1(1,2)-0.5,Tgroove1(2,2)-0.5,Tgroove1(3,2)+0.5,Tgroove1(3,2)+0.5,Tgroove1(1,2)-0.5],'r','linewidth',2)
plot([Tgroove2(1,1)-0.5,Tgroove2(2,1)+0.5,Tgroove2(3,1)+0.5,Tgroove2(1,1)-0.5,Tgroove2(1,1)-0.5], ...
    [Tgroove2(1,2)-0.5,Tgroove2(2,2)-0.5,Tgroove2(3,2)+0.5,Tgroove2(3,2)+0.5,Tgroove2(1,2)-0.5],'r','linewidth',2)
plot([Tgroove3(1,1)-0.5,Tgroove3(2,1)+0.5,Tgroove3(3,1)+0.5,Tgroove3(1,1)-0.5,Tgroove3(1,1)-0.5], ...
    [Tgroove3(1,2)-0.5,Tgroove3(2,2)-0.5,Tgroove3(3,2)+0.5,Tgroove3(3,2)+0.5,Tgroove3(1,2)-0.5],'r','linewidth',2)

hold off

cd ..
end