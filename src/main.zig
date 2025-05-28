const std = @import("std");

pub fn main() !void {
    const adress = try std.net.Address.parseIp4("127.0.0.1", 8080);
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();


    var server = try adress.listen(std.net.Address.ListenOptions{});
    defer server.deinit();

    while (true) {
        try handle_connections(try server.accept(), allocator);
    }
}

fn handle_connections(conn: std.net.Server.Connection, allocator: std.mem.Allocator) !void {
    defer conn.stream.close();

    var buffer: [1024]u8 = undefined;
    var http_server = std.http.Server.init(conn, &buffer);
    var req = try http_server.receiveHead();

    const file = try read_file("index.html", allocator);
    try req.respond(file, std.http.Server.Request.RespondOptions{});
}

fn read_file(path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
