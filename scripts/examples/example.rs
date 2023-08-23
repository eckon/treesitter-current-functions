#[allow(dead_code)]
struct Example1 {
    foo: usize
}

impl Example1 {
    fn new() -> Self {
        Example1 { foo: 0 }
    }
}

#[allow(dead_code)]
enum Example2 {
    Item1,
    Item2,
    Item3,
}

impl Example2 {
    fn index(&self) -> usize {
        match self {
            Example2::Item1 => 0,
            Example2::Item2 => 1,
            Example2::Item3 => 2,
        }
    }
}

#[allow(unused_variables)]
fn main() {
    let test1 = Example1::new();
    let test2 = Example2::Item1;
    test2.index();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_main() {
        main();
        assert_eq!("foo", "bar");
    }
}
