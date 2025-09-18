function accel_Plot()
% plot acceleration time history and response spectra

% load recorded nodal data
acc = load('acceleration.out');
time = acc(:,1);
% remove time column from data
acc(:,1) = [];

% data descriptors
[nStep, nAcc] = size(acc);
nDOF  = 2;
nNode = nAcc/nDOF;

% reshape data 
a = reshape(acc, nStep, nDOF, nNode)/9.81;

% plot horizontal input acceleration time history
figure(1)
    plot(time, a(:,1,1), '-b','linewidth',1.5)
	grid on
	box on
	xlabel('Time (sec)','fontsize',16)
	ylabel('acceleration (g)','fontsize',16)
    title('Input Acceleration','fontsize',16)
    set(gca,'fontsize',14)
print -depsc2 inputAccel.eps

% plot horizontal acceleration time history at ground surface
figure(2)
    plot(time, a(:,1,nNode), '-b','linewidth',1.5)
	grid on
	box on
	xlabel('Time (sec)','fontsize',16)
	ylabel('Acceleration (g)','fontsize',16)
    title('Surface Acceleration','fontsize',16)
    set(gca,'fontsize',14)
print -depsc2 surfaceAccel.eps


% build response spectra
[p, umax, vmax, amax] = respSpectra(a(:,1,nNode), time(end), nStep);

% response spectra on log-linear plot
figure(3)
    subplot(3,1,1)
        semilogx(p, amax, 'b','linewidth',1.5)
        grid on 
		box on
		ylabel('S_a  (g)','fontsize',16)
		set(gca,'XtickLabel',[],'fontsize',16)
	subplot(3,1,2)
        semilogx(p, vmax,'b', 'linewidth',1.5)
		grid on 
		box on
		ylabel('S_v  (m/s)','fontsize',16)
        set(gca,'XtickLabel',[],'fontsize',16)
    subplot(3,1,3)
        semilogx(p, umax, 'b','linewidth',1.5)
		grid on 
		box on
		ylabel('S_d  (m)','fontsize',16)
		xlabel('Period, T (sec)','fontsize',16)
        set(gca,'fontsize',16)
	suptitle('Log Spectra')
print -depsc2 logSpectra.eps

return
