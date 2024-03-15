const std = @import("std");

pub fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;

    var bytes_entered = try stdin.read(&buffer);
    const entered = buffer[0..bytes_entered];
    const trimmed_str = std.mem.trim(u8, entered, "\n ");
    const str_copy = try allocator.alloc(u8, trimmed_str.len);
    std.mem.copy(u8, str_copy, trimmed_str);
    return str_copy;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    std.debug.print("Type weight: ", .{});
    const weight_str = try getPrompt(allocator);
    defer allocator.free(weight_str);
    const weight = try std.fmt.parseFloat(f32, weight_str);

    std.debug.print("Type height: ", .{});
    const height_str = try getPrompt(allocator);
    defer allocator.free(height_str);
    const height = try std.fmt.parseFloat(f32, height_str);

    const bmi = weight / (height * height);

    std.debug.print("{d}\n", .{bmi});
}
