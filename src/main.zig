const std = @import("std");
const cova = @import("cova");

const CommandT = cova.Command.Custom(.{
    .global_help_prefix = "Verdis - Version-controlled disk system",
});

const InitOptions = struct {
    path: []const u8,
};

const SnapshotOptions = struct {
    comment: ?[]const u8 = null,
};

const RollbackOptions = struct {
    version: []const u8,
    path: []const u8,
};

const ListOptions = struct {
    path: ?[]const u8 = null,
};

fn handleRoot(cmd: *CommandT) !void {
    // Show help when no subcommand provided
    try cmd.help(std.io.getStdOut().writer());
    return error.MissingSubcommand;
}

const root_cmd = CommandT.from(@TypeOf(handleRoot), .{
    .cmd_name = "verdis",
    .cmd_description = "Version-controlled storage system with snapshot capabilities",
    .sub_descriptions = &.{
        .{ "init", "Initialize new filesystem" },
        .{ "snapshot", "Create new snapshot" },
        .{ "rollback", "Restore path to version" },
        .{ "list", "List versions/history" },
    },
    .sub_cmds = &.{
        CommandT.from(InitOptions, .{
            .cmd_name = "init",
            .cmd_description = "Initialize new repository",
            .value_refs = &.{
                .{ .name = "path", .descritpion = "Path to initialize", .required = true },
            },
        }),
        CommandT.from(SnapshotOptions, .{
            .cmd_name = "snapshot",
            .cmd_description = "Create new snapshot",
            .value_refs = &.{
                .{ .name = "comment", .descritpion = "Snapshot description", .short_name = 'c' },
            },
        }),
        CommandT.from(RollbackOptions, .{
            .cmd_name = "rollback",
            .cmd_description = "Restore path to version",
            .value_refs = &.{
                .{ .name = "version", .descritpion = "Target version ID", .required = true },
                .{ .name = "path", .descritpion = "Path to restore", .required = true },
            },
        }),
        CommandT.from(ListOptions, .{
            .cmd_name = "list",
            .cmd_description = "List versions/history",
            .value_refs = &.{
                .{ "path", "Path to inspect (optional)" },
            },
        }),
    },
    .action = .{ .handler = handleRoot }, // Connect root handler
});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var cmd = try root_cmd.init(allocator, .{});
    defer cmd.deinit();

    var args_iter = try cova.ArgIteratorGeneric.init(allocator);
    defer args_iter.deinit();

    try cova.parseArgs(&args_iter, CommandT, &cmd, std.io.getStdOut().writer(), .{});

    // Execute the matched command
    if (cmd.hasSubCmd()) {
        try handleCommand(cmd);
    } else {
        try handleRoot(cmd); // Handle bare 'verdis' command
    }
}

fn handleCommand(cmd: *CommandT) !void {
    if (cmd.matchSubCmd("init")) |subcmd| {
        const opts = try subcmd.to(InitOptions, .{});
        return handleInit(opts);
    }
    if (cmd.matchSubCmd("snapshot")) |subcmd| {
        const opts = try subcmd.to(SnapshotOptions, .{});
        return handleSnapshot(opts);
    }
    if (cmd.matchSubCmd("rollback")) |subcmd| {
        const opts = try subcmd.to(RollbackOptions, .{});
        return handleRollback(opts);
    }
    if (cmd.matchSubCmd("list")) |subcmd| {
        const opts = try subcmd.to(ListOptions, .{});
        return handleList(opts);
    }
}

fn handleInit(opts: InitOptions) !void {
    std.debug.print("Initializing repository at: {s}\n", .{opts.path});
    // TODO: Write to image file/device
}

fn handleSnapshot(opts: SnapshotOptions) !void {
    const comment = opts.comment orelse "no comment";
    std.debug.print("Creating snapshot: {s}\n", .{comment});
    // TODO: Capture current state
}

fn handleRollback(opts: RollbackOptions) !void {
    std.debug.print("Rolling back {s} to version {s}\n", .{
        opts.path,
        opts.version,
    });
    // TODO: Validate version exists
}

fn handleList(opts: ListOptions) !void {
    if (opts.path) |path| {
        std.debug.print("Showing history for: {s}\n", .{path});
    } else {
        std.debug.print("Listing all versions:\n", .{});
        // TODO: List all snapshots
    }
}
