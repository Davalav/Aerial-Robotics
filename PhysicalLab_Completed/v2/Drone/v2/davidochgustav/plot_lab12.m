t = logg_xy.Time;
a = logg_xy.Data;
b = logg_z.Data;

figure(1); clf
subplot(4,1,1); plot(t, a(:,1), 'r--', t, a(:,3), 'b'); grid on; ylabel('x [m]')
legend('Referens', 'Uppmätt'); title('Referens mot uppmätt')
subplot(4,1,2); plot(t, a(:,2), 'r--', t, a(:,4), 'b'); grid on; ylabel('y [m]')
subplot(4,1,3); plot(t, b(:,1), 'r--', t, b(:,2), 'b'); grid on; ylabel('z [m]')
subplot(4,1,4); plot(t, a(:,8), 'r--', t, a(:,5), 'b'); grid on; ylabel('yaw [rad]')
xlabel('Tid [s]')

figure(2); clf
plot(a(:,3), a(:,4), 'b'); hold on
plot(a(end,1), a(end,2), 'rx', 'MarkerSize', 12, 'LineWidth', 2)
axis equal; grid on
xlabel('x [m]'); ylabel('y [m]')
legend('Uppmätt bana', 'Mål'); title('Bana i XY-planet')

load('lutad.mat')      % ger t, a och b

figure(3); clf
plot3(a(:,1), a(:,2), b(:,1), 'r--', 'LineWidth', 1.5); hold on
plot3(a(:,3), a(:,4), b(:,2), 'b')
axis equal; grid on
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]')
legend('Referens', 'Uppmätt'); title('Lutad cirkel i 3D')
view(30, 25)

exportgraphics(figure(3), 'lutad_3d.png', 'Resolution', 300)

exportgraphics(figure(1), 'lab12_axlar.png', 'Resolution', 300)
exportgraphics(figure(2), 'lab12_xy.png', 'Resolution', 300)