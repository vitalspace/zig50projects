const std = @import("std");

const User = struct { id: u32, name: []const u8, password: []const u8 };

var usersCount: u32 = 0;

const Ui = struct {
    const Self = @This();

    pub fn menu(self: *Self) void {
        _ = self;
        std.debug.print("\n--- Menu ---\n", .{});
        std.debug.print("1 - Menu\n", .{});
        std.debug.print("2 - Sinup\n", .{});
        std.debug.print("3 - Login\n", .{});
        std.debug.print("4 - Get all accounts\n", .{});
        std.debug.print("5 - Remove User\n", .{});
        std.debug.print("6 - Exit\n", .{});
    }

    pub fn getPrompt(self: *Self, allocator: std.mem.Allocator) ![]const u8 {
        _ = self;
        var stdin = std.io.getStdIn().reader();
        var buffer: [100]u8 = undefined;
        var bytes_entered = try stdin.read(&buffer);
        const entered = buffer[0..bytes_entered];
        const str = std.mem.trim(u8, entered, "\n ");
        const str_copy = try allocator.alloc(u8, str.len);
        std.mem.copy(u8, str_copy, str);
        return str_copy;
    }
};

// Um = User manager
const Um = struct {
    const Self = @This();

    pub fn singup(self: *Self, accounts: *std.ArrayList(User), name: []const u8, password: []const u8) !void {
        _ = self;

        if (accounts.items.len > 0) {
            for (accounts.items) |value| {
                if (std.mem.eql(u8, name, value.name)) {
                    std.debug.print("\nThis user has already been registered\n", .{});
                    return;
                } else {
                    try accounts.append(User{ .id = usersCount, .name = name, .password = password });
                    usersCount += 1;
                }
            }
        } else {
            try accounts.append(User{ .id = usersCount, .name = name, .password = password });
            usersCount += 1;
        }
    }

    pub fn login(self: *Self, accounts: *std.ArrayList(User), name: []const u8, password: []const u8) !void {
        _ = self;

        for (accounts.items) |value| {
            if (std.mem.eql(u8, value.name, name) and std.mem.eql(u8, value.password, password)) {
                std.debug.print("\nWelcome Back Friend: {s}\n", .{name});
            } else {
                std.debug.print("\nIncorrect user or Password\n", .{});
            }
        }
    }

    pub fn removeUser(self: *Self, allocator: std.mem.Allocator, accounts: *std.ArrayList(User), id: u32) !void {
        _ = self;

        if (id < accounts.items.len) {
            const removedUser = accounts.orderedRemove(id);
            defer allocator.free(removedUser.name);
            defer allocator.free(removedUser.password);

            usersCount -= 1;

            for (accounts.items) |*value| {
                if (value.id > 0) {
                    value.id -= 1;
                }
            }
        }
    }

    pub fn getAllAccounts(self: *Self, accounts: *std.ArrayList(User)) !void {
        _ = self;

        if (accounts.items.len > 0) {
            for (accounts.items) |value| {
                std.debug.print("Account: {} Name: {s}\n", .{ value.id, value.name });
            }
        } else {
            std.debug.print("\nThere are no registered users\n", .{});
        }
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var ui = Ui{};
    var um = Um{};

    ui.menu();

    var accounts = std.ArrayList(User).init(allocator);

    while (true) {
        const output = try ui.getPrompt(allocator);
        const option = std.fmt.parseInt(u32, output, 0) catch |err| {
            std.debug.print("\nPlease type a valid option Err: {}\n", .{err});
            return;
        };

        switch (option) {
            1 => {
                ui.menu();
            },
            2 => {
                std.debug.print("\n--- Singup ---\n", .{});
                std.debug.print("Type name: ", .{});
                const name = try ui.getPrompt(allocator);
                std.debug.print("Type: password: ", .{});
                const password = try ui.getPrompt(allocator);

                try um.singup(&accounts, name, password);
                std.debug.print("\n(1) to back to the menu\n", .{});
            },
            3 => {
                std.debug.print("\n--- Login ---\n", .{});
                std.debug.print("Type name: ", .{});
                const name = try ui.getPrompt(allocator);
                defer allocator.free(name);

                std.debug.print("Type: password: ", .{});
                const password = try ui.getPrompt(allocator);
                defer allocator.free(password);

                try um.login(&accounts, name, password);
                std.debug.print("\n(1) to back to the menu\n", .{});
            },
            4 => {
                std.debug.print("\n", .{});
                try um.getAllAccounts(&accounts);
                std.debug.print("\n(1) to back to the menu\n", .{});
            },
            5 => {
                std.debug.print("\n--- Login ---\n", .{});
                std.debug.print("Type id: ", .{});
                const str = try ui.getPrompt(allocator);
                const id = try std.fmt.parseInt(u8, str, 0);
                try um.removeUser(allocator, &accounts, id);
                std.debug.print("\n(1) to back to the menu\n", .{});
            },
            6 => {
                std.debug.print("\nSee you!!\n", .{});
                return;
            },
            else => {
                std.debug.print("\nPlease type a valid option\n", .{});
            },
        }
    }
}
