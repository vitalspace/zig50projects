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

        while (true) {
            const part1 = itV1.next();
            const part2 = itV2.next();

            if (part1 == null and part2 == null) {
                return false;
            }

            var v1: u32 = 0;
            var v2: u32 = 0;

            if (part1 != null) {
                v1 = try std.fmt.parseInt(u32, part1.?, 10);
            }
            if (part2 != null) {
                v2 = try std.fmt.parseInt(u32, part2.?, 10);
            }

            if (v1 > v2) {
                return true;
            } else if (v1 < v2) {
                return false;
            }
        }
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const semver = Semver{};
    const valid = try semver.isValidVersion("10.11.1");

    std.debug.print("{s}\n", .{valid});

    const clean = try semver.clean(allocator, " v=1.2.3??  ?  ");
    defer allocator.free(clean);

    std.debug.print("{s}\n", .{clean});

    const gt = try semver.gt("0.200.2", "0.201.1");
    std.debug.print("{}\n", .{gt});
}
