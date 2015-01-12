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

#ifndef KERKYTHEA_HPP
#define KERKYTHEA_HPP
//#define MAKE_IT_FASTER
#include <string>
#include <vector>
#include <utility>
#include <unordered_map>
#include <set>
#include <cstdint>

#include "../clh/clh.hpp"
#include "pugixml.hpp"
#include "util.hpp"
#include "easylogging.hpp"

template<typename T>
std::vector< std::pair<std::vector<T>,std::string> > LoadBoxes(const std::string& path_to_file);

/**
 * Contains all the relevant data extracted from a Kerkythea file
 */
template<typename T>
class Kerkythea
{
public:
								Kerkythea 	(std::string path_to_file, T res);
	const clh::Vector<cl_int>&	volume_data () { return volume_data_; }
	clh::Vector<T>&				coef_a		() { return coef_a_; }
	clh::Vector<T>&				coef_b		() { return coef_b_; }
private:
	clh::Vector<cl_int>			volume_data_;
	clh::Vector<T>				coef_a_;
	clh::Vector<T>				coef_b_;
};

/**
 * Returns the geometric information contained within a Kerkythea file
 *
 * Only boxes aligned with euclidean axes will be identified correclty.
 * A box will be described by a pair of a vector and a string. The vector
 * contains 6 elements denoting the minimal and maximal cooridnate values
 * of the box along the X,Y and Z axes. The string is the material
 * descriptor of the box e.g. "plywood".
 */
template<typename T>
std::vector< std::pair<std::vector<T>,std::string> > LoadBoxes(const std::string& path_to_file)
{
	pugi::xml_document doc;
	doc.load_file(path_to_file.c_str());

	std::vector< std::pair<std::vector<T>,std::string> > boxes;

	for (pugi::xml_node object : doc.child("Root").children("Object"))
	{
		if (object.attribute("Type").as_string() == std::string("Scene"))
		{
			for (pugi::xml_node object : object.children("Object"))
			{
				if (object.attribute("Type").as_string() == std::string("Model"))
				{
					std::string name_string = object.attribute("Name").value();

					for (pugi::xml_node object : object.child("Object").children("Parameter"))
					{
						if (object.attribute("Name").as_string() == std::string("Vertex List")) {
							T min_x, max_x, min_y, max_y, min_z, max_z;

							min_x = (T) 10000.0f;
							min_y = (T) 10000.0f;
							min_z = (T) 10000.0f;
							max_x = (T)-10000.0f;
							max_y = (T)-10000.0f;
							max_z = (T)-10000.0f;

							for (pugi::xml_node object : object.children("P"))
							{
								T x, y, z, a, b, c;
								sscanf(object.attribute("xyz").value(), "%f %f %f", &a, &b, &c);

								x = a;
								y = c;
								z = -b;

								if (x < min_x) min_x = x;
								if (x > max_x) max_x = x;
								if (y < min_y) min_y = y;
								if (y > max_y) max_y = y;
								if (z < min_z) min_z = z;
								if (z > max_z) max_z = z;
							}

							std::string material_name = name_string.substr(name_string.find_last_of("_") + 1);
#ifdef MAKE_IT_FASTER // this stuff increases the problem size, and shortens runtime I hate it cause it's magic
							min_x += (T)0.5f*0.02f;
							max_x -= (T)0.5f*0.02f;
							min_y += (T)0.5f*0.02f;
							max_y -= (T)0.5f*0.02f;
							min_z += (T)0.5f*0.02f;
							max_z -= (T)0.5f*0.02f;
#endif
							if (min_x < (T)0.0f) min_x = (T)0.0f;
							if (min_y < (T)0.0f) min_y = (T)0.0f;
							if (min_z < (T)0.0f) min_z = (T)0.0f;
							boxes.push_back({{min_x, max_x, min_y, max_y, min_z, max_z}, material_name});
						}
					}
				}
			}
		}
	} // for (pugi::xml_node object)

	return boxes;
}

template<typename T>
Kerkythea<T>::Kerkythea(std::string path_to_file, T res)
{
	el::Loggers::getLogger("Kerkythea");

	auto boxes = LoadBoxes<T>(path_to_file);
	CLOG(INFO, "Kerkythea") << "Loaded " << boxes.size() << " boxes from " << path_to_file;

	T max_x = 0.0f;
	T max_y = 0.0f;
	T max_z = 0.0f;

	for (auto b : boxes)
	{
		if (b.first[1] > max_x) max_x = b.first[1];
		if (b.first[3] > max_y) max_y = b.first[3];
		if (b.first[5] > max_z) max_z = b.first[5];
	}

	size_t size_x = Util::RoundTo((size_t)(max_x / res) + 1, 32);
	size_t size_y = Util::RoundTo((size_t)(max_y / res) + 1, 32);
	size_t size_z = Util::RoundTo((size_t)(max_z / res) + 1, 32);

	volume_data_ = clh::Vector<cl_int>({size_x, size_y, size_z}, -1);

	std::set<std::string> material_names;
	for (auto b : boxes)
	{
		material_names.insert(b.second);
	}

	std::unordered_map<std::string, cl_int> material_dict;

	// determine the order of material filters
	auto coefs = Util::FileToVariable<T>(Util::GetDirectory(path_to_file) + "/" + *(material_names.begin()) + "_a.dat");

	coef_a_ = clh::Vector<T>({coefs.size(), 0}, 0.0f);
	coef_b_ = clh::Vector<T>({coefs.size(), 0}, 0.0f);

	cl_int ix_mat = 0;
	for (auto material_name : material_names)
	{
		coef_a_.push_back( Util::FileToVariable<T>(Util::GetDirectory(path_to_file) + "/" + material_name + "_a.dat") );
		coef_b_.push_back( Util::FileToVariable<T>(Util::GetDirectory(path_to_file) + "/" + material_name + "_b.dat") );
		material_dict[material_name] = ix_mat++;
		CLOG(INFO, "Kerkythea") << "Material " << material_name << " has been loaded";
	}

	// creating volumetric data
	for (auto b : boxes)
	{
		auto pos = b.first;

		for (size_t z = (size_t)(pos[4] / res); z <= (size_t)(pos[5] / res); ++z)
		{
			for (size_t y = (size_t)(pos[2] / res); y <= (size_t)(pos[3] / res); ++y)
			{
				for (size_t x = (size_t)(pos[0] / res); x <= (size_t)(pos[1] / res); ++x)
				{
					volume_data_[z*size_y*size_x + y*size_x + x] = material_dict.at(b.second);
				}
			}
		}
	}
}

#endif
