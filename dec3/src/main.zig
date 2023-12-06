const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 10, 4361);
    const real_answer = try process("input.txt", 140);
    std.debug.print("The answer for part 1 is {d}.\n", .{real_answer});
}

fn test_process(filename: []const u8, comptime size: u64, answer: u64) !void {
    const test_sum = try process(filename, size);
    if (test_sum == answer) {
        std.debug.print("TEST PASSED\n", .{});
    } else {
        std.debug.print("TEST FAILED, got {d} not {d}.\n", .{ test_sum, answer });
        return error.TestFailed;
    }
}

fn process(filename: []const u8, comptime size: u64) !u64 {
    var grid = std.mem.zeroes([size][size]u8);
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
            if (ch == '\n') {
                y += 1;
                x = 0;
            } else {
                grid[y][x] = ch;
                x += 1;
            }
        }
    }
    var answer: u64 = 0;
    var to_skip: usize = 0;
    for (0..size) |y| {
        for (0..size) |x| {
            if (to_skip > 0) {
                to_skip -= 1;
                continue;
            }
            const here = grid[y][x];
            var numch = here;
            var num: u64 = 0;
            var offset: usize = 0;
            while (isNumber(numch)) {
                num *= 10;
                num += numch - '0';
                offset += 1;
                if (((x + offset) >= 0) and ((x + offset) < size)) {
                    numch = grid[y][x + offset];
                } else {
                    numch = 0;
                }
            }
            to_skip = offset;
            if (num > 0) {
                var found = false;
                for (0..(offset + 2)) |x_offset| {
                    for (0..3) |y_offset| {
                        if (((x + x_offset) < 1) or ((x + x_offset - 1) >= size)) {
                            continue;
                        }
                        if (((y + y_offset) < 1) or ((y + y_offset - 1) >= size)) {
                            continue;
                        }
                        var inspected = grid[y + y_offset - 1][x + x_offset - 1];
                        if ((inspected < '0' or inspected > '9') and inspected != '.') {
                            found = true;
                        }
                    }
                }
                if (found) {
                    answer += num;
                }
            }
        }
    }
    return answer;
}

fn isNumber(ch: u8) bool {
    return (ch >= '0' and ch <= '9');
}
