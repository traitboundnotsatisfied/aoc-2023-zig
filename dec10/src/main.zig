const std = @import("std");

const Dir = struct { i8, i8 };

pub fn main() !void {
    try test_process("test.txt", Dir{ 0, -1 }, 5, 8);
    const real_sum = try process("input.txt", Dir{ 0, -1 }, 140);
    std.debug.print("The answer for part 1 is {d}.\n", .{real_sum});
}

fn test_process(filename: []const u8, face: Dir, comptime n: comptime_int, answer: i64) !void {
    const test_sum = try process(filename, face, n);
    if (test_sum == answer) {
        std.debug.print("TEST PASSED\n", .{});
    } else {
        std.debug.print("TEST FAILED, got {d} not {d}.\n", .{ test_sum, answer });
        return error.TestFailed;
    }
}

const Ident = [3]u8;

fn process(filename: []const u8, face: Dir, comptime n: comptime_int) !u64 {
    var grid = std.mem.zeroes([n][n]u8);
    var currx: isize = undefined;
    var curry: isize = undefined;
    {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();
        var reader = file.reader();
        var ch: u8 = undefined;
        var x: usize = 0;
        var y: usize = 0;
        while (true) {
            ch = reader.readByte() catch |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            };
            if (ch == 'S') {
                currx = @intCast(x);
                curry = @intCast(y);
            }
            if (ch == '\n') {
                x = 0;
                y += 1;
            } else {
                grid[y][x] = ch;
                x += 1;
            }
        }
    }
    for (0..n) |y| {
        for (0..n) |x| std.debug.print("{s}", .{[1]u8{grid[y][x]}});
        std.debug.print("\n", .{});
    }
    std.debug.print("end grid\n", .{});
    var facing = face;
    var length: u64 = 0;
    var not_first: bool = false;
    while (true) {
        const at = grid[@intCast(curry)][@intCast(currx)];
        std.debug.print("{s}", .{[1]u8{at}});
        switch (at) {
            '|', '-' => {},
            'S' => if (not_first) break,
            'J' => {
                if (facing[0] != 0) {
                    facing = Dir{ 0, 1 };
                } else {
                    facing = Dir{ -1, 0 };
                }
            },
            'F' => {
                if (facing[0] != 0) {
                    facing = Dir{ 0, -1 };
                } else {
                    facing = Dir{ 1, 0 };
                }
            },
            '7' => {
                if (facing[0] != 0) {
                    facing = Dir{ 0, -1 };
                } else {
                    facing = Dir{ -1, 0 };
                }
            },
            'L' => {
                if (facing[0] != 0) {
                    facing = Dir{ 0, 1 };
                } else {
                    facing = Dir{ 1, 0 };
                }
            },
            '.' => @panic("hit ground"),
            else => @panic("unexpected character"),
        }
        length += 1;
        currx += @intCast(facing[0]);
        curry -= @intCast(facing[1]);
        not_first = true;
    }
    std.debug.print("\n", .{});
    return length / 2;
}
