const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 8);
    try test_process_part2("test.txt", 2286);
    const real_sum = try process("input.txt");
    std.debug.print("The sum for part 1 is {d}.\n", .{real_sum});
    const real_sum_part2 = try process_part2("input.txt");
    std.debug.print("The sum for part 2 is {d}.\n", .{real_sum_part2});
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

fn test_process_part2(filename: []const u8, answer: u64) !void {
    const test_sum = try process_part2(filename);
    if (test_sum == answer) {
        std.debug.print("TEST PASSED\n", .{});
    } else {
        std.debug.print("TEST FAILED, got {d} not {d}.\n", .{ test_sum, answer });
        return error.TestFailed;
    }
}

fn process(filename: []const u8) !u64 {
    const rgbpossible: struct { u64, u64, u64 } = .{ 12, 13, 14 };
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var id: u64 = 1;
    var sum_of_ids: u64 = 0;
    var last_space = false;
    var ch: u8 = undefined;
    var rgbcount: struct { u64, u64, u64 } = .{ 0, 0, 0 };
    var lastnum: u64 = 0;
    var possible = true;
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch == '\n') {
            if (possible) {
                sum_of_ids += id;
            }
            id += 1;
            possible = true;
            lastnum = 0;
            rgbcount = .{ 0, 0, 0 };
        }
        if (ch >= '0' and ch <= '9') {
            lastnum = (lastnum * 10) + (ch - '0');
        }
        if (ch == ';') {
            //std.debug.print("r: {d}, g: {d}, b: {d}\n", rgbcount);
            inline for (0..3) |i| {
                if (rgbcount[i] > rgbpossible[i]) {
                    possible = false;
                }
            }
            lastnum = 0;
            rgbcount = .{ 0, 0, 0 };
        }
        if (last_space) {
            if (ch == 'r') {
                rgbcount[0] += lastnum;
                lastnum = 0;
            }
            if (ch == 'g') {
                rgbcount[1] += lastnum;
                lastnum = 0;
            }
            if (ch == 'b') {
                rgbcount[2] += lastnum;
                lastnum = 0;
            }
        }
        last_space = (ch == ' ');
    }
    return sum_of_ids;
}

fn process_part2(filename: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var sum_of_powers: u64 = 0;
    var last_space = false;
    var ch: u8 = undefined;
    var rgbmax: struct { u64, u64, u64 } = .{ 0, 0, 0 };
    var rgbcount: struct { u64, u64, u64 } = .{ 0, 0, 0 };
    var lastnum: u64 = 0;
    var possible = true;
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch == '\n') {
            if (possible) {
                sum_of_powers += rgbmax[0] * rgbmax[1] * rgbmax[2];
            }
            possible = true;
            lastnum = 0;
            rgbcount = .{ 0, 0, 0 };
            rgbmax = .{ 0, 0, 0 };
        }
        if (ch >= '0' and ch <= '9') {
            lastnum = (lastnum * 10) + (ch - '0');
        }
        if (ch == ';') {
            //std.debug.print("r: {d}, g: {d}, b: {d}\n", rgbcount);
            inline for (0..3) |i| {
                if (rgbcount[i] > rgbmax[i]) {
                    rgbmax[i] = rgbcount[i];
                }
            }
            lastnum = 0;
            rgbcount = .{ 0, 0, 0 };
        }
        if (last_space) {
            if (ch == 'r') {
                rgbcount[0] += lastnum;
                lastnum = 0;
            }
            if (ch == 'g') {
                rgbcount[1] += lastnum;
                lastnum = 0;
            }
            if (ch == 'b') {
                rgbcount[2] += lastnum;
                lastnum = 0;
            }
        }
        last_space = (ch == ' ');
    }
    return sum_of_powers;
}
