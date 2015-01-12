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

#ifndef CLH_DEVICE_HPP
#define CLH_DEVICE_HPP

#include "clh-device-descriptor.hpp"

#include <CL/cl.hpp>
#include <iostream>

namespace clh
{
	class Device
	{
	public:
							Device(DeviceDescriptor&);
		cl::Context&		context()	{ return context_; }
		cl::CommandQueue&	queue()		{ return queue_; }
		cl::Device&			device()	{ return device_; }
	private:
		cl::Device			device_;
		cl::Context			context_;
		cl::CommandQueue	queue_;
	};

	Device::Device(DeviceDescriptor& descriptor) : device_(descriptor.device()), context_({descriptor.device()})
	{
		queue_ = cl::CommandQueue(context_, descriptor.device());
	}
}

#endif
