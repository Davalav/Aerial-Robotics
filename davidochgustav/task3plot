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
