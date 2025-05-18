const std = @import("std");

const rubr = @import("rubr");

pub const Server = struct {
    const Self = @This();

    name: []const u8,
    process: std.process.Child,
    client: rubr.lsp.Client,

    pub fn init(name: []const u8, argv: [][]const u8, a: std.mem.Allocator) !Self {
        var process = std.process.Child.init(argv, a);
        process.stdin_behavior = std.process.Child.StdIo.Pipe;
        process.stdout_behavior = std.process.Child.StdIo.Pipe;
        // process.stderr_behavior = std.process.Child.StdIo.Pipe;
        try process.spawn();
        return Self{
            .name = name,
            .process = process,
            .client = rubr.lsp.Client.init((process.stdout orelse unreachable).reader(), (process.stdin orelse unreachable).writer(), null, a),
        };
    }
    pub fn deinit(self: *Self) void {
        _ = self.process.kill() catch {};
    }
};
