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

#ifndef CL_HELPER_HPP
#define CL_HELPER_HPP

#ifdef _WIN32
#include <Windows.h>
#endif

#include "clh-device.hpp"
#include "clh-platform-manager.hpp"
#include "clh-device-descriptor.hpp"
#include "clh-buffer.hpp"
#include "clh-kernel.hpp"
#include "clh-vector.hpp"

#include <vector>

namespace clh
{

auto GetZeroSize = [](const std::vector< std::vector<size_t> >& sizes)
{
	return std::vector<size_t>();
};

std::wstring GetSelfLocation()
{
#ifdef _WIN32
	wchar_t buffer[MAX_PATH];
	GetModuleFileName(NULL, buffer, MAX_PATH);
	auto exe_loc = std::wstring(buffer);
	size_t found;
	found = exe_loc.find_last_of(L"/\\");
	return exe_loc.substr(0, found);
#else
	// todo: readlink /proc/self/exe
#endif
}

}

#endif
