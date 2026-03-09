function [Tc err] = horn3drot(X,Y)
%FID = fopen('hornmm_testdat.txt');
%C = textscan(FID, '%f %f %f %f %f %f');

 %X = [C{1,1} C{1,2} C{1,3}];
 %Y = [C{1,4} C{1,5} C{1,6}];

    %error(nargchk(2,2,nargin));
    %if size(X,2) ~= 3, error('X must be N x 3'); end;
    %if size(Y,2) ~= 3, error('Y must be N x 3'); end;
    %if size(X,1) ~= size(Y,1), error('X and Y must be the same size'); end;

    numDat = length(X);
    % mean correct
    
    Xm = mean(X,1); X1 = X - ones(size(X,1),1)*Xm;
    Ym = mean(Y,1); Y1 = Y - ones(size(Y,1),1)*Ym;
        
    XX = X1(:,1); XY = X1(:,2); XZ = X1(:,3);
    YX = Y1(:,1); YY = Y1(:,2); YZ = Y1(:,3);
    
    Sxx = sumprod(XX,YX,numDat);
    Sxy = sumprod(XX,YY,numDat);
    Sxz = sumprod(XX,YZ,numDat);
    Syx = sumprod(XY,YX,numDat);
    Syy = sumprod(XY,YY,numDat);
    Syz = sumprod(XY,YZ,numDat);
    Szx = sumprod(XZ,YX,numDat);
    Szy = sumprod(XZ,YY,numDat);
    Szz = sumprod(XZ,YZ,numDat);
    
    M = [[Sxx, Sxy, Sxz];[Syx,Syy,Syz];[Szx,Szy,Szz]];
    N = [[(Sxx+Syy+Szz), (Syz-Szy), (Szx-Sxz), (Sxy-Syx)];
         [(Syz-Szy), (Sxx-Syy-Szz), (Sxy+Syx), (Szx+Sxz)];
         [(Szx-Sxz), (Sxy+Syx), (-Sxx+Syy-Szz), (Syz+Szy)];
         [(Sxy-Syx), (Szx+Sxz), (Syz+Szy), (-Sxx-Syy+Szz)]];
     
    N2 = N;
    [Eig_v, Eig_d] = eigs(N);
    Eig_d1 = diag(Eig_d);
    index = find(Eig_d1 == max(Eig_d1));
    Eig_vec = Eig_v(:,index);
    
    q0 = Eig_vec(1);
    qx = Eig_vec(2);
    qy = Eig_vec(3);
    qz = Eig_vec(4);
    
Trans =[[(q0^2+qx^2-qy^2-qz^2),2*(qx*qy-q0*qz),2*(qx*qz+q0*qy),0];
        [2*(qy*qx+q0*qz),(q0^2-qx^2+qy^2-qz^2),2*(qy*qz-q0*qx),0];
        [2*(qz*qx-q0*qy),2*(qz*qy+q0*qx),(q0^2-qx^2-qy^2+qz^2),0];
        [0,0,0,1]];
    
Pos1 = [Xm 1];
Pos2 = [Ym 1];
d = (Pos1.') - inv(Trans)*(Pos2.');

Tr = [[1 0 0 -d(1)];[0 1 0 -d(2)];[0 0 1 -d(3)];[0 0 0 1]];

Tc = Trans*Tr;
err = (1:numDat);

if 3<2
    %Evaluate transformation for each marker%
    for j=1:numDat 
      p = [X(j,1) X(j,2) X(j,3) 1];
      pred = Tc*(p.');
      dx(j) = abs(pred(1)-Y(j,1));
      dy(j) = abs(pred(2)-Y(j,2));
      dz(j) = abs(pred(3)-Y(j,3));
      disp([num2str(j),' Abs diff. ', num2str(dx(j)), ' ', num2str(dy(j)), ' ', num2str(dz(j))]);
      err(j) = sqrt(dx(j)^2+dy(j)^2+dz(j)^2);
    end
end

%Evaluate transformation for each marker%
pred = zeros(numDat, numDat);
for j=1:numDat 
p = [X(j,1) X(j,2) X(j,3) 1];
temp = (Tc*(p.'))';
pred(j,:) = temp(1:3);
end
dx = sqrt((Y(1)-pred(1))^2+(Y(2)-pred(2))^2+(Y(3)-pred(3))^2);
dy = sqrt((Y(4)-pred(4))^2+(Y(5)-pred(5))^2+(Y(6)-pred(6))^2);
dz = sqrt((Y(7)-pred(7))^2+(Y(8)-pred(8))^2+(Y(9)-pred(9))^2);

err = sqrt(dx^2+dy^2+dz^2);
    
fclose all
end