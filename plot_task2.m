t = logg.Time;
d = logg.Data;

figure(1); clf
subplot(4,1,1); plot(t, d(:,1), 'r--', t, d(:,5), 'b'); grid on; ylabel('x [m]')
legend('Referens', 'Uppmätt'); title('Task 2: referens mot uppmätt')
subplot(4,1,2); plot(t, d(:,2), 'r--', t, d(:,6), 'b'); grid on; ylabel('y [m]')
subplot(4,1,3); plot(t, d(:,3), 'r--', t, d(:,7), 'b'); grid on; ylabel('z [m]')
subplot(4,1,4); plot(t, d(:,4), 'r--', t, d(:,8), 'b'); grid on; ylabel('yaw [rad]')
xlabel('Tid [s]')

figure(2); clf
plot(d(:,5), d(:,6), 'b'); hold on
plot(d(end,1), d(end,2), 'rx', 'MarkerSize', 12, 'LineWidth', 2)
axis equal; grid on
xlabel('x [m]'); ylabel('y [m]')
legend('Uppmätt bana', 'Mål'); title('Task 2: bana i XY-planet')

exportgraphics(figure(1), 'task2_axlar.png', 'Resolution', 300)
exportgraphics(figure(2), 'task2_xy.png', 'Resolution', 300)