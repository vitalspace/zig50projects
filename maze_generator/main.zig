const std = @import("std");

const rows: i32 = 25;
const cols: i32 = 25;

var maze: [rows][cols]i32 = undefined;

pub fn initializeMaze() void {
    var i: u32 = 0;
    while (i < rows) : (i += 1) {
        var j: u32 = 0;
        while (j < cols) : (j += 1) {
            maze[i][j] = 1;
        }
    }
}

fn printMaze() void {
    var i: u32 = 0;
    while (i < rows) : (i += 1) {
        var j: u32 = 0;
        while (j < cols) : (j += 1) {
            const rs = if (maze[i][j] == 1) "#" else ".";
            std.debug.print("{s} ", .{rs});
        }
        std.debug.print("\n", .{});
    }
}

fn isValid(x: i32, y: i32) i32 {
    return @intFromBool(((((x > @as(i32, 0)) and (x < @as(i32, rows))) and (y > @as(i32, 0))) and (y < @as(i32, cols))) and (maze[@as(usize, @intCast(x))][@as(usize, @intCast(y))] == @as(i32, 1)));
}

fn generateMaze(x: i32, y: i32) void {
    var dx = [_]i32{ 2, 0, -2, 0 };
    var dy = [_]i32{ 0, 2, 0, -2 };

    var direction = [4]i32{ 0, 1, 2, 3 };

    var seed: u64 = undefined;
    std.os.getrandom(std.mem.asBytes(&seed)) catch unreachable;
    var prng = std.rand.DefaultPrng.init(seed);

    {
        var i: u32 = 3;
        while (i > 0) : (i -= 1) {
            var j = prng.random().int(u32) % (i + 1);
            var temp = direction[i];
            direction[i] = direction[j];
            direction[j] = temp;
        }
    }

    {
        var i: u32 = 0;
        while (i < 4) : (i += 1) {
            var nx = x + dx[@as(usize, @intCast(direction[i]))];
            var ny = y + dy[@as(usize, @intCast(direction[i]))];
            if (isValid(nx, ny) != 0) {
                maze[@as(usize, @intCast(nx))][@as(usize, @intCast(ny))] = 0;
                maze[@as(usize, @intCast(x + @divTrunc(nx - x, @as(i32, 2))))][@as(usize, @intCast(y + @divTrunc(ny - y, @as(i32, 2))))] = 0;
                generateMaze(nx, ny);
            }
        }
    }
}

pub fn main() !void {
    initializeMaze();
    var startX: i32 = 1;
    var startY: i32 = 1;
    maze[@as(usize, @intCast(startX))][@as(usize, @intCast(startY))] = 0;
    generateMaze(startX, startY);
    printMaze();
}
