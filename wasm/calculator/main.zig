pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub export fn sub(a: i32, b: i32) i32 {
    return a - b;
}

pub export fn mult(a: i32, b: i32) i32 {
    return a * b;
}

pub export fn div(a: i32, b: i32) i32 {
    return @divExact(a, b);
}

pub fn main() !void {}
