## Beware
Using initializer lists for the ndsize arguments can lead to ambiguity. E.g. clh::Vector<float> v({3,2}) will match the ctor with the arguments (const std::vector<size_t>& ndsize) and thus create a Vector with dimensions [2][3]. However clh::Vector<size_t> v({3,2}) will match the ctor taking the (const size_t size, const T& def_val) arguments, and thus will create a Vector[2] and value-initialize it with 2.

To stay safe use clh::Vector<float> v(std::vector<size_t> {3,2}) or just be conscious about what you're doing.