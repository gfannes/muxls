const std = @import("std");
const builtin = @import("builtin");

const rubr = @import("rubr");

const cfg = @import("cfg.zig");
const lsp = @import("lsp.zig");

pub const Error = error{
    ExpectedStdErr,
};

pub const App = struct {
    const Self = @This();
    const Servers = std.ArrayList(lsp.Server);

    log: rubr.log.Log = .{},

    gpa: std.heap.GeneralPurposeAllocator(.{}) = .{},
    a: std.mem.Allocator = undefined,

    config: cfg.Config = .{},
    config_loader: cfg.Loader = undefined,

    do_continue: bool = true,
    server: rubr.lsp.Server = undefined,
    servers: Servers = undefined,

    pub fn init(self: *Self) !void {
        self.log.init();
        // try self.log.toFile("/tmp/muxls.log");

        self.a = self.gpa.allocator();

        self.config_loader = cfg.Loader.init(&self.config, &self.log, self.a);

        self.server = rubr.lsp.Server.init(std.io.getStdIn().reader(), std.io.getStdOut().writer(), self.log.writer(), self.a);
        self.servers = Servers.init(self.a);
    }
    pub fn deinit(self: *Self) void {
        for (self.servers.items) |*server|
            server.deinit();
        self.servers.deinit();

        self.server.deinit();

        self.config_loader.deinit();

        if (self.gpa.deinit() == std.heap.Check.leak)
            self.log.warning("Found memory leaks\n", .{}) catch {};

        self.log.deinit();
    }

    pub fn run(self: *Self) !void {
        try self.loadConfig_();

        try self.spawnServers_();

        var iteration: usize = 0;
        while (self.do_continue) : (iteration += 1) {
            try self.log.info("Iteration {}\n", .{iteration});
            var aa = std.heap.ArenaAllocator.init(self.a);
            defer aa.deinit();
            const aaa = aa.allocator();
            _ = aaa;

            if (self.server.receive()) |request| {
                try self.log.info("Request {s}\n", .{request.method});
                for (self.servers.items) |*server| {
                    try server.client.send(request.*);
                }
            } else |_| {
                self.do_continue = false;
            }
        }
    }

    fn spawnServers_(self: *Self) !void {
        for (self.config.servers) |cfg_server| {
            try self.log.info("Spawning server '{s}'\n", .{cfg_server.name});

            var server = try lsp.Server.init(cfg_server.name, cfg_server.cmd, self.a);
            errdefer server.deinit();

            try self.log.info("Server has id {}\n", .{server.process.id});

            try self.servers.append(server);
        }
    }

    fn loadConfig_(self: *Self) !void {
        // &todo: Replace hardcoded HOME folder
        // &:zig:build:info Couple filename with build.zig.zon#name
        const fp = if (builtin.os.tag == .macos) "/Users/geertf/.config/muxls/config.zon" else "/home/geertf/.config/muxls/config.zon";

        try self.config_loader.loadFromFile(fp);

        try self.log.info("Loaded config from '{s}'\n", .{fp});
    }
};
