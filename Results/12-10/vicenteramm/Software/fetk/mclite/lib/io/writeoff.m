function [rc] = writeoff(socktype,dim,VERT,SIMP);
%WRITEOFF  Write simplex mesh in OFF format to file and to then to INET socket
%
% Usage: [rc] = writeoff(socktype,dim,VERT,SIMP);
%
% Output:
%
%    Socket output and an OFF file; filename is hardcoded to be "mcout.off".
%    To view the file with MCsg or Geomview, simply type:   mcsg mcout.off
%                                                     or:   geomview mcout.off
%
% Author:   Michael Holst
% rcsid="$Id: writeoff.m,v 1.1.1.1 2007/04/27 08:28:08 hrg Exp $"

%%% change to external MCSF-style storage

   fid = fopen('mcout.off','W');

   [N,dummy]=size(VERT);
   [L,dummy]=size(SIMP);
   ONEN=ones(N,1);
   ONEL=ones(L,1);
   VERT_F=zeros(N,6);
   assertw( ((dim==2) | (dim==3)), 'meshout 1' );
   if (dim==2)
       SIMP_F=zeros(L,9);
   else
       SIMP_F=zeros(L,11);
   end

   VERT_F(:,1:3) = VERT(:,4:6);
   VERT_F(:,4:6) = VERT(:,1:3);
   VERT_F(:,1)   = VERT_F(:,1) - ONEN;

   if (dim == 2)
       SIMP_F(:,1:3)  = SIMP(:,9:11);
       SIMP_F(:,4:6)  = SIMP(:,5:7);
       SIMP_F(:,7:9)  = SIMP(:,1:3);
       SIMP_F(:,1)    = SIMP_F(:,1) - ONEL;
       SIMP_F(:,7)    = SIMP_F(:,7) - ONEL;
       SIMP_F(:,8)    = SIMP_F(:,8) - ONEL;
       SIMP_F(:,9)    = SIMP_F(:,9) - ONEL;
   else
       SIMP_F(:,1:3)  = SIMP(:,9:11);
       SIMP_F(:,4:7)  = SIMP(:,5:8);
       SIMP_F(:,8:11) = SIMP(:,1:4);
       SIMP_F(:,1)    = SIMP_F(:,1)  - ONEL;
       SIMP_F(:,8)    = SIMP_F(:,8)  - ONEL;
       SIMP_F(:,9)    = SIMP_F(:,9)  - ONEL;
       SIMP_F(:,10)   = SIMP_F(:,10) - ONEL;
       SIMP_F(:,11)   = SIMP_F(:,11) - ONEL;
   end

fprintf(fid,'(geometry MC_geometry { : MC_mesh })\n');
fprintf(fid,'(read geometry {\n');
fprintf(fid,'    appearance { +edge }\n');
fprintf(fid,'    define MC_mesh\n');
fprintf(fid,'\n');
fprintf(fid,'# This file was generated by MC.\n');
fprintf(fid,'OFF\n');
fprintf(fid,'%d %d %d\n', N, L, 0);
for i=1:N
    fprintf(fid,'%10.3e %10.3e %10.3e\n', ...
    VERT_F(i,4), VERT_F(i,5), VERT_F(i,6) );
end
theColor = [ 1.0 0.0 0.0 ];
for i=1:L
    if (dim==2)
        fprintf(fid, ...
            '%d %d %d %d %4.2f %4.2f %4.2f\n', ...
            3, ...
            SIMP_F(i,7), ...
            SIMP_F(i,8), ...
            SIMP_F(i,9), ...
            theColor(1),theColor(2),theColor(3) );
    else
        fprintf(fid,'ACK!!  3D\n');
    end
end
fprintf(fid,'\n})\n');

fclose(fid);

% use "mcbridge" to send the file to UNIX domain socket 1 or INET socket 1
if (socktype == 0)
    !mcbridge -f2u mcout.off 11
else
    !mcbridge -f2i mcout.off 11
end
