const std = @import("std");

const Semver = struct {
    pub fn isValidVersion(this: @This(), version: []const u8) ![]const u8 {
        _ = this;

        var prevCharWasDot: bool = false;
        var dots: i32 = 0;

        for (version) |value| {
            if (@as(i32, '.') == value) {
                if (prevCharWasDot) {
                    return error.ConsecutiveDots;
                }

                dots += 1;

                prevCharWasDot = true;
            } else if (value < @as(i32, '0') or value > @as(i32, '9')) {
                return error.InvalidCharacter;
            } else {
                prevCharWasDot = false;
            }
        }

        if (dots != 2) {
            return error.InvalidVersionFormat;
        }

        return version;
    }

    pub fn clean(this: @This(), allocator: std.mem.Allocator, version: []const u8) ![]const u8 {
        _ = this;
        const str = std.mem.trim(u8, version, " ");

        var arr = std.ArrayList(u8).init(allocator);
        defer arr.deinit();

        var prevCharWasDot: bool = false;
        var dotCount: i32 = 0;

        for (str) |value| {
            if (value == @as(u8, '.')) {
                if (prevCharWasDot) {
                    return error.ConsecutiveDots;
                }
                prevCharWasDot = true;
                dotCount += 1;
                try arr.append(value);
            } else if (value == @as(u8, '.') or (value >= @as(u8, '0') and value <= @as(u8, '9'))) {
                try arr.append(value);
                prevCharWasDot = false;
            }
        }

        if (dotCount < 2) {
            return error.InvalidVersionFormat;
        }

        const items = try allocator.alloc(u8, arr.items.len);
        std.mem.copy(u8, items, arr.items);
        return items;
    }

    pub fn gt(this: @This(), version1: []const u8, version2: []const u8) !bool {
        _ = this;

        var itV1 = std.mem.split(u8, version1, ".");
        var itV2 = std.mem.split(u8, version2, ".");

        var sumV1: u32 = 0;
        var sumV2: u32 = 0;

        var i: u8 = 0;
        while (i < 2) : (i += 1) {
            const part1 = itV1.next() orelse break;
            const part2 = itV2.next() orelse break;

            const v1 = try std.fmt.parseInt(u32, part1, 10);
            const v2 = try std.fmt.parseInt(u32, part2, 10);

            sumV1 += v1;
            sumV2 += v2;
        }

        if (sumV1 > sumV2) {
            return true;
        } else {
            return false;
        }

        // std.debug.print("{}\n", .{sumV1});
        // std.debug.print("{}\n", .{sumV2});

        // if (sumV1 > sumV2) {
        //     std.debug.print("Sum of first two numbers in {} is greater than in {}\n", .{ version1, version2 });
        // } else if (sumV1 < sumV2) {
        //     std.debug.print("Sum of first two numbers in {} is less than in {}\n", .{ version1, version2 });
        // } else {
        //     std.debug.print("Sum of first two numbers in {} is equal to in {}\n", .{ version1, version2 });
        // }
    }
};

pub fn main() !void {
    // const allocator = std.heap.page_allocator;

    // const semver = Semver{};
    // const valid = try semver.isValidVersion("10.11.1");

    // std.debug.print("{s}\n", .{valid});

    // const clean = try semver.clean(allocator, " v=1.2.3??  ?  ");
    // defer allocator.free(clean);

    // std.debug.print("{s}\n", .{clean});

    const semver = Semver{};

    const gt = try semver.gt("1.200.1", "0.1000.3");
    std.debug.print("{}\n", .{gt});
}
