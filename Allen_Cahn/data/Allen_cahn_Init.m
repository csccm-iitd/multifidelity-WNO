clear
close all
clc

T = 20;                                 % Time period,
N =500;                               % Totam time steps, Delta t = T/N,
a = [3 3];                             % Boundary points, [x,y],
k = 6;                                   % Resolution factor k in, 2^k,
J = [2^k 2^k];                    % Resolution,
epsilon = 0.001;               % Diffusion coefficient,
x = (0:a(1)/J(1):a(1))';      % x-grid,
y = (0:a(2)/J(2):a(2))';      % y-grid,

tic
sample = 10000;                         % Number of Training samples,
initial = zeros(numel(x), numel(y), sample);
for i =1:sample
    if mod(i, 10) == 0
        disp(i)
    end
    u0= RandField_Matern(0.1, 0.1, 5, 0.1, 0, k, 1);

    initial(:,:,i) = u0;
end
toc

%%
figure(1); 
imagesc(initial(:,:,10)); 
colormap(jet); title('Initial')

save('initac2d.mat', 'x', 'initial', '-v7.3')
