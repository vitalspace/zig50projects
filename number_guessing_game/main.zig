const std = @import("std");

fn getRandomNumberBetween(a: i32, b: i32) !i32 {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var prng = std.rand.DefaultPrng.init(seed);
    var random_number = prng.random().intRangeAtMost(i32, a, b);
    return random_number;
}

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    const bytes_read = try stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

fn menu() void {
    std.debug.print("\n -- Menu -- \n", .{});
    std.debug.print("1 - Menu\n", .{});
    std.debug.print("2 - Play\n", .{});
    std.debug.print("3 - Exit\n", .{});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    menu();

    while (true) {
        std.debug.print("\n", .{});
        const str = try getPrompt(allocator);
        defer allocator.free(str);

        const option = std.fmt.parseInt(u32, str, 0) catch |err| {
            std.debug.print("\nType a valid option Err: {}\n", .{err});
            return;
        };

        switch (option) {
            1 => menu(),
            2 => {
                std.debug.print("\n-- Let's play --\n", .{});
                std.debug.print("\nType a numer: ", .{});
                var str_entered = try getPrompt(allocator);
                defer allocator.free(str_entered);

                const option_entered = std.fmt.parseInt(u32, str_entered, 0) catch |err| {
                    if (err == error.InvalidCharacter) {
                        std.debug.print("\nType only numbers\n", .{});
                    }
                    return;
                };

                const result = try getRandomNumberBetween(1, 3);

                if (option_entered == result) {
                    std.debug.print("\nYou win\n", .{});
                } else {
                    std.debug.print("\nYou lost\n", .{});
                }

                std.debug.print("\nType 1) to see the menu or 2) to play again\n", .{});
            },

            3 => {
                std.debug.print("\nSee you!!\n", .{});
                return;
            },

            else => {
                std.debug.print("\nThis option don't exists\n", .{});
            },
        }
    }
}
