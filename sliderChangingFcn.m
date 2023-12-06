function sliderChangingFcn(event, z, h)
        zeta_value = round(event.Value);
        delete(h);
        z(:,:) = zeta_value;
        h = surf(ax, z);
    end

