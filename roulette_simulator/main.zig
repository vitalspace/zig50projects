const std = @import("std");

fn getRandomNumberBetween(a: u32, b: u32) !u32 {
    var seed: u32 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var prng = std.rand.DefaultPrng.init(seed);
    const random_number = prng.random().intRangeAtMost(u32, a, b);
    return random_number;
}

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    var bytes_read = try stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    var str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    std.debug.print("\n--- Welcome to the Roulette Simulator in Zig ---\n", .{});
    std.debug.print("Enter your choise (0/36): ", .{});
    const str = try getPrompt(allocator);
    defer allocator.free(str);
    const election = try std.fmt.parseInt(u32, str, 0);

    if (election < 37) {
        var randomNumber = try getRandomNumberBetween(0, 37);
        if (election == randomNumber) {
            std.debug.print("\nCongratulations! You've won.\n", .{});
        } else {
            std.debug.print("Sorry, you lost, Better luck next time\n", .{});
        }
    } else {
        std.debug.print("Please enter a number between 0 to 36\n", .{});
    }
}
