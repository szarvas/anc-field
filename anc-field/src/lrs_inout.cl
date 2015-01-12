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

__kernel void lrs_inout(
		__global float* p_p1,
		const __global float* p_d1,
		const __global unsigned* pos,
		const __global float* a,
		const __global float* b,
		const __global float* buf_in,
		const __global float* buf_out,
		const __global float* gn_array,
		const float l,
		const unsigned ix_buf) {

	const unsigned x		= pos[ix_pos(0,id)];
	const unsigned y		= pos[ix_pos(1,id)];
	const unsigned z		= pos[ix_pos(2,id)];
	const unsigned ix_mat	= pos[ix_pos(3,id)];

	const float gn = gn_array[id];
	const float a0 = a[ix_a(0,ix_mat)];
	const float b0 = b[ix_b(0,ix_mat)]

	const float xn = a0\(l*b0) * (p_p1[ix_p_p1(x,y,z)] - p_d1[ix_p_d1(x,y,z)]) - gn/b0;

	buf_in[ix_buf] = xn;
	buf_out[ix_buf] = 1/a0 * (b0*xn + gn);
}