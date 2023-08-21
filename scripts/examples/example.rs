
#[allow(dead_code)]
struct Test1 {
    foo: usize
}
impl Test1 {
    fn new() -> Self {
        Test1 { foo: 0 }
    }
}

#[allow(dead_code)]
enum Test2 {
    Item1,
    Item2,
    Item3,
}
impl Test2 {
    fn index(&self) -> usize {
        match self {
            Test2::Item1 => 0,
            Test2::Item2 => 1,
            Test2::Item3 => 2,
        }
    }
}

#[allow(unused_variables)]
fn main() {
    let test1 = Test1::new();
    let test2 = Test2::Item1;
    test2.index();
}
