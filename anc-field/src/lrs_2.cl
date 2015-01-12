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

#ifndef	CLH_SIZES
#define	size_p_p1_0	256
#define	size_p_p1_1	128
#define	size_p_p1_2	384
#define	size_p_0	256
#define	size_p_1	128
#define	size_p_2	384
#define	size_p_d1_0	256
#define	size_p_d1_1	128
#define	size_p_d1_2	384
#define	size_pos_0	5
#define	size_pos_1	621
#define	size_a_0	4
#define	size_a_1	5
#define	size_b_0	4
#define	size_b_1	5
#define	size_buf_in_0	8
#define	size_buf_in_1	621
#define	size_buf_out_0	8
#define	size_buf_out_1	621

#define	ix_p_p1(x,y,z)	((z)*size_p_p1_1*size_p_p1_0+(y)*size_p_p1_0+(x))
#define	ix_p(x,y,z)		((z)*size_p_1*size_p_0+(y)*size_p_0+(x))
#define	ix_p_d1(x,y,z)	((z)*size_p_d1_1*size_p_d1_0+(y)*size_p_d1_0+(x))
#define	ix_pos(x,y)		((y)*size_pos_0+(x))
#define	ix_a(x,y)		((y)*size_a_0+(x))
#define	ix_b(x,y)		((y)*size_b_0+(x))
#define	ix_buf_in(x,y)	((y)*size_buf_in_0+(x))
#define	ix_buf_out(x,y)	((y)*size_buf_out_0+(x))
#endif

__kernel void lrs_2(
		__global float* p_p1,
		const __global float* p,
		const __global float* p_d1,
		const __global unsigned* pos,
		const __constant float* a,
		const __constant float* b,
		__global float* buf_in,
		__global float* buf_out,
		const float l,
		const unsigned ix_buf) {

	unsigned id = get_global_id(0);

	const unsigned x		= (unsigned)pos[ix_pos(0,id)];
	const unsigned y		= (unsigned)pos[ix_pos(1,id)];
	const unsigned z		= (unsigned)pos[ix_pos(2,id)];
	const unsigned ix_mat_0	= (unsigned)pos[ix_pos(3,id)];
	const unsigned ix_mat_1	= (unsigned)pos[ix_pos(4,id)];

	const unsigned size_f	= size_buf_in_0 / 2;

	const float a0_0 = a[ix_a(0,ix_mat_0)];
	const float a0_1 = a[ix_a(0,ix_mat_1)];
	const float b0_0 = b[ix_b(0,ix_mat_0)];
	const float b0_1 = b[ix_b(0,ix_mat_1)];

	float gn_0 = 0.0f;
	float gn_1 = 0.0f;

	for (unsigned i = 1; i < size_a_0; ++i) {
		gn_0 += b[ix_b(i,ix_mat_0)] * buf_in[ix_buf_in((ix_buf+i)%size_f,id)]
				- a[ix_a(i,ix_mat_0)] * buf_out[ix_buf_out((ix_buf+i)%size_f,id)];

		gn_1 += b[ix_b(i,ix_mat_1)] * buf_in[ix_buf_in((ix_buf+i)%size_f+size_f,id)]
				- a[ix_a(i,ix_mat_1)] * buf_out[ix_buf_out((ix_buf+i)%size_f+size_f,id)];
	}

	const float l2 = l*l;

#ifdef X_P_Y_P
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x-1,y,z)] + 2.0f*p[ix_p(x,y-1,z)] + p[ix_p(x,y,z+1)] + p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_P_Y_M
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x-1,y,z)] + 2.0f*p[ix_p(x,y+1,z)] + p[ix_p(x,y,z+1)] + p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_P_Z_P
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x-1,y,z)] + p[ix_p(x,y+1,z)] + p[ix_p(x,y-1,z)] + 2.0f*p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_P_Z_M
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x-1,y,z)] + p[ix_p(x,y+1,z)] + p[ix_p(x,y-1,z)] + 2.0f*p[ix_p(x,y,z+1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_M_Y_P
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x+1,y,z)] + 2.0f*p[ix_p(x,y-1,z)] + p[ix_p(x,y,z+1)] + p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_M_Y_M
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x+1,y,z)] + 2.0f*p[ix_p(x,y+1,z)] + p[ix_p(x,y,z+1)] + p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_M_Z_P
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x+1,y,z)] + p[ix_p(x,y+1,z)] + p[ix_p(x,y-1,z)] + 2.0f*p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef X_M_Z_M
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (2.0f*p[ix_p(x+1,y,z)] + p[ix_p(x,y+1,z)] + p[ix_p(x,y-1,z)] + 2.0f*p[ix_p(x,y,z+1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef Y_P_Z_P
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (p[ix_p(x+1,y,z)] + p[ix_p(x-1,y,z)] + 2.0f*p[ix_p(x,y-1,z)] + 2.0f*p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef Y_P_Z_M
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (p[ix_p(x+1,y,z)] + p[ix_p(x-1,y,z)] + 2.0f*p[ix_p(x,y-1,z)] + 2.0f*p[ix_p(x,y,z+1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef Y_M_Z_P
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (p[ix_p(x+1,y,z)] + p[ix_p(x-1,y,z)] + 2.0f*p[ix_p(x,y+1,z)] + 2.0f*p[ix_p(x,y,z-1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

#ifdef Y_M_Z_M
	p_p1[ix_p_p1(x,y,z)] =

		(l2 * (p[ix_p(x+1,y,z)] + p[ix_p(x-1,y,z)] + 2.0f*p[ix_p(x,y+1,z)] + 2.0f*p[ix_p(x,y,z+1)])

		+ l2*(gn_0/b0_0 + gn_1/b0_1) + 2.0f*(1.0f-3.0f*l2)*p[ix_p(x,y,z)]
		+ (l*a0_0/b0_0 + l*a0_1/b0_1 - 1.0f)*p_d1[ix_p_d1(x,y,z)])
		/ (1.0f + l*a0_0/b0_0 + l*a0_1/b0_1);
#endif

	const float xn_0 = a0_0/(l*b0_0) * (p_p1[ix_p_p1(x,y,z)] - p_d1[ix_p_d1(x,y,z)]) - gn_0/b0_0;
	buf_in[ix_buf_in(ix_buf,id)] = xn_0;
	buf_out[ix_buf_out(ix_buf,id)] = 1.0f/a0_0*(b0_0*xn_0 + gn_0);

	const float xn_1 = a0_1/(l*b0_1) * (p_p1[ix_p_p1(x,y,z)] - p_d1[ix_p_d1(x,y,z)]) - gn_1/b0_1;
	buf_in[ix_buf_in(ix_buf+size_f,id)] = xn_1;
	buf_out[ix_buf_out(ix_buf+size_f,id)] = 1/a0_1*(b0_1*xn_1 + gn_1);
}
