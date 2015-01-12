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

#include <iostream>
#include <vector>
#include <cmath>
#include <memory>
#include <cstdint>

#include "../clh/clh.hpp"
#include "simulation.hpp"
#include "datafile.hpp"
#include "commandline.hpp"

typedef cl_float real;

_INITIALIZE_EASYLOGGINGPP
int main()
{
	Commandline cmd(std::cin);
	std::unique_ptr<Simulation> sim;

	// LIST DEVICES
	cmd.AddCommand("lsd", [&](const std::vector<std::string>& args)
	{
		auto device_desc = clh::PlatformManager::GetDevices();

		std::cout << "Available compute devices" << std::endl;

		int i = 0;
		for (auto device : device_desc)
		{
			std::cout << i++ << ". " << device.name() << std::endl;
		}
	}, {});

	// SELECT DEVICES
	std::vector<clh::Device> devices;
	cmd.AddCommand("sd", [&](const std::vector<std::string>& args)
	{
		auto device_desc = clh::PlatformManager::GetDevices();
		auto ix_list = Commandline::ToIntList(args[0]);

		for (auto ix : ix_list)
		{
			devices.push_back(clh::Device(device_desc[ix]));
			std::cout << device_desc[ix].name() << " added to active devices\n";
		}

		sim = std::unique_ptr<Simulation>(new Simulation(devices, 0.02f));
	}, {"int_list"});

	// SELECT DEVICES
	cmd.AddCommand("sdt", [&](const std::vector<std::string>& args)
	{
		if (args[0] == "cpu")
		{
			auto device_desc = clh::PlatformManager::GetDevices(CL_DEVICE_TYPE_CPU);
			devices.push_back(clh::Device(device_desc[0]));
			std::cout << device_desc[0].name() << " added to active devices\n";
			sim = std::unique_ptr<Simulation>(new Simulation(devices, 0.02f));
		}
		else if (args[0] == "gpu")
		{
			auto device_desc = clh::PlatformManager::GetDevices(CL_DEVICE_TYPE_GPU);
			devices.push_back(clh::Device(device_desc[0]));
			std::cout << device_desc[0].name() << " added to active devices\n";
			sim = std::unique_ptr<Simulation>(new Simulation(devices, 0.02f));
		}
		else
		{
			std::cout << "Valid command arguments are 'cpu' or 'gpu'\n";
		}
	}, {"string"});

	// CLEAR ACTIVE DEVICE LIST
	cmd.AddCommand("cd", [&](const std::vector<std::string>& args)
	{
		std::cout << "Compute devices removed\n";
		devices.clear();
	}, {});

	cmd.AddCommand("load", [&](const std::vector<std::string>& args)
	{
		sim->Load(args[0]);
	}, {"file"});

	cmd.AddCommand("addsource", [&](const std::vector<std::string>& args)
	{
		sim->AddSource(Commandline::ToFloatList(args[0]), df::Load<real>(args[1]).vdata());
	}, {"float_list", "file"});

	cmd.AddCommand("addmic", [&](const std::vector<std::string>& args)
	{
		sim->AddMic(Commandline::ToFloatList(args[0]));
	}, {"float_list"});

	cmd.AddCommand("vis", [&](const std::vector<std::string>& args)
	{
		sim->AddVisualization(Commandline::ToFloat(args[0]));
	}, {"float"});

	//const int fs = 29593;
	const int fs = 32000;
	cmd.AddCommand("run", [&](const std::vector<std::string>& args)
	{
		sim->Run((int)(Commandline::ToFloat(args[0])*(real)fs));
	}, {"float"});

	cmd.AddCommand("save", [&](const std::vector<std::string>& args)
	{
		df::Save(sim->mics(), args[0]);
	}, {"string"});

	cmd.AddCommand("minsize", [&](const std::vector<std::string>& args)
	{
		auto sizes = Commandline::ToFloatList(args[0]);
		sim->SetMinSize(sizes[0], sizes[1], sizes[2]);
	}, {"float_list"});

	cmd.AddCommand("pml", [&](const std::vector<std::string>& args)
	{
		sim->SetPml(Commandline::ToInt(args[0]));
	}, {"int"});

	cmd.Run();

	return EXIT_SUCCESS;
}
