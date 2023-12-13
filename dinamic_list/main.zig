const std = @import("std");

fn DinamicList(comptime T: type) type {
    return struct {
        pos: usize,
        items: []T,
        allocator: std.mem.Allocator,
        size: T,

        fn init(allocator: std.mem.Allocator, size: T) !DinamicList(T) {
            return .{
                .pos = 0,
                .size = size,
                .allocator = allocator,
                .items = try allocator.alloc(T, size),
            };
        }

        fn deinit(this: @This()) void {
            this.allocator.free(this.items);
        }

        fn append(this: *@This(), value: T) !void {
            const pos = this.pos;
            const len = this.items.len;

            if (pos == len) {
                var larger = try this.allocator.alloc(T, len * 2);
                std.mem.copy(T, larger[0..len], this.items);
                this.allocator.free(this.items);
                this.items = larger;
            }

            this.items[pos] = value;
            this.pos = pos + 1;
        }

        fn getList(this: @This()) ![]T {
            return this.items[0..this.pos];
        }
    };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var list = try DinamicList(u8).init(allocator, 5);
    defer list.deinit();

    for (0..100) |item| {
        try list.append(@as(u8, @intCast(item)));
    }

    std.debug.print("{any}", .{list.getList()});
}
