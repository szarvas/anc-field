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

#ifndef LRS_HPP
#define LRS_HPP

#include <vector>
#include "../clh/clh.hpp"

#define PATTERN_X_P 100000
#define PATTERN_X_M 10000
#define PATTERN_Y_P 1000
#define PATTERN_Y_M 100
#define PATTERN_Z_P 10
#define PATTERN_Z_M 1

#define PATTERN_X_P_Y_P 101000
#define PATTERN_X_P_Y_M 100100
#define PATTERN_X_P_Z_P 100010
#define PATTERN_X_P_Z_M 100001
#define PATTERN_X_M_Y_P 11000
#define PATTERN_X_M_Y_M 10100
#define PATTERN_X_M_Z_P 10010
#define PATTERN_X_M_Z_M 10001
#define PATTERN_Y_P_Z_P 1010
#define PATTERN_Y_P_Z_M 1001
#define PATTERN_Y_M_Z_P 110
#define PATTERN_Y_M_Z_M 101

#define PATTERN_X_P_Y_P_Z_P 101010
#define PATTERN_X_P_Y_P_Z_M 101001
#define PATTERN_X_P_Y_M_Z_P 100110
#define PATTERN_X_P_Y_M_Z_M 100101
#define PATTERN_X_M_Y_P_Z_P 11010
#define PATTERN_X_M_Y_P_Z_M 11001
#define PATTERN_X_M_Y_M_Z_P 10110
#define PATTERN_X_M_Y_M_Z_M 10101

#define X_P			0
#define X_M			1
#define Y_P			2
#define Y_M			3
#define Z_P			4
#define Z_M			5
#define X_P_Y_P		6
#define X_P_Y_M		7
#define X_P_Z_P		8
#define X_P_Z_M		9
#define X_M_Y_P		10
#define X_M_Y_M		11
#define X_M_Z_P		12
#define X_M_Z_M		13
#define Y_P_Z_P		14
#define Y_P_Z_M		15
#define Y_M_Z_P		16
#define Y_M_Z_M		17
#define X_P_Y_P_Z_P 18
#define X_P_Y_P_Z_M 19
#define X_P_Y_M_Z_P 20
#define X_P_Y_M_Z_M 21
#define X_M_Y_P_Z_P 22
#define X_M_Y_P_Z_M 23
#define X_M_Y_M_Z_P 24
#define X_M_Y_M_Z_M 25

#define AIR -1

template<typename T>
class LrsData
{
public:
	LrsData(clh::Device&, 	const clh::Vector<cl_int>&, size_t);
	LrsData(clh::Device&, 	const clh::Vector<cl_int>&, size_t, const std::vector<size_t>&, const std::vector<size_t>&);
	clh::Buffer<cl_int>&	pos			(int i)	{ return pos_[i]; }
	clh::Buffer<T>&			buf_in		(int i)	{ return buf_in_[i]; }
	clh::Buffer<T>&			buf_out		(int i)	{ return buf_out_[i]; }

private:
	void Init(clh::Device&, const clh::Vector<cl_int>&, size_t, const std::vector<size_t>&, const std::vector<size_t>&);
	int 					GetGroupIx	(int pattern);

	std::vector< clh::Buffer<int32_t> >		pos_;
	std::vector< clh::Buffer<T> >			buf_in_;
	std::vector< clh::Buffer<T> >			buf_out_;
};

template<typename T>
LrsData<T>::LrsData(clh::Device& device, const clh::Vector<cl_int>& volume_data, size_t dif_order)
{
	std::vector<size_t> from {0,0,0};
	std::vector<size_t> to {volume_data.size(0),volume_data.size(1),volume_data.size(2)};
	Init(device, volume_data, dif_order, from, to);
}

template<typename T>
LrsData<T>::LrsData(clh::Device& device, const clh::Vector<cl_int>& volume_data, size_t dif_order,
	const std::vector<size_t>& from, const std::vector<size_t>& to)
{
	Init(device, volume_data, dif_order, from, to);
}

template<typename T>
void LrsData<T>::Init(clh::Device& device, const clh::Vector<cl_int>& volume_data, size_t dif_order,
	const std::vector<size_t>& from, const std::vector<size_t>& to)
{
	for (int i = 0; i <= Z_M; ++i) {
		pos_.push_back(clh::Buffer<int>(device, {4,0}));
		buf_in_.push_back(clh::Buffer<T>(device, {dif_order, 0}));
		buf_out_.push_back(clh::Buffer<T>(device, {dif_order, 0}));
	}

	for (int i = X_P_Y_P; i <= Y_M_Z_M; ++i) {
		pos_.push_back(clh::Buffer<int>(device, {5,0}));
		buf_in_.push_back(clh::Buffer<T>(device, {2*dif_order, 0}));
		buf_out_.push_back(clh::Buffer<T>(device, {2*dif_order, 0}));
	}

	for (int i = X_P_Y_P_Z_P; i <= X_M_Y_M_Z_M; ++i) {
		pos_.push_back(clh::Buffer<int>(device, {6,0}));
		buf_in_.push_back(clh::Buffer<T>(device, {3*dif_order, 0}));
		buf_out_.push_back(clh::Buffer<T>(device, {3*dif_order, 0}));
	}

	int surface_count = 0;
	int edge_count = 0;
	int corner_count = 0;

	size_t size_x = volume_data.size(0);
	size_t size_y = volume_data.size(1);
	size_t size_z = volume_data.size(2);
	size_t off_x = from[0];
	size_t off_y = from[1];
	size_t off_z = from[2];
	size_t lim_x = to[0];
	size_t lim_y = to[1];
	size_t lim_z = to[2];

	auto& v = volume_data;

	for (int z = off_z+1; z < lim_z-1; ++z)
	{
		for (int y = off_y+1; y < lim_y-1; ++y)
		{
			for (int x = off_x+1; x < lim_x-1; ++x)
			{
				if (v[z*size_y*size_x + y*size_x + x] == AIR)
				{
					int pattern = 0;
					int materials[6] = {AIR, AIR, AIR, AIR, AIR, AIR};

					if (v[z*size_y*size_x + y*size_x + x+1  ] != AIR){ materials[X_P] = v[z*size_y*size_x + y*size_x + x+1  ]; pattern += 100000; }
					if (v[z*size_y*size_x + y*size_x + x-1  ] != AIR){ materials[X_M] = v[z*size_y*size_x + y*size_x + x-1  ]; pattern += 10000; }
					if (v[z*size_y*size_x + (y+1)*size_x + x] != AIR){ materials[Y_P] = v[z*size_y*size_x + (y+1)*size_x + x]; pattern += 1000; }
					if (v[z*size_y*size_x + (y-1)*size_x + x] != AIR){ materials[Y_M] = v[z*size_y*size_x + (y-1)*size_x + x]; pattern += 100; }
					if (v[(z+1)*size_y*size_x + y*size_x + x] != AIR){ materials[Z_P] = v[(z+1)*size_y*size_x + y*size_x + x]; pattern += 10; }
					if (v[(z-1)*size_y*size_x + y*size_x + x] != AIR){ materials[Z_M] = v[(z-1)*size_y*size_x + y*size_x + x]; pattern += 1; }

					if (pattern != 0)
					{
						int ix = GetGroupIx(pattern);
						size_t length_buf = dif_order;

						// only one neighbouring ghost point
						if (ix <= Z_M) {
							pos_[ix].push_back({x,y,z,materials[ix]});
							buf_in_[ix].push_back(std::vector<T>(length_buf, (T)0.0f));
							buf_out_[ix].push_back(std::vector<T>(length_buf, (T)0.0f));
							surface_count += 1;
						}
						else if (ix <= Y_M_Z_M) {
							int material2[2];
							int k = 0;
							for(int i = 0; i < 6; ++i) {
								if (materials[i] != AIR) material2[k++] = materials[i];
							}
							pos_[ix].push_back({x,y,z,material2[0],material2[1]});
							buf_in_[ix].push_back(std::vector<T>(2*length_buf, (T)0.0f));
							buf_out_[ix].push_back(std::vector<T>(2*length_buf, (T)0.0f));
							edge_count += 1;
						}
						else if (ix <= X_M_Y_M_Z_M) {
							int material3[3];
							int k = 0;
							for(int i = 0; i < 6; ++i) {
								if (materials[i] != AIR) material3[k++] = materials[i];
							}
							pos_[ix].push_back({x,y,z,material3[0],material3[1],material3[2]});
							buf_in_[ix].push_back(std::vector<T>(3*length_buf, (T)0.0f));
							buf_out_[ix].push_back(std::vector<T>(3*length_buf, (T)0.0f));
							corner_count += 1;
						}
					}
				}
			}
		}
	}

	CLOG(INFO,"Kerkythea") << surface_count << " surface points identified";
	CLOG(INFO,"Kerkythea") << edge_count << " edge points identified";
	CLOG(INFO,"Kerkythea") << corner_count << " corner points identified";
}

template<typename T>
int LrsData<T>::GetGroupIx(const int pattern)
{
	switch (pattern)
	{
	case PATTERN_X_P:
		return X_P;
		break;

	case PATTERN_X_M:
		return X_M;
		break;

	case PATTERN_Y_P:
		return Y_P;
		break;

	case PATTERN_Y_M:
		return Y_M;
		break;

	case PATTERN_Z_P:
		return Z_P;
		break;

	case PATTERN_Z_M:
		return Z_M;
		break;

	case PATTERN_X_P_Y_P:
		return X_P_Y_P;
		break;

	case PATTERN_X_P_Y_M:
		return X_P_Y_M;
		break;

	case PATTERN_X_P_Z_P:
		return X_P_Z_P;
		break;

	case PATTERN_X_P_Z_M:
		return X_P_Z_M;
		break;

	case PATTERN_X_M_Y_P:
		return X_M_Y_P;
		break;

	case PATTERN_X_M_Y_M:
		return X_M_Y_M;
		break;

	case PATTERN_X_M_Z_P:
		return X_M_Z_P;
		break;

	case PATTERN_X_M_Z_M:
		return X_M_Z_M;
		break;

	case PATTERN_Y_P_Z_P:
		return Y_P_Z_P;
		break;

	case PATTERN_Y_P_Z_M:
		return Y_P_Z_M;
		break;

	case PATTERN_Y_M_Z_P:
		return Y_M_Z_P;
		break;

	case PATTERN_Y_M_Z_M:
		return Y_M_Z_M;
		break;

	case PATTERN_X_P_Y_P_Z_P:
		return X_P_Y_P_Z_P;
		break;

	case PATTERN_X_P_Y_P_Z_M:
		return X_P_Y_P_Z_M;
		break;

	case PATTERN_X_P_Y_M_Z_P:
		return X_P_Y_M_Z_P;
		break;

	case PATTERN_X_P_Y_M_Z_M:
		return X_P_Y_M_Z_M;
		break;

	case PATTERN_X_M_Y_P_Z_P:
		return X_M_Y_P_Z_P;
		break;

	case PATTERN_X_M_Y_P_Z_M:
		return X_M_Y_P_Z_M;
		break;

	case PATTERN_X_M_Y_M_Z_P:
		return X_M_Y_M_Z_P;
		break;

	case PATTERN_X_M_Y_M_Z_M:
		return X_M_Y_M_Z_M;
		break;

	default:
		throw std::runtime_error("Unphysical surfaces encountered");
		break;
	}
}

#endif
