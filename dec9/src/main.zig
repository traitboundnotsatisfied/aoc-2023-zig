const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 6, 114);
    const real_sum = try process("input.txt");
    std.debug.print("The answer for part 1 is {d}.\n", .{real_sum});
}

fn test_process(filename: []const u8, comptime n: comptime_int, answer: u64) !void {
    const test_sum = try process(filename, n);
    if (test_sum == answer) {
        std.debug.print("TEST PASSED\n", .{});
    } else {
        std.debug.print("TEST FAILED, got {d} not {d}.\n", .{ test_sum, answer });
        return error.TestFailed;
    }
}

const Ident = [3]u8;

fn process(filename: []const u8, comptime n: comptime_int) !u64 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var ch: u8 = undefined;
    var line = std.mem.zeroInit([n]i64, undefined);
    var line_i: usize = 0;
    var num: u64 = 0;
    var sum: i64 = 0;
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch == '\n') {
            sum += process_line(line, n);
            num = 0;
            line_i = 0;
        } else if (ch == ' ') {
            line[line_i] = num;
            line_i += 1;
            num = 0;
        } else if (ch >= '0' and ch <= '9') {
            num *= 10;
            num += ch - '0';
        }
    }
    return sum;
}

fn process_line(line_untyped: anytype, comptime n: comptime_int) i64 {
    const line = @as([n]i64, line_untyped);
    var diff = std.mem.zeroInit([n]i64, undefined);
    for (0..n) |i| diff[i] = line[i];
    var diff_len = n;
    var lasts = std.mem.zeroInit([n]i64, undefined);
    var lasts_i: usize = 0;
    while (!allZeroes(diff, n, diff_len)) {
        lasts[lasts_i] = diff[diff_len - 1];
        lasts_i += 1;
        for (0..(diff_len - 1)) |i| diff[i] = diff[i + 1] - diff[i];
        diff_len -= 1;
    }
    return extrapolate(lasts, lasts_i, n);
}

fn extrapolate(lasts_untyped: anytype, lasts_len: usize, comptime n: comptime_int) i64 {
    const lasts = @as([n]i64, lasts_untyped);
    var predicted: i64 = lasts[lasts_len - 1];
    var lasts_i: usize = lasts_len - 2;
    while (lasts_i >= 0) {
        predicted += lasts[lasts_i];
        lasts_i += 1;
    }
    return predicted;
}

fn allZeroes(arr: anytype, comptime n: comptime_int, n_use: usize) bool {
    for (@as([n]i64, arr)) |i| if (i < n_use and arr[i] != 0) return false;
    return true;
}
