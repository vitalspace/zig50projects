const std = @import("std");

const Semver = struct {
    fn checkDots(this: @This(), dots: *i32, isPreRelease: bool, segmentLength: *i32, segmentStartsWithZero: *bool, prevCharWasDot: *bool) !void {
        _ = this;
        if (prevCharWasDot.* or (!isPreRelease and dots.* >= 2) or segmentLength.* > 15 or (segmentStartsWithZero.* and segmentLength.* > 1)) {
            return error.InvalidVersionFormat;
        }
        if (!isPreRelease) {
            dots.* += 1;
        }
        prevCharWasDot.* = true;
        segmentLength.* = 0;
        segmentStartsWithZero.* = false;
    }

    fn checkDash(this: @This(), dots: *i32, isPreRelease: *bool, segmentLength: *i32, segmentStartsWithZero: *bool, prevCharWasDot: *bool) !void {
        _ = this;
        if (dots.* != 2 or isPreRelease.* or segmentLength.* > 15 or (segmentStartsWithZero.* and segmentLength.* > 1)) {
            return error.InvalidVersionFormat;
        }
        isPreRelease.* = true;
        prevCharWasDot.* = false;
        segmentLength.* = 0;
        segmentStartsWithZero.* = false;
    }

    fn checkPlusSign(this: @This(), index: usize, buildMetadataStart: *?usize) void {
        _ = this;
        buildMetadataStart.* = index;
    }

    fn checkZeroStart(this: @This(), value: i32, prevCharWasDot: *bool, segmentLength: *i32, segmentStartsWithZero: *bool) !void {
        _ = this;
        if (value == @as(i32, '0') and segmentLength.* == 0) {
            segmentStartsWithZero.* = true;
        }
        prevCharWasDot.* = false;
        segmentLength.* += 1;
    }

    fn checkAlpha(this: @This(), prevCharWasDot: *bool, isPreRelease: bool, segmentLength: *i32) !void {
        _ = this;
        if (!isPreRelease) {
            return error.InvalidVersionFormat;
        }
        prevCharWasDot.* = false;
        segmentLength.* += 1;
    }

    fn checkInvalidCharacters(this: @This()) !void {
        _ = this;
        return error.InvalidCharacter;
    }

    pub fn isValidVersion(this: @This(), version: []const u8) ![]const u8 {
        var dots: i32 = 0;
        var prevCharWasDot: bool = false;
        var isPreRelease: bool = false;
        var segmentLength: i32 = 0;
        var buildMetadataStart: ?usize = null;
        var segmentStartsWithZero: bool = false;

        for (version, 0..) |value, index| {
            switch (value) {
                @as(i32, '.') => {
                    try this.checkDots(&dots, isPreRelease, &segmentLength, &segmentStartsWithZero, &prevCharWasDot);
                },
                @as(i32, '-') => {
                    try this.checkDash(&dots, &isPreRelease, &segmentLength, &segmentStartsWithZero, &prevCharWasDot);
                },
                @as(i32, '+') => {
                    this.checkPlusSign(index, &buildMetadataStart);
                },
                @as(i32, '0')...@as(i32, '9') => {
                    try this.checkZeroStart(value, &prevCharWasDot, &segmentLength, &segmentStartsWithZero);
                },
                @as(i32, 'a')...@as(i32, 'z') => {
                    try this.checkAlpha(&prevCharWasDot, isPreRelease, &segmentLength);
                },
                else => {
                    try this.checkInvalidCharacters();
                },
            }
        }

        if (dots != 2 or prevCharWasDot or segmentLength > 15 or (segmentStartsWithZero and segmentLength > 1)) {
            return error.InvalidVersionFormat;
        }

        if (buildMetadataStart) |index| {
            return version[0..index];
        } else {
            return version;
        }
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
                    return error.InvalidVersionFormat;
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

            var v1: u32 = 0;
            var v2: u32 = 0;

            if (part1 != null and part2 != null) {
                // Split the version part into number and pre-release identifier
                var itPart1 = std.mem.split(u8, part1.?, "-");
                var itPart2 = std.mem.split(u8, part2.?, "-");

                v1 = try std.fmt.parseInt(u32, itPart1.next().?, 10);
                v2 = try std.fmt.parseInt(u32, itPart2.next().?, 10);

                // Compare pre-release identifiers if the numbers are equal
                if (v1 == v2) {
                    const pre1 = itPart1.next();
                    const pre2 = itPart2.next();

                    if (pre1 == null and pre2 != null) {
                        return true;
                    } else if (pre1 != null and pre2 == null) {
                        return false;
                    } else if (pre1 != null and pre2 != null) {
                        return std.mem.eql(u8, pre1.?, pre2.?);
                    }
                }
            } else {
                return false;
            }

            if (v1 > v2) {
                return true;
            } else if (v1 < v2) {
                return false;
            }
        }
    }

    pub fn lt(this: @This(), version1: []const u8, version2: []const u8) !bool {
        _ = try this.isValidVersion(version1);
        _ = try this.isValidVersion(version2);

        var itv1 = std.mem.split(u8, version1, ".");
        var itv2 = std.mem.split(u8, version2, ".");

        while (true) {
            const part1 = itv1.next();
            const part2 = itv2.next();

            var v1: u32 = 0;
            var v2: u32 = 0;

            if (part1 != null and part2 != null) {
                v1 = try std.fmt.parseInt(u32, part1.?, 10);
                v2 = try std.fmt.parseInt(u32, part2.?, 10);
            } else {
                return false;
            }

            if (v2 > v1) {
                return true;
            } else if (v1 > v2) {
                return false;
            }
        }
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    _ = allocator;

    const semver = Semver{};
    const valid = try semver.isValidVersion("1.2.3-beta+exp.sha.5114f85");

    std.debug.print("{s}\n", .{valid});

    // const clean = try semver.clean(allocator, " v=1.2.3??  ?  ");
    // defer allocator.free(clean);

    // std.debug.print("{s}\n", .{clean});

    // const gt = try semver.gt("1.1.0-beta.1", "1.0.0-beta.1");
    // std.debug.print("{}\n", .{gt});

    // const lt = try semver.lt("1.2.3", "9.8.7");
    // std.debug.print("{}\n", .{lt});
}

test "fn isValidVersion" {
    const semver = Semver{};
    try std.testing.expectEqual(semver.isValidVersion("0.0.0"), "0.0.0");
    try std.testing.expectEqual(semver.isValidVersion("0.0.0-alpha"), "0.0.0-alpha");
    try std.testing.expectEqual(semver.isValidVersion("0.0.0-0.3.7"), "0.0.0-0.3.7");
    try std.testing.expectEqual(semver.isValidVersion("0.0.0-alpha.1"), "0.0.0-alpha.1");
    try std.testing.expectEqual(semver.isValidVersion("1.2.3-alpha.1.2"), "1.2.3-alpha.1.2");
    try std.testing.expectEqualStrings(try semver.isValidVersion("1.2.3+20130313144700"), "1.2.3");
    try std.testing.expectEqualStrings(try semver.isValidVersion("1.2.3-beta+exp.sha.5114f85"), "1.2.3-beta");
    try std.testing.expectEqual(semver.isValidVersion("999999999999999.999999999999999.999999999999999"), "999999999999999.999999999999999.999999999999999");
    try std.testing.expectEqual(semver.isValidVersion("1.2.3*"), error.InvalidCharacter);
    try std.testing.expectEqual(semver.isValidVersion("1.2.3?"), error.InvalidCharacter);
    try std.testing.expectEqual(semver.isValidVersion("1.2.3/"), error.InvalidCharacter);
    try std.testing.expectEqual(semver.isValidVersion(" 1.2.3"), error.InvalidCharacter);
    try std.testing.expectEqual(semver.isValidVersion("1.2.3 "), error.InvalidCharacter);
    try std.testing.expectEqual(semver.isValidVersion("1.2.3-ß"), error.InvalidCharacter);
    try std.testing.expectEqual(semver.isValidVersion("1.2..3"), error.InvalidVersionFormat);
    try std.testing.expectEqual(semver.isValidVersion("01.2.3"), error.InvalidVersionFormat);
    try std.testing.expectEqual(semver.isValidVersion("1.02.3"), error.InvalidVersionFormat);
    try std.testing.expectEqual(semver.isValidVersion("1.2.03"), error.InvalidVersionFormat);
    try std.testing.expectEqual(semver.isValidVersion("1.2.3.4"), error.InvalidVersionFormat);
    try std.testing.expectEqual(semver.isValidVersion("1.2.3beta"), error.InvalidVersionFormat);
    try std.testing.expectEqual(semver.isValidVersion("9999999999999999.9999999999999999.9999999999999999"), error.InvalidVersionFormat);
}
