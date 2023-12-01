const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 142);
    try test_process("test2_part2.txt", 281);
    const real_sum = try process("input.txt");
    std.debug.print("The sum for part 1 is {d}.\n", .{real_sum});
    const real_sum_pt2 = try process("input_part2.txt");
    std.debug.print("The sum for part 2 is {d}.\n", .{real_sum_pt2});
}

fn test_process(filename: []const u8, answer: u64) !void {
    const test_sum = try process(filename);
    if (test_sum == answer) {
        std.debug.print("TEST PASSED\n", .{});
    } else {
        std.debug.print("TEST FAILED, got {d} not {d}.\n", .{ test_sum, answer });
        return error.TestFailed;
    }
}

fn process(filename: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var sum: u64 = 0;
    var digit_head: u8 = 10;
    var digit_last: u8 = 10;
    var ch: u8 = undefined;
    //std.debug.print("START\n", .{});
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch >= '0' and ch <= '9') {
            if (digit_head == 10) {
                digit_head = ch - '0';
            }
            digit_last = ch - '0';
        }
        if (ch == '\n') {
            if (digit_last == 10) continue;
            //std.debug.print("{d} {d}\n", .{ digit_head, digit_last });
            sum += (digit_head * 10) + digit_last;
            digit_head = 10;
            digit_last = 10;
        }
    }
    return sum;
}
