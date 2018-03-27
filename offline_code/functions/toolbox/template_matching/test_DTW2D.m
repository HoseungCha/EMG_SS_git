function test_DTW2D()

    load('C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\alphabet_a.mat');

    window_width = 3;
    max_slope_length = 2;
    speedup_mode = 1;
    tic
    
    ref = A_dat{1};
    test = A_dat{2};
    %[dist, table, match_pair] = fastDTW( ref, test, max_slope_length, speedup_mode, window_width );
    [dist, table, match_pair] = fastDPW( ref, test, max_slope_length, speedup_mode, window_width );

    toc
    draw_dtwmatching_graph3D(ref, test, match_pair, size(match_pair,1));
    disp(dist);
end
