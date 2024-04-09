const std = @import("std");

pub fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    const bytes_entered = try stdin.read(&buffer);
    const str = buffer[0..bytes_entered];
    const str_trimmed = std.mem.trim(u8, str, "\n ");
    const str_copy = try allocator.alloc(u8, str_trimmed.len);
    std.mem.copyForwards(u8, str_copy, str_trimmed);
    return str_copy;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    std.debug.print("Type weight: ", .{});
    const str_weight = try getPrompt(allocator);
    defer allocator.free(str_weight);
    const weight = try std.fmt.parseFloat(f32, str_weight);

    std.debug.print("Type height: ", .{});
    const str_height = try getPrompt(allocator);
    defer allocator.free(str_height);
    const height = try std.fmt.parseFloat(f32, str_height);

    const bmi = weight / (height * height);

    std.debug.print("Your bmi is {}\n", .{bmi});
}
