function [tree_4hz_HP,tree_4hz] = resample_4Hz_and_butterworth_filter(tree_in,fs_tree)


    if istable(tree_in); tree_in=table2array(tree_in); end    
    colx=size(tree_in,2)-1;
    coly=size(tree_in,2);
    
    tree_corrected_HP = replace_nan_with_col_mean(tree_in);
    tree_4hz=resample(tree_corrected_HP,4,fs_tree);
    tree_4hz=tree_4hz-mean(tree_4hz,'omitnan'); 
    tree_corrected=cat(2,tree_4hz,hypot(tree_4hz(:,colx),tree_4hz(:,coly)));

    fs_tree=4; % overwrite this
    lower_frequency_threshold=0.0017; % this is ten minutes
    [b2,a2]       = butter(4,lower_frequency_threshold / 2,'high');
    tree_4hz_HP= filtfilt(b2,a2,tree_4hz); % High Pass Filter
end

