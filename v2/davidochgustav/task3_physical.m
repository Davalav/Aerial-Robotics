%% 1. Bygg banan (före varje körning)
% referens = [t x y z yaw]

bana = 'fyrkant';      % 'fyrkant', 'cirkel' eller 'lutad'

x0   = 0;              % drönarens startposition från Vicon [m]
y0   = 4;
yaw0 = 0;              % drönarens start-yaw från Vicon [rad]

z0   = 1.0;            % flyghöjd [m]
v    = 0.05;           % fart längs banan [m/s]
sida = 1.0;            % fyrkantens sida [m]
r    = 0.5;            % cirkelns radie [m]
dt   = 0.1;

referens = [0 0 0 0 yaw0];
referens(end+1,:) = [3  0 0 0  yaw0];
referens(end+1,:) = [13 0 0 z0 yaw0];
referens(end+1,:) = [18 0 0 z0 0];

switch bana
    case 'fyrkant'
        horn = [0 0; sida 0; sida sida; 0 sida; 0 0];
        t = referens(end,1);
        for k = 1:4
            p1 = horn(k,:);
            p2 = horn(k+1,:);
            yaw = atan2(p2(2) - p1(2), p2(1) - p1(1));
            t = t + 4;
            referens(end+1,:) = [t p1(1) p1(2) z0 yaw];
            t = t + norm(p2 - p1) / v;
            referens(end+1,:) = [t p2(1) p2(2) z0 yaw];
        end

    case 'cirkel'
        cx = r;  cy = 0;
        t0 = referens(end,1);
        T  = 2*pi*r / v;
        for t = dt:dt:T
            s = pi + 2*pi*t/T;
            x = cx + r*cos(s);
            y = cy + r*sin(s);
            yaw = atan2(cy - y, cx - x);
            referens(end+1,:) = [t0+t x y z0 yaw];
        end

    case 'lutad'
        cx = r;  cy = 0;  lut = deg2rad(45);
        t0 = referens(end,1);
        T  = 2*pi*r / v;
        for t = dt:dt:T
            s = pi + 2*pi*t/T;
            x = cx + r*cos(s);
            y = cy + r*sin(s)*cos(lut);
            z = z0 + r*sin(s)*sin(lut);
            referens(end+1,:) = [t0+t x y z 0];
        end
end

s = referens(end,:);
referens(end+1,:) = [s(1)+5  s(2) s(3) s(4) s(5)];
referens(end+1,:) = [s(1)+15 s(2) s(3) 0    s(5)];

referens(:,2) = referens(:,2) + x0;
referens(:,3) = referens(:,3) + y0;
referens(:,5) = unwrap(referens(:,5));

fprintf('Bana "%s": %.0f s lång.\n', bana, referens(end,1))

figure(10); clf
plot3(referens(:,2), referens(:,3), referens(:,4), 'r', 'LineWidth', 1.5)
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
title(['Planerad bana: ' bana])


%% 2. Plotta (efter körningen)
t = logg_xy.Time;
a = logg_xy.Data;      % 1 x_ref 2 y_ref 3 x 4 y 5 yaw 6 vx 7 vy 8 yaw_ref
b = logg_z.Data;       % 1 z_ref 2 z 3 dz 4 T0
a(:,5) = unwrap(a(:,5));

figure(1); clf
subplot(4,1,1); plot(t, a(:,1), 'r--', t, a(:,3), 'b'); grid on; ylabel('x [m]')
legend('Referens', 'Uppmätt'); title(['Task 3 (' bana '): referens mot uppmätt'])
subplot(4,1,2); plot(t, a(:,2), 'r--', t, a(:,4), 'b'); grid on; ylabel('y [m]')
subplot(4,1,3); plot(t, b(:,1), 'r--', t, b(:,2), 'b'); grid on; ylabel('z [m]')
subplot(4,1,4); plot(t, a(:,8), 'r--', t, a(:,5), 'b'); grid on; ylabel('yaw [rad]')
xlabel('Tid [s]')

figure(2); clf
plot(a(:,1), a(:,2), 'r--', 'LineWidth', 1.5); hold on
plot(a(:,3), a(:,4), 'b')
for k = 1:round(numel(t)/25):numel(t)
    quiver(a(k,3), a(k,4), 0.08*cos(a(k,5)), 0.08*sin(a(k,5)), 0, 'k')
end
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]')
legend('Referens', 'Uppmätt', 'Yaw'); title(['Task 3 (' bana '): bana i XY-planet'])

if strcmp(bana, 'lutad')
    figure(3); clf
    plot3(a(:,1), a(:,2), b(:,1), 'r--', 'LineWidth', 1.5); hold on
    plot3(a(:,3), a(:,4), b(:,2), 'b')
    axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
    legend('Referens', 'Uppmätt'); title('Task 3 (lutad): bana i 3D'); view(30, 25)
    exportgraphics(figure(3), ['task3_fysisk_' bana '_3d.png'], 'Resolution', 300)
end

exportgraphics(figure(1), ['task3_fysisk_' bana '_axlar.png'], 'Resolution', 300)
exportgraphics(figure(2), ['task3_fysisk_' bana '_xy.png'], 'Resolution', 300)
save(['task3_fysisk_' bana '_logg.mat'], 'logg_xy', 'logg_z', 'referens')
