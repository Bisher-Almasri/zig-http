const std = @import("std");

pub fn main() !void {
    const adress = try std.net.Address.parseIp4("127.0.0.1", 8080);
    
    var server = try adress.listen(std.net.Address.ListenOptions{});
    defer server.deinit();

    while (true) {
        try handle_connections(try server.accept());
    }
}

fn handle_connections(conn: std.net.Server.Connection) !void {
    defer conn.stream.close();

    var buffer: [1024]u8 = undefined;
    var http_server = std.http.Server.init(conn, &buffer);
    var req = try http_server.receiveHead();
    try req.respond("hello world\n", std.http.Server.Request.RespondOptions{});
}
