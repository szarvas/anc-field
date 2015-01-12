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

#ifndef CLH_PLATFORMMANAGER_HPP
#define CLH_PLATFORMMANAGER_HPP

#include <CL/cl.hpp>
#include "clh-device-descriptor.hpp"

#include <algorithm>
#include <functional>
#include <cctype>

namespace clh {

	class PlatformManager
	{
	public:
		static std::vector<DeviceDescriptor>	GetDevices	(int type);

	private:

		static std::string			ltrim		(std::string s)
		{
			s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
			return s;
		}
	};

	std::vector<DeviceDescriptor> PlatformManager::GetDevices(int type=CL_DEVICE_TYPE_ALL)
	{
		std::vector< cl::Platform > platforms;
		cl::Platform::get(&platforms);

		std::vector< DeviceDescriptor > descriptors;

		for (cl::Platform platform : platforms)
		{
			std::vector<cl::Device> devices;
			platform.getDevices(type, &devices);

			for (auto& device : devices)
			{
				descriptors.push_back( DeviceDescriptor(ltrim(device.getInfo<CL_DEVICE_NAME>()), device) );
			}
		}

		return descriptors;
	}
}

#endif
