const std = @import("std");

const rubr = @import("rubr");

pub const App = struct {
    const Self = @This();

    log: rubr.log.Log = .{},
    gpa: std.heap.GeneralPurposeAllocator(.{}) = .{},

    a: std.mem.Allocator = undefined,

    pub fn init(self: *Self) !void {
        self.log.init();
        try self.log.toFile("/tmp/muxls.log");

        self.a = self.gpa.allocator();
    }
    pub fn deinit(self: *Self) void {
        if (self.gpa.deinit() == std.heap.Check.leak)
            self.log.warning("Found memory leaks\n", .{}) catch {};

        self.log.info("Everything went OK.\n", .{}) catch {};
        self.log.deinit();
    }

    pub fn run(self: *Self) !void {
        _ = self;
    }
};
