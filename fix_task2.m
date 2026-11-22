% fix_task2.m
% Rättar Task 2-delen i den ÖPPNA modellen lab3VM. Sparar inte - du sparar själv (Ctrl+S) när du har tittat.
%  1. Rätt uttryck till rätt ingång: roll-uttrycket -> roll, pitch-uttrycket -> pitch
%  2. Yaw: Mux till 8 ingångar, Constant yaw_ref (0) på ingång 8, yaw-uttrycket använder u(8) och u(5)
%  3. Saturation: roll/pitch +-0.3 rad, yaw_rate +-1 rad/s (läggs till om den saknas)
%  4. X_value = 0, y_value = 0 (drönaren ska stanna över startpunkten)

mdl = 'lab3VM';
open_system(mdl);
pub   = [mdl '/Command Velocity Publisher1'];
pubPH = get_param(pub, 'PortHandles');      % Inport(1)=roll, (2)=pitch, (3)=yaw_rate

namn  = {'roll', 'pitch', 'yaw_rate'};
uttryck = { ...
    '-3*( 1*( -sin(u(5))*(u(1)-u(3)) + cos(u(5))*(u(2)-u(4)) ) - u(7) )', ...  % roll
    '3*( 1*( cos(u(5))*(u(1)-u(3)) + sin(u(5))*(u(2)-u(4)) ) - u(6) )', ...    % pitch
    '1*atan2(sin(u(8)-u(5)), cos(u(8)-u(5)))'};                               % yaw_rate
grans = [0.3, 0.3, 1];                       % saturation +-grans

for k = 1:3
    % --- Gå bakåt från publisherns ingång: (Saturation ->) Fcn ---
    b = kallBlock(pubPH.Inport(k));
    if isempty(b)
        error('Ingången %s på publishern är inte kopplad.', namn{k});
    end
    if strcmp(get_param(b, 'BlockType'), 'Saturate')
        sat = b;
        fcn = kallBlock(get_param(sat, 'PortHandles').Inport(1));
    else
        sat = [];
        fcn = b;
    end
    if isempty(fcn) || ~strcmp(get_param(fcn, 'BlockType'), 'Fcn')
        error('Hittade inget Fcn-block bakom ingången %s.', namn{k});
    end

    % --- 1. Rätt uttryck ---
    set_param(fcn, 'Expression', uttryck{k});

    % --- 3. Saturation ---
    if isempty(sat)
        delete_line(get_param(pubPH.Inport(k), 'Line'));
        fpos = get_param(fcn, 'Position');
        sat = add_block('simulink/Discontinuities/Saturation', [mdl '/Sat_' namn{k}], ...
            'MakeNameUnique', 'on', ...
            'Position', [fpos(3)+40, fpos(2), fpos(3)+80, fpos(4)]);
        add_line(mdl, get_param(fcn, 'PortHandles').Outport(1), ...
                      get_param(sat, 'PortHandles').Inport(1), 'autorouting', 'on');
        add_line(mdl, get_param(sat, 'PortHandles').Outport(1), ...
                      pubPH.Inport(k), 'autorouting', 'on');
        fprintf('La till Saturation före %s\n', namn{k});
    end
    set_param(sat, 'UpperLimit', num2str(grans(k)), 'LowerLimit', num2str(-grans(k)));

    % --- 2. Yaw: Mux till 8 ingångar + yaw_ref ---
    if k == 3
        mux = kallBlock(get_param(fcn, 'PortHandles').Inport(1));
        if isempty(mux) || ~strcmp(get_param(mux, 'BlockType'), 'Mux')
            error('Yaw-Fcn får inte sin signal från en Mux.');
        end
        if str2double(get_param(mux, 'Inputs')) < 8
            set_param(mux, 'Inputs', '8');
        end
        muxPH = get_param(mux, 'PortHandles');
        if get_param(muxPH.Inport(8), 'Line') == -1
            mpos = get_param(mux, 'Position');
            yr = add_block('simulink/Sources/Constant', [mdl '/yaw_ref'], ...
                'MakeNameUnique', 'on', 'Value', '0', ...
                'Position', [mpos(1)-140, mpos(4)+20, mpos(1)-100, mpos(4)+50]);
            add_line(mdl, get_param(yr, 'PortHandles').Outport(1), muxPH.Inport(8), ...
                'autorouting', 'on');
            fprintf('La till Constant yaw_ref = 0 på Mux-ingång 8\n');
        end
    end
    fprintf('%-9s <- %s   (saturation +-%g)\n', namn{k}, uttryck{k}, grans(k));
end

% --- 4. Målpunkt i origo ---
try, set_param([mdl '/X_value'], 'Value', '0'); end
try, set_param([mdl '/y_value'], 'Value', '0'); end

disp('Klart! Titta på modellen och spara med Ctrl+S.')

% ===== hjälpfunktion =====
function b = kallBlock(portHandle)
    % Returnerar blocket som skickar signal till en ingångsport (tomt om okopplad)
    l = get_param(portHandle, 'Line');
    if l == -1
        b = [];
    else
        b = get_param(l, 'SrcBlockHandle');
        if b == -1, b = []; end
    end
end
