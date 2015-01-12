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

#ifndef CLH_DEVICE_DESCRIPTOR_HPP
#define CLH_DEVICE_DESCRIPTOR_HPP

#include <CL/cl.hpp>
#include <string>

namespace clh
{
	class DeviceDescriptor
	{
	public:
						DeviceDescriptor(std::string name, cl::Device device);
		cl::Context		GetContext();
		std::string		name() { return name_; }
		cl::Device		device() { return device_; }
	private:
		std::string		name_;
		cl::Device		device_;
		bool			initialized_;
	};

	DeviceDescriptor::DeviceDescriptor(std::string name, cl::Device device)
		: name_(name), device_(device), initialized_(false)
	{}
}

#endif
