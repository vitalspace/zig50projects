const std = @import("std");
const c = @cImport({
    @cInclude("arpa/inet.h");
    @cInclude("unistd.h");
});

pub fn main() void {
    var server_fd: i32 = undefined;
    var new_socket: i32 = undefined;
    var address = c.sockaddr_in{
        .sin_family = c.AF_INET,
        .sin_port = c.htons(8080),
        .sin_addr = c.in_addr{
            .s_addr = c.INADDR_ANY,
        },
        .sin_zero = [_]u8{0} ** 8,
    };
    var addrlen: c.socklen_t = @sizeOf(c.sockaddr_in);

    server_fd = c.socket(c.AF_INET, c.SOCK_STREAM, 0);
    if (server_fd == 0) {
        std.debug.print("Failed to create socket\n", .{});
        return error.SocketCreationFailed;
    }

    if (c.bind(server_fd, @as(*c.sockaddr, @ptrCast(&address)), addrlen) < 0) {
        std.debug.print("Failed to bind\n", .{});
        return error.BindFailed;
    }

    if (c.listen(server_fd, 10) < 0) {
        std.debug.print("Failed to listen\n", .{});
        return error.ListenFailed;
    }

    while (true) {
        std.debug.print("Waiting for new connection\n", .{});
        new_socket = c.accept(server_fd, @as(*c.sockaddr, @ptrCast(&address)), &addrlen);
        if (new_socket < 0) {
            std.debug.print("Failed to accept\n", .{});
            return error.AcceptFailed;
        }

        var buffer: [2048]u8 = undefined;
        const bytesRead = c.read(new_socket, &buffer, buffer.len);
        if (bytesRead < 0) {
            std.debug.print("Failed to read\n", .{});
            return error.ReadFailed;
        }
        std.debug.print("Received: {s}\n", .{std.mem.sliceTo(buffer[0..@as(usize, @intCast(bytesRead))], 0)});

        const response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello, world!\n";
        _ = c.write(new_socket, response, @as(usize, response.len));
        std.debug.print("Message sent\n", .{});
        _ = c.close(new_socket);
    }
}

//  zig run main.zig -lc
