function change_threshold(newtrh)

cd parameters 
    ThermalParameters = load("ThermalParameters.mat");
    ThermalParameters = ThermalParameters.ThermalParameters;
    ThermalParameters.soglia_max = newtrh;
    ThermalParameters.soglia_min = -newtrh;
    save("ThermalParameters.mat","ThermalParameters")
cd ..

end