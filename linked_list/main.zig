// const std = @import("std");

// const Node = struct {
//     data: i32,
//     next: ?*Node,
// };

// const LinkedList = struct {
//     head: ?*Node,
// };

// pub fn main() !void {
//     var allocator = std.heap.page_allocator;

//     var list = LinkedList{ .head = null };

//     var node1 = try allocator.create(Node);
//     defer allocator.destroy(node1);
//     list.head = node1;
//     node1.* = Node{ .data = 1, .next = null };

//     var node2 = try allocator.create(Node);
//     node2.* = Node{ .data = 2, .next = null };
//     node1.next = node2;
//     defer allocator.destroy(node2);

//     var node3 = try allocator.create(Node);
//     node3.* = Node{ .data = 3, .next = null };
//     node2.next = node3;
//     defer allocator.destroy(node3);

//     var current = list.head;

//     while (current) |node| {
//         std.debug.print("\n{}\n", .{node});
//         current = node.next;
//     }
// }

const std = @import("std");

pub const Node = struct {
    data: i32,
    next: ?*Node,
};

pub const LinkedList = struct {
    head: ?*Node,

    pub fn addNode(self: *LinkedList, allocator: std.mem.Allocator, data: i32) !void {
        var newNode = try allocator.create(Node);
        newNode.* = Node{ .data = data, .next = null };

        if (self.head) |head| {
            var current = head;
            while (current.next) |node| {
                current = node;
            }
            current.next = newNode;
        } else {
            self.head = newNode;
        }
    }

    pub fn deleteNode(self: *LinkedList, allocator: std.mem.Allocator, data: i32) !void {
        if (self.head) |head| {
            if (head.data == data) {
                self.head = head.next;
                std.debug.print("\nhere: \n", .{});
                allocator.destroy(head);
            } else {
                var current = head;
                while (current.next) |node| {
                    if (node.data == data) {
                        std.debug.print("\n{any}\n", .{head.next});
                        current.next = node.next;
                        allocator.destroy(node);
                        return;
                    }
                    current = node;
                }
            }
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var list = LinkedList{ .head = null };

    try list.addNode(allocator, 1);
    try list.addNode(allocator, 2);
    try list.addNode(allocator, 3);

    try list.deleteNode(allocator, 2);

    // Ahora puedes recorrer la lista enlazada
    var current = list.head;
    while (current) |node| {
        std.debug.print("{}\n", .{node.data});
        current = node.next;
    }
}
