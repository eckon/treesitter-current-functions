#include <cstdint>
#include <utility>

/*
 * Test 1: Basics, method definitions outside the class definition. Also testing basic
 *          functions with primitive, pointer, and reference return types.
 */

class test_1_out {

private:
    int a, b;

public:
    std::pair<int, int> get_ab() const;
    test_1_out(int _a, int _b);
    ~test_1_out();
};
test_1_out *test_1_out_inst = nullptr;

test_1_out::test_1_out(int _a, int _b)   { a = _a; b = _b; }
test_1_out::~test_1_out()                {  }
std::pair<int, int> test_1_out::get_ab() const { return { a, b }; }

test_1_out get_test_1_out_inst_reg() {
    return *test_1_out_inst;
}
test_1_out *get_test_1_out_inst_ptr() {
    return test_1_out_inst;
}
test_1_out &get_test_1_out_inst_ref() {
   return *test_1_out_inst;
}


/*
 * Test 2: Templated functions outside of class definitions.
 */

template <typename T>
class test_2_out {

private:
    T a, b;

public:
    std::pair<T, T> get_ab() const;
    test_2_out(T _a, T _b);
};
test_2_out<std::uint64_t> *test_2_out_inst = nullptr;

template <typename T> test_2_out<T>::test_2_out(T _a, T _b) { a = _a; b = _b; }
template <typename T> std::pair<T, T> test_2_out<T>::get_ab() const { return { a, b }; }

test_2_out<std::uint64_t> get_test_2_out_inst_reg() {
    return *test_2_out_inst;
}
test_2_out<std::uint64_t> *get_test_2_out_inst_ptr() {
    return test_2_out_inst;
}
test_2_out<std::uint64_t> &get_test_2_out_inst_ref() {
    return *test_2_out_inst;
}


/*
 * Test 3: Operator overloading.
 */

struct test_3_out {
    std::uint64_t x, y, z;
};

test_3_out operator+(const test_3_out &a, const test_3_out &b) {
    return { a.x + b.x, a.y + b.y, a.z + b.z };
}

test_3_out operator-(const test_3_out &a, const test_3_out &b) {
    return { a.x - b.x, a.y - b.y, a.z - b.z };
}



/* TODO: Functions declared inside a class as follows still don't appear

   class a {
       void foo() { ... }
   };

*/

