const std = @import("std");
const print = std.debug.print;

fn add(a: u32, b: u32) u32 {
    return a + b;
}

fn mult(a: u32, b: u32) u32 {
    return a * b;
}

fn sub(a: i32, b: i32) i32 {
    return a - b;
}

fn div(a: u32, b: u32) u32 {
    return a / b;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 4) {
        print("Insufficient arguments\n", .{});
        return;
    }

    if (std.mem.eql(u8, args[1], "add") and args[2].len > 0 and args[3].len > 0) {
        const num1 = try std.fmt.parseInt(u32, args[2][0..], 0);
        const num2 = try std.fmt.parseInt(u32, args[3][0..], 0);
        print("{d}\n", .{add(num1, num2)});
    }

    if (std.mem.eql(u8, args[1], "mult") and args[2].len > 0 and args[3].len > 0) {
        const num1 = try std.fmt.parseInt(u32, args[2][0..], 0);
        const num2 = try std.fmt.parseInt(u32, args[3][0..], 0);
        print("{d}\n", .{mult(num1, num2)});
    }

    if (std.mem.eql(u8, args[1], "sub") and args[2].len > 0 and args[3].len > 0) {
        const num1 = try std.fmt.parseInt(i32, args[2], 0);
        const num2 = try std.fmt.parseInt(i32, args[3], 0);
        print("{d}\n", .{sub(num1, num2)});
    }

    if (std.mem.eql(u8, args[1], "div") and args[2].len > 0 and args[3].len > 0) {
        const num1 = try std.fmt.parseInt(u32, args[2], 0);
        const num2 = try std.fmt.parseInt(u32, args[3], 0);
        print("{d}\n", .{div(num1, num2)});
    }
}
