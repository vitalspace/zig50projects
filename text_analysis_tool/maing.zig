const std = @import("std");

pub fn gePrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    var bytes_read = try stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var str = try gePrompt(allocator);
    defer allocator.free(str);

    var counts: [256]u32 = [_]u32{0} ** 256;

    for (str) |char| {
        counts[char] += 1;
    }

    for (counts, 0..) |count, i| {
        if (count > 0) {
            std.debug.print("The character '{c}': {} times\n", .{ std.math.cast(u8, i).?, count });
        }
    }
}
