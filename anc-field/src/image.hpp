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

#ifndef IMAGE_HPP
#define IMAGE_HPP

namespace Image
{

// Matlab color scale
inline void IntensityToColor(float& r, float& g, float& b, float v, float floor, float ceil)
{
	v = (v-floor)/(ceil-floor);
	if (v < 0.0f) v = 0.0f;
	if (v > 1.0f) v = 1.0f;

	const float darklevel = 0.6f;
	const float limiters[4] = {0.2f, 0.3667f, 0.6333f, 0.8f};

	if (v <= limiters[0])
	{
		r = 0.0f;
		g = 0.0f;
		b = darklevel + (1.0f-darklevel) * v/limiters[0];
	}
	else if (v <= limiters[1])
	{
		r = 0.0f;
		g = (v-limiters[0]) / (limiters[1]-limiters[0]);
		b = 1.0f;
	}
	else if (v <= limiters[2])
	{
		r = (v-limiters[1]) / (limiters[2]-limiters[1]);
		g = 1.0f;
		b = 1.0f - (v-limiters[1]) / (limiters[2]-limiters[1]) ;
	}
	else if (v <= limiters[3])
	{
		r = 1.0f;
		g = 1.0f - (v-limiters[2]) / (limiters[3]-limiters[2]);
		b = 0.0f;
	}
	else
	{
		r = 1.0f - 0.5f * (v-limiters[3]) / (1.0f-limiters[3]);
		g = 0.0f;
		b = 0.0f;
	}
}

inline unsigned char Saturate(float v)
{
	return (unsigned char) (v * 254.0f);
}

}

#endif
