function [T6]=make_t6(Tx,Ty,Tz,Ry,Rx,Rz)

%**************************************************************************
% INPUT:  3D position and rotations
% OUTPUT: 4x4 Transformation matrix 
% (see Paul RP, 'Robot Manipulators: Mathematics, Programming, and Control',
%  The MIT Press, Cambridge, 1982).
%**************************************************************************

tp = pitch(Ry);
ty = yaw(Rx);
tr = roll(Rz);
orientation = tr*tp*ty;
position=[[1 0 0 Tx]; [0 1 0 Ty]; [0 0 1 Tz]; [0 0 0 1]];
T6 = position*orientation;

end