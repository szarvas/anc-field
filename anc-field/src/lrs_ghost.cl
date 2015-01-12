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

#define	size_p_0		256
#define	size_p_1		256
#define	size_p_2		256
#define	size_p_d1_0		256
#define	size_p_d1_1		256
#define	size_p_d1_2		256
#define	size_pos_0		4
#define	size_pos_1		0
#define	size_a_0		4
#define	size_a_1		0
#define	size_b_0		4
#define	size_b_1		0
#define	size_buf_in_0	3
#define	size_buf_in_1	0
#define	size_buf_out_0	3
#define	size_buf_out_1	0

#define	ix_p(x,y,z)		((z)*size_p_1*size_p_0+(y)*size_p_0+(x))
#define	ix_p_d1(x,y,z)	((z)*size_p_d1_1*size_p_d1_0+(y)*size_p_d1_0+(x))
#define	ix_pos(x,y)		((y)*size_pos_0+(x))
#define	ix_a(x,y)		((y)*size_a_0+(x))
#define	ix_b(x,y)		((y)*size_b_0+(x))
#define	ix_buf_in(x,y)	((y)*size_buf_in_0+(x))
#define	ix_buf_out(x,y)	((y)*size_buf_out_0+(x))

#endif

__kernel void lrs_ghost(
		__global float* p,
		const __global float* p_d1,
		const __global unsigned* pos,
		const __global float* a,
		const __global float* b,
		const __global float* buf_in,
		const __global float* buf_out,
		__global float* gn_array,
		const float l,
		const unsigned ix_buf) {

	const unsigned id = get_global_id(0);

	const unsigned x		= pos[ix_pos(0,id)];
	const unsigned y		= pos[ix_pos(1,id)];
	const unsigned z		= pos[ix_pos(2,id)];
	const unsigned ix_mat	= pos[ix_pos(3,id)];

	const float l2 = l*l;
	const float a0 = a[ix_a(0,ix_mat)];
	const float b0 = a[ix_b(0,ix_mat)];

	float gn = 0.0f;

	for (unsigned i = 1; i < size_a_0; ++i) {
		gn += b[ix_b(i,ix_mat)] * buf_in[ix_buf_in((ix_buf+i)%size_buf_in_0,id)]
				- a[ix_a(i,ix_mat)] * buf_out[ix_buf_out((ix_buf+i)%size_buf_out_0,id)];
	}

	gn_array[id] = gn;

#ifdef X_P
	p[ix_p(x+1,y,z)] = -(a0*l2*p[ix_p(x,y-1,z)] + a0*l2*p[ix_p(x,y+1,z)] + a0*l2*p[ix_p(x,y,z-1)]
			+ a0*l2*p[ix_p(x,y,z+1)] - gn*l - 2*(3*a0*l2 - a0)*p[ix_p(x,y,z)]
			- 2*a0*p_d1[ix_p_d1(x,y,z)] + (a0*l2 - b0*l)*p[ix_p(x-1,y,z)]) / (a0*l2 + b0*l);
#endif

#ifdef X_M
	p[ix_p(x-1,y,z)] = -(a0*l2*p[ix_p(x,y-1,z)] + a0*l2*p[ix_p(x,y+1,z)] + a0*l2*p[ix_p(x,y,z-1)]
			+ a0*l2*p[ix_p(x,y,z+1)] - gn*l - 2*(3*a0*l2 - a0)*p[ix_p(x,y,z)]
			- 2*a0*p_d1[ix_p_d1(x,y,z)] + (a0*l2 - b0*l)*p[ix_p(x+1,y,z)]) / (a0*l2 + b0*l);
#endif

#ifdef Y_P
	p[ix_p(x,y+1,z)] = -(a0*l2*p[ix_p(x-1,y,z)] + a0*l2*p[ix_p(x+1,y,z)] + a0*l2*p[ix_p(x,y,z-1)]
			+ a0*l2*p[ix_p(x,y,z+1)] - gn*l - 2*(3*a0*l2 - a0)*p[ix_p(x,y,z)]
			- 2*a0*p_d1[ix_p_d1(x,y,z)] + (a0*l2 - b0*l)*p[ix_p(x,y-1,z)]) / (a0*l2 + b0*l);
#endif

#ifdef Y_M
	p[ix_p(x,y-1,z)] = -(a0*l2*p[ix_p(x-1,y,z)] + a0*l2*p[ix_p(x+1,y,z)] + a0*l2*p[ix_p(x,y,z-1)]
			+ a0*l2*p[ix_p(x,y,z+1)] - gn*l - 2*(3*a0*l2 - a0)*p[ix_p(x,y,z)]
			- 2*a0*p_d1[ix_p_d1(x,y,z)] + (a0*l2 - b0*l)*p[ix_p(x,y+1,z)]) / (a0*l2 + b0*l);
#endif

#ifdef Z_P
	p[ix_p(x,y,z+1)] = -(a0*l2*p[ix_p(x-1,y,z)] + a0*l2*p[ix_p(x+1,y,z)] + a0*l2*p[ix_p(x,y-1,z)]
			+ a0*l2*p[ix_p(x,y+1,z)] - gn*l - 2*(3*a0*l2 - a0)*p[ix_p(x,y,z)]
			- 2*a0*p_d1[ix_p_d1(x,y,z)] + (a0*l2 - b0*l)*p[ix_p(x,y,z-1)]) / (a0*l2 + b0*l);
#endif

#ifdef Z_M
	p[ix_p(x,y,z-1)] = -(a0*l2*p[ix_p(x-1,y,z)] + a0*l2*p[ix_p(x+1,y,z)] + a0*l2*p[ix_p(x,y-1,z)]
			+ a0*l2*p[ix_p(x,y+1,z)] - gn*l - 2*(3*a0*l2 - a0)*p[ix_p(x,y,z)]
			- 2*a0*p_d1[ix_p_d1(x,y,z)] + (a0*l2 - b0*l)*p[ix_p(x,y,z+1)]) / (a0*l2 + b0*l);
#endif

}
