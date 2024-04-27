const std = @import("std");

const ExpenseType = struct { category: []const u8, ammount: i32, date: []const u8 };

pub fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    var stdin = std.io.getStdIn().reader();
    var input: [100]u8 = undefined;
    const bytes_entered = try stdin.read(&input);
    const entered = input[0..bytes_entered];
    const str = std.mem.trim(u8, entered, " \r\n\t");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copyForwards(u8, str_copy, str);
    return str_copy;
}

pub fn menu() !void {
    std.debug.print("\n---------- Menu ---------- \n", .{});
    std.debug.print("1 - Menu \n", .{});
    std.debug.print("2 - Enter expense\n", .{});
    std.debug.print("3 - Generate Report\n", .{});
    std.debug.print("4 - Exit\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.debug.print("memory leak \n", .{});
        }
    }

    var expenseList = std.ArrayList(ExpenseType).init(allocator);
    defer expenseList.deinit();

    try menu();

    while (true) {
        std.debug.print("\n", .{});

        const output = try getPrompt(allocator);
        defer allocator.free(output);
        const option = try std.fmt.parseInt(u32, output, 0);

        switch (option) {
            1 => {
                try menu();
            },

            2 => {
                std.debug.print("Enter the expense category: \n", .{});
                const category = try getPrompt(allocator);

                std.debug.print("Enter the expense ammount: \n", .{});
                const ammount_str = try getPrompt(allocator);
                defer allocator.free(ammount_str);
                const ammount = try std.fmt.parseInt(i32, ammount_str, 0);

                std.debug.print("Enter the expense date (dd/mm/yyyy): \n", .{});
                const date = try getPrompt(allocator);

                try expenseList.append(ExpenseType{ .category = category, .ammount = ammount, .date = date });

                std.debug.print("\n1) to see menu\n", .{});
            },
            3 => {
                std.debug.print("\n--- Expense Report ---\n", .{});
                std.debug.print("{s:<20} {s:<20} {s:<20}\n", .{ "Category", "Ammount", "Date" });

                var gasto: i32 = 0;

                for (expenseList.items) |value| {
                    gasto = gasto + value.ammount;
                    std.debug.print("{s:<20} {d:<20} {s:<20}\n", .{ value.category, value.ammount, value.date });
                }

                std.debug.print("\n{s:_>60}\n", .{"_"});
                std.debug.print("\n{s:<20} {d:<20}\n", .{ "Total:", gasto });

                std.debug.print("\n1) to see menu\n", .{});
            },

            4 => {
                for (expenseList.items) |value| {
                    defer allocator.free(value.category);
                    defer allocator.free(value.date);
                }
                std.debug.print("\nSee you!!\n", .{});
                return;
            },

            else => {
                std.debug.print("\nInvalid option.\n", .{});
            },
        }
    }
}
