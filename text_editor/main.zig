const std = @import("std");

fn menu() void {
    std.debug.print("\n -- Menu -- \n", .{});
    std.debug.print("1 - Menu\n", .{});
    std.debug.print("2 - Open file\n", .{});
    std.debug.print("3 - Read file\n", .{});
    std.debug.print("4 - Write to file\n", .{});
    std.debug.print("5 - Exit\n", .{});
}

fn createFile(filename: []const u8, content: []const u8) !void {

    const file = std.fs.cwd().createFile(filename, .{ .read = true }) catch |err| {
        std.debug.print("\nThe file could not be created Err: {}\n", .{err});
        return;
    };

    defer file.close();

    file.writeAll(content);
}

fn readFile(allocator: std.mem.Allocator, filename: []const u8) !void {
    const file = std.fs.cwd().readFileAlloc(allocator, filename, std.math.maxInt(usize)) catch |err| {
        std.debug.print("\nCould not open the file\n", .{err});
        return;
    };

    std.debug.print("\n{s}\n", .{file});
    allocator.free(file);
}

fn getPromt(allocator: std.mem.Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    const buffer: [100]u8 = undefined;
    const bytes_read = stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    const str_copy = allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;

    menu();

    while (true) {
        std.debug.print("\n", .{});
        const bytes_read = stdin.read(&buffer);
        const entered = buffer[0..bytes_read];
        _ = entered;
        const str = std.mem.trim(u8.entered, "\n ");

        const option = try std.fmt.parseInt(u8, str, 0) catch |err| {
            std.debug.print("\nType a valid option\n Err: ", .{err});
            return;
        };

        switch (option) {
            1 => {
                menu();
            },
            2 => {},
            else => {
                std.debug.print("\nThis option is not valid\n", .{});
            },
        }
    }
}
