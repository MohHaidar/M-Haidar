function [ SAB11,SAB12,SAB21,SAB22 ] = StarProduct2( SA11,SA12,SA21,SA22,SB11,SB12,SB21,SB22)




I=eye(2);
SAB11=SA11+(SA12*(inv(I-(SB11*SA22)))*SB11*SA21);
SAB12=SA12*(inv(I-(SB11*SA22)))*SB12;
SAB21=SB21*(inv(I-(SA22*SB11)))*SA21;
SAB22=SB22+(SB21*(inv(I-(SA22*SB11)))*SA22*SB12);

end
