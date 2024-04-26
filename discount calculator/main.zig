const std = @import("std");

pub fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var output: [100]u8 = undefined;
    const bytes_read = try stdin.read(&output);
    const entered = output[0..bytes_read];
    const str = std.mem.trim(u8, entered, " \r\n\t");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copyForwards(u8, str_copy, str);
    return str_copy;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    std.debug.print("\n--- Discount Calculator ---\n", .{});

    var finalPrice: f32 = 0;

    std.debug.print("Enter the original price: ", .{});
    const str_orinal_price = try getPrompt(allocator);
    defer allocator.free(str_orinal_price);
    const original_price = try std.fmt.parseFloat(f32, str_orinal_price);

    std.debug.print("Enter the discount percentage: ", .{});
    const str_discount = try getPrompt(allocator);
    defer allocator.free(str_discount);
    const discount = try std.fmt.parseFloat(f32, str_discount);

    finalPrice = original_price - (original_price * discount / 100);
    std.debug.print("Final Price {d:}\n", .{finalPrice});
}
