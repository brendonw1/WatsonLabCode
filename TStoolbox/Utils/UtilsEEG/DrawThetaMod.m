function DrawThetaMod(A,dset,cell,figDir)


A = getResource(A,'ProbaTheta',dset);
A = getResource(A,'HcChannels',dset);
%  A = getResource(A,'CellNames',dset);
%  cell = find(ismember(cellnames,cell));
%  if ~length(cell) | length(cell)>1
%  	error('Bad cell names');
%  end

sig = sum(probaTheta<0.05);
[dummy,ix] = max(sig);

A = getResource(A,'HcThetaPhase',dset);
phase = hcThetaPhase{hcChannels(ix)};
phase = Data(phase{cell});

[prefPh, modTheta probaTheta] = CircularMean(phase);
dB = 2*pi/50;
B = [dB/2:dB:2*pi-dB/2];
C = hist(phase,B);
t=prefPh;t = mod(t+pi,2*pi)-pi;
vm = von_mises_pdf(B-pi,t+pi,modTheta);
modT = num2str(modTheta,3);	
probaT = num2str(probaTheta,3);

fh1 = figure(1),clf
hold on
h=bar(B,100*C/sum(C))
plot(B,100*dB*vm,'lineWidth',2,'Color','r');
ylabel('Percentage os spikes');
xlabel('Phase (rad)');
xlim([0 2*pi])
set(h,'EdgeColor','k')
set(h,'FaceColor','b')
set(h,'BarWidth',1)
%  title([ds ', ' cellnames{j} ', concentration factor : ' modT ', p = ' probaT]);

%  keyboard

[dummy, dataset, dummy] = fileparts(dset);

set(1,'PaperPositionMode','auto')
name = [figDir dataset '_' num2str(cell)];
print('-f1','-zbuffer','-dtiff',[name '.tif']);





