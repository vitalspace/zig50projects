const std = @import("std");

fn median(arr: *std.ArrayList(i32)) f32 {
    const len = arr.items.len;

    if (len % 2 == 0) {
        return @as(f32, @floatFromInt(arr.items[len / 2 - 1] + arr.items[len / 2])) / 2.0;
    } else {
        return @as(f32, @floatFromInt(arr.items[len / 2]));
    }
}

fn calculateMean(numbers: *std.ArrayList(f32)) !f32 {
    var sum: f32 = 0.0;

    if (numbers.items.len == 0) {
        return 0.0;
    }

    for (numbers.items) |item| {
        sum += item;
    }

    return sum / @as(f32, @floatFromInt(numbers.items.len));
}

fn calculateMode(numbers: *std.ArrayList(i32)) !i32 {
    var mode: i32 = 0;
    var fm: i32 = 0;

    for (numbers.items) |item| {
        var f: i32 = 0;

        for (numbers.items) |o| {
            if (item == o) {
                f += 1;
            }
        }

        if (f > fm) {
            fm = f;
            mode = item;
        }
    }

    return mode;
}

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    var bytes_read = try stdin.read(&buffer);
    var entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

fn menu() void {
    std.debug.print("\n--- Menu ---\n", .{});
    std.debug.print("1 - Menu\n", .{});
    std.debug.print("2 - Calculate Mean\n", .{});
    std.debug.print("3 - Calculate Median\n", .{});
    std.debug.print("4 - Calculate Mode\n", .{});
    std.debug.print("5 - Exit\n", .{});
}
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var numbers = std.ArrayList(f32).init(allocator);
    defer numbers.deinit();

    var numbers_median = std.ArrayList(i32).init(allocator);
    defer numbers_median.deinit();

    var numbers_mode = std.ArrayList(i32).init(allocator);
    defer numbers_mode.deinit();

    menu();

    while (true) {
        std.debug.print("\n", .{});
        std.debug.print("", .{});

        const output = try getPrompt(allocator);
        defer allocator.free(output);
        const option = try std.fmt.parseInt(u32, output, 0);

        switch (option) {
            1 => {
                menu();
            },
            2 => {
                std.debug.print("\n--- Caculate the Mean ---\n", .{});
                std.debug.print("Enter the amount of numbers: ", .{});
                const n_str = try getPrompt(allocator);
                defer allocator.free(n_str);
                const n = try std.fmt.parseInt(u32, n_str, 0);
                var i: u32 = 0;
                while (i < n) : (i += 1) {
                    std.debug.print("Type number: ", .{});
                    const str = try getPrompt(allocator);
                    const number = try std.fmt.parseFloat(f32, str);
                    try numbers.append(number);
                }
                const mean = try calculateMean(&numbers);
                std.debug.print("\nThe Mean: {d:.}\n", .{mean});
                std.debug.print("\n(1) to back to the menu.\n", .{});
            },
            3 => {
                std.debug.print("\n--- Calculate the Media ---\n", .{});
                std.debug.print("Enter the amount of numbers: ", .{});
                const n_str = try getPrompt(allocator);
                const n = try std.fmt.parseInt(u32, n_str, 0);

                var i: u32 = 0;
                while (i < n) : (i += 1) {
                    std.debug.print("Type number: ", .{});
                    const str = try getPrompt(allocator);
                    const number = try std.fmt.parseInt(i32, str, 0);
                    try numbers_median.append(number);
                }

                std.sort.insertion(i32, numbers_median.items, {}, std.sort.asc(i32));
                const med = median(&numbers_median);
                std.debug.print("\nThe Media: {d}\n", .{med});
                std.debug.print("\n(1) to back to the menu.\n", .{});
            },
            4 => {
                std.debug.print("\n--- Calculate the Mode ---\n", .{});
                std.debug.print("Enter the amout of numbers: ", .{});
                const n_str = try getPrompt(allocator);
                const n = try std.fmt.parseInt(i32, n_str, 0);
                var i: i32 = 0;
                while (i < n) : (i += 1) {
                    std.debug.print("Type number: ", .{});
                    const str = try getPrompt(allocator);
                    const number = try std.fmt.parseInt(i32, str, 0);
                    try numbers_mode.append(number);
                }
                std.sort.insertion(i32, numbers_mode.items, {}, std.sort.asc(i32));
                const mode = try calculateMode(&numbers_mode);
                std.debug.print("\nThe Mode {any}\n", .{mode});
                std.debug.print("\n(1) to back to the menu.\n", .{});
            },
            5 => {
                std.debug.print("See you!!\n", .{});
                return;
            },
            else => {
                std.debug.print("Please type a valid option.\n", .{});
            },
        }
    }
}
