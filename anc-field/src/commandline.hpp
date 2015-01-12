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

#ifndef COMMANDLINE_HPP
#define COMMANDLINE_HPP

#include <iostream>
#include <functional>
#include <unordered_map>
#include <vector>
#include <string>
#include <algorithm>

class Commandline
{
typedef std::function<void(const std::vector<std::string>&)> command_t;

public:
	Commandline(std::istream& in) : in_{in} {}

	static int ToInt(const std::string& token)
	{
		size_t wat;
		int result = std::stoi(token, &wat);

		if (wat < token.size())
		{
			throw std::invalid_argument("nope");
		}

		return result;
	}

	static float ToFloat(const std::string& token)
	{
		size_t wat;
		float result = std::stof(token, &wat);

		if (wat < token.size())
		{
			throw std::invalid_argument("nope");
		}

		return result;
	}

	static std::vector<int> ToIntList(const std::string& token)
	{
		std::string s,s2;
		std::remove_copy(token.begin(), token.end(), std::back_inserter(s), '[');
		std::remove_copy(s.begin(), s.end(), std::back_inserter(s2), ']');
		auto numbers = Util::split(s2, ',');

		std::vector<int> result;
		for (auto n : numbers)
		{
			size_t wat;
			float i_n = std::stoi(n, &wat);
			result.push_back(i_n);

			if (wat < n.size())
			{
				throw std::invalid_argument("nope");
			}
		}

		return result;
	}

	static std::vector<cl_float> ToFloatList(const std::string& token)
	{
		std::string s,s2;
		std::remove_copy(token.begin(), token.end(), std::back_inserter(s), '[');
		std::remove_copy(s.begin(), s.end(), std::back_inserter(s2), ']');
		auto numbers = Util::split(s2, ',');

		std::vector<cl_float> result;
		for (auto n : numbers)
		{
			size_t wat;
			float i_n = std::stof(n, &wat);
			result.push_back(i_n);

			if (wat < n.size())
			{
				throw std::invalid_argument("nope");
			}
		}

		return result;
	}

	void AddCommand(std::string command, command_t handler, std::vector<std::string> types)
	{
		commands_[command] = std::make_pair(handler, types);
	}

	void Run()
	{
		dont_stop_ = true;

		while(dont_stop_)
		{
			std::cout << ">> ";
			std::string line;
			getline(in_, line);
			std::istringstream iss(line);
			std::vector<std::string> tokens{std::istream_iterator<std::string>{iss},
				std::istream_iterator<std::string>{}};

			if (tokens.size() != 0 && tokens[0] == "quit")
			{
				dont_stop_ = false;
			}
			else if (tokens.size() != 0)
			{
				if (commands_.find(tokens[0]) != commands_.end())
				{
					std::vector<std::string> args(tokens.begin()+1, tokens.end());
					auto& f = commands_[tokens[0]].first;
					auto& types = commands_[tokens[0]].second;

					if (args.size() == types.size())
					{
						bool args_ok = true;
						for (size_t i = 0; i < args.size(); ++i)
						{
							try
							{
								if (types[i] == "int")
								{
									ToInt(args[i]);
								}
								else if(types[i] == "float")
								{
									ToFloat(args[i]);
								}
								else if(types[i] == "file")
								{
									if (!std::ifstream(args[i]))
									{
										throw std::range_error("nope");
									}
								}
								else if(types[i] == "int_list")
								{
									ToIntList(args[i]);
								}
								else if(types[i] == "float_list")
								{
									ToFloatList(args[i]);
								}
							}
							catch (std::invalid_argument e)
							{
								std::cout << "Error: argument[" << i << "] should be a(n) " << types[i] << "\n";
								args_ok = false;
							}
							catch (std::range_error e)
							{
								std::cout << "Error: file " << args[i] << " doesn't exist\n";
								args_ok = false;
							}
						}

						if (args_ok)
						{
							f(args);
						}
					}
					else
					{
						std::cout << "Error: command " << tokens[0] << " takes " << types.size() << " argument(s)\n";
					}
				}
				else
				{
					std::cout << "Error: unrecognized command\n";
				}
			}
		}
	}

private:
	std::istream& in_;
	std::unordered_map<std::string, std::pair<command_t, std::vector<std::string>>> commands_;
	bool dont_stop_;
};

#endif
