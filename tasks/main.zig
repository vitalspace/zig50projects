const std = @import("std");

const Task = struct { id: usize, title: []const u8, description: []const u8 };
const allocator = std.heap.page_allocator;

var task = std.ArrayList(Task).init(allocator);
var taskCount: usize = 0;

fn menu() void {
    std.debug.print("\n-- Menu --\n", .{});
    std.debug.print("1 - Menu \n", .{});
    std.debug.print("2 - Create Task \n", .{});
    std.debug.print("3 - See all Tasks \n", .{});
    std.debug.print("4 - Delete Task \n", .{});
    std.debug.print("5 - Exit \n", .{});
}

fn getPrompt() ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    const bytes_read = try stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    var str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

fn createTask() !void {
    std.debug.print("\nType Tittle: ", .{});
    const title = try getPrompt();

    std.debug.print("\nType Description: ", .{});
    const description = try getPrompt();

    const newTask = Task{ .id = taskCount, .title = title, .description = description };
    try task.append(newTask);
    taskCount += 1;
    std.debug.print("\n(2) Add another taks. (1) to see the menu.\n", .{});
}

fn showAllTasks() !void {
    std.debug.print("\n", .{});
    if (task.items.len > 0) {
        for (task.items) |value| {
            std.debug.print("Id: {d} Title: {s} Description: {s}\n", .{ value.id, value.title, value.description });
        }
        std.debug.print("\n(3) To see again the lists. (1) to see the menu.\n", .{});
    } else {
        std.debug.print("There are no tasks\n", .{});
    }
}

fn delteTask() !void {
    std.debug.print("Type id: ", .{});
    var stdin = std.io.getStdIn().reader();
    var input: [100]u8 = undefined;
    const bytes_read = try stdin.read(&input);
    const entered = input[0..bytes_read];
    const trimmed_entered = std.mem.trim(u8, entered, "\n ");
    const id = try std.fmt.parseInt(u32, trimmed_entered, 0);

    if (id < task.items.len) {
        std.debug.print("\nThe task \"{s}\" was eliminated. (1) To back to the menu.\n", .{task.items[id].title});

        const removedTask = task.orderedRemove(id);
        defer allocator.free(removedTask.title);
        defer allocator.free(removedTask.description);

        taskCount -= 1;

        for (task.items[id..]) |*value| {
            if (value.id > 0) {
                value.id -= 1;
            }
        }
    } else {
        return std.debug.print("\nInvalid Index. (1) To back to the menu.\n", .{});
    }
}

pub fn main() !void {
    var stdin = std.io.getStdIn().reader();
    var input: [100]u8 = undefined;

    menu();

    while (true) {
        std.debug.print("\n", .{});
        const bytes_read = try stdin.read(&input);
        const entered = input[0..bytes_read];
        const str = std.mem.trim(u8, entered, "\n ");

        const option = std.fmt.parseInt(u32, str, 0) catch |err| {
            std.debug.print("\nType a valid option ERR: {}\n", .{err});
            return;
        };

        switch (option) {
            1 => {
                menu();
            },
            2 => {
                try createTask();
            },
            3 => {
                try showAllTasks();
            },
            4 => {
                try delteTask();
            },
            5 => {
                if (task.items.len > 0) {
                    for (task.items) |value| {
                        defer allocator.free(value.title);
                        defer allocator.free(value.description);
                    }
                }

                defer task.deinit();
                std.debug.print("\nSee you!!\n", .{});
                return;
            },
            else => {
                std.debug.print("\nThis option don't exists\n", .{});
            },
        }
    }
}
