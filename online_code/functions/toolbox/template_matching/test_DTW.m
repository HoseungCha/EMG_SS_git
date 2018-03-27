function test_DTW()
    a = [0	0.198669331	0.389418342	0.564642473	0.717356091	0.841470985	0.932039086	0.98544973	0.999573603	0.973847631	0.909297427	0.808496404	0.675463181	0.515501372	0.33498815	0.141120008	-0.058374143	-0.255541102	-0.442520443	-0.611857891	-0.756802495	-0.871575772	-0.951602074	-0.993691004	-0.996164609	-0.958924275	-0.883454656]';
    b = [0	0.13934129	0.280866882	0.422009942	0.559765796	0.690689246	0.810911446	0.916183017	1.001951173	1.063479659	1.096020977	1.095050447	1.056570699	0.977492637	0.856094008	0.692548531	0.489505932	0.252685137	-0.008581776	-0.280948826	-0.546930075	-0.785219968	-0.971667114	-1.081125445	-1.09038265	-0.982267771	-0.750824533]';

    window_width = 3;
    max_slope_length = 2;
    speedup_mode = 1;
    tic
    [dist, table, match_pair] = fastDTW( a, b, max_slope_length, speedup_mode, window_width );
%    [dist, table, match_pair] = fastDTW( a, b, max_slope_length, speedup_mode, window_width );
%     [dist, table,slope] = dtw( a, b, 0,max_slope_length, 0 );
%     [match_pair, nPair] = dtw_backtracking(table, slope,[]);
    toc
    draw_dtwmatching_graph(a, b, match_pair, size(match_pair,1));
    disp(dist);
end