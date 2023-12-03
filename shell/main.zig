const std = @import("std");
const c = @cImport({
    @cInclude("stdlib.h");
});

pub fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    var bytes_read = try stdin.read(&buffer);
    var entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    while (true) {
        std.debug.print("Enter cmd: ", .{});
        const str = try getPrompt(allocator);
        defer allocator.free(str);

        if (std.mem.eql(u8, str, "exit")) {
            std.debug.print("Exiting the shell.\n", .{});
            break;
        }

        _ = c.system(@as([*c]const u8, @ptrCast(str)));
    }
}
