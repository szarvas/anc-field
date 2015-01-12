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
#define		size_p_0			256
#define		size_p_1			128
#define		size_p_2			384
#define		size_pos_0			3
#define		size_pos_1			2
#define		size_source_0		3200
#define		size_source_1		2

#define		ix_p(x,y,z)			((z)*size_p_1*size_p_0+(y)*size_p_0+(x))
#define		ix_pos(x,y)			((y)*size_pos_0+(x))
#define		ix_source(x,y)		((y)*size_source_0+(x))
#endif

__kernel void source(__global float* p, __constant int* pos, __global float* source, const unsigned time)
{
	const int ix = get_global_id(0);
	const int x = pos[ix_pos(0,ix)];
	const int y = pos[ix_pos(1,ix)];
	const int z = pos[ix_pos(2,ix)];

	p[ix_p(x,y,z)] += source[ix_source(time, ix)];
}
