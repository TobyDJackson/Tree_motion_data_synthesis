function h1 = plot_pxx_gwv(in,SamplingFrequency,color_in,LineStyle,offset)

DownSample=round(length(in)./(3*4*60*60))
subplot(1,2,1)
[pxx, f, fitresult, x, y,h1] = power_spectrum_plot(in,SamplingFrequency,DownSample,0.999,color_in,LineStyle,offset,1); hold on
subplot(1,2,2)
[coeffs1,wfreq,coi1] = global_wavelet_plot(in,SamplingFrequency,color_in,LineStyle,offset,1); hold on
end

