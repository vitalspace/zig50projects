const std = @import("std");
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("time.h");
});

pub fn main() !void {
    var current_time: c.time_t = undefined;
    var time_info: ?*c.struct_tm = null;
    var buffer: [80]u8 = undefined;

    _ = c.time(&current_time);
    time_info = c.localtime(&current_time);

    _ = c.strftime(&buffer[0], 80, "%Y-%m-%d %H:%M:%S", time_info);
    std.debug.print("{s}\n", .{@as([*c]u8, @ptrCast(@alignCast(&buffer[0])))});
}

// zig run time -lc