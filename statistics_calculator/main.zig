const std = @import("std");

fn calculateMean(numbers: *std.ArrayList(f32)) !f32 {
    var sum: f32 = 0.0;

    if (numbers.items.len == 0) {
        return 0.0;
    }

    for (numbers.items) |value| {
        sum += value;
    }

    return sum / @as(f32, @floatFromInt(numbers.items.len));
}

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
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
    std.debug.print("\n--- Caculate The Mean ---\n", .{});
    std.debug.print("Ingrese la canitidad de numers:  ", .{});
    const n_str = try getPrompt(allocator);
    const n = try std.fmt.parseInt(u32, n_str, 0);
    defer allocator.free(n_str);

    var numbers = std.ArrayList(f32).init(allocator);

    var i: u32 = 0;

    while (i < n) : (i += 1) {
        const str = try getPrompt(allocator);
        const number = try std.fmt.parseFloat(f32, str);
        try numbers.append(number);
    }

    const mean = try calculateMean(&numbers);
    std.debug.print("La media es: {d:.}", .{mean});
}
