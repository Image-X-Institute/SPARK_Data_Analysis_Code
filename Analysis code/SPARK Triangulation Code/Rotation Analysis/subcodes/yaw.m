function [Rx]=yaw(angle)

%**************************************************************************
% INPUT:  Rotation angle in degrees
% OUTPUT: Transformation matrix representing a rotation about the x-axis
%**************************************************************************
angle = angle*2.0*pi/360;

Rx = [[1 0 0 0]; [0 cos(angle) -sin(angle) 0]; ...
      [0 sin(angle) cos(angle) 0]; [0 0 0 1]];

end