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

#ifndef UTIL_H
#define UTIL_H

#include <string>
#include <fstream>

namespace Util
{

std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems) {
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        elems.push_back(item);
    }
    return elems;
}


std::vector<std::string> split(const std::string &s, char delim) {
    std::vector<std::string> elems;
    split(s, delim, elems);
    return elems;
}

unsigned RoundTo(unsigned n, unsigned unit)
{
	if (n%unit == 0) return n;
	return n + (unit - (n%unit));
}

void StringToWstring(std::string& str, std::wstring& wstr)
{
	wstr.assign(str.begin(), str.end());
}

std::wstring StringToWstring(std::string& str)
{
	std::wstring wstr;
	wstr.assign(str.begin(), str.end());

	return wstr;
}

std::wstring StringToWstring(char* cstr)
{
	std::string str(cstr);
	std::wstring wstr;
	wstr.assign(str.begin(), str.end());

	return wstr;
}

std::string WstringToString(std::wstring& wstr)
{
	std::string str;
	str.assign(wstr.begin(), wstr.end());

	return str;
}

void StringToFile(std::string filename, std::string content)
{
	std::ofstream out(filename);
	out << content;
	out.close();
}

template<typename T>
void FileToVariable(std::string filename, T* variable)
{
	std::ifstream file(filename);
	std::string line;

	if (std::getline(file, line))
	{
		*variable = (T)std::stod(line);
	}

	file.close();
}

template<typename T>
std::vector<T> FileToVariable(const std::string& filename)
{
	std::vector<T> variable;
	std::ifstream file(filename);
	std::string line;

	while(std::getline(file, line))
	{
		variable.push_back( (T)std::stod(line) );
	}

	file.close();

	return variable;
}

std::string GetDirectory(const std::string& filename)
{
	size_t found;
	found = filename.find_last_of("/\\");
	return filename.substr(0, found);
}

inline int NotNeg(const int n)
{
	return n<0 ? 0 : n;
}

}

#endif