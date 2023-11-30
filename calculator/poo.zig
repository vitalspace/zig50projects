const std = @import("std");

const Calculalor = struct {
    const Self = @This();

    pub fn sum(self: *Self, a: i32, b: i32) i32 {
        _ = self;

        return a + b;
    }

    pub fn subtract(self: *Self, a: i32, b: i32) i32 {
        _ = self;
        return a - b;
    }

    pub fn multiply(self: *Self, a: i32, b: i32) i32 {
        _ = self;
        return a * b;
    }

    pub fn divide(self: *Self, a: i32, b: i32) i32 {
        _ = self;
        if (b == 0) {
            return 0; 
        }
        return @divTrunc(a, b);
    }
};

pub fn main() !void {
    var calculator = Calculalor{};

    var result = calculator.sum(2, 4);
    std.debug.print("result: {}\n", .{result});

    result = calculator.multiply(2, 4);
    std.debug.print("Result: {}\n", .{result});

    result = calculator.subtract(4, 2);
    std.debug.print("Result; {}\n", .{result});

    result = calculator.divide(14, 2);
    std.debug.print("Result: {d:}\n", .{result});
}
