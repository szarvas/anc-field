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

#ifndef VISUALIZATION_HPP
#define VISUALIZATION_HPP

#include "clh.hpp"

#include <GLFW/glfw3.h>
#include <iostream>
#include <thread>
#include <cmath>

namespace Visualization_H
{
	size_t NextPowerOf2(size_t n)
	{
		size_t power_of_two = 1;
		while (power_of_two < n)
		{
			power_of_two <<= 1;
		}

		return power_of_two;
	}

	// Matlab color scale
	inline
	void IntensityToColor(float& b, float& g, float& r, float v, float floor, float ceil)
	{
		v = (v-floor)/(ceil-floor);
		if (v < 0.0f) v = 0.0f;
		if (v > 1.0f) v = 1.0f;

		const float darklevel = 0.6f;
		const float limiters[4] = {0.2f, 0.3667f, 0.6333f, 0.8f};

		if (v <= limiters[0])
		{
			r = 0.0f;
			g = 0.0f;
			b = darklevel + (1.0f-darklevel) * v/limiters[0];
		}
		else if (v <= limiters[1])
		{
			r = 0.0f;
			g = (v-limiters[0]) / (limiters[1]-limiters[0]);
			b = 1.0f;
		}
		else if (v <= limiters[2])
		{
			r = (v-limiters[1]) / (limiters[2]-limiters[1]);
			g = 1.0f;
			b = 1.0f - (v-limiters[1]) / (limiters[2]-limiters[1]) ;
		}
		else if (v <= limiters[3])
		{
			r = 1.0f;
			g = 1.0f - (v-limiters[2]) / (limiters[3]-limiters[2]);
			b = 0.0f;
		}
		else
		{
			r = 1.0f - 0.5f * (v-limiters[3]) / (1.0f-limiters[3]);
			g = 0.0f;
			b = 0.0f;
		}
	}
}

class Visualization {
public:
			Visualization		(clh::Buffer<float>&);
			~Visualization		();
	void	Stop				();
	void	SetOverlay			(clh::Buffer<unsigned>&);

private:
	void	Run					();
	void	Draw				();
	void	RenderLoop			();
	void	RenderField			(float*);
	size_t	ix					(size_t x, size_t y, size_t z);

	clh::Buffer<float>&		field_;
	GLFWwindow*				window_;
	std::thread				window_thread_;
	GLuint					colormap_pbo;
	GLuint					colormap_texture;
	size_t					buffer_width_;
	size_t					buffer_height_;
	size_t					texture_width_;
	size_t					texture_height_;
	int						window_width_, window_height_;
	bool					valid_;
	float					proj_offset_x_, proj_offset_y_;

	clh::Buffer<unsigned>*	image_overlay_;
};

void Visualization::SetOverlay(clh::Buffer<unsigned>& overlay) {
	image_overlay_ = &overlay;
}

Visualization::Visualization(clh::Buffer<float>& field) : field_(field)
{
	// OpenGL texture dimensions must be a power of 2
	texture_width_  = Visualization_H::NextPowerOf2( field_.sizes()[0] );
	texture_height_ = Visualization_H::NextPowerOf2( field_.sizes()[1] );

	window_width_  = 512;
	window_height_ = 512;

	buffer_width_  = field.sizes()[0];
	buffer_height_ = field.sizes()[1];

	proj_offset_x_ = 0.0f;
	proj_offset_y_ = 0.0f;

	if (texture_height_ > buffer_height_) {
		proj_offset_y_ = 1.0f - (float)buffer_height_/(float)texture_height_;
	}

	if (texture_width_ > buffer_width_) {
		proj_offset_x_ = 1.0f - (float)buffer_width_/(float)texture_width_;
	}

	image_overlay_ = NULL;
	valid_ = true;
	window_thread_ = std::thread(&Visualization::Run, this);
}

Visualization::~Visualization()
{
	window_thread_.join();
}

void Visualization::Stop()
{
	valid_ = false;
}

void Visualization::Run()
{
	if (!glfwInit())
	{
		std::cout << "Error initializing GLFW" << std::endl;
	}

	/* Create a windowed mode window and its OpenGL context */
	window_ = glfwCreateWindow(window_width_, window_height_, "Pressure field visualization", NULL, NULL);
	if (!window_)
	{
		glfwTerminate();
		std::cout << "Error creating GLFW window" << std::endl;
	}

	glfwMakeContextCurrent(window_);

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glViewport(0, 0, 128, 128);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(proj_offset_x_, 1.0f, proj_offset_y_, 1.0f, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	GLenum glew_init_result;
	glew_init_result = glewInit();

	if (GLEW_OK != glew_init_result)
	{
		fprintf(stderr, "ERROR: %s\n", glewGetErrorString(glew_init_result));
		exit(EXIT_FAILURE);
	}

	glGenBuffers(1, &colormap_pbo);
	glBindBuffer(GL_PIXEL_UNPACK_BUFFER, colormap_pbo);
	glBufferData(GL_PIXEL_UNPACK_BUFFER, texture_width_*texture_height_*4*sizeof(float), 0, GL_STREAM_DRAW_ARB);

	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &colormap_texture);
	glBindTexture(GL_TEXTURE_2D, colormap_texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, texture_width_, texture_height_, 0, GL_RGBA, GL_FLOAT, NULL);

	while(!glfwWindowShouldClose(window_) && valid_)
	{
		glfwGetWindowSize(window_, &window_width_, &window_height_);

		window_height_ = (int) ( (float)window_width_ * ((float)buffer_height_/(float)buffer_width_) );

		glfwSetWindowSize(window_, window_width_, window_height_);

		glViewport(0, 0, window_width_, window_height_);
		Draw();
		glfwPollEvents();
		Sleep(20);
	}

	glfwTerminate();
}

void
Visualization::Draw()
{
	glClear(GL_COLOR_BUFFER_BIT);

	float* ptr = (float*)glMapBuffer(GL_PIXEL_UNPACK_BUFFER, GL_WRITE_ONLY);

	if (ptr)
	{
		RenderField(ptr);
	}

	glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER); // release the mapped buffer

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, colormap_texture);
	glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, colormap_pbo);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texture_width_, texture_height_, GL_BGRA, GL_FLOAT, 0);

	glBegin(GL_QUADS);
		glTexCoord2f(0, 1.0f);
		glVertex3f(0, 0, 0);
		glTexCoord2f(0, 0);
		glVertex3f(0, 1.0f, 0);
		glTexCoord2f(1.0f, 0);
		glVertex3f(1.0f, 1.0f, 0);
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(1.0f, 0, 0);
	glEnd();

	glfwSwapBuffers(window_);
}

void
Visualization::RenderField(float* target)
{
	float f = 0.0f;
	for (unsigned i = 0; i < buffer_width_; i++)
	{
		for (unsigned j = 0; j < buffer_height_; j++)
		{
			Visualization_H::IntensityToColor(
				target[j*texture_width_*4+i*4  ],
				target[j*texture_width_*4+i*4+1],
				target[j*texture_width_*4+i*4+2],
				field_.h_data_array()[j*buffer_width_+i],
				-2.0f,
				2.0f
			);
		}
	}

	if (image_overlay_ != NULL) {
		for (unsigned i = 0; i < buffer_width_; i++)
		{
			for (unsigned j = 0; j < buffer_height_; j++)
			{
				if (image_overlay_->Get(j*buffer_width_+i) != 0) {
					target[j*texture_width_*4+i*4  ] = ((float) image_overlay_->Get(j*buffer_width_+i)) / 5.0f;
					target[j*texture_width_*4+i*4+1] = ((float) image_overlay_->Get(j*buffer_width_+i)) / 5.0f;
					target[j*texture_width_*4+i*4+2] = ((float) image_overlay_->Get(j*buffer_width_+i)) / 5.0f;
				}
			}
		}
	}

}

#endif
