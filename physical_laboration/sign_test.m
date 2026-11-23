% sign_test.m - testsignal för physical_sign_test.slx, ETT test per körning
% Kolumner: [t pitch roll yaw_rate]  (rad, rad, rad/s)
% Knuffen kommer vid 20 s. Landa ca 10 s efter knuffen.

test = 'pitch';      % 'pitch', 'roll' eller 'yaw'
a = 0.05;            % ca 3 grader

switch test
    case 'pitch'     % förväntat: x ökar, y står still
        testsignal = [0 0 0 0; 20 a 0 0; 20.5 -a 0 0; 21 0 0 0; 300 0 0 0];
    case 'roll'      % förväntat: y minskar, x står still
        testsignal = [0 0 0 0; 20 0 a 0; 20.5 0 -a 0; 21 0 0 0; 300 0 0 0];
    case 'yaw'       % förväntat: yaw ökar ca 0.6 rad, x och y står still
        testsignal = [0 0 0 0; 20 0 0 0.3; 22 0 0 0; 300 0 0 0];
end
