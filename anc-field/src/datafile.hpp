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

#ifndef DATAFILE_HPP
#define DATAFILE_HPP

#include <iostream>
#include "../clh/clh.hpp"

namespace df
{

template<typename T>
clh::Vector<T> Load(const std::string& filename)
{
	std::string line;
	std::vector<std::vector<T>> numbers;
	std::ifstream file;
	file.open(filename);
	while (getline(file, line))
	{
		std::vector<std::string> elems;
		elems.reserve(line.length()/8);

		std::stringstream ss(line);
		std::string buf;

		while (ss >> buf)
			elems.push_back(buf);

		std::vector<T> T_elems(elems.size());
		for (int i = 0; i < elems.size(); ++i)
		{
			T_elems[i] = atof(elems[i].c_str());
		}
		numbers.push_back(T_elems);
	}
	file.close();

	clh::Vector<T> data;

	if (numbers.size() > 0)
	{
		data.resize({numbers[0].size(), 0});
	}

	for (auto row : numbers)
	{
		data.push_back(row);
	}

	return data;
}

template<typename T>
void Save(const clh::Vector<T>& data, const std::string& filename)
{
	std::ofstream file;
	switch(data.ndsize().size())
	{
	case 1:
		file.open(filename);
		for (auto e : data)
		{
			file << e << " ";
		}
		file << "\n";
		file.close();
		break;

	case 2:
		file.open(filename);
		for(size_t j = 0; j < data.size(1); ++j)
		{
			for(size_t i = 0; i < data.size(0); ++i)
			{
				file << data[{i,j}] << " ";
			}
			file << "\n";
		}
		file << "\n";
		file.close();
		break;

	default:
		throw std::range_error("df::Save supports only one and two-dimensional vectors");
	}
}

}

#endif
