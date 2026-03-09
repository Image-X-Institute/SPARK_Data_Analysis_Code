function [Ry]=pitch(angle)

%**************************************************************************
% INPUT:  Rotation angle in degrees
% OUTPUT: Transformation matrix representing a rotation about the y-axis
%**************************************************************************
angle = angle*2.0*pi/360;

Ry = [[cos(angle) 0 sin(angle) 0];[0 1 0 0]; ...
      [-sin(angle) 0 cos(angle) 0];[0 0 0 1]];

end