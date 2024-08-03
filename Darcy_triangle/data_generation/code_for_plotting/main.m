clear;
close all

ubc; % Running the ubc.m file to generate the boundary conditions

load bc;
global bc_cond
num = 2000;

notch_left = 0.49;
notch_right = 0.51;
    %--PDE solver----------------------------------------------
    bc_cond = f_bc(1, :);
    model = createpde;
    
    R1 = [3, 4, 0, 1, 0.5+1e-12, 0.5-1e-12, 0, 0, sqrt(3)/2, sqrt(3)/2]';
    R2 = [3, 4, notch_left, notch_right, notch_right, notch_left, 0, 0, 0.4, 0.4]';
    gm = [R1,R2];
    sf = 'R1-R2';
    ns = char('R1','R2');
    ns = ns';
    g = decsg(gm,sf,ns);
    
    geometryFromEdges(model,g);
    %     pdegplot(model,'EdgeLabels','on')
    
    applyBoundaryCondition(model,'dirichlet','Edge',1:3, 'u', @bcvalues, 'Vectorized', 'on');
    applyBoundaryCondition(model,'dirichlet','Edge',4, 'u', 0);
    applyBoundaryCondition(model,'dirichlet','Edge',5, 'u', 0);
    applyBoundaryCondition(model,'dirichlet','Edge',6, 'u', 0);
    applyBoundaryCondition(model,'dirichlet','Edge',7:8, 'u', @bcvalues, 'Vectorized', 'on');
    
    specifyCoefficients(model,'m',0,...
        'd',0,...
        'c',1,...
        'a',0,...
        'f',10);
    
    %%
   figure('Position',[100 100 1000 400])
   hmax = 0.028;
    hmin = 0.026;
    generateMesh(model,'Hmax',hmax,'Hmin',hmin);
    subplot(1,2,1); 
    pdemesh(model);
    xlabel('x'); ylabel('y')
    ylim([0,0.88]); xlim([0,1])
    title('(a) Fine grid', FontWeight='normal', FontName='serif')
    
    hmax = 0.18;
    hmin = 0.16;
    generateMesh(model,'Hmax',hmax,'Hmin',hmin);
    subplot(1,2,2); 
    pdemesh(model);
    xlabel('x'); ylabel('y')
    ylim([0,0.88]); xlim([0,1])
    title('(b) Coarse grid', FontWeight='normal', FontName='serif')
    