const std = @import("std");

pub const Config = struct {
    pub const Server = struct {
        name: []const u8,
        cmd: []const u8,
        args: ?[][]const u8,
    };
    pub const Language = struct {
        name: []const u8,
        extensions: [][]const u8,
        servers: [][]const u8,
    };

    servers: []Server = &.{},
    languages: []Language = &.{},
};

pub const Loader = struct {
    const Self = @This();

    config: *Config,
    aa: std.heap.ArenaAllocator = undefined,

    pub fn init(config: *Config, a: std.mem.Allocator) Self {
        return Self{ .config = config, .aa = std.heap.ArenaAllocator.init(a) };
    }
    pub fn deinit(self: *Self) void {
        self.aa.deinit();
    }

    // For some reason, std.zon.parse.fromSlice() expects a sentinel string
    pub fn loadFromContent(self: *Self, content: [:0]const u8) !void {
        self.config.* = try std.zon.parse.fromSlice(Config, self.aa.allocator(), content, null, .{});

        try self.normalize();
    }

    pub fn loadFromFile(self: *Self, filename: []const u8) !void {
        var file = try std.fs.openFileAbsolute(filename, .{});
        defer file.close();

        // For some reason, std.zon.parse.fromSlice() expects a sentinel string
        const content = try file.readToEndAllocOptions(self.aa.allocator(), std.math.maxInt(usize), null, 1, 0);

        try self.loadFromContent(content);
    }

    // - Rework include extensions from 'md' to '.md'
    fn normalize(self: *Self) !void {
        const a = self.aa.allocator();
        for (self.config.languages) |*language| {
            const new_extensions = try a.alloc([]const u8, language.extensions.len);
            for (language.extensions, 0..) |ext, ix| {
                new_extensions[ix] = if (ext.len > 0 and ext[0] != '.')
                    try std.mem.concat(a, u8, &[_][]const u8{ ".", ext })
                else
                    ext;
            }
            language.extensions = new_extensions;
        }
    }
};

test "cfg" {
    const ut = std.testing;
    try ut.expect(false);
}
