%% TASK 3 - trajektorier (fysiska labbens tre banor)
% Kör en sektion i taget: klicka i sektionen och tryck Ctrl+Enter.
%   Sektion 1: bygg banan          (före varje körning)
%   Sektion 2: plotta              (efter körningen, när Simulink är stoppad)
% Modellen görs om en gång med andra_task3_modell.m
%
% referens = [t  x  y  z  yaw]   en rad per tidpunkt, Simulink interpolerar mellan raderna

bana = 'fyrkant';      % 'fyrkant', 'cirkel' eller 'lutad'

z0   = 0.5;            % flyghöjd [m]  (VM: 0.5, fysiska labben: t.ex. 1.0)
v    = 0.05;           % fart längs banan [m/s]  (långsamt = följer bättre)
sida = 1.0;            % fyrkantens sida [m]
r    = 0.5;            % cirkelns radie [m]  (diameter 1 m)
dt   = 0.1;            % tidssteg för cirkelpunkterna [s]

if strcmp(bana, 'lutad')
    z0 = max(z0, 0.8); % den lutade cirkeln går 0.35 m upp och ned -> flyg högre
end

% --- Start: stå på marken, lyft mjukt till z0, sväva ---
referens = [0 0 0 0 0];
referens(end+1,:) = [3  0 0 0  0];      % stå still 3 s
referens(end+1,:) = [13 0 0 z0 0];      % lyft till z0 på 10 s (mjukt = ingen översläng)
referens(end+1,:) = [18 0 0 z0 0];      % sväva 5 s

switch bana
    case 'fyrkant'
        % Hörnen, tillbaka till start. Vid varje hörn: vrid mot nästa hörn, flyg sedan dit.
        horn = [0 0; sida 0; sida sida; 0 sida; 0 0];
        t = referens(end,1);
        for k = 1:4
            p1 = horn(k,:);
            p2 = horn(k+1,:);
            yaw = atan2(p2(2) - p1(2), p2(1) - p1(1));   % riktning mot nästa hörn

            t = t + 4;                                   % vrid på stället i 4 s
            referens(end+1,:) = [t p1(1) p1(2) z0 yaw];

            t = t + norm(p2 - p1) / v;                   % flyg till nästa hörn
            referens(end+1,:) = [t p2(1) p2(2) z0 yaw];
        end

    case 'cirkel'
        % Mitten i (r, 0) så att cirkeln börjar i (0, 0). Titta mot mitten.
        cx = r;  cy = 0;
        t0 = referens(end,1);
        T  = 2*pi*r / v;                                 % tid för ett varv
        for t = dt:dt:T
            s = pi + 2*pi*t/T;                           % vinkel på cirkeln
            x = cx + r*cos(s);
            y = cy + r*sin(s);
            yaw = atan2(cy - y, cx - x);                 % riktning mot mitten
            referens(end+1,:) = [t0+t x y z0 yaw];
        end

    case 'lutad'
        % Samma cirkel, lutad 45 grader runt x-axeln. Fast riktning (yaw = 0).
        cx = r;  cy = 0;  lut = deg2rad(45);
        t0 = referens(end,1);
        T  = 2*pi*r / v;
        for t = dt:dt:T
            s = pi + 2*pi*t/T;
            x = cx + r*cos(s);
            y = cy + r*sin(s)*cos(lut);
            z = z0 + r*sin(s)*sin(lut);
            yaw = 0;
            referens(end+1,:) = [t0+t x y z yaw];
        end
end

% --- Slut: sväva 5 s, landa mjukt på 10 s ---
s = referens(end,:);
referens(end+1,:) = [s(1)+5  s(2) s(3) s(4) s(5)];
referens(end+1,:) = [s(1)+15 s(2) s(3) 0    s(5)];

% Yaw får inte hoppa mellan -pi och pi (då vrider sig drönaren åt fel håll)
referens(:,5) = unwrap(referens(:,5));

fprintf('Bana "%s": %.0f s lång. Starta Simulink och låt den köra tills drönaren har landat.\n', ...
    bana, referens(end,1))

figure(10); clf
plot3(referens(:,2), referens(:,3), referens(:,4), 'r', 'LineWidth', 1.5)
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
title(['Planerad bana: ' bana])


%% 2. Plotta (efter körningen)
t = logg.Time;
d = logg.Data;            % 1 x_ref 2 y_ref 3 z_ref 4 yaw_ref 5 x 6 y 7 z 8 yaw

figure(1); clf
subplot(4,1,1); plot(t, d(:,1), 'r--', t, d(:,5), 'b'); grid on; ylabel('x [m]')
legend('Referens', 'Uppmätt'); title(['Task 3 (' bana '): referens mot uppmätt'])
subplot(4,1,2); plot(t, d(:,2), 'r--', t, d(:,6), 'b'); grid on; ylabel('y [m]')
subplot(4,1,3); plot(t, d(:,3), 'r--', t, d(:,7), 'b'); grid on; ylabel('z [m]')
subplot(4,1,4); plot(t, d(:,4), 'r--', t, d(:,8), 'b'); grid on; ylabel('yaw [rad]')
xlabel('Tid [s]')

figure(2); clf
plot(d(:,1), d(:,2), 'r--', 'LineWidth', 1.5); hold on
plot(d(:,5), d(:,6), 'b')
L = 0.08;                                    % heading-pilar (valfritt i labben)
for k = 1:round(numel(t)/25):numel(t)
    quiver(d(k,5), d(k,6), L*cos(d(k,8)), L*sin(d(k,8)), 0, 'k')
end
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]')
legend('Referens', 'Uppmätt', 'Heading'); title(['Task 3 (' bana '): bana i XY-planet'])

if strcmp(bana, 'lutad')
    figure(3); clf
    plot3(d(:,1), d(:,2), d(:,3), 'r--', 'LineWidth', 1.5); hold on
    plot3(d(:,5), d(:,6), d(:,7), 'b')
    axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
    legend('Referens', 'Uppmätt'); title('Task 3 (lutad): bana i 3D'); view(30, 25)
    exportgraphics(figure(3), ['task3_' bana '_3d.png'], 'Resolution', 300)
end

exportgraphics(figure(1), ['task3_' bana '_axlar.png'], 'Resolution', 300)
exportgraphics(figure(2), ['task3_' bana '_xy.png'], 'Resolution', 300)
save(['task3_' bana '_logg.mat'], 'logg', 'referens')
