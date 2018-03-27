function number_examples_for_dummy_mode(num_char)
% NUMBER_EXAMPLES_FOR_DUMMY_MODE
% Generates an examplar eye-dispositions for recognition
% Only works in the dummy mode
% Input Argument
% num_char      : number that you want to generate examplar signal for
%                 e.g. '0', '1', '2', ... '9'

global params;
global buffer;

ExtendFactor = 1/params.DelayTime;
calib_space = linspace(0, 0, ExtendFactor * params.CalibrationTime);
calib_space_y = linspace(params.default_fixation_y, params.default_fixation_y, ExtendFactor * params.CalibrationTime);
packed_space = linspace(0, 0, ExtendFactor * params.DataAcquisitionTime - 6 * ExtendFactor);

if double('0') <= double(num_char) && double('9') >= double(num_char)

if strcmp(num_char, '0')
    X_train = [-10 -10 -10 10 10 10];
    Y_train = [10 0 -10 -10 0 10];
elseif strcmp(num_char, '1') 
    X_train = [10 10 10 10 10 10];
    Y_train = [10 0 -10 -10 0 10];
elseif strcmp(num_char, '2') 
    X_train = [-10 10 -10 10 10 10];
    Y_train = [10 10 -10 -10 -10 -10];
elseif strcmp(num_char, '3') 
    X_train = [-10 10 -10 0 10 -10];
    Y_train = [10 10 0 0 -10 -10];
elseif strcmp(num_char, '4') 
    X_train = [-10 -10 10 10 10 10];
    Y_train = [10 0 0 -10 -10 -10];
elseif strcmp(num_char, '5')
    X_train = [10 -10 -10 10 10 -10];
    Y_train = [10 0 0 0 0 -10];
elseif strcmp(num_char, '6') 
    X_train = [-10 -10 -10 -10 10 -10];
    Y_train = [10 0 -10 -10 -10 0];
elseif strcmp(num_char, '7') 
    X_train = [-10 10 10 10 10 10];
    Y_train = [10 10 0 -10 -10 -10];
elseif strcmp(num_char, '8') 
    X_train = [-10 10 -10 10 10 10];
    Y_train = [10 -10 -10 10 10 10];
elseif strcmp(num_char, '9') 
    X_train = [10 10 -10 10 10 10];
    Y_train = [0 0 10 10 0 -10];
end

    DelayTime = params.DelayTime;
    idx_start = ExtendFactor/2 + 1;
    n_number = 6 * ExtendFactor;
    
    X_train = interp1(1:8, [0 X_train 0], 1:DelayTime:8, 'linear');
    Y_train = interp1(1:8, [0 Y_train 0], 1:DelayTime:8, 'linear');
    
    X_train = X_train(idx_start:idx_start+n_number-1);
    Y_train = Y_train(idx_start:idx_start+n_number-1);
    
    buffer.X_train = [calib_space X_train packed_space]';
    buffer.Y_train = [calib_space_y Y_train packed_space]';
% disp(['Stimulus Example for Dummy Mode : ', num_char]);
end

end

