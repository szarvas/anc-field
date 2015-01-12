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

#ifndef SIMULATION_HPP
#define SIMULATION_HPP

typedef cl_float real;

#include <memory>
#include <cmath>

#include "../clh/clh.hpp"
#include "kerkythea.hpp"
#include "lrs-data.hpp"
#include "mjpeg-visualizer.hpp"
#include "datafile.hpp"

#define TIMING
#include "timing.hpp"

auto GetLeapfrogGlobalSize = [](const std::vector< std::vector<size_t> >& sizes) {
	return sizes[0];
};

auto GetLrsGlobalSize = [](const std::vector< std::vector<size_t> >& sizes) {
	std::vector<size_t> v {sizes[3][1]};
	return v;
};

auto GetSourceGlobalSize = [](const std::vector< std::vector<size_t> >& sizes) {
	std::vector<size_t> v {sizes[2][1]};
	return v;
};

auto GetCopyGlobalSize = [](const std::vector< std::vector<size_t> >& sizes) {
	return sizes[1];
};

// p_p1, p, p_d1, pos, a, b, buf_in, buf_out, l, ix_buf
typedef clh::Kernel< clh::Buffer<real>&,clh::Buffer<real>&,clh::Buffer<real>&,clh::Buffer<int32_t>&,
	clh::Buffer<real>&, clh::Buffer<real>&,clh::Buffer<real>&,clh::Buffer<real>&,real,cl_uint > lrs_kernel_t;
typedef clh::Kernel<clh::Buffer<real>&, clh::Buffer<real>&,clh::Buffer<real>&, real> leapfrog_kernel_t;
typedef clh::Kernel<clh::Buffer<real>&,clh::Buffer<real>&,cl_int> copy_kernel_t;
typedef clh::Kernel<clh::Buffer<real>&, clh::Buffer<int>&, clh::Buffer<real>&,cl_int> source_kernel_t;
typedef clh::Kernel<clh::Buffer<real>&, clh::Buffer<int>&, clh::Buffer<real>&,cl_int> mic_kernel_t;

//p, pm1, pm2, fi_x, fi_xm1,fi_y,fi_ym1,fi_z,fi_zm1,psiph,psimh,ksi_x,ksi_y,ksi_z,c,dx,dt
typedef clh::Kernel<
	clh::Buffer<real>&, // p_p1
	clh::Buffer<real>&, // p
	clh::Buffer<real>&, // p_m1
	clh::Buffer<real>&, // fi_x
	clh::Buffer<real>&, // fi_x_m1
	clh::Buffer<real>&, // fi_y
	clh::Buffer<real>&, // fi_y_m1
	clh::Buffer<real>&, // fi_z
	clh::Buffer<real>&, // fi_z_m1
	clh::Buffer<real>&, // psi_ph
	clh::Buffer<real>&, // psi_mh
	clh::Buffer<real>&, // ksi_x
	clh::Buffer<real>&, // ksi_y
	clh::Buffer<real>&, // ksi_z
	real,				// c
	real,				// dx
	real,				// dt
	cl_int				// PML_LENGTH
> pml_kernel_t;

class Simulation
{
public:
										Simulation(std::vector<clh::Device> devices, real res);
	void								AddVisualization(real level);
	void								Load(const std::string& path_to_file);
	void								Run(int steps);
	void								AddSource(std::vector<real> pos, std::vector<real> source);
	void								AddMic(std::vector<real> pos);
	void								SetMinSize(cl_float x, cl_float y, cl_float z);
	void								SetPml(cl_int width);
	clh::Buffer<real>&					p() { return *p_[0];}
	clh::Vector<real>&					mics() { mics_->Sync(true); return mics_->h_data(); }

private:
	static const std::vector<std::string> kSurfaceTpyes;

	std::vector<clh::Device>			devices_;
	real								res_;

	std::vector<clh::Buffer<real>>		p_data_;
	std::vector<clh::Buffer<real>*>		p_;

	std::vector<clh::Buffer<real>>		fi_x_data_;
	std::vector<clh::Buffer<real>*>		fi_x_;
	std::vector<clh::Buffer<real>>		fi_y_data_;
	std::vector<clh::Buffer<real>*>		fi_y_;
	std::vector<clh::Buffer<real>>		fi_z_data_;
	std::vector<clh::Buffer<real>*>		fi_z_;

	std::vector<clh::Buffer<real>>		psi_data_;
	std::vector<clh::Buffer<real>*>		psi_;

	std::unique_ptr<clh::Buffer<real>>	ksi_x_;
	std::unique_ptr<clh::Buffer<real>>	ksi_y_;
	std::unique_ptr<clh::Buffer<real>>	ksi_z_;

	std::unique_ptr<Kerkythea<real>>	scene_;
	std::unique_ptr<LrsData<real>>		surfaces_;
	std::unique_ptr<clh::Buffer<real>>	a_;
	std::unique_ptr<clh::Buffer<real>>	b_;

	std::unique_ptr<clh::Buffer<real>>	cross_section_;

	std::unique_ptr<leapfrog_kernel_t>	LeapfrogKernel_;
	std::unique_ptr<source_kernel_t>	SourceKernel_;
	std::unique_ptr<mic_kernel_t>		MicKernel_;
	std::unique_ptr<copy_kernel_t>		CopyKernel_;
	std::unique_ptr<pml_kernel_t>		PmlKernel_;
	std::vector<lrs_kernel_t>			lrs_kernels_;

	std::unique_ptr<MjpegVisualizer> 	visualizer_;
	cl_uint								level_;

	std::unique_ptr<clh::Buffer<real>>	sources_;
	std::unique_ptr<clh::Buffer<cl_int>> pos_sources_;

	cl_uint								ix_buf_;
	cl_uint								sim_cnt_;

	std::unique_ptr<clh::Buffer<real>>	mics_;
	std::unique_ptr<clh::Buffer<cl_int>> pos_mics_;

	void								CheckVariables(const int steps);

	std::string							self_location_;

	size_t								size_x_, size_y_, size_z_;
	cl_int								pml_width_;

	real								lambda2_, c_, dx_, dt_;
	bool								init_;
	void								Init();
};

Simulation::Simulation(std::vector<clh::Device> devices, real res)
	: devices_{devices}, res_{res}, size_x_{0}, size_y_{0}, size_z_{0}
{
	//lambda2_ = 0.3f;
	c_ = 340.0f;
	dx_ = 0.02f;
	//dt_ = sqrt(lambda2_)*dx_/c_;
	dt_ = (real)3.125E-05;
	lambda2_ = (dt_ * c_ / dx_) * (dt_ * c_ / dx_);
	pml_width_ = 0;
	auto wloc = clh::GetSelfLocation();
	self_location_ = std::string(wloc.begin(), wloc.end());
	init_ = false;
}

void Simulation::Load(const std::string& path_to_file)
{
	scene_ = decltype(scene_)(new Kerkythea<real>(path_to_file, res_));
	surfaces_ = decltype(surfaces_)(new LrsData<real>(devices_[0], scene_->volume_data(), scene_->coef_a().size(0)));
	a_ = decltype(a_)(new clh::Buffer<real>(devices_[0], scene_->coef_a()));
	b_ = decltype(b_)(new clh::Buffer<real>(devices_[0], scene_->coef_b()));

	size_x_ = size_x_ < scene_->volume_data().size(0) ? scene_->volume_data().size(0) : size_x_;
	size_y_ = size_y_ < scene_->volume_data().size(1) ? scene_->volume_data().size(1) : size_y_;
	size_z_ = size_z_ < scene_->volume_data().size(2) ? scene_->volume_data().size(2) : size_z_;

	lrs_kernels_.clear();
	for (size_t i = X_P; i <= Z_M; ++i) {
		lrs_kernels_.push_back(lrs_kernel_t(self_location_+"/lrs_1.cl", GetLrsGlobalSize, clh::GetZeroSize));
		lrs_kernels_[i].AddDefinition(kSurfaceTpyes[i]);
	}

	for (size_t i = X_P_Y_P; i <= Y_M_Z_M; ++i) {
		lrs_kernels_.push_back(lrs_kernel_t(self_location_+"/lrs_2.cl", GetLrsGlobalSize, clh::GetZeroSize));
		lrs_kernels_[i].AddDefinition(kSurfaceTpyes[i]);
	}

	for (size_t i = X_P_Y_P_Z_P; i <= X_M_Y_M_Z_M; ++i) {
		lrs_kernels_.push_back(lrs_kernel_t(self_location_+"/lrs_3.cl", GetLrsGlobalSize, clh::GetZeroSize));
		lrs_kernels_[i].AddDefinition(kSurfaceTpyes[i]);
	}
}

void Simulation::Init()
{
	p_data_.clear();
	p_.clear();
	for (int i = 0; i < 3; ++i)
	{
		p_data_.push_back(clh::Buffer<real>(devices_[0], {size_x_, size_y_, size_z_}));
	}

	for (int i = 0; i < 3; ++i)
	{
		p_.push_back(&p_data_[i]);
	}

	LeapfrogKernel_ = decltype(LeapfrogKernel_)(new leapfrog_kernel_t(self_location_+"/leapfrog.cl", GetLeapfrogGlobalSize,
		clh::GetZeroSize));

	SourceKernel_ = decltype(SourceKernel_)(new source_kernel_t(self_location_+"/source.cl", GetSourceGlobalSize,
		clh::GetZeroSize));

	MicKernel_ = decltype(MicKernel_)(new mic_kernel_t(self_location_+"/mic.cl", GetSourceGlobalSize,
		clh::GetZeroSize));

	PmlKernel_ = decltype(PmlKernel_)(new pml_kernel_t(self_location_+"/pml.cl", GetLeapfrogGlobalSize,
		clh::GetZeroSize));

	CopyKernel_ = decltype(CopyKernel_)(new copy_kernel_t(self_location_+"/copy_plane.cl", GetCopyGlobalSize, clh::GetZeroSize));

	ix_buf_ = 0;
	sim_cnt_ = 0;
}

void Simulation::SetPml(cl_int width)
{
	pml_width_ = width;

	fi_x_data_.clear();
	fi_x_.clear();
	fi_y_data_.clear();
	fi_y_.clear();
	fi_z_data_.clear();
	fi_z_.clear();

	psi_data_.clear();
	psi_.clear();

	for (int i = 0; i < 2; ++i)
	{
		fi_x_data_.push_back(clh::Buffer<real>(devices_[0], {size_x_, size_y_, size_z_}));
		fi_y_data_.push_back(clh::Buffer<real>(devices_[0], {size_x_, size_y_, size_z_}));
		fi_z_data_.push_back(clh::Buffer<real>(devices_[0], {size_x_, size_y_, size_z_}));
		psi_data_.push_back(clh::Buffer<real>(devices_[0], {size_x_, size_y_, size_z_}));
	}

	for (int i = 0; i < 2; ++i)
	{
		fi_x_.push_back(&fi_x_data_[i]);
		fi_y_.push_back(&fi_y_data_[i]);
		fi_z_.push_back(&fi_z_data_[i]);
		psi_.push_back(&psi_data_[i]);
	}

	auto ksi_profile = df::Load<real>(self_location_+"/ksi_profile_32.dat");
	ksi_x_ = decltype(ksi_x_)(new clh::Buffer<real>(devices_[0], size_x_));
	ksi_y_ = decltype(ksi_y_)(new clh::Buffer<real>(devices_[0], size_y_));
	ksi_z_ = decltype(ksi_z_)(new clh::Buffer<real>(devices_[0], size_z_));

	for (int i = 0; i < ksi_profile.size(); ++i)
	{
		ksi_x_->Set(i, ksi_profile[ksi_profile.size()-1-i]);
		ksi_x_->Set(ksi_x_->size()-i-1, ksi_profile[ksi_profile.size()-1-i]);
		ksi_y_->Set(i, ksi_profile[ksi_profile.size()-1-i]);
		ksi_y_->Set(ksi_y_->size()-i-1, ksi_profile[ksi_profile.size()-1-i]);
		ksi_z_->Set(i, ksi_profile[ksi_profile.size()-1-i]);
		ksi_z_->Set(ksi_z_->size()-i-1, ksi_profile[ksi_profile.size()-1-i]);
	}
}

void Simulation::SetMinSize(real x, real y, real z)
{
	size_x_ = Util::RoundTo((size_t) (x / res_) + 1, 32);
	size_y_ = Util::RoundTo((size_t) (y / res_) + 1, 32);
	size_z_ = Util::RoundTo((size_t) (z / res_) + 1, 32);
}

void Simulation::AddVisualization(real level)
{
	cross_section_ = decltype(cross_section_)(new clh::Buffer<real>(devices_[0], {size_x_, size_z_}));
	visualizer_ = decltype(visualizer_)(new MjpegVisualizer(cross_section_->h_data(), 1440));

	if (scene_.get() != nullptr)
	{
		clh::Vector<cl_int> image_overlay({scene_->volume_data().size(0), scene_->volume_data().size(2)}, 0);
		for (size_t j = 0; j < scene_->volume_data().size(2); ++j)
		{
			for (size_t i = 0; i < scene_->volume_data().size(0); ++i)
			{
				if (scene_->volume_data()[{i,(size_t)(level/res_),j}] > -1)
				{
					image_overlay[{i,j}] = scene_->volume_data()[{i,(size_t)(level/res_),j}] + 1;
				}
			}
		}
		visualizer_->SetOverlay(image_overlay);
	}
	level_ = (cl_uint)(level/res_);
}

void Simulation::AddSource(std::vector<real> pos, std::vector<real> source)
{
	if (sources_.get() == nullptr)
	{
		sources_ = decltype(sources_)(new clh::Buffer<real>(devices_[0], {source.size(), 0}));
	}
	sources_->push_back(source);

	if (pos_sources_.get() == nullptr)
	{
		pos_sources_ = decltype(pos_sources_)(new clh::Buffer<cl_int>(devices_[0], {pos.size(), 0}));
	}

	std::vector<cl_int> ix_pos {(cl_int)(pos[0] / res_), (cl_int)(pos[1] / res_), (cl_int)(pos[2] / res_)};
	pos_sources_->push_back(ix_pos);
}

void Simulation::AddMic(std::vector<real> pos)
{
	if (mics_.get() == nullptr)
	{
		mics_ = decltype(mics_)(new clh::Buffer<real>(devices_[0]));
	}

	if (pos_mics_.get() == nullptr)
	{
		pos_mics_ = decltype(pos_mics_)(new clh::Buffer<cl_int>(devices_[0], {pos.size(), 0}));
	}

	std::vector<cl_int> ix_pos {(cl_int)(pos[0] / res_), (cl_int)(pos[1] / res_), (cl_int)(pos[2] / res_)};
	pos_mics_->push_back(ix_pos);
}

void Simulation::Run(int steps)
{
	if (!init_)
	{
		Init();
		init_ = true;
	}

	if (cross_section_.get() != nullptr)
	{
		while(!visualizer_->handler_.IsConnected()) {
			Sleep(1);
		}
	}

	CheckVariables(steps);
	for (int i = 0; i < steps; ++i)
	{
		std::rotate(p_.begin(), p_.begin() + 2, p_.end());
		(*LeapfrogKernel_)(*p_[0], *p_[1], *p_[2], lambda2_);

		if (lrs_kernels_.size() != 0)
		{
			if (ix_buf_ == 0) ix_buf_ = surfaces_->buf_in(X_P).size(0)-1; else ix_buf_ -= 1;
			for (int j = X_P; j <= X_M_Y_M_Z_M; ++j)
			{
				lrs_kernels_[j](*p_[0], *p_[1], *p_[2], surfaces_->pos(j), *a_, *b_, surfaces_->buf_in(j),
					surfaces_->buf_out(j), lambda2_, ix_buf_);
			}
		}

		if (pml_width_ != 0)
		{
			std::rotate(fi_x_.begin(), fi_x_.begin() + 1, fi_x_.end());
			std::rotate(fi_y_.begin(), fi_y_.begin() + 1, fi_y_.end());
			std::rotate(fi_z_.begin(), fi_z_.begin() + 1, fi_z_.end());
			std::rotate(psi_.begin(), psi_.begin() + 1, psi_.end());

			(*PmlKernel_)(*p_[0], *p_[1], *p_[2], *fi_x_[0], *fi_x_[1], *fi_y_[0], *fi_y_[1], *fi_z_[0], *fi_z_[1],
				*psi_[0], *psi_[1], *ksi_x_, *ksi_y_, *ksi_z_, c_, dx_, dt_, pml_width_);
		}

		if (sources_.get() != nullptr)
		{
			(*SourceKernel_)(*p_[0], *pos_sources_, *sources_, sim_cnt_ + i);
		}

		if (mics_.get() != nullptr)
		{
			(*MicKernel_)(*p_[0], *pos_mics_, *mics_, sim_cnt_ + i);
		}

		if (cross_section_.get() != nullptr)
		{
			if (i%3 == 0)
			{
				(*CopyKernel_)(*p_[0], *cross_section_, level_);
				cross_section_->Sync();
			}
		}

		if (i == 0) std::cout << "BEGIN" << std::endl;

		if (i % 200 == 0)
		{
			devices_[0].queue().finish();
			std::cout << i << "/" << steps << std::endl;
		}

		if (pml_width_ != 0 && i % 8000 == 0)
		{
			std::fill((*fi_x_[0]).h_data().vdata().begin(), (*fi_x_[0]).h_data().vdata().end(), 0.0f);
			std::fill((*fi_x_[1]).h_data().vdata().begin(), (*fi_x_[1]).h_data().vdata().end(), 0.0f);
			std::fill((*fi_y_[0]).h_data().vdata().begin(), (*fi_y_[0]).h_data().vdata().end(), 0.0f);
			std::fill((*fi_y_[1]).h_data().vdata().begin(), (*fi_y_[1]).h_data().vdata().end(), 0.0f);
			std::fill((*fi_z_[0]).h_data().vdata().begin(), (*fi_z_[0]).h_data().vdata().end(), 0.0f);
			std::fill((*fi_z_[1]).h_data().vdata().begin(), (*fi_z_[1]).h_data().vdata().end(), 0.0f);
			std::fill((*psi_[0]).h_data().vdata().begin(), (*psi_[0]).h_data().vdata().end(), 0.0f);
			std::fill((*psi_[1]).h_data().vdata().begin(), (*psi_[1]).h_data().vdata().end(), 0.0f);

			(*fi_x_[0]).InvalidateDevice();
			(*fi_x_[1]).InvalidateDevice();
			(*fi_y_[0]).InvalidateDevice();
			(*fi_y_[1]).InvalidateDevice();
			(*fi_z_[0]).InvalidateDevice();
			(*fi_z_[1]).InvalidateDevice();
			(*psi_[0]).InvalidateDevice();
			(*psi_[1]).InvalidateDevice();
		}
	}
	sim_cnt_ += steps;
	std::cout << steps << "/" << steps << std::endl;
}

void Simulation::CheckVariables(const int steps)
{
	if (sources_.get() != nullptr && sources_->size(0) < sim_cnt_ + steps)
	{
		sources_->resize({sim_cnt_ + steps, sources_->size(1)});
	}

	if (mics_.get() != nullptr && mics_->size(0) < sim_cnt_ + steps)
	{
		mics_->resize({sim_cnt_ + steps, pos_mics_->size(1)});
	}
}

decltype(Simulation::kSurfaceTpyes) Simulation::kSurfaceTpyes =
		{"X_P=1","X_M=1","Y_P=1","Y_M=1","Z_P=1","Z_M=1","X_P_Y_P=1","X_P_Y_M=1",
		"X_P_Z_P=1","X_P_Z_M=1","X_M_Y_P=1","X_M_Y_M=1","X_M_Z_P=1","X_M_Z_M=1","Y_P_Z_P=1","Y_P_Z_M=1","Y_M_Z_P=1","Y_M_Z_M=1",
		"X_P_Y_P_Z_P=1","X_P_Y_P_Z_M=1","X_P_Y_M_Z_P=1","X_P_Y_M_Z_M=1","X_M_Y_P_Z_P=1","X_M_Y_P_Z_M=1","X_M_Y_M_Z_P=1","X_M_Y_M"};

#endif // SIMULATION_HPP
