% add_logging.m
% Lägger till loggning i den ÖPPNA modellen lab3VM:
%   Mux (8 signaler) -> To Workspace 'logg' (Timeseries)
%   Kolumner: 1 x_ref  2 y_ref  3 z_ref  4 yaw_ref  5 x  6 y  7 z  8 yaw
% Sparar inte - spara själv med Ctrl+S när du har tittat.

mdl = 'lab3VM';
open_system(mdl);

if ~isempty(find_system(mdl, 'SearchDepth', 1, 'Name', 'logg_mux'))
    disp('Loggningen finns redan - inget gjordes.'); return
end

% --- Hitta källorna ---
% Bus Selector3 = den med 13 utgångar (x, y, z, kvaternion, hastigheter)
bs = find_system(mdl, 'SearchDepth', 1, 'BlockType', 'BusSelector');
bsel = '';
for i = 1:numel(bs)
    if numel(get_param(bs{i}, 'PortHandles').Outport) == 13
        bsel = bs{i};
    end
end
if isempty(bsel), error('Hittade inte Bus Selector med 13 utgångar.'); end
bselPH = get_param(bsel, 'PortHandles');
convPH = get_param([mdl '/Conversion'], 'PortHandles');

kallor = { ...
    get_param([mdl '/X_value'],  'PortHandles').Outport(1), ...  % 1 x_ref
    get_param([mdl '/y_value'],  'PortHandles').Outport(1), ...  % 2 y_ref
    get_param([mdl '/z_height'], 'PortHandles').Outport(1), ...  % 3 z_ref
    get_param([mdl '/yaw_ref'],  'PortHandles').Outport(1), ...  % 4 yaw_ref
    bselPH.Outport(1), ...                                       % 5 x
    bselPH.Outport(2), ...                                       % 6 y
    bselPH.Outport(3), ...                                       % 7 z
    convPH.Outport(1)};                                          % 8 yaw

% --- Nya block (längst ner till vänster i modellen) ---
alla = find_system(mdl, 'SearchDepth', 1, 'Type', 'Block');
ymax = 0;
for i = 1:numel(alla)
    p = get_param(alla{i}, 'Position'); ymax = max(ymax, p(4));
end
x0 = 200; y0 = ymax + 80;

mux = add_block('simulink/Signal Routing/Mux', [mdl '/logg_mux'], ...
    'Inputs', '8', 'Position', [x0, y0, x0+5, y0+200]);
tw  = add_block('simulink/Sinks/To Workspace', [mdl '/logg'], ...
    'VariableName', 'logg', 'SaveFormat', 'Timeseries', ...
    'Position', [x0+60, y0+85, x0+140, y0+115]);

muxPH = get_param(mux, 'PortHandles');
for k = 1:8
    add_line(mdl, kallor{k}, muxPH.Inport(k), 'autorouting', 'on');   % gren från befintlig signal
end
add_line(mdl, muxPH.Outport(1), get_param(tw, 'PortHandles').Inport(1), 'autorouting', 'on');

disp('Klart! Mux "logg_mux" -> To Workspace "logg" ligger längst ner i modellen. Spara med Ctrl+S.')
