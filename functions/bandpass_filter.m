function [out_bpfilt] = bandpass_filter(in,sf,bp_low,bp_high,PLOT)
    
    ts  = 1 / sf;             % Sampling period (s)
    Nyf = 0.5 * sf;           % Nyquist-frequency (Hz)
    bp_low           = 0.01;        % Lower bandpass low frequency (Hz)
    bp_high           = 0.35;        % Upper bandpass low frequency (Hz)
    fOrder        = 4;           % Filter order    
    [b3,a3]       = butter(fOrder,[bp_low/Nyf,bp_high/Nyf],'bandpass');
    out_bpfilt = filtfilt(b3,a3,in);
    if PLOT==1
        plot(in ,'r'); hold on; plot(out_bpfilt ,'r'); legend('in','out bp')
    end
end

