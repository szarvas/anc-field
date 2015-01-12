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

#ifndef TIMING_HPP
#define TIMING_HPP

#include <iostream>
#include <chrono>

#ifdef TIMING
#define INIT_TIMER auto start = std::chrono::high_resolution_clock::now()
#define START_TIMER  start = std::chrono::high_resolution_clock::now()
//#define STOP_TIMER(name)  std::cout << "RUNTIME of " << name << ": " << \
//    std::chrono::duration_cast<std::chrono::milliseconds>( \
//            std::chrono::high_resolution_clock::now()-start \
//    ).count() << " ms " << std::endl;
#define STOP_TIMER  std::chrono::duration_cast<std::chrono::milliseconds>( \
            std::chrono::high_resolution_clock::now()-start \
    ).count()
#else
#define INIT_TIMER
#define START_TIMER
#define STOP_TIMER(name)
#endif

#endif