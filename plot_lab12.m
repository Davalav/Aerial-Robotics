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

exportgraphics(figure(1), 'lab12_axlar.png', 'Resolution', 300)
exportgraphics(figure(2), 'lab12_xy.png', 'Resolution', 300)