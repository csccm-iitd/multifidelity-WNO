clear;
close all

ubc; % Running the ubc.m file to generate the boundary conditions

load bc;
global bc_cond
num = 2000;

notch_left = 0.49;
notch_right = 0.51;
for i=1:num
    disp(i)
    %--PDE solver----------------------------------------------
    tic;
    bc_cond = f_bc(i, :);
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
    
    hmax = 0.03;
    generateMesh(model,'Hmax',hmax);
    %     figure
    %     pdemesh(model);
    
    results = solvepde(model);
    X = results.Mesh.Nodes;
    X = X';
    xx = X(:, 1);
    yy = X(:, 2);
    
    u = results.NodalSolution;
    u_field(i, :) = u';
    toc
    
end


%%
for i=1:num
    disp(i)
    tic;
    %--PDE solver----------------------------------------------
    bc_cond = f_bc(i, :);
    lmodel = createpde;
    
    R1 = [3, 4, 0, 1, 0.5+1e-12, 0.5-1e-12, 0, 0, sqrt(3)/2, sqrt(3)/2]';
    R2 = [3, 4, notch_left, notch_right, notch_right, notch_left, 0, 0, 0.4, 0.4]';
    gm = [R1,R2];
    sf = 'R1-R2';
    ns = char('R1','R2');
    ns = ns';
    g = decsg(gm,sf,ns);
    
    geometryFromEdges(lmodel,g);
    %     pdegplot(lmodel,'EdgeLabels','on')
    
    applyBoundaryCondition(lmodel,'dirichlet','Edge',1:3, 'u', @bcvalues, 'Vectorized', 'on');
    applyBoundaryCondition(lmodel,'dirichlet','Edge',4, 'u', 0);
    applyBoundaryCondition(lmodel,'dirichlet','Edge',5, 'u', 0);
    applyBoundaryCondition(lmodel,'dirichlet','Edge',6, 'u', 0);
    applyBoundaryCondition(lmodel,'dirichlet','Edge',7:8, 'u', @bcvalues, 'Vectorized', 'on');
    
    specifyCoefficients(lmodel,'m',0,...
        'd',0,...
        'c',1,...
        'a',0,...
        'f',10);
    
    hmax = 0.1;
    hmin = 0.08;
    generateMesh(lmodel,'Hmax',hmax,'Hmin',hmin);
         %figure
         %pdemesh(lmodel);
    
    lresults = solvepde(lmodel);
    lX = lresults.Mesh.Nodes;
    lX = lX';
    lxx = lX(:, 1);
    lyy = lX(:, 2);
    
    lu = lresults.NodalSolution;
    lu_field(i, :) = lu';
    toc
    
end

[xq,yq] = meshgrid(0:.01:1, 0:.01:1);
N = length(xq);
sol = zeros(num,N,N);
boundCoeff = zeros(num,N,N);
coord_x = zeros(num,N,N);
coord_y = zeros(num,N,N);

for i = 1:num
    v = u_field(i, :)';
    func_data = scatteredInterpolant(xx,yy,v,'linear','nearest');
    vq = func_data(xq,yq);
    sol(i,:,:) = vq;
    bound = f_bc(i,:)';
    boundCoeff(i,:,:) = repmat(bound,[1,101])';
    coord_x(i,:,:) = xq;
    coord_y(i,:,:) = yq;
end

for i = 1:num
    lv = lu_field(i, :)';
    lfunc_data = scatteredInterpolant(lxx,lyy,lv,'linear','nearest');
    lvq = lfunc_data(xq,yq);
    lressol(i,:,:) = lvq;
end
immse(lressol,sol)
save('Darcy_Triangular_FNO_multifid_hmax01_hmin008','boundCoeff', 'coord_x', 'coord_y', 'sol','lressol');

