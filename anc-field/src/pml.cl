/*
 * Copyright 2014 Attila Szarvas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef		CLH_SIZES
#define		size_p_0			128
#define		size_p_1			128
#define		size_p_2			128
#define		size_pm1_0			128
#define		size_pm1_1			128
#define		size_pm1_2			128
#define		size_pm2_0			128
#define		size_pm2_1			128
#define		size_pm2_2			128
#define		size_fi_x_0			128
#define		size_fi_x_1			128
#define		size_fi_x_2			128
#define		size_fi_xm1_0		128
#define		size_fi_xm1_1		128
#define		size_fi_xm1_2		128
#define		size_fi_y_0			128
#define		size_fi_y_1			128
#define		size_fi_y_2			128
#define		size_fi_ym1_0		128
#define		size_fi_ym1_1		128
#define		size_fi_ym1_2		128
#define		size_fi_z_0			128
#define		size_fi_z_1			128
#define		size_fi_z_2			128
#define		size_fi_zm1_0		128
#define		size_fi_zm1_1		128
#define		size_fi_zm1_2		128
#define		size_psiph_0		128
#define		size_psiph_1		128
#define		size_psiph_2		128
#define		size_psimh_0		128
#define		size_psimh_1		128
#define		size_psimh_2		128
#define		size_ksi_x_0		128
#define		size_ksi_y_0		128
#define		size_ksi_z_0		128

#define		ix_p(x,y,z)			((z)*size_p_1*size_p_0+(y)*size_p_0+(x))
#define		ix_pm1(x,y,z)		((z)*size_pm1_1*size_pm1_0+(y)*size_pm1_0+(x))
#define		ix_pm2(x,y,z)		((z)*size_pm2_1*size_pm2_0+(y)*size_pm2_0+(x))
#define		ix_fi_x(x,y,z)		((z)*size_fi_x_1*size_fi_x_0+(y)*size_fi_x_0+(x))
#define		ix_fi_xm1(x,y,z)	((z)*size_fi_xm1_1*size_fi_xm1_0+(y)*size_fi_xm1_0+(x))
#define		ix_fi_y(x,y,z)		((z)*size_fi_y_1*size_fi_y_0+(y)*size_fi_y_0+(x))
#define		ix_fi_ym1(x,y,z)	((z)*size_fi_ym1_1*size_fi_ym1_0+(y)*size_fi_ym1_0+(x))
#define		ix_fi_z(x,y,z)		((z)*size_fi_z_1*size_fi_z_0+(y)*size_fi_z_0+(x))
#define		ix_fi_zm1(x,y,z)	((z)*size_fi_zm1_1*size_fi_zm1_0+(y)*size_fi_zm1_0+(x))
#define		ix_psiph(x,y,z)		((z)*size_psiph_1*size_psiph_0+(y)*size_psiph_0+(x))
#define		ix_psimh(x,y,z)		((z)*size_psimh_1*size_psimh_0+(y)*size_psimh_0+(x))
#endif

typedef struct
{
	float dx;
} state;

float fi_x_avg(__global float* fi, int x, int y, int z)
{
	return 0.25f * (fi[ix_fi_x(x,y,z)] + fi[ix_fi_x(x,y,z+1)] + fi[ix_fi_x(x,y+1,z)] + fi[ix_fi_x(x,y+1,z+1)]);
}

float fi_y_avg(__global float* fi, int x, int y, int z)
{
	return 0.25f * (fi[ix_fi_y(x,y,z)] + fi[ix_fi_y(x,y,z+1)] + fi[ix_fi_y(x+1,y,z)] + fi[ix_fi_y(x+1,y,z+1)]);
}

float fi_z_avg(__global float* fi, int x, int y, int z)
{
	return 0.25f * (fi[ix_fi_z(x,y,z)] + fi[ix_fi_z(x,y+1,z)] + fi[ix_fi_z(x+1,y,z)] + fi[ix_fi_z(x+1,y+1,z)]);
}

float ksi_avg(__constant float* ksi, int ix)
{
	return 0.5f * (ksi[ix] + ksi[ix+1]);
}

float p_x_avg(__global float* p, int x, int y, int z)
{
	return 0.25f * (p[ix_p(x,y,z)] + p[ix_p(x,y,z+1)] + p[ix_p(x,y+1,z)] + p[ix_p(x,y+1,z+1)]);
}

float p_y_avg(__global float* p, int x, int y, int z)
{
	return 0.25f * (p[ix_p(x,y,z)] + p[ix_p(x,y,z+1)] + p[ix_p(x+1,y,z)] + p[ix_p(x+1,y,z+1)]);
}

float p_z_avg(__global float* p, int x, int y, int z)
{
	return 0.25f * (p[ix_p(x,y,z)] + p[ix_p(x,y+1,z)] + p[ix_p(x+1,y,z)] + p[ix_p(x+1,y+1,z)]);
}

float psi_x_avg(state s_, __global float* p, int x, int y, int z)
{
	return 0.25f * (p[ix_psiph(x,y,z)] + p[ix_psiph(x,y,z+1)] + p[ix_psiph(x,y+1,z)] + p[ix_psiph(x,y+1,z+1)]);
}

float psi_y_avg(state s_, __global float* p, int x, int y, int z)
{
	return 0.25f * (p[ix_psiph(x,y,z)] + p[ix_psiph(x,y,z+1)] + p[ix_psiph(x+1,y,z)] + p[ix_psiph(x+1,y,z+1)]);
}

float psi_z_avg(state s_, __global float* p, int x, int y, int z)
{
	return 0.25f * (p[ix_psiph(x,y,z)] + p[ix_psiph(x,y+1,z)] + p[ix_psiph(x+1,y,z)] + p[ix_psiph(x+1,y+1,z)]);
}

float Dxp(state s_, __global float* p, __global float* pm1, int x, int y, int z)
{
	return 0.5f/s_.dx * (p_x_avg(p,x+1,y,z) - p_x_avg(p,x,y,z) + p_x_avg(pm1,x+1,y,z) - p_x_avg(p,x,y,z));
}

float Dyp(state s_, __global float* p, __global float* pm1, int x, int y, int z)
{
	return 0.5f/s_.dx * (p_y_avg(p,x,y+1,z) - p_y_avg(p,x,y,z) + p_y_avg(pm1,x,y+1,z) - p_y_avg(p,x,y,z));
}

float Dzp(state s_, __global float* p, __global float* pm1, int x, int y, int z)
{
	return 0.5f/s_.dx * (p_z_avg(p,x,y,z+1) - p_z_avg(p,x,y,z) + p_z_avg(pm1,x,y,z+1) - p_z_avg(p,x,y,z));
}

float Dxpsi(state s_, __global float* psi, int x, int y, int z)
{
	return 1.0f/s_.dx * (psi_x_avg(s_,psi,x+1,y,z) - psi_x_avg(s_,psi,x,y,z));
}

float Dypsi(state s_, __global float* psi, int x, int y, int z)
{
	return 1.0f/s_.dx * (psi_y_avg(s_,psi,x,y+1,z) - psi_y_avg(s_,psi,x,y,z));
}

float Dzpsi(state s_, __global float* psi, int x, int y, int z)
{
	return 1.0f/s_.dx * (psi_z_avg(s_,psi,x,y,z+1) - psi_z_avg(s_,psi,x,y,z));
}

__kernel void calculate_pml(
	__global float* p,
	__global float* pm1,
	__global float* pm2,
	__global float* fi_x,
	__global float* fi_xm1,
	__global float* fi_y,
	__global float* fi_ym1,
	__global float* fi_z,
	__global float* fi_zm1,
	__global float* psiph,
	__global float* psimh,
	__constant float* ksi_x,
	__constant float* ksi_y,
	__constant float* ksi_z,
	float c,
	float dx,
	float dt,
	int PML_LENGTH
	)
{
	const int x = get_global_id(0);
	const int y = get_global_id(1);
	const int z = get_global_id(2);

	state s_;
	s_.dx = dx;

	if (x > 1 && x < size_p_0-2 && y > 1 && y < size_p_1-2 && z > 1 && z < size_p_2-2)
	{
		// (1) calculating psi
		psiph[ix_psiph(x,y,z)] = dt * pm1[ix_pm1(x,y,z)] + psimh[ix_psimh(x,y,z)];

		// (2) applying PML correction
		p[ix_p(x,y,z)] =
			(

			c*c/(dx*dx)*(pm1[ix_pm1(x+1,y,z)] + pm1[ix_pm1(x-1,y,z)] + pm1[ix_pm1(x,y+1,z)]
			+ pm1[ix_pm1(x,y-1,z)] + pm1[ix_pm1(x,y,z+1)] + pm1[ix_pm1(x,y,z-1)] - 6.0f*pm1[ix_pm1(x,y,z)])

			+ 1.0f/dx * (fi_x_avg(fi_xm1, x+1,y,z) - fi_x_avg(fi_xm1, x,y,z) + fi_y_avg(fi_ym1, x,y+1,z)
			- fi_y_avg(fi_ym1,x,y,z) + fi_z_avg(fi_zm1, x,y,z+1) - fi_z_avg(fi_zm1, x,y,z))

			- ksi_x[x] * ksi_y[y] * ksi_z[z] * 0.5f * (psiph[ix_psiph(x,y,z)] + psimh[ix_psiph(x,y,z)])

			- 1.0f/(dt*dt) * (pm2[ix_pm2(x,y,z)] - 2.0f*pm1[ix_pm1(x,y,z)])

			- (ksi_x[x] * ksi_y[y] + ksi_y[y] * ksi_z[z] + ksi_z[z] * ksi_x[x]) * pm1[ix_pm1(x,y,z)]

			+ (ksi_x[x] + ksi_y[y] + ksi_z[z])/(2.0f*dt) * pm2[ix_pm2(x,y,z)]

			)

			/ (1.0f/(dt*dt) + (ksi_x[x] + ksi_y[y] + ksi_z[z]) / (2.0f*dt));

			/*
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
			*/

		if ( x < PML_LENGTH || x > size_p_0 - PML_LENGTH - 1 )
		{
			fi_x[ix_fi_x(x,y,z)] = (
				- 0.5f * ksi_avg(ksi_x, x) * fi_xm1[ix_fi_xm1(x,y,z)]
				+ (ksi_avg(ksi_y,y) + ksi_avg(ksi_z,z) - ksi_avg(ksi_x,x)) * Dxp(s_,p,pm1,x,y,z)
				+ (ksi_avg(ksi_y,y) * ksi_avg(ksi_z,z)) * Dxpsi(s_,psiph,x,y,z)
				+ 1.0f/dt * (fi_xm1[ix_fi_xm1(x,y,z)])
			)
			/ (1.0f/dt + ksi_avg(ksi_x,x)*0.5f);
		}

		if ( y < PML_LENGTH || y > size_p_1 - PML_LENGTH - 1 )
		{
			fi_y[ix_fi_y(x,y,z)] = (
				- 0.5f * ksi_avg(ksi_y, y) * fi_ym1[ix_fi_ym1(x,y,z)]
				+ (ksi_avg(ksi_x,x) + ksi_avg(ksi_z,z) - ksi_avg(ksi_y,y)) * Dyp(s_,p,pm1,x,y,z)
				+ (ksi_avg(ksi_x,y) * ksi_avg(ksi_z,z)) * Dypsi(s_,psiph,x,y,z)
				+ 1.0f/dt * (fi_ym1[ix_fi_ym1(x,y,z)])
			)
			/ (1.0f/dt + ksi_avg(ksi_y,y)*0.5f);
		}

		if ( z < PML_LENGTH || z > size_p_2 - PML_LENGTH - 1 )
		{
			fi_z[ix_fi_z(x,y,z)] = (
				- 0.5f * ksi_avg(ksi_z, z) * fi_zm1[ix_fi_zm1(x,y,z)]
				+ (ksi_avg(ksi_x,x) + ksi_avg(ksi_y,y) - ksi_avg(ksi_z,z)) * Dzp(s_,p,pm1,x,y,z)
				+ (ksi_avg(ksi_x,x) * ksi_avg(ksi_y,y)) * Dzpsi(s_,psiph,x,y,z)
				+ 1.0f/dt * (fi_zm1[ix_fi_zm1(x,y,z)])
			)
			/ (1.0f/dt + ksi_avg(ksi_z,z)*0.5f);
		}

	}
}
