const std = @import("std");
const Seat = struct { number: u32, reserved: bool };

const TicketReservation = struct {
    const This = @This();

    pub fn initializeSeats(this: *This, seats: *std.ArrayList(Seat)) !void {
        _ = this;
        var i: u32 = 0;

        for (0..10) |_| {
            try seats.append(Seat{ .number = i, .reserved = false });
            i += 1;
        }
    }

    pub fn showAvailability(this: *This, seats: *std.ArrayList(Seat)) !void {
        _ = this;
        std.debug.print("\nSeat availability:\n", .{});
        for (seats.items) |value| {
            std.debug.print("Seat {}: {}\n", .{ value.number, value.reserved });
        }
    }

    pub fn reserveSeat(this: *This, seats: *std.ArrayList(Seat), numberOfSeat: u32) !void {
        _ = this;

        if (!seats.items[numberOfSeat].reserved) {
            seats.items[numberOfSeat].reserved = true;
            std.debug.print("\nThe seat \"{}\" has been reserved\n", .{numberOfSeat});
        } else {
            std.debug.print("\nYou cannot reserve this seat\n", .{});
        }
    }

    pub fn calcelReservation(this: *This, seats: *std.ArrayList(Seat), numberOfSeat: u32) !void {
        _ = this;

        if (seats.items[numberOfSeat].reserved) {
            seats.items[numberOfSeat].reserved = false;
            std.debug.print("\nWe have canceled your reservation\n", .{});
        } else {
            std.debug.print("\nYou have not booked this seat previously\n", .{});
        }
    }
};

const Ui = struct {
    const This = @This();

    pub fn menu(this: *This) void {
        _ = this;
        std.debug.print("\n--- Menu ---\n", .{});
        std.debug.print("1 - Menu\n", .{});
        std.debug.print("2 - See availability\n", .{});
        std.debug.print("3 - Reserve Seat\n", .{});
        std.debug.print("4 - Cancel reservation\n", .{});
        std.debug.print("5 - Exit\n", .{});
    }

    pub fn getPrompt(this: *This, allocator: std.mem.Allocator) ![]const u8 {
        _ = this;
        var stdin = std.io.getStdIn().reader();
        var buffer: [100]u8 = undefined;
        const bytes_read = try stdin.read(&buffer);
        const entered = buffer[0..bytes_read];
        const str = std.mem.trim(u8, entered, " \r\n\t");
        const str_copy = try allocator.alloc(u8, str.len);
        std.mem.copyForwards(u8, str_copy, str);
        return str_copy;
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var tk = TicketReservation{};

    var seats = std.ArrayList(Seat).init(allocator);
    defer seats.deinit();

    try tk.initializeSeats(&seats);
    var ui = Ui{};

    ui.menu();

    while (true) {
        std.debug.print("\n", .{});
        const str = try ui.getPrompt(allocator);
        defer allocator.free(str);
        const option = std.fmt.parseInt(u32, str, 0) catch |err| {
            std.debug.print("\nPlease type a valid option Err: {}", .{err});
            return;
        };
        switch (option) {
            1 => {
                ui.menu();
            },
            2 => {
                try tk.showAvailability(&seats);
                std.debug.print("\n(1) to back to the menu.\n", .{});
            },
            3 => {
                std.debug.print("\n-- Resevet a Seat --\n", .{});
                std.debug.print("Type seat number: ", .{});
                const entered = try ui.getPrompt(allocator);
                defer allocator.free(entered);
                const seat = try std.fmt.parseInt(u32, entered, 0);
                try tk.reserveSeat(&seats, seat);
                std.debug.print("\n(1) to back to the menu.\n", .{});
            },
            4 => {
                std.debug.print("\n-- Cancel reservation --\n", .{});
                std.debug.print("Type seat number: ", .{});
                const entered = try ui.getPrompt(allocator);
                defer allocator.free(entered);
                const seat = try std.fmt.parseInt(u32, entered, 0);
                try tk.calcelReservation(&seats, seat);
                std.debug.print("\n(1) to back to the menu.\n", .{});
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
