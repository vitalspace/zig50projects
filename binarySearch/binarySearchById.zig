const std = @import("std");

const Object = struct { id: i32, name: []const u8 };

fn binarySearchById(items: []Object, target: i32) ?usize {
    var left: usize = 0;
    var right = items.len;

    while (left < right) {
        const mid = left + (right - left) / 2;

        if (items[mid].id == target) {
            return mid;
        } else if (items[mid].id < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return null;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var items = [_]Object{
        Object{ .id = 1, .name = "lucas" },
        Object{ .id = 2, .name = "sam" },
        Object{ .id = 3, .name = "lucia" },
    };

    const target: i32 = 2;
    const result = binarySearchById(items[0..], target);

    if (result == null) {
        std.debug.print("The number {d}, was not found in the array\n", .{target});
    } else {
        const rs = try std.json.stringifyAlloc(allocator, items[result.?], .{ .whitespace = .indent_2 });
        defer allocator.free(rs);

        std.debug.print("{s}\n", .{rs});
    }
}
