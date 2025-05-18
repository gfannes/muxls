const std = @import("std");

pub const app = @import("app.zig");
pub const cfg = @import("cfg.zig");

test {
    const ut = std.testing;
    ut.refAllDecls(app);
    ut.refAllDecls(cfg);
}
