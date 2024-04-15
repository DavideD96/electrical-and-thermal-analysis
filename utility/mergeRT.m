termopath = 'D:\09_04_24_termoT\esportazione\E26_4Elst_C1_2mm_3-8_IMP_f113_-144';
respath = 'D:\09_04_24_termoR\2024Apr09\113';

check = exist(termopath,"dir")

if check ~= 0

riuscito = copyfile(respath,termopath);

cd(termopath)
plotRS_Keithley2606B('Data.txt',0)
cd ..

end