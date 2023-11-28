const std = @import("std");

fn createFile(filename: []const u8, content: []const u8) !void {
    const file = std.fs.cwd().createFile(filename, .{ .read = true }) catch |err| {
        std.debug.print("\nThe file could not created Err: {}\n", .{err});
        return;
    };
    defer file.close();

    file.writeAll(content) catch |err| {
        std.debug.print("\nCould not write the file Err: {}\n", .{err});
        return;
    };

    std.debug.print("\nThe file was created\n", .{});
}

fn readFile(allocator: std.mem.Allocator, filename: []const u8) !void {
    const file = std.fs.cwd().readFileAlloc(allocator, filename, std.math.maxInt(usize)) catch |err| {
        std.debug.print("No de pudo abrir el archivo Err: {}\n", .{err});
        return;
    };

    std.debug.print("\n{s}\n", .{file});
    allocator.free(file);
}

fn deleteFile(filename: []const u8) !bool {
    std.fs.cwd().deleteFile(filename) catch |err| {
        std.debug.print("No de pudo eleminar el archivo Err: {}\n", .{err});
        return false;
    };

    return true;
}

fn fileExists(filename: []const u8) !bool {
    std.fs.cwd().access(filename, .{ .mode = .read_only }) catch |err| {
        if (err == error.FileNotFound) {
            // std.debug.print("Err {}", .{err});
            return false;
        }
    };
    return true;
}

fn getPromt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    const bytes_read = try stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    var str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

fn menu() void {
    std.debug.print("\n -- Menu -- \n", .{});
    std.debug.print("1 - Menu\n", .{});
    std.debug.print("2 - Exist File.\n", .{});
    std.debug.print("3 - Create File.\n", .{});
    std.debug.print("4 - Read File.\n", .{});
    std.debug.print("5 - Delete File.\n", .{});
    std.debug.print("6 - Exit. \n", .{});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var stdin = std.io.getStdIn().reader();
    var input: [100]u8 = undefined;

    menu();

    while (true) {
        std.debug.print("\n", .{});
        const bytes_read = try stdin.read(&input);
        const entred = input[0..bytes_read];
        const str = std.mem.trim(u8, entred, "\n ");

        const option = std.fmt.parseInt(u32, str, 0) catch |err| {
            std.debug.print("\nType a valid option ERR: {}\n", .{err});
            return;
        };

        switch (option) {
            1 => {
                menu();
            },
            2 => {
                std.debug.print("\nType filename: ", .{});
                const filename = try getPromt(allocator);
                const file = try fileExists(filename);
                defer allocator.free(filename);
                if (file) {
                    std.debug.print("\nThe file \"{s}\" exists.\n", .{filename});
                } else {
                    std.debug.print("\nThe file \"{s}\" no exists.\n", .{filename});
                }

                std.debug.print("\nType 1) to see the menu\n", .{});
            },
            3 => {
                std.debug.print("\nType filename: ", .{});
                const filename = try getPromt(allocator);
                defer allocator.free(filename);

                std.debug.print("\nType content: : ", .{});
                const content = try getPromt(allocator);
                defer allocator.free(content);

                try createFile(filename, content);
                std.debug.print("\nType 1) to see the menu\n", .{});
            },
            4 => {
                std.debug.print("\nType filename: ", .{});
                const filename = try getPromt(allocator);
                defer allocator.free(filename);
                try readFile(allocator, filename);
                std.debug.print("\nType 1) to see the menu\n", .{});
            },
            5 => {
                std.debug.print("\nType filename: ", .{});
                const filename = try getPromt(allocator);
                defer allocator.free(filename);

                const file = try deleteFile(filename);

                if (file) {
                    std.debug.print("\nThe file was deleted\n", .{});
                } else {
                    std.debug.print("\nCould not deleted the file\n", .{});
                }

                std.debug.print("\nType 1) to see the menu\n", .{});
            },
            6 => {
                std.debug.print("\nSee you!!\n", .{});
                return;
            },
            else => {
                std.debug.print("\nThis option is not valid\n", .{});
            },
        }
    }
}
