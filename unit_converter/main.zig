const std = @import("std");

fn kmToMilles(kilometers: f32) f32 {
    return kilometers / 1.609344;
}

fn milesToKm(miles: f32) f32 {
    return miles / 0.621371;
}

fn celsiusToFahrenheit(celius: f32) f32 {
    return (celius * 9 / 5) + 32;
}

fn fahrenheitToCelsius(fahrenheit: f32) f32 {
    return (fahrenheit - 32) * 5 / 9;
}

fn getPrompt(allocator: std.mem.Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;
    var bytes_read = try stdin.read(&buffer);
    const entered = buffer[0..bytes_read];
    const str = std.mem.trim(u8, entered, "\n ");
    const str_copy = try allocator.alloc(u8, str.len);
    std.mem.copy(u8, str_copy, str);
    return str_copy;
}

fn menu() void {
    std.debug.print("\n-- Menu --\n", .{});
    std.debug.print("1 - Menu\n", .{});
    std.debug.print("2 - Convert milles to kilometers\n", .{});
    std.debug.print("3 - Convert kilometers to milles\n", .{});
    std.debug.print("4 - Convert celsius to fahrenheit\n", .{});
    std.debug.print("5 - Convert kilometers to milles\n", .{});
    std.debug.print("6 - Exit\n", .{});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    menu();

    while (true) {
        std.debug.print("\n", .{});
        const str = try getPrompt(allocator);
        const option = std.fmt.parseInt(u32, str, 0) catch |err| {
            std.debug.print("\nPlease type a valid option\n Err: {}", .{err});
            return;
        };

        switch (option) {
            1 => {
                menu();
            },
            2 => {
                std.debug.print("\n--- Miles to kilometers ---\n", .{});
                std.debug.print("\nType mile: ", .{});
                const str_mile = try getPrompt(allocator);
                defer allocator.free(str_mile);
                const mile = try std.fmt.parseFloat(f32, str_mile);
                const result = milesToKm(mile);
                std.debug.print("\nResult: {d:.5}\n", .{result});
                std.debug.print("\n1) Type to back the menu\n", .{});
            },
            3 => {
                std.debug.print("\n--- Km to Miles ---\n", .{});
                std.debug.print("\nType a Km: ", .{});
                const str_km = try getPrompt(allocator);
                defer allocator.free(str_km);
                const km = try std.fmt.parseFloat(f32, str_km);
                const result = kmToMilles(km);
                std.debug.print("\nResult: {d:.6}\n", .{result});
                std.debug.print("\n1) Type to back the menu\n", .{});
            },
            4 => {
                std.debug.print("\n--- Celsius to Fahrenheit ---\n", .{});
                std.debug.print("\nType celisus: ", .{});
                const str_celsius = try getPrompt(allocator);
                defer allocator.free(str_celsius);
                const celsius = try std.fmt.parseFloat(f32, str_celsius);
                const result = celsiusToFahrenheit(celsius);
                std.debug.print("\nResult: {d:.1}\n", .{result});
                std.debug.print("\n1) Type to back the menu\n", .{});
            },
            5 => {
                std.debug.print("\n--- Fahrenheit to Celsius ---\n", .{});
                std.debug.print("\nType fahrenheit: ", .{});
                const str_fahrenheit = try getPrompt(allocator);
                defer allocator.free(str_fahrenheit);
                const fahrenheit = try std.fmt.parseFloat(f32, str_fahrenheit);
                const result = fahrenheitToCelsius(fahrenheit);
                std.debug.print("\nResult: {d:.4}\n", .{result});
                std.debug.print("\n1) Type to back the menu\n", .{});
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
