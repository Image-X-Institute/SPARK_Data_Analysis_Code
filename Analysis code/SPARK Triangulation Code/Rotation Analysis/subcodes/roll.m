function [Rz]=roll(angle)

%**************************************************************************
% INPUT:  3D position and rotations
% OUTPUT: 4x4 Transformation matrix 
% (see Paul RP, 'Robot Manipulators: Mathematics, Programming, and Control',
%  The MIT Press, Cambridge, 1982).
%**************************************************************************
angle = angle*2.0*pi/360;

Rz = [[cos(angle) -sin(angle) 0 0]; [sin(angle) cos(angle) 0 0]; ...
      [0 0 1 0]; [0 0 0 1]];

end