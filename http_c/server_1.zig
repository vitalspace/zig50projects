const std = @import("std");

const c = @cImport({
    @cInclude("arpa/inet.h");
    @cInclude("unistd.h");
    @cInclude("sys/socket.h");
});

pub const Server = struct {
    // address: c.sockaddr_in,
    var server_fd: i32 = undefined;
    var new_socket: i32 = undefined;
    var address = c.sockaddr_in{ .sin_family = c.AF_INET, .sin_addr = c.in_addr{ .s_addr = c.INADDR_ANY }, .sin_zero = [_]u8{0} ** 8 };
    var addrlen: c.socklen_t = @sizeOf(c.sockaddr_in);
    // const this = @This();
    pub fn setPort(this: @This(), port: u16) void {
        _ = this;
        address.sin_port = c.htons(port);
    }

    pub fn start(this: @This()) !void {
        _ = this;

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
    }

    pub const HandleRequestError = error{AcceptFailed};

    pub fn handleRequest(this: @This(), handler: *const fn (i32) void) !void {
        _ = this;

        while (true) {
            new_socket = c.accept(server_fd, @as(*c.sockaddr, @ptrCast(&address)), &addrlen);
            if (new_socket < 0) {
                std.debug.print("Failed to accept\n", .{});
                return error.AcceptFailed;
            }

            handler(new_socket);
        }
    }
};

pub fn myHandler(new_socket: i32) void {
    var buffer: [2048]u8 = undefined;
    const bytesRead = c.read(new_socket, &buffer, buffer.len);
    if (bytesRead < 0) {
        std.debug.print("Failed to read\n", .{});
        return;
    }
    std.debug.print("Received: {s}\n", .{std.mem.sliceTo(buffer[0..@as(usize, @intCast(bytesRead))], 0)});

    const response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello, world!\n";
    _ = c.write(new_socket, response, @as(usize, response.len));
    std.debug.print("Message sent\n", .{});
    _ = c.close(new_socket);
}

pub fn main() !void {
    const sv = Server{};

    sv.setPort(4000);
    try sv.start();
    std.debug.print("me cumplo\n", .{});
    try sv.handleRequest(myHandler);
}
