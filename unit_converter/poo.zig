const std = @import("std");

const UnitConverter = struct {
    const Self = @This();

    pub fn kmToMiles(self: *Self, kilometers: f32) f32 {
        _ = self;
        return kilometers / 1.609344;
    }

    pub fn milesToKm(self: *Self, miles: f32) f32 {
        _ = self;
        return miles / 0.621371;
    }

    pub fn celsiusToFahrenheit(self: *Self, celsius: f32) f32 {
        _ = self;
        return (celsius * 9 / 5) + 32;
    }

    pub fn fahrenheitToCelsius(self: *Self, fahrenheit: f32) f32 {
        _ = self;
        return (fahrenheit - 32) * 5 / 9;
    }
};

const Ui = struct {
    const Self = @This();

    var un = UnitConverter{};

    pub fn Menu(
        self: *Self,
    ) void {
        _ = self;
        std.debug.print("\n-- Menu --\n", .{});
        std.debug.print("1 - Menu\n", .{});
        std.debug.print("2 - Convert milles to kilometers\n", .{});
        std.debug.print("3 - Convert kilometers to milles\n", .{});
        std.debug.print("4 - Convert celsius to fahrenheit\n", .{});
        std.debug.print("5 - Convert fahrenheit to celsius\n", .{});
        std.debug.print("6 - Exit\n", .{});
    }

    pub fn getPrompt(self: *Self, allocator: std.mem.Allocator) ![]const u8 {
        _ = self;
        const stdin = std.io.getStdIn().reader();
        var buffer: [100]u8 = undefined;
        var bytes_read = try stdin.read(&buffer);
        const entered = buffer[0..bytes_read];
        const str = std.mem.trim(u8, entered, "\n ");
        const str_copy = try allocator.alloc(u8, str.len);
        std.mem.copy(u8, str_copy, str);
        return str_copy;
    }

    pub fn milesToKm(self: *Self, allocator: std.mem.Allocator) !void {
        std.debug.print("\n--- Miles to kilometers ---\n", .{});
        std.debug.print("\nType mile: ", .{});
        const str = try self.getPrompt(allocator);
        defer allocator.free(str);
        const mile = try std.fmt.parseFloat(f32, str);
        const result = un.milesToKm(mile);
        std.debug.print("\nResult: {d:.5}\n", .{result});
        std.debug.print("\n1) Type to back the menu\n", .{});
    }

    pub fn kmToMile(self: *Self, allocator: std.mem.Allocator) !void {
        std.debug.print("\n--- Km to Miles ---\n", .{});
        std.debug.print("\nType a Km: ", .{});
        const str = try self.getPrompt(allocator);
        defer allocator.free(str);
        const mile = try std.fmt.parseFloat(f32, str);
        const result = un.kmToMiles(mile);
        std.debug.print("\nResult: {d:.5}\n", .{result});
        std.debug.print("\n1) Type to back the menu\n", .{});
    }

    pub fn celsiusToFahrenheit(self: *Self, allocator: std.mem.Allocator) !void {
        std.debug.print("\n--- Celsius to Fahrenheit ---\n", .{});
        std.debug.print("\nType celisus: ", .{});
        const str = try self.getPrompt(allocator);
        defer allocator.free(str);
        const mile = try std.fmt.parseFloat(f32, str);
        const result = un.celsiusToFahrenheit(mile);
        std.debug.print("\nResult: {d:.5}\n", .{result});
        std.debug.print("\n1) Type to back the menu\n", .{});
    }

    pub fn fahrenheitToCelsius(self: *Self, allocator: std.mem.Allocator) !void {
        std.debug.print("\n--- Fahrenheit to Celsius ---\n", .{});
        std.debug.print("\nType fahrenheit: ", .{});
        const str = try self.getPrompt(allocator);
        defer allocator.free(str);
        const mile = try std.fmt.parseFloat(f32, str);
        const result = un.fahrenheitToCelsius(mile);
        std.debug.print("\nResult: {d:.5}\n", .{result});
        std.debug.print("\n1) Type to back the menu\n", .{});
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var ui = Ui{};

    ui.Menu();

    while (true) {
        std.debug.print("\n", .{});
        const str = try ui.getPrompt(allocator);
        defer allocator.free(str);

        const option = std.fmt.parseInt(u32, str, 0) catch |err| {
            std.debug.print("\nPlease type a valid option Err: {}\n", .{err});
            return;
        };

        switch (option) {
            1 => {
                ui.Menu();
            },
            2 => {
                try ui.milesToKm(allocator);
            },
            3 => {
                try ui.kmToMile(allocator);
            },
            4 => {
                try ui.celsiusToFahrenheit(allocator);
            },
            5 => {
                try ui.fahrenheitToCelsius(allocator);
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
