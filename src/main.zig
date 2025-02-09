const std = @import("std");
const cli = @import("zig-cli");

var config = struct {
    init_path: []const u8 = undefined,
    snapshot_comment: ?[]const u8 = null,
    rollback_version: []const u8 = undefined,
    rollback_path: []const u8 = undefined,
    list_path: ?[]const u8 = null,
}{};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var r = try cli.AppRunner.init(allocator);
    defer r.deinit();

    const init_cmd = cli.Command{
        .name = "init",
        .description = "Initialize new filesystem",
        .options = try r.allocOptions(&.{
            .{
                .long_name = "path",
                .help = "Path to initialize",
                .required = true,
                .value_ref = r.mkRef(&config.init_path),
            },
        }),
        .target = .{ .action = .{ .exec = handleInit } },
    };

    const snapshot_cmd = cli.Command{
        .name = "snapshot",
        .description = "Create new snapshot",
        .options = try r.allocOptions(&.{
            .{
                .long_name = "comment",
                .short_name = 'c',
                .help = "Snapshot description",
                .value_ref = r.mkRef(&config.snapshot_comment),
            },
        }),
        .target = .{ .action = .{ .exec = handleSnapshot } },
    };

    const rollback_cmd = cli.Command{
        .name = "rollback",
        .description = "Restore path to version",
        .options = try r.allocOptions(&.{
            .{
                .long_name = "version",
                .help = "Target version ID",
                .required = true,
                .value_ref = r.mkRef(&config.rollback_version),
            },
            .{
                .long_name = "path",
                .help = "Path to restore",
                .required = true,
                .value_ref = r.mkRef(&config.rollback_path),
            },
        }),
        .target = .{ .action = .{ .exec = handleRollback } },
    };

    const list_cmd = cli.Command{
        .name = "list",
        .description = "List versions/history",
        .options = try r.allocOptions(&.{
            .{
                .long_name = "path",
                .help = "Path to inspect (optional)",
                .value_ref = r.mkRef(&config.list_path),
            },
        }),
        .target = .{ .action = .{ .exec = handleList } },
    };

    const app = cli.App{
        .command = .{
            .name = "verdis",
            .description = "Version-controlled disk system",
            .subcommands = try r.allocCommands(&.{
                init_cmd,
                snapshot_cmd,
                rollback_cmd,
                list_cmd,
            }),
        },
    };

    try r.run(&app);
}

fn handleInit() !void {
    std.debug.print("Initializing repository at: {s}\n", .{config.init_path});
    // TODO: Write to image file/device.
    // TODO: Generate genesis version ID.
}

fn handleSnapshot() !void {
    const comment = config.snapshot_comment orelse "no comment";
    std.debug.print("Creating snapshot: {s}\n", .{comment});
    // TODO: Capture current state.
    // TODO: Generate version ID.
}

fn handleRollback() !void {
    std.debug.print("Rolling back {s} to version {s}\n", .{
        config.rollback_path,
        config.rollback_version,
    });
    // TODO: Validate version exists.
    // TODO: Restore file/directory state.
}

fn handleList() !void {
    if (config.list_path) |path| {
        std.debug.print("Showing history for: {s}", .{path});
        // TODO: Display version history for path.
    } else {
        std.debug.print("Listing all versions:\n", .{});
        // TODO: Display all snapshots.
    }
}
