const std = @import("std");

const Account = struct { id: u32, name: []const u8, balance: u32 };

var accountCount: u32 = 0;

const Bank = struct {
    pub fn createAccount(_: @This(), allocator: std.mem.Allocator, accounts: *std.ArrayList(Account), name: []const u8, balance: u32) !void {
        try accounts.append(allocator, Account{ .id = accountCount, .name = name, .balance = balance });
        accountCount += 1;
    }

    pub fn getAllAccount(_: @This(), accounts: *std.ArrayList(Account)) !void {
        for (accounts.items) |value| {
            std.debug.print("Account: {} Name: {s} Balance: {}\n", .{ value.id, value.name, value.balance });
        }
    }

    pub fn removeAccount(_: @This(), allocator: std.mem.Allocator, accounts: *std.ArrayList(Account), id: u32) !void {
        if (id < accounts.items.len) {
            const removedAccount = accounts.orderedRemove(id);
            allocator.free(removedAccount.name);

            accountCount -= 1;

            for (accounts.items) |*value| {
                if (value.id > id) {
                    value.id -= 1;
                }
            }
        }
    }
};

const Ui = struct {
    pub fn menu(_: *@This()) void {
        std.debug.print("\n -- Menu -- \n", .{});
        std.debug.print("1 - Menu\n", .{});
        std.debug.print("2 - Create Account\n", .{});
        std.debug.print("3 - Get All Accounts\n", .{});
        std.debug.print("4 - Remove Account\n", .{});
        std.debug.print("5 - Exit\n", .{});
    }

    pub fn getPrompt(_: @This(), allocator: std.mem.Allocator, io: std.Io) ![]const u8 {
        var stdin_buffer: [256]u8 = undefined;
        var stdin_reader = std.Io.File.stdin().reader(io, &stdin_buffer);

        const stdin = &stdin_reader.interface;

        const input = try stdin.takeDelimiterExclusive('\n');

        const trimmed = std.mem.trim(u8, input, " \r\t");
        const str_copy = try allocator.dupe(u8, trimmed);
        return str_copy;
    }
};

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const gpa_status = gpa.deinit();
        if (gpa_status == .leak) {
            @panic("WTF A LEAK");
        }
    }

    const allocator = gpa.allocator();

    var ui = Ui{};
    ui.menu();

    var bank = Bank{};

    var accounts = try std.ArrayList(Account).initCapacity(allocator, 0);

    while (true) {
        std.debug.print("\n", .{});

        const output = try ui.getPrompt(allocator, init.io);
        defer allocator.free(output);

        const option = try std.fmt.parseInt(u32, output, 0);

        switch (option) {
            1 => {
                ui.menu();
            },
            2 => {
                std.debug.print("\n --- Create Account --- \n", .{});
                std.debug.print("Type name: ", .{});
                const name = try ui.getPrompt(allocator, init.io);
                std.debug.print("Type Balance: ", .{});
                const str = try ui.getPrompt(allocator, init.io);
                defer allocator.free(str);
                const balance = std.fmt.parseInt(u32, str, 0) catch |err| {
                    std.debug.print("\nPlease type a only FUCKING NUMBERS!!!! {}\n", .{err});
                    return;
                };
                try bank.createAccount(allocator, &accounts, name, balance);
                std.debug.print("\n(1) To back to the menu\n", .{});
            },

            3 => {
                std.debug.print("\n", .{});
                try bank.getAllAccount(&accounts);
                std.debug.print("\n(1) To back to the menu\n", .{});
            },
            4 => {
                std.debug.print("\n --- Remove Account --- \n", .{});
                std.debug.print("Type id: ", .{});
                const str = try ui.getPrompt(allocator, init.io);
                defer allocator.free(str);
                const id = try std.fmt.parseInt(u32, str, 0);
                try bank.removeAccount(allocator, &accounts, id);
                std.debug.print("\n(1) To back to the menu\n", .{});
            },
            5 => {
                for (accounts.items) |account| {
                    allocator.free(account.name);
                }
                accounts.deinit(allocator);
                std.debug.print("\nSee you!!\n", .{});
                return;
            },
            else => {
                std.debug.print("\nPlease type a valid option\n", .{});
            },
        }
    }
}
