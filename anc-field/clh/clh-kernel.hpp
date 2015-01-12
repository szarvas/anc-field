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

#ifndef CLH_KERNEL_HPP
#define CLH_KERNEL_HPP

/*
 * PASSING FUNCTION LIKE MACRO DEFINITIONS TO THE INTEL OPENCL COMPILER
 * DOESN'T WORK ON LINUX
 *
 * THIS ALTERNATE SOLUTION MAY BECOME THE DEFAULT LATER ON
 */
#define INTEL_LINUX_COMPATIBILITY

#include <iostream>
#include <sstream>
#include <fstream>
#include <iterator>
#include <regex>

#include <CL/cl.hpp>
#include "easylogging.hpp"

namespace clh
{

typedef std::function< std::vector<size_t>(const std::vector<std::vector<size_t>>&) > RangeFunc;

template<typename... Args>
class Kernel
{
public:
				Kernel				(const std::string&, RangeFunc, RangeFunc);
	void		operator()			(Args...);
	void		AddDefinition		(std::string);
	void		AppendSourceWithDefs(bool);

private:
	template<typename T>
	void		ExamineArg	(Buffer<T>&);

	cl::NDRange	VectorToNDRange(const std::vector<size_t>&);

	template<typename T>
	void		ExamineArg	(T);

	template<typename T>
	void		BindArg		(Buffer<T>&);

	template<typename T>
	void		BindArg		(T);

	template<typename T>
	void		Invalidate	(Buffer<T>&);

	template<typename T>
	void		Invalidate	(T);

	template<typename T, typename... Brgs>
	void		UnpackThenExamine(T&, Brgs&...);
	void		UnpackThenExamine();

	template<typename T, typename... Brgs>
	void		UnpackThenBind(T&, Brgs&...);
	void		UnpackThenBind();

	template<typename T, typename... Brgs>
	void		UnpackThenInvalidate(T&, Brgs&...);
	void		UnpackThenInvalidate();

	cl::Kernel	BuildKernel(Device&);
	void		AppendSourcefile();
	std::string	GenerateSourceDefinitions();

	const std::string			filename_;
	cl::Kernel					kernel_;
	bool						kernel_init_;
	size_t						bind_counter_;
	std::vector<std::string>	kernel_variables_;
	std::string					build_options_;
	std::string					user_build_options_;
	clh::Device*				device_;
	RangeFunc					GetGlobalRange_;
	RangeFunc					GetLocalRange_;
	std::vector< std::vector<size_t> > sizes_;
	bool						append_sourcefile_with_defs_;
};

template<typename... Args>
template<typename T, typename... Brgs>
void Kernel<Args...>::UnpackThenExamine(T& var, Brgs&... params)
{
	ExamineArg(var);
	UnpackThenExamine(params...);
}

template<typename... Args>
void Kernel<Args...>::UnpackThenExamine() { }

template<typename... Args>
template<typename T, typename... Brgs>
void Kernel<Args...>::UnpackThenBind(T& var, Brgs&... params)
{
	BindArg(var);
	UnpackThenBind(params...);
}

template<typename... Args>
void Kernel<Args...>::UnpackThenBind() { }

template<typename... Args>
template<typename T, typename... Brgs>
void Kernel<Args...>::UnpackThenInvalidate(T& var, Brgs&... params)
{
	Invalidate(var);
	UnpackThenInvalidate(params...);
}

template<typename... Args>
void Kernel<Args...>::UnpackThenInvalidate() { }

template<typename... Args>
Kernel<Args...>::Kernel(const std::string& filename, RangeFunc GetGlobalRange, RangeFunc GetLocalRange)
	: filename_{filename}, GetGlobalRange_{GetGlobalRange}, GetLocalRange_{GetLocalRange}
{
	kernel_init_ = false;

	std::ifstream file(filename_);
	std::string source(std::istreambuf_iterator<char>(file), (std::istreambuf_iterator<char>()));
	file.close();

	std::regex e_func_decl("__kernel([^\\x00]+?)\\{");
	std::smatch m;
	std::string s = source;
	std::regex_search(s, m, e_func_decl);
	s = m[0];
	std::regex e("(__global|__constant)?\\s+[a-zA-Z0-9_]+\\*\\s+([a-zA-Z0-9_]+)");

	while (std::regex_search(s, m, e))
	{
		kernel_variables_.push_back(m[2]);
		s = m.suffix().str();
	}

	append_sourcefile_with_defs_ = false;
}

template<typename... Args>
void Kernel<Args...>::operator()(Args... params)
{
	bind_counter_ = 0;
	build_options_ = "";
	sizes_.clear();
	UnpackThenExamine(params...);
	if (!kernel_init_)
	{
		if (append_sourcefile_with_defs_) AppendSourcefile();
		build_options_ += user_build_options_;
		kernel_ = BuildKernel(*device_);
		kernel_init_ = true;
	}
	bind_counter_ = 0;
	UnpackThenBind(params...);
	cl::NDRange global_range = VectorToNDRange(GetGlobalRange_(sizes_));
	cl::NDRange local_range = VectorToNDRange(GetLocalRange_(sizes_));

	device_->queue().enqueueNDRangeKernel(kernel_, cl::NullRange, global_range, local_range);
	UnpackThenInvalidate(params...);
}

template<typename... Args>
cl::NDRange Kernel<Args...>::VectorToNDRange(const std::vector<size_t>& v)
{
	cl::NDRange range;
	switch (v.size()) {
	case 0:
		range = cl::NullRange;
		break;

	case 1:
		range = (v[0] == 0) ? cl::NullRange : cl::NDRange(v[0]);
		break;

	case 2:
		range = cl::NDRange(v[0], v[1]);
		break;

	case 3:
		range = cl::NDRange(v[0], v[1], v[2]);
		break;

	default:
		LOG(ERROR) << "Invalid range returned";
	}

	return range;
}

template<typename... Args>
template<typename T>
void Kernel<Args...>::ExamineArg(Buffer<T>& buffer)
{
	device_ = &buffer.device();
	sizes_.push_back(buffer.ndsize());
	if (bind_counter_ == 0)
	{
		build_options_ += " -D CLH_SIZES=1";
	}

	for (size_t i = 0; i < buffer.ndsize().size(); ++i)
	{
		char buf[256];
		sprintf(buf, " -D size_%s_%lu=%lu", kernel_variables_[bind_counter_].c_str(), i, buffer.size(i));
		build_options_ += buf;
	}

	char buf[256];
	switch (buffer.ndsize().size())
	{
	case 2:
		sprintf(buf, " -D ix_%s(x,y)=((y)*size_%s_0+(x))", kernel_variables_[bind_counter_].c_str(),
			kernel_variables_[bind_counter_].c_str());
		build_options_ += buf;
		break;

	case 3:
		char buf[256];
		sprintf(buf, " -D ix_%s(x,y,z)=((z)*size_%s_1*size_%s_0+(y)*size_%s_0+(x))",
			kernel_variables_[bind_counter_].c_str(),
			kernel_variables_[bind_counter_].c_str(),
			kernel_variables_[bind_counter_].c_str(),
			kernel_variables_[bind_counter_].c_str());
		build_options_ += buf;
		break;
	}
	++bind_counter_;
}

template<typename... Args>
template<typename T>
void Kernel<Args...>::ExamineArg(T var)
{
	// minden masra ott a mastercard
}

template<typename... Args>
template<typename T>
void Kernel<Args...>::BindArg(Buffer<T>& buffer)
{
	kernel_.setArg(bind_counter_, buffer.d_data());
	++bind_counter_;
}

template<typename... Args>
template<typename T>
void Kernel<Args...>::BindArg(T var)
{
	kernel_.setArg(bind_counter_, var);
	++bind_counter_;
}

template<typename... Args>
cl::Kernel Kernel<Args...>::BuildKernel(Device& device)
{
	std::ifstream file(filename_);
	std::string source(std::istreambuf_iterator<char>(file), (std::istreambuf_iterator<char>()));
	file.close();

#ifdef INTEL_LINUX_COMPATIBILITY
	source = GenerateSourceDefinitions() + source;
	build_options_ = "";
#endif

	cl::Program::Sources sor(1, std::make_pair(source.c_str(), source.length() + 1));

	cl::Program program(device.context(), sor);

	cl::STRING_CLASS build_log;

	LOG(INFO) << "Build started: " << filename_;
	auto bval = program.build({device.device()}, build_options_.c_str());
	if (CL_SUCCESS == bval)
	{
		LOG(INFO) << "Build: " << filename_ << " succeeded";
	}
	else
	{
		program.getBuildInfo(device.device(), (cl_program_build_info) CL_PROGRAM_BUILD_LOG, &build_log);
		LOG(ERROR) << "Build: " << filename_ << " failed";
		LOG(ERROR) << build_log;
	}

	std::vector<cl::Kernel> kernels;
	program.createKernels(&kernels);

	return kernels[0];
}

template<typename... Args>
template<typename T>
void Kernel<Args...>::Invalidate(Buffer<T>& buffer)
{
	buffer.InvalidateHost();
}

template<typename... Args>
template<typename T>
void Kernel<Args...>::Invalidate(T var)
{
	// mesterkartya
}

template<typename... Args>
void Kernel<Args...>::AppendSourceWithDefs(bool value)
{
	append_sourcefile_with_defs_ = value;
}

template<typename ...Args>
std::string Kernel<Args...>::GenerateSourceDefinitions()
{
	std::regex e("-D\\s+([\\(\\),a-zA-Z0-9_]+)=(\\S+)");
	std::smatch m;
	std::string s = build_options_;

	std::vector<std::string> defs;
	std::vector<std::string> obj_macros;
	std::vector<std::string> func_macros;

	while (std::regex_search(s, m, e))
	{
		std::string definition;
		definition += "#define\t\t";
		definition += m[1];
		definition += "\t\t";
		definition += m[2];
		defs.push_back(definition);

		s = m.suffix().str();
	}

	// sorting object and function like macros
	for (auto def : defs)
	{
		if (def.find("(") == std::string::npos) obj_macros.push_back(def);
		else func_macros.push_back(def);
	}

	std::string definitions;
	for (auto def : obj_macros)
	{
		definitions += def;
		definitions += "\n";
	}
	definitions += "\n";
	for (auto def : func_macros)
	{
		definitions += def;
		definitions += "\n";
	}
	definitions += "\n";

	return definitions;
}

template<typename... Args>
void Kernel<Args...>::AppendSourcefile()
{
	std::ifstream file(filename_);
	std::string source(std::istreambuf_iterator<char>(file), (std::istreambuf_iterator<char>()));
	file.close();

	LOG(INFO) << "Appending sourcefile " << filename_ << " with definitions";

	std::string definitions = GenerateSourceDefinitions();

	std::ofstream out(filename_);
	out << definitions + source;
	out.close();
}

template<typename... Args>
void Kernel<Args...>::AddDefinition(std::string definition)
{
	user_build_options_ += std::string(" -D ") + definition;
}

}

#endif
