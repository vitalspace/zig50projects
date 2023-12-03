const std = @import("std");

fn binarySearch(items: []u8, target: u32) ?usize {
    var left: usize = 0;
    var right = items.len;

    while (left < right) {
        const mid = left + (right - left) / 2;
        if (items[mid] == target) {
            return mid;
        } else if (items[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return null;
}

pub fn main() !void {
    var items = [_]u8{ 1, 2, 3, 10, 34, 87 };
    const target = 3;
    const result = binarySearch(items[0..], target);

    if (result == null) {
        std.debug.print("The number {d}, was not found in the array\n", .{target});
    } else {
        std.debug.print("Index: {any}\n", .{result});
    }
}
