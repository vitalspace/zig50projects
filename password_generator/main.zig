const std = @import("std");

pub fn main() !void {
    var seed = std.math.cast(u64, std.time.microTimestamp()).?;

    var prng = std.rand.DefaultPrng.init(seed);
    var caracteres = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+";
    var password: [12]u8 = undefined;

    for (&password) |*char| {
        var index = prng.random().int(u64) % caracteres.len;
        char.* = caracteres[index];
    }

    std.debug.print("Tu nueva contraseña es: {s}\n", .{password});
}
