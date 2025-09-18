function profile_pp_Plot()

% load recorded nodal data
acc = load('acceleration.out');
disp = load('displacement.out');
strain = load('strain.out');
stress = load('stress.out');
porepressure = load('porePressure.out');
nodes = load('nodesInfo.dat');
time = disp(:,1);

% remove time column from data
disp(:,1) = [];
acc(:,1) = [];
strain(:,1) = [];
stress(:,1) = [];
porepressure(:,1) = [];

% data descriptors
[nStep, nDisp] = size(disp);
nDOF  = 2;
nNode = nDisp/nDOF;
nstraincomp=3;
nstresscomp=5;
[nstep, temp] = size(strain);
 nElem = temp / nstraincomp;

%obtain elevation
elevation=nodes(2:2:end,3);
depth=flipud(elevation);
sizeElem=elevation(end)/nElem;
elevation_el=elevation(1:end-1)+sizeElem/2;
depth_el=flipud(elevation_el);
% reshape data 
d = reshape(disp, nStep, nDOF, nNode);
a = reshape(acc, nStep, nDOF, nNode);
st = reshape(strain, nStep, nstraincomp, nElem);
stress_r = reshape(stress, nStep, nstresscomp, nElem);

% build response spectra
[p, umax, vmax, amax] = respSpectra(a(:,1,nNode), time(end), nStep);

%compute max relative displacement
    for i=1:nNode
      d_rel(:,i)=d(:,1,i)- d(:,1,1);
      d_max(i)=max(abs(max(d_rel(:,i))), abs(min(d_rel(:,i))));
      a_max(:,i)=max(abs(a(:,1,i)))/9.81;
    end

    for i=1:nElem
        strain_max(i)=max(abs(max(st(:,3,i))), abs(min(st(:,3,i))));
        max_ratio(:,i)=max(max(abs(stress_r(:,4,i)))./max(abs(stress_r(:,2,i))));
    end

% plot displacement profile

figure(4)
    % plot max horizontal displacement versus depth
    subplot(1,4,1)
    plot(d_max(1:2:end), depth, '-b','linewidth',1.5)
	grid on
	box on
	xlabel('Max displacement (m)','fontsize',16)
	ylabel('Depth (m)','fontsize',16)
    set(gca,'Ydir','reverse')
    set(gca,'fontsize',14)
    % plot PGA versus depth
    subplot(1,4,2)
    plot(a_max(1:2:end), depth, '-b','linewidth',1.5)
	grid on
	box on
	xlabel('PGA (g)','fontsize',16)
    set(gca,'Ydir','reverse')
    set(gca,'fontsize',14)

    subplot(1,4,3)
    % plot maximum shear strain versus depth
    plot(strain_max*100, depth_el, '-b','linewidth',1.5)
	grid on
	box on
	xlabel('strain (%)','fontsize',16)
    set(gca,'Ydir','reverse')
    set(gca,'fontsize',14)

    subplot(1,4,4)
    % plot max tau/sigma versus depth
    plot(max_ratio, depth_el, '-b','linewidth',1.5)
	grid on
	box on
	xlabel('(\tau/\sigma_v_0)_m_a_x','fontsize',16)
    set(gca,'Ydir','reverse')
    set(gca,'fontsize',14)
    print -depsc2 Profiles.eps

% plot max tau vs sigma at center of liquefable layer
Liq_el=find(strain_max == max(strain_max(:)));%find elevation of max tau/sigma
ele_val_Liq=depth_el(Liq_el);

figure(5)
    plot(st(:,3,Liq_el)*100,stress_r(:,4,Liq_el), '-b','linewidth',1.5)
	grid on
	box on
	xlabel('\gamma (%)','fontsize',16)
	ylabel('\tau (kPa)','fontsize',16)
    tit=sprintf('Stress-strain response at %.2f m',ele_val_Liq);
    title(tit,'fontsize',16)
    set(gca,'fontsize',14)
    print -depsc2 stress_strain_liq_depth.eps

% ru=abs(stress_r(:,4,Liq_el)./max(abs(stress_r(:,2,Liq_el))));
% 
% figure(6)
%     plot(time,ru, '-b','linewidth',1.5)
% 	grid on
% 	box on
% 	xlabel('time (sec)','fontsize',16)
% 	ylabel('\tau/\sigma_v_0','fontsize',16)
%     tit2=sprintf('\\tau/ \\sigma_v_0 time variation at %.2f m',ele_val_Liq);
%     title(tit2,'fontsize',16)
%     set(gca,'fontsize',14)
%     print -depsc2 Ratio_time_liq_depth.eps
 
%plot excess pore water pressure    
    for i=1:length(time)
    	uexcess(:,i) = porepressure(i,:) - porepressure(1,:);
    end

figure(6)
    plot(time,uexcess(Liq_el,:), '-b','linewidth',1.5)
	grid on
	box on
	xlabel('time (sec)','fontsize',16)
	ylabel('u_e_x (kPa)','fontsize',16)
    tit3=sprintf('Pore Pressure variation at %.2f m',ele_val_Liq);
    title(tit3,'fontsize',16)
    set(gca,'fontsize',14)
    print -depsc2 PorePressure.eps
    
return
