function v = RR_cordic_core(v,n,rot,mode,cordic_tables)
% function v = RR_cordic_core(v,n,rot,mode,cordic_tables)
% Apply n shift/add iterations of the CORDIC algorithm.
% (This Matlab code uses floating point numbers, so it's just for demo purposes.)
% INPUT:  v=[x;y;z]
%         n=number of iterations (with increased precision for larger n; try n<40)
%         rot={1,2,3} (for circular, hyperbolic, or linear rotations, respectively)
%         mode={1,2}  (for rotation or vectoring mode, respectively)
%         cordic_tables=tables of useful values generated by RR_cordic_init
% OUTPUT: v, modified by n shift/add iterations of the CORDIC algorithm,
% with convergence in each of its 2x3=6 forms as follows:
% {rot,mode}={1,1}:  [x;y] -> K1*G*[x;y] with G=[cos(z) -sin(z); sin(z) cos(z)]
%           ={1,2}:  [x;z] -> [K1*sqrt(x^2+y^2); z+atan(y/x)]
%           ={2,1}:  [x;y] -> K2*F*[x;y] with F=[cosh(z) -sinh(z); sinh(z) cosh(z)]
%           ={2,2}:  [x;z] -> [K2*(x^2-y^2); z+atanh(y/x)]
%           ={3,1}:  [x;y] -> [x; y+x*z] 
%           ={3,2}:  [x;z] -> [x; z+y/x]
% Note that z=v(3)->0 for mode=1 ("rotation"), and y=v(2)->0 for mode=2 ("vectoring")
% See RR_cordic.m and RR_cordic_derived.m for how to set up the input v,
% and how to process the output v, to approximate various specific functions.
% Renaissance Robotics codebase, Chapter 1, https://github.com/tbewley/RR
% Copyright 2021 by Thomas Bewley, distributed under BSD 3-Clause License.

switch rot  % Initialize {mu,f,ang} for different types of rotations 
  case 1, mu= 1; f=1;   ang=cordic_tables.ang(1,1); % Circular rotations
  case 2, mu=-1; f=1/2; ang=cordic_tables.ang(2,1); % Hyperbolic rotations
  case 3, mu= 0; f=1;   ang=1;                      % Linear rotations
end        
for j=1:n                                           % perform n iterations
  % Compute sign of next rotation (mode=1 for "rotation", mode=2 for "vectoring")
  if mode==1, sigma=sign(v(3)); else, sigma=-sign(v(2)); end  
  
  %%%% BELOW IS THE HEART OF THE CORDIC ALGORITHM %%%%
  v(1:2)=[1 -mu*sigma*f; sigma*f 1]*v(1:2);   % generalized rotation of v(1:2) by f
  v(3)  =v(3)-sigma*ang;                      % increment v(3)
  
  % update f (divide by 2) [factors {1/2^4, 1/2^13, 1/2^40} repeated in hyperbolic case]
  if mu>-1 || ((j~=4) && (j~=14) && (j~=42)), f=f/2; end
  % update ang from tables, or divide by 2
  if j+1<=cordic_tables.N && rot<3, ang=cordic_tables.ang(rot,j+1); else, ang=ang/2; end
end
% NOTE: the scaling of v by K, if necessary, is done in RR_cordic.m, not in this code.
end