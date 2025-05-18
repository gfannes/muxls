const std = @import("std");
const builtin = @import("builtin");

const rubr = @import("rubr");

const cfg = @import("cfg.zig");

pub const App = struct {
    const Self = @This();

    log: rubr.log.Log = .{},

    gpa: std.heap.GeneralPurposeAllocator(.{}) = .{},
    a: std.mem.Allocator = undefined,

    config: cfg.Config = .{},
    config_loader: cfg.Loader = undefined,

    server: rubr.lsp.Server = undefined,
    do_continue: bool = true,

    pub fn init(self: *Self) !void {
        self.log.init();
        try self.log.toFile("/tmp/muxls.log");

        self.a = self.gpa.allocator();

        self.config_loader = cfg.Loader.init(&self.config, self.a);

        self.server = rubr.lsp.Server.init(std.io.getStdIn().reader(), std.io.getStdOut().writer(), self.log.writer(), self.a);
    }
    pub fn deinit(self: *Self) void {
        self.server.deinit();

        self.config_loader.deinit();

        if (self.gpa.deinit() == std.heap.Check.leak)
            self.log.warning("Found memory leaks\n", .{}) catch {};

        self.log.info("Everything went OK.\n", .{}) catch {};
        self.log.deinit();
    }

    pub fn run(self: *Self) !void {
        try self.loadConfig_();

        var iteration: usize = 0;
        while (self.do_continue) : (iteration += 1) {
            try self.log.info("Iteration {}\n", .{iteration});

            if (self.server.receive()) |_| {} else |_| {}
        }
    }

    fn loadConfig_(self: *Self) !void {
        // &todo: Replace hardcoded HOME folder
        // &:zig:build:info Couple filename with build.zig.zon#name
        const fp = if (builtin.os.tag == .macos) "/Users/geertf/.config/champ/config.zon" else "/home/geertf/.config/champ/config.zon";

        try self.config_loader.loadFromFile(fp);
    }
};
