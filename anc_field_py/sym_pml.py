# -*- coding: utf-8 -*-
"""
Copyright 2014 Attila Szarvas

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

from sympy import *

p = var('p')
pm1 = var('pm1')
pm2 = var('pm2')
ksi_x = var('ksi_x')
ksi_y = var('ksi_y')
ksi_z = var('ksi_z')
dx = var('dx')
dt = var('dt')
c = var('c')
pm1_xp1 = var('pm1_xp1')
pm1_xm1 = var('pm1_xm1')
pm1_yp1 = var('pm1_yp1')
pm1_ym1 = var('pm1_ym1')
pm1_zp1 = var('pm1_zp1')
pm1_zm1 = var('pm1_zm1')
fi_m1_xph = var('fi_m1_xph')
fi_m1_xmh = var('fi_m1_xmh')
fi_m1_yph = var('fi_m1_yph')
fi_m1_ymh = var('fi_m1_ymh')
fi_m1_zph = var('fi_m1_zph')
fi_m1_zmh = var('fi_m1_zmh')
psiph = var('psiph')
psimh = var('psimh')

p_update = Eq(
	(p - 2*pm1 + pm2) / (dt*dt) + (ksi_x + ksi_y + ksi_z)*(p-pm2)/(2* dt) \
	+(ksi_x*ksi_y + ksi_y*ksi_z + ksi_z*ksi_x)*pm1, \
	(c*c*pm1_xp1 - (c*c + c*c)*pm1 + c*c*pm1_xm1)/(dx*dx) \
	+ (c*c*pm1_yp1 - (c*c + c*c)*pm1 + c*c*pm1_ym1)/(dx*dx) \
	+ (c*c*pm1_zp1 - (c*c + c*c)*pm1 + c*c*pm1_zm1)/(dx*dx) \
	+ (fi_m1_xph - fi_m1_xmh)/dx \
	+ (fi_m1_yph - fi_m1_ymh)/dx + (fi_m1_zph - fi_m1_zmh)/dx - ksi_x*ksi_y*ksi_z \
	*(psiph + psimh)/2)

print solve(p_update, p)

'''
(-12*c*c*dt*dt*pm1[ix_pm1(x,y,z)] + 2*c*c*dt*dt*pm1[ix_pm1(x-1,y,z)] + 2*c*c*dt*dt*pm1[ix_pm1(x+1,y,z)]
+ 2*c*c*dt*dt*pm1[ix_pm1(x,y-1,z)] + 2*c*c*dt*dt*pm1[ix_pm1(x,y+1,z)] + 2*c*c*dt*dt*pm1[ix_pm1(x,y,z-1)]
+ 2*c*c*dt*dt*pm1[ix_pm1(x,y,z+1)] - dt*dt*dx*dx*ksi_x[x]*ksi_y[y]*ksi_z[z]*psimh[ix_psimh(x,y,z)]
- dt*dt*dx*dx*ksi_x[x]*ksi_y[y]*ksi_z[z]*psiph[ix_psiph(x,y,z)] - 2*dt*dt*dx*dx*ksi_x[x]*ksi_y[y]*pm1[ix_pm1(x,y,z)]
- 2*dt*dt*dx*dx*ksi_x[x]*ksi_z[z]*pm1[ix_pm1(x,y,z)] - 2*dt*dt*dx*dx*ksi_y[y]*ksi_z[z]*pm1[ix_pm1(x,y,z)]

+ 2*dt*dt*dx*(

- fi_x_avg(fi_xm1,x,y,z)
+ fi_x_avg(fi_xm1,x+1,y,z)
- fi_y_avg(fi_xm1,x,y,z)
+ fi_y_avg(fi_xm1,x,y+1,z)
- fi_z_avg(fi_xm1,x,y,z)
+ fi_z_avg(fi_xm1,x,y,z+1)

)

+ dt*dx*dx*ksi_x[x]*pm2[ix_pm2(x,y,z)] + dt*dx*dx*ksi_y[y]*pm2[ix_pm2(x,y,z)] + dt*dx*dx*ksi_z[z]*pm2[ix_pm2(x,y,z)]
+ 4*dx*dx*pm1[ix_pm1(x,y,z)] - 2*dx*dx*pm2[ix_pm2(x,y,z)])/(dx*dx*(dt*ksi_x[x] + dt*ksi_y[y] + dt*ksi_z[z] + 2));
'''

#p_update2 = Eq(
#	(p - 2*pm1 + pm2) / (dt*dt) + (ksi_x + ksi_y + ksi_z)*(p-pm2)/(2* dt) \
#	+(ksi_x*ksi_y + ksi_y*ksi_z + ksi_z*ksi_x)*pm1, \
#	c*c/(dx*dx)*(pm1_xp1 + c*c*pm1_xm1 + pm1_yp1 + pm1_ym1 + pm1_zp1 + pm1_zm1 - 6*pm1) \
#	+ (fi_m1_xph - fi_m1_xmh)/dx \
#	+ (fi_m1_yph - fi_m1_ymh)/dx + (fi_m1_zph - fi_m1_zmh)/dx - ksi_x*ksi_y*ksi_z \
#	*(psiph + psimh)/2)
#
#print solve(p_update2, p)
