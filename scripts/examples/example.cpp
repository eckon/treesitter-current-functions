#include <utility>

/*
 * Test 1: Basics, method definitions both inside and outside the class definition. Also testing basic
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

