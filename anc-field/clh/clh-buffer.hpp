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

#ifndef CLH_BUFFER_HPP
#define CLH_BUFFER_HPP

#include <exception>

#include <CL/cl.hpp>
#include "clh-vector.hpp"
#include "easylogging.hpp"

namespace clh
{

// Describes which of the parties contains the latest, up-to-date information
enum class Valid
{
	kHost,
	kDevice,
	kAll
};

template<typename T>
class Buffer
{
public:
				Buffer		(Device& device);
				Buffer		(Device& device, Vector<T>& data);
				Buffer		(Device& device, const size_t size);
				Buffer		(Device& device, const size_t size, const T& def_val);
				Buffer		(Device& device, const std::vector<size_t>& ndsize);
				Buffer		(Device& device, const std::vector<size_t>& ndsize, const T& def_val);

	void		Set			(const size_t ix, const T value);
	void		Set			(const std::vector<size_t>& ndix, const T value);
	const T&	Get			(const size_t ix);
	const T&	Get			(const std::vector<size_t>& ndix);
	cl::Buffer& d_data		();

	// vector style accessors, use Set and Get instead to avoid modifying without synchronization
	T&			at			(const size_t ix);
	T&			at			(const std::vector<size_t>& ndix);

	T&			operator[]	(const size_t ix) 						{ return at(ix); }
	T&			operator[]	(const std::vector<size_t>& ndix)		{ return at(ndix); }

	void		push_back	(const T& value);
	void		push_back	(const std::vector<T>& values);

	void		resize		(const size_t size);
	void		resize		(const std::vector<size_t>& ndsize);

	size_t		size		() const								{ return h_data_.size(); }
	size_t		size		(size_t dim) const						{ return h_data_.size(dim); }
	const std::vector<size_t>&
				ndsize		() const								{ return h_data_.ndsize(); }

	// use with care, changing host data through these accessors will not trigger synchronization
	clh::Vector<T>&
				h_data		()										{ return h_data_; }
	const clh::Vector<T>&
				h_data		() const								{ return h_data_; }
	T*			data		()										{ return h_data_.data(); }
	const T*	data		() const								{ return h_data_.data(); }

	void		InvalidateHost();
	void		InvalidateDevice();

	void		Sync		();
	void		Sync		(bool blocking);

	clh::Device& device		() 										{ return device_; }

private:
	Device					device_;
	Vector< T >				h_data_;
	cl::Buffer				d_data_;
	size_t					d_size_;
	Valid					synced_;
};

/*
 * CONSTRUCTORS
 */

template<typename T>
Buffer<T>::Buffer(Device& device)
	: device_{device}, synced_{Valid::kHost}, d_size_{0}
{};

template<typename T>
Buffer<T>::Buffer(Device& device, Vector<T>& data)
	: device_{device}, h_data_{data}, d_size_{0}, synced_{Valid::kHost}
{};

template<typename T>
Buffer<T>::Buffer(Device& device, const size_t size)
	: device_{device}, h_data_{size}, synced_{Valid::kHost}
{};

template<typename T>
Buffer<T>::Buffer(Device& device, const size_t size, const T& def_val)
	: device_{device}, h_data_{size, def_val}, synced_{Valid::kHost}
{};

template<typename T>
Buffer<T>::Buffer(Device& device, const std::vector<size_t>& ndsize)
	: device_{device}, h_data_{ndsize},	synced_{Valid::kHost}
{};

template<typename T>
Buffer<T>::Buffer(Device& device, const std::vector<size_t>& ndsize, const T& def_val)
	: device_{device}, h_data_{ndsize, def_val}, synced_{Valid::kHost}
{};

/*
 * ACCESSORS
 */

template<typename T>
void Buffer<T>::Set(const size_t ix, const T value)
{
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 135\n";
	h_data_[ix] = value;
}

template<typename T>
void Buffer<T>::Set(const std::vector<size_t>& ndix, const T value)
{
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 142\n";
	h_data_[ndix] = value;
}

template<typename T>
const T& Buffer<T>::Get(const size_t ix)
{
	if (synced_ == Valid::kDevice) Sync(true);
	return h_data_[ix];
}

template<typename T>
const T& Buffer<T>::Get(const std::vector<size_t>& ndix)
{
	if (synced_ == Valid::kDevice) Sync(true);
	return h_data_[ndix];
}

template<typename T>
cl::Buffer& Buffer<T>::d_data()
{
	if (synced_ != Valid::kDevice)
	{
		Sync();
	}
	return d_data_;
}

template<typename T>
T& Buffer<T>::at(const size_t ix)
{
	if (synced_ == Valid::kDevice) Sync(true);
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 174\n";
	return h_data_[ix];
}

template<typename T>
T& Buffer<T>::at(const std::vector<size_t>& ndix)
{
	if (synced_ == Valid::kDevice) Sync(true);
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 182\n";
	return h_data_[ndix];
}

template<typename T>
void Buffer<T>::InvalidateHost()
{
	synced_ = Valid::kDevice;//LOG(INFO) << "kDevice 189\n";
}

template<typename T>
void Buffer<T>::InvalidateDevice()
{
	synced_ = Valid::kHost;//LOG(INFO) << "kDevice 189\n";
}

template<typename T>
void Buffer<T>::push_back(const T& value)
{
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 185\n";
	h_data_.push_back(value);
}

template<typename T>
void Buffer<T>::push_back(const std::vector<T>& values)
{
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 202\n";
	h_data_.push_back(values);
}

template<typename T>
void Buffer<T>::resize(const size_t size)
{
	if (synced_ == Valid::kDevice)
	{
		Sync(true);
	}
	h_data_.resize(size);
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 214\n";
}

template<typename T>
void Buffer<T>::resize(const std::vector<size_t>& ndsize)
{
	if (synced_ == Valid::kDevice)
	{
		Sync(true);
	}
	h_data_.resize(ndsize);
	synced_ = Valid::kHost;//LOG(INFO) << "kHost 225\n";
}

template<typename T>
void Buffer<T>::Sync()
{
	Sync(false);
}

template<typename T>
void Buffer<T>::Sync(bool blocking)
{
	switch(synced_)
	{
	// The host is up-to-date, the device needs to be updated
	case Valid::kHost:
		if (d_size_ != h_data_.size())
		{
			d_data_ = cl::Buffer(device_.context(), CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, sizeof(T)*h_data_.size(), h_data_.data());
			d_size_ = h_data_.size();
		}
		// writing to a device doesn't need to be blocking unless out of order execution is enabled
		//                                          ˇˇˇˇˇ
		device_.queue().enqueueWriteBuffer(d_data_, false, 0, sizeof(T)*d_size_, (void*) h_data_.data());
		synced_ = Valid::kAll;
		break;

	// The device is up-to-date, the host needs to be updated
	case Valid::kDevice:
		if (d_size_ != h_data_.size())
		{
			h_data_ = Vector<T>(d_size_);
		}
		device_.queue().enqueueReadBuffer(d_data_, blocking, 0, sizeof(T)*d_size_, h_data_.data());
		synced_ = Valid::kAll;
		break;

	// Nothing to do here, move along
	case Valid::kAll:
		break;
	}
}

}

#endif
