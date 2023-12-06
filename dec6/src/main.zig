const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 42);
    const real_sum = try process("input.txt");
    std.debug.print("The sum for part 1 is {d}.\n", .{real_sum});
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
    _ = filename;
    return 42;
}
