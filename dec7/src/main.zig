const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 5, 6440);
    const real_sum = try process("input.txt", 1000);
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

const Line = struct {
    hand: [5]u8,
    bid: u64,
};

fn process(filename: []const u8, comptime n: comptime_int) !u64 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var ch: u8 = undefined;
    var reading_bid = false;
    var bid: u64 = 0;
    var hand: [5]u8 = std.mem.zeroes([5]u8);
    var hand_i: usize = 0;
    var lines = std.mem.zeroes([n]Line);
    var lines_i: usize = 0;
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch == ' ') {
            reading_bid = true;
            bid = 0;
            continue;
        }
        if (ch == '\n') {
            // handle current line
            lines[lines_i] = Line{
                .hand = hand,
                .bid = bid,
            };
            // reset for next time
            reading_bid = false;
            hand = std.mem.zeroes([5]u8);
            hand_i = 0;
            continue;
        }
        if (reading_bid) {
            bid *= 10;
            bid += ch - '0';
        } else {
            hand[hand_i] = ch;
            hand_i += 1;
        }
    }
    return 42;
}
