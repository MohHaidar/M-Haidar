function y=rdct(x,n,a,b)
0002 %RDCT     Discrete cosine transform of real data Y=(X,N,A,B)
0003 % Data is truncated/padded to length N.
0004 %
0005 % This routine is equivalent to multiplying by the matrix
0006 %
0007 %   rdct(eye(n)) = diag([sqrt(2)*B/A repmat(2/A,1,n-1)]) * cos((0:n-1)'*(0.5:n)*pi/n)
0008 %
0009 % Default values of the scaling factors are A=sqrt(2N) and B=1 which
0010 % results in an orthogonal matrix. Other common values are A=1 or N and/or B=1 or sqrt(2).
0011 % If b~=1 then the columns are no longer orthogonal.
0012 %
0013 % see IRDCT for the inverse transform
0014 
0015 % BUG: in line 51 we should do chopping after transform and not before
0016 
0017 
0018 
0019 %      Copyright (C) Mike Brookes 1998
0020 %      Version: $Id: rdct.m 713 2011-10-16 14:45:43Z dmb $
0021 %
0022 %   VOICEBOX is a MATLAB toolbox for speech processing.
0023 %   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
0024 %
0025 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
0026 %   This program is free software; you can redistribute it and/or modify
0027 %   it under the terms of the GNU General Public License as published by
0028 %   the Free Software Foundation; either version 2 of the License, or
0029 %   (at your option) any later version.
0030 %
0031 %   This program is distributed in the hope that it will be useful,
0032 %   but WITHOUT ANY WARRANTY; without even the implied warranty of
0033 %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
0034 %   GNU General Public License for more details.
0035 %
0036 %   You can obtain a copy of the GNU General Public License from
0037 %   http://www.gnu.org/copyleft/gpl.html or by writing to
0038 %   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
0039 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
0040 
0041 fl=size(x,1)==1;
0042 if fl x=x(:); end
0043 [m,k]=size(x);
0044 if nargin<2 n=m;
0045 end
0046 if nargin<4 b=1;  
0047     if nargin<3 a=sqrt(2*n);
0048     end
0049     end
0050 if n>m x=[x; zeros(n-m,k)];
0051 elseif n<m x(n+1:m,:)=[];
0052 end
0053 
0054 x=[x(1:2:n,:); x(2*fix(n/2):-2:2,:)];
0055 z=[sqrt(2) 2*exp((-0.5i*pi/n)*(1:n-1))].';
0056 y=real(fft(x).*z(:,ones(1,k)))/a;
0057 y(1,:)=y(1,:)*b;
0058 if fl y=y.'; end