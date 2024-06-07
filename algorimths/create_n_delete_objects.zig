const std = @import("std");

const Person = struct {
    id: u32,
    name: []const u8,
    age: u8,
};

pub fn main() !void {
    const startTime = std.time.milliTimestamp();
    const allocator = std.heap.page_allocator;

    var users = std.ArrayList(Person).init(allocator);
    defer users.deinit();
    while (users.items.len < 100000000) {
        const usr = Person{ .id = @intCast(users.items.len + 1), .name = "lucas", .age = 22 };
        try users.append(usr);
    }

    var i: i32 = @intCast(users.items.len - 1);
    while (i >= 0) : (i -= 1) {
        const person = &users.items[@intCast(i)];
        if (person.age == 22) {
            _ = users.orderedRemove(@intCast(i));
            // or
            // _ = users.swapRemove(@intCast(i));
        }
    }
    std.debug.print("{}\n", .{users.items.len});
    std.debug.print("{any}\n", .{users.items});
    defer std.debug.print("Program executed in {d} s\n", .{@divTrunc(std.time.milliTimestamp() - startTime, 1000)});
}
