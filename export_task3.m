%% 1. Bygg banan (före varje körning)
bana = 'fyrkant';      % 'fyrkant', 'cirkel' eller 'lutad'

% Startposition från Vicon
x0   = 4;
y0   = 0;
yaw0 = 0;

% Banans storlek och fart
z0   = 1.0;            % flyghöjd [m]
v    = 0.05;           % fart [m/s]
sida = 1.0;            % fyrkantens sida [m]
r    = 0.5;            % cirkelns radie [m]

% Start: stå 3 s, lyft på 10 s, sväva 5 s
%             t   x  y  z   yaw
referens = [  0   0  0  0   yaw0
              3   0  0  0   yaw0
             13   0  0  z0  yaw0
             18   0  0  z0  0    ];
t0 = 18;

switch bana
    case 'fyrkant'
        horn = [0 0; sida 0; sida sida; 0 sida; 0 0];
        yaw  = [0 pi/2 pi 3*pi/2];
        t = t0;
        for k = 1:4
            t = t + 4;          % vrid mot nästa hörn
            referens(end+1,:) = [t horn(k,:)   z0 yaw(k)];
            t = t + sida/v;     % flyg till nästa hörn
            referens(end+1,:) = [t horn(k+1,:) z0 yaw(k)];
        end

    case 'cirkel'
        T = 2*pi*r/v;
        t = (0.1:0.1:T)';
        s = pi + 2*pi*t/T;
        x = r + r*cos(s);
        y = r*sin(s);
        z = z0*ones(size(t));
        yaw = atan2(-y, r - x);           % titta mot mitten
        referens = [referens; t0+t x y z yaw];

    case 'lutad'
        T = 2*pi*r/v;
        t = (0.1:0.1:T)';
        s = pi + 2*pi*t/T;
        x = r + r*cos(s);
        y = r*sin(s)*cos(pi/4);           % lutad 45 grader
        z = z0 + r*sin(s)*sin(pi/4);
        yaw = zeros(size(t));
        referens = [referens; t0+t x y z yaw];
end

% Slut: sväva 5 s, landa på 10 s
sista = referens(end,:);
referens(end+1,:) = [sista(1)+5   sista(2:5)];
referens(end+1,:) = [sista(1)+15  sista(2:3) 0 sista(5)];

% Flytta banan till startpositionen
referens(:,2) = referens(:,2) + x0;
referens(:,3) = referens(:,3) + y0;
referens(:,5) = unwrap(referens(:,5));

fprintf('Bana "%s": %.0f s lång.\n', bana, referens(end,1))

figure(10); clf
plot3(referens(:,2), referens(:,3), referens(:,4), 'r', 'LineWidth', 1.5)
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
title(['Planerad bana: ' bana])


%% 2. Plotta (efter körningen)
t       = logg_xy.Time;
x_ref   = logg_xy.Data(:,1);
y_ref   = logg_xy.Data(:,2);
x       = logg_xy.Data(:,3);
y       = logg_xy.Data(:,4);
yaw     = unwrap(logg_xy.Data(:,5));
yaw_ref = logg_xy.Data(:,8);
z_ref   = logg_z.Data(:,1);
z       = logg_z.Data(:,2);

figure(1); clf
subplot(4,1,1); plot(t, x_ref, 'r--', t, x, 'b'); grid on; ylabel('x [m]')
legend('Referens', 'Uppmätt'); title(['Task 3 (' bana '): referens mot uppmätt'])
subplot(4,1,2); plot(t, y_ref, 'r--', t, y, 'b'); grid on; ylabel('y [m]')
subplot(4,1,3); plot(t, z_ref, 'r--', t, z, 'b'); grid on; ylabel('z [m]')
subplot(4,1,4); plot(t, yaw_ref, 'r--', t, yaw, 'b'); grid on; ylabel('yaw [rad]')
xlabel('Tid [s]')

figure(2); clf
plot(x_ref, y_ref, 'r--', 'LineWidth', 1.5); hold on
plot(x, y, 'b')
k = 1:round(numel(t)/25):numel(t);
quiver(x(k), y(k), 0.08*cos(yaw(k)), 0.08*sin(yaw(k)), 0, 'k')
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]')
legend('Referens', 'Uppmätt', 'Yaw'); title(['Task 3 (' bana '): bana i XY-planet'])

if strcmp(bana, 'lutad')
    figure(3); clf
    plot3(x_ref, y_ref, z_ref, 'r--', 'LineWidth', 1.5); hold on
    plot3(x, y, z, 'b')
    axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
    legend('Referens', 'Uppmätt'); title('Task 3 (lutad): bana i 3D'); view(30, 25)
    exportgraphics(figure(3), ['task3_fysisk_' bana '_3d.png'], 'Resolution', 300)
end

exportgraphics(figure(1), ['task3_fysisk_' bana '_axlar.png'], 'Resolution', 300)
exportgraphics(figure(2), ['task3_fysisk_' bana '_xy.png'], 'Resolution', 300)
save(['task3_fysisk_' bana '_logg.mat'], 'logg_xy', 'logg_z', 'referens')
