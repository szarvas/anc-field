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

#ifndef CLH_VECTOR_HPP
#define CLH_VECTOR_HPP

#include <vector>

namespace clh
{

typedef std::vector<size_t> clhs;

template<typename T>
class Vector
{
public:
				Vector		();
				Vector		(const size_t size);
				Vector		(const size_t size, const T& def_val);
				Vector		(const clhs& ndsize);
				Vector		(const clhs& ndsize, const T& def_val);

	T&			at			(const size_t ix);
	const T&	at			(const size_t ix) const;
	T&			at			(const clhs& ndix);
	const T&	at			(const clhs& ndix) const;

	T&			operator[]	(const size_t ix) 						{ return at(ix); }
	const T&	operator[]	(const size_t ix) const					{ return at(ix); }
	T&			operator[]	(const clhs& ndix)						{ return at(ndix); }
	const T&	operator[]	(const clhs& ndix) const				{ return at(ndix); }

	typename std::vector<T>::iterator
				begin		()										{ return data_.begin(); }
	typename std::vector<T>::iterator
				end			()										{ return data_.end(); }
	typename std::vector<T>::const_iterator
				begin		() const								{ return data_.begin(); }
	typename std::vector<T>::const_iterator
				end			() const								{ return data_.end(); }

	void		push_back	(const T& value);
	void		push_back	(const std::vector<T>& values);

	void		resize		(const size_t size);
	void		resize		(const clhs& ndsize);

	size_t		size		() const								{ return data_.size(); }
	size_t		size		(size_t dim) const						{ return ndsize_[dim]; }
	const clhs& ndsize		() const								{ return ndsize_; }

	std::vector<T>&
				vdata		()										{ return data_; }
	const std::vector<T>&
				vdata		() const								{ return data_; }
	T*			data		()										{ return data_.data(); }
	const T*	data		() const								{ return data_.data(); }

private:
	std::vector<T> data_;
	clhs		 ndsize_;

	size_t 		NdixToIx	(const clhs& ndix) const;
	size_t		NdixToIx	(const clhs& ndsize, const clhs& ndix) const;
};

/*
 * CONSTRUCTORS
 */
template<typename T>
Vector<T>::Vector()
{
	ndsize_.push_back(0);
}

template<typename T>
Vector<T>::Vector(const size_t size)
{
	data_ = std::vector<T>(size);
	ndsize_.push_back(size);
}

template<typename T>
Vector<T>::Vector(const size_t size, const T& def_val)
{
	data_ = std::vector<T>(size, def_val);
	ndsize_.push_back(size);
}

template<typename T>
Vector<T>::Vector(const clhs& ndsize) : ndsize_{ndsize}
{
	if (ndsize_.size() > 0)
	{
		size_t size = 1;

		for (auto s : ndsize_)
		{
			size *= s;
		}

		data_ = std::vector<T>(size);
	}
}

template<typename T>
Vector<T>::Vector(const clhs& ndsize, const T& def_val) : ndsize_{ndsize}
{
	if (ndsize_.size() > 0)
	{
		size_t size = 1;

		for (auto s : ndsize_)
		{
			size *= s;
		}

		data_ = std::vector<T>(size, def_val);
	}
}

/*
 * ACCESSORS
 */

template<typename T>
T& Vector<T>::at(const size_t ix)
{
	return data_.at(ix);
}

template<typename T>
const T& Vector<T>::at(const size_t ix) const
{
	return data_.at(ix);
}

template<typename T>
inline size_t Vector<T>::NdixToIx(const clhs& ndsize, const clhs& ndix) const
{
	if (ndix.size() < 1)
	{
		throw std::range_error("clh::Vector ndix function called with empty argument");
	}
	size_t ix = 0;
	for (size_t i = 0; i < ndix.size(); ++i)
	{
		size_t expanse = 1;
		for (size_t j = 0; j < i; ++j)
		{
			expanse *= ndsize[j];
		}
		ix += ndix[i] * expanse;
	}

	return ix;
}

template<typename T>
inline size_t Vector<T>::NdixToIx(const clhs& ndix) const
{
	return NdixToIx(ndsize_, ndix);
}

template<typename T>
T& Vector<T>::at(const clhs& ndix)
{
	return data_.at(NdixToIx(ndix));
}

template<typename T>
const T& Vector<T>::at(const clhs& ndix) const
{
	return data_.at(NdixToIx(ndix));
}

/*
 * THE REST IS THE BEST
 */

template<typename T>
void Vector<T>::push_back(const T& value)
{
	if (ndsize_.size() > 1)
	{
		std::string err_mes = "Attempting to push scalar value into clh::Vector";
		for (auto s : ndsize_) err_mes += std::string("[") + std::to_string(s) + std::string("]");
		throw std::range_error(err_mes);
	}

	data_.push_back(value);
	ndsize_[0] = data_.size();
}

/*
 * SPECIAL FUNCTION FOR PUSHING A ROW INTO MxN VECTORS
 * bit of an oddball function, but really useful
 */

template<typename T>
void Vector<T>::push_back(const std::vector<T>& values)
{
	if (ndsize_.size() == 2 && values.size() == ndsize_[0])
	{
		for (auto v : values) data_.push_back(v);
		ndsize_[1] += 1;
	}
	else
	{
		std::string err_mes = "Attempting to push vector[";
		err_mes += std::to_string(values.size()) + std::string("]");
		err_mes += " into clh::Vector";
		for (auto s : ndsize_) err_mes += std::string("[") + std::to_string(s) + std::string("]");
		throw std::range_error(err_mes.c_str());
	}
}

template<typename T>
void Vector<T>::resize(const size_t size)
{
	data_.resize(size);
	ndsize_ = clhs {size};
}

template<typename T>
void Vector<T>::resize(const clhs& ndsize)
{
	std::vector<T> old_data = data_;

	if (ndsize_.size() > 0)
	{
		size_t size = 1;

		for (auto s : ndsize)
		{
			size *= s;
		}

		data_ = std::vector<T>(size);
	}

	clhs ixes(ndsize_.size(), 0);

	if (old_data.size() < data_.size())
	{
		for (size_t ix = 0; ix < old_data.size(); ++ix)
		{
			data_[NdixToIx(ndsize, ixes)] = old_data[NdixToIx(ndsize_, ixes)];

			size_t numeral = 0;
			ixes[numeral] += 1;

			while(ixes[numeral] == ndsize_[numeral] && ix != old_data.size()-1)
			{
				ixes[numeral] = 0;
				ixes[++numeral] += 1;
			}
		}
	}
	else
	{
		for (size_t ix = 0; ix < data_.size(); ++ix)
		{
			data_[NdixToIx(ndsize, ixes)] = old_data[NdixToIx(ndsize_, ixes)];

			size_t numeral = 0;
			ixes[numeral] += 1;

			while(ixes[numeral] == ndsize[numeral] && ix != data_.size()-1)
			{
				ixes[numeral] = 0;
				ixes[++numeral] += 1;
			}
		}
	}

	ndsize_ = ndsize;
}

}
#endif // CLH_VECTOR_HPP
