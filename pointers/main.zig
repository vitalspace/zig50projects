// const std = @import("std");

// const User = struct {
//     name: []const u8,
//     power: i32,
// };

// pub fn changeValue(value: *User, newName: []const u8, newPower: i32) void {
//     value.*.name = newName;
//     value.*.power = newPower;
// }

// pub fn main() !void {
//     var user = User{ .name = "lucas", .power = 100 };

//     std.debug.print("User: {s} Power: {d} \n", .{ user.name, user.power });

//     changeValue(&user, "sam", 101);
//     std.debug.print("User: {s} Power: {d} \n", .{ user.name, user.power });

//     changeValue(&user, "Leon", 12);
//     std.debug.print("User: {s} Power: {d} \n", .{ user.name, user.power });

//     changeValue(&user, "karla", 11);
//     std.debug.print("User: {s} Power: {d} \n", .{ user.name, user.power });

//     changeValue(&user, "Carlos", 145);
//     std.debug.print("User: {s} Power: {d} \n", .{ user.name, user.power });

//     changeValue(&user, "Sara", 211);
//     std.debug.print("User: {s} Power: {d} \n", .{ user.name, user.power });
// }

const std = @import("std");

const Node = struct {
    name: []const u8,
    value: i32,
    next: ?*Node,
};

pub fn main() !void {
    var node3 = Node{ .name = "lucas", .value = 3, .next = null };
    var node2 = Node{ .name = "samantha", .value = 2, .next = &node3 };
    var node1 = Node{ .name = "leon", .value = 1, .next = &node2 };

    var current_node: ?*Node = &node1;
    while (current_node) |node| {
        std.debug.print("Node name: {s}, Node value: {d}\n", .{
            node.name,
            node.value,
        });
        current_node = node.next;
    }
}
