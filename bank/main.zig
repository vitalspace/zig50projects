const std = @import("std");

const Account = struct { id: u32, name: []const u8, balance: u32 };

var accountCount: u32 = 0;

const Bank = struct {
    const Self = @This();

    pub fn createAccount(self: *Self, accounts: *std.ArrayList(Account), name: []const u8, balance: u32) !void {
        _ = self;
        try accounts.append(Account{ .id = accountCount, .name = name, .balance = balance });
        accountCount += 1;
    }

    pub fn getAllAccount(self: *Self, accounts: *std.ArrayList(Account)) !void {
        _ = self;

        for (accounts.items) |value| {
            std.debug.print("Account: {} Name: {s} Balance: {}\n", .{ value.id, value.name, value.balance });
        }
    }

    pub fn removeAccount(self: *Self, allocator: std.mem.Allocator, accounts: *std.ArrayList(Account), id: u32) !void {
        _ = self;

        if (id < accounts.items.len) {
            const removedAccount = accounts.orderedRemove(id);
            defer allocator.free(removedAccount.name);

            accountCount -= 1;

            for (accounts.items) |*value| {
                if (value.id > 0) {
                    value.id -= 1;
                }
            }
        }
    }
};

const Ui = struct {
    const Self = @This();

    pub fn menu(self: *Self) void {
        _ = self;
        std.debug.print("\n-- Menu ---\n", .{});
        std.debug.print("1 - Menu\n", .{});
        std.debug.print("2 - Create Account\n", .{});
        std.debug.print("3 - Get all Accounts\n", .{});
        std.debug.print("4 - Remove Account\n", .{});
        std.debug.print("5 - Exit\n", .{});
    }

    pub fn getPrompt(self: *Self, allocator: std.mem.Allocator) ![]const u8 {
        _ = self;
        var stdin = std.io.getStdIn().reader();
        var buffer: [100]u8 = undefined;
        var bytes_read = try stdin.read(&buffer);
        var entered = buffer[0..bytes_read];
        const str = std.mem.trim(u8, entered, "\n ");
        const str_copy = try allocator.alloc(u8, str.len);
        std.mem.copy(u8, str_copy, str);
        return str_copy;
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var ui = Ui{};
    ui.menu();

    var bank = Bank{};

    var accounts = std.ArrayList(Account).init(allocator);

    while (true) {
        std.debug.print("\n", .{});
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
                std.debug.print("\n --- Create Account ---\n", .{});
                std.debug.print("Type name: ", .{});
                const name = try ui.getPrompt(allocator);
                std.debug.print("Type balance: ", .{});
                const str = try ui.getPrompt(allocator);
                const balance = try std.fmt.parseInt(u32, str, 0);
                try bank.createAccount(&accounts, name, balance);
                std.debug.print("\n(1) To back to the menu\n", .{});
            },

            3 => {
                std.debug.print("\n", .{});
                try bank.getAllAccount(&accounts);
                std.debug.print("\n(1) To back to the menu\n", .{});
            },
            4 => {
                std.debug.print("\n--- Remove Account ---\n", .{});
                std.debug.print("Type id: ", .{});
                const str = try ui.getPrompt(allocator);
                const id = try std.fmt.parseInt(u32, str, 0);
                try bank.removeAccount(allocator, &accounts, id);
                std.debug.print("\n(1) To back to the menu\n", .{});
            },
            5 => {
                std.debug.print("\nSee you!!\n", .{});
                return;
            },
            else => {
                std.debug.print("\nPlease type a valid option\n", .{});
            },
        }
    }
}
