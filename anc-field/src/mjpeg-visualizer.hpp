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

#ifndef MJPEG_VISUALIZER_HPP
#define MJPEG_VISUALIZER_HPP

#include <thread>
#include <vector>
#include <memory>

#include "../clh/clh.hpp"
#include "image.hpp"
#include "mjpeg-handler.hpp"
#include "libjpeg-turbo/turbojpeg.h"

#include "easylogging.hpp"

class MjpegVisualizer
{
public:
			MjpegVisualizer	(const clh::Vector<float>&, unsigned);
			~MjpegVisualizer() { dont_stop_ = false; draw_thread_.join(); }
	void	Stop			() { dont_stop_ = false; }
	void	SetOverlay		(clh::Vector<int> overlay) { image_overlay_ = overlay; }
	MjpegHandler handler_;

private:
	void Run();
	const unsigned kColors = 3;
	const unsigned kJpegQuality = 75;
	const unsigned kFrameDelay = 30;

	const clh::Vector<float>& field_;
	bool dont_stop_;
	std::thread draw_thread_;
	std::vector<unsigned char> image_;
	unsigned width_, height_;
	clh::Vector<int> image_overlay_;
	std::unique_ptr<CivetServer> server_;
};

MjpegVisualizer::MjpegVisualizer(const clh::Vector<float>& field, unsigned port)
	: field_{ field }, image_overlay_{ NULL }
{
	char buf[128];
	sprintf(buf, "%d", port);
	const char* options[3] {"listening_ports", "1440", 0};
	options[1] = buf;

	server_ = std::unique_ptr<CivetServer>(new CivetServer(options));

	width_ = field.size(0);
	height_ = field.size(1);
	image_ = std::vector<unsigned char>(width_ * height_ * kColors);

	(*server_).addHandler("/live", &handler_);

	LOG(INFO) << "Visualization server is listening on port " << port;

	dont_stop_ = true;
	draw_thread_ = std::thread(&MjpegVisualizer::Run, this);
}

void MjpegVisualizer::Run()
{
	float r, g, b;
	long unsigned int jpeg_size = 500000;
	unsigned char* compressed_image = tjAlloc(jpeg_size);
	tjhandle jpeg_compressor = tjInitCompress();

	while (dont_stop_)
	{
		if (handler_.IsConnected())
		{
			for (unsigned i = 0; i < width_; i++)
			{
				for (unsigned j = 0; j < height_; j++)
				{
					Image::IntensityToColor(r, g, b, field_.data()[j*width_ + i], -0.02f, 0.02f);
					image_[j*width_*kColors + i*kColors] = Image::Saturate(r);
					image_[j*width_*kColors + i*kColors + 1] = Image::Saturate(g);
					image_[j*width_*kColors + i*kColors + 2] = Image::Saturate(b);
				}
			}

			if (image_overlay_.size() > 0) {
				for (unsigned i = 0; i < width_; i++)
				{
					for (unsigned j = 0; j < height_; j++)
					{
						if (image_overlay_.at(j*width_ + i) != 0) {
							image_[j*width_*kColors + i*kColors] = 10 + 20 * image_overlay_.at(j*width_ + i);
							image_[j*width_*kColors + i*kColors + 1] = 10 + 20 * image_overlay_.at(j*width_ + i);
							image_[j*width_*kColors + i*kColors + 2] = 10 + 20 * image_overlay_.at(j*width_ + i);
						}
					}
				}
			}

			if (tjCompress2(jpeg_compressor, image_.data(), width_, 0, height_, TJPF_RGB, &compressed_image,
				&jpeg_size, TJSAMP_444, kJpegQuality, TJFLAG_FASTDCT) != 0)
			{
				LOG(ERROR) << "tjCompress2: " << tjGetErrorStr();
			}
			handler_.SendImage(compressed_image, jpeg_size);
		}

#ifdef _WIN32
		Sleep(kFrameDelay);
#else
		usleep(kFrameDelay*1000);
#endif
	}
	tjDestroy(jpeg_compressor);
	tjFree(compressed_image);

	handler_.Stop();
	(*server_).removeHandler("/live");
	(*server_).close();
}

#endif
