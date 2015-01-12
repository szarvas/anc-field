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
#define	size_from_0	128
#define	size_from_1	128
#define	size_from_2	128
#define	size_to_0	128
#define	size_to_1	128

#define	ix_from(x,y,z)	((z)*size_from_1*size_from_0+(y)*size_from_0+(x))
#define	ix_to(x,y)		((y)*size_to_0+(x))
#endif

__kernel void copy(__global float* from, __global float* to, unsigned ix_plane)
{
	size_t x = get_global_id(0);
	size_t z = get_global_id(1);

	to[ix_to(x,z)] = from[ix_from(x,ix_plane,z)];
}