const std = @import("std");
const debug = @import("debug.zig");
const images = @import("images.zig");
const colors = @import("colors.zig");
const modules = @import("modules.zig");
const scripting = @import("scripting/manager.zig");

// Main systems
const app_backend = @import("platform/app.zig");
const input = @import("platform/input.zig");
const audio = @import("platform/audio.zig");

pub var assets_path: [:0]const u8 = "assets";

pub const AppConfig = struct {
    title: [:0]const u8 = "Delve Framework",

    width: i32 = 960,
    height: i32 = 540,

    target_fps: ?i32 = null,
    use_fixed_timestep: bool = false,
    fixed_timestep_delta: f32 = 1.0 / 60.0,

    // maximum sizes for graphics buffers
    buffer_pool_size: i32 = 512,
    shader_pool_size: i32 = 512,
    pipeline_pool_size: i32 = 512,
    image_pool_size: i32 = 256,
    sampler_pool_size: i32 = 128,
    pass_pool_size: i32 = 32,
};

pub fn setAssetsPath(path: [:0]const u8) !void {
    assets_path = path;
}

pub fn start(config: AppConfig) !void {
    debug.init();
    defer debug.deinit();

    debug.log("Delve Framework Starting", .{});

    // App backend init
    try app_backend.init();
    defer app_backend.deinit();

    // Change the working dir to where the assets are
    debug.log("Assets Path: {s}", .{assets_path});
    const chdir_res = std.c.chdir(assets_path);
    if (chdir_res == -1) return error.Oops;

    // Kick off the game loop! This will also start and stop the subsystems.
    app_backend.startMainLoop(config);

    debug.log("Delve framework stopping", .{});
}

pub fn startSubsystems() !void {
    try colors.init();
    try input.init();
    try scripting.init();
    try audio.init();
}

pub fn stopSubsystems() void {
    colors.deinit();
    input.deinit();
    scripting.deinit();
    audio.deinit();
}
