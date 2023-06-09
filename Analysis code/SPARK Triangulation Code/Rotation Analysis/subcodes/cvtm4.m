function t = cvtm4(m)
% angles, pitch, yaw and roll and X, Y and Z translations.
% Inputs: m	Contains the transformation matrix to be converted
% Outputs: A 6 element floating point vector containing P, Y and R and XYZ.
% Roger Fulton November 1997.

sy = -m(3,1);
cy = 1-(sy.*sy);

if cy > 1e-4 
    cy = sqrt(cy);
    cx = m(3,3)/cy;
    sx = m(3,2)/cy;
    cz = m(1,1)/cy;
    sz = m(2,1)/cy;
else
    cy = 0.0;
    cx = m(2,2);
    sx = -m(2,3);
    cz = 1.0;
    sz = 0.0;
end

r2deg = 360.0/(2*pi);

t = [atan2(sy,cy)*r2deg;atan2(sx,cx)*r2deg;atan2(sz,cz)*r2deg;m(1,4);m(2,4);m(3,4)];
%t = t.'
fclose all
end
