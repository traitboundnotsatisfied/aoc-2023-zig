const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 6, false, 114);
    try test_process("test.txt", 6, true, 2);
    const real_sum = try process("input.txt", 21, false);
    std.debug.print("The answer for part 1 is {d}.\n", .{real_sum});
    const real_sum_part2 = try process("input.txt", 21, true);
    std.debug.print("The answer for part 2 is {d}.\n", .{real_sum_part2});
}

fn test_process(
    filename: []const u8,
    comptime n: comptime_int,
    comptime part2: bool,
    answer: i64,
) !void {
    const test_sum = try process(filename, n, part2);
    if (test_sum == answer) {
        std.debug.print("TEST PASSED\n", .{});
    } else {
        std.debug.print("TEST FAILED, got {d} not {d}.\n", .{ test_sum, answer });
        return error.TestFailed;
    }
}

const Ident = [3]u8;

fn process(filename: []const u8, comptime n: comptime_int, comptime part2: bool) !i64 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var ch: u8 = undefined;
    var line = std.mem.zeroes([n]i64);
    var line_i: usize = 0;
    var num: i64 = 0;
    var num_neg: bool = false;
    var sum: i64 = 0;
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch == '\n') {
            sum += process_line(line, n);
            num = 0;
            num_neg = false;
            line_i = 0;
        } else if (ch == ' ') {
            if (part2) {
                if (num_neg) {
                    line[n - line_i - 1] = -num;
                } else {
                    line[n - line_i - 1] = num;
                }
            } else {
                if (num_neg) {
                    line[line_i] = -num;
                } else {
                    line[line_i] = num;
                }
            }
            line_i += 1;
            num = 0;
            num_neg = false;
        } else if (ch >= '0' and ch <= '9') {
            num *= 10;
            num += ch - '0';
        } else if (ch == '-') {
            num_neg = true;
        }
    }
    return sum;
}

fn process_line(line_untyped: anytype, comptime n: comptime_int) i64 {
    const line = @as([n]i64, line_untyped);
    var diff = std.mem.zeroes([n]i64);
    for (0..n) |i| diff[i] = line[i];
    var diff_len: usize = @as(usize, n);
    var lasts = std.mem.zeroes([n]i64);
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
    std.debug.print("{d} | {d}", .{ lasts, lasts_len });
    var predicted: i64 = lasts[lasts_len - 1];
    var lasts_i: usize = lasts_len - 2;
    while (true) {
        predicted += lasts[lasts_i];
        if (lasts_i == 0) break;
        lasts_i -= 1;
    }
    std.debug.print(" -> {d}\n", .{predicted});
    return predicted;
}

fn allZeroes(arr: anytype, comptime n: comptime_int, n_use: usize) bool {
    for (0..n_use) |i| if (@as([n]i64, arr)[i] != 0) return false;
    return true;
}
