const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 6);
    const real_sum = try process("input.txt");
    std.debug.print("The answer for part 2 is {d}.\n", .{real_sum});
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

const Ident = [3]u8;

fn process(filename: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("MEMORY LEAK DETECTED!");
    }
    var transition = std.AutoHashMap(Ident, struct { Ident, Ident }).init(alloc);
    defer transition.deinit();
    var directions = std.ArrayList(u8).init(alloc);
    defer directions.deinit();
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var reader = file.reader();
    var ch: u8 = undefined;
    var reading_directions: bool = true;
    var nothing_so_far = true;
    var transition_line = [11]u8{
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
        undefined,
    };
    var transition_line_i: u8 = 0;
    while (true) {
        ch = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        if (ch == '\n') {
            if (nothing_so_far) {
                reading_directions = false;
            } else if (!reading_directions) {
                var spliterator = std.mem.split(u8, &transition_line, ",");
                var i: u8 = 0;
                var src: Ident = undefined;
                var dst_l: Ident = undefined;
                var dst_r: Ident = undefined;
                while (spliterator.next()) |part| {
                    switch (i) {
                        0 => {
                            for (0..3) |j| src[j] = part[j];
                        },
                        1 => {
                            for (0..3) |j| dst_l[j] = part[j];
                        },
                        2 => {
                            for (0..3) |j| dst_r[j] = part[j];
                        },
                        else => {},
                    }
                    i += 1;
                }
                try transition.put(src, .{ dst_l, dst_r });
            }
            nothing_so_far = true;
            transition_line_i = 0;
            continue;
        } else {
            nothing_so_far = false;
        }
        if (reading_directions) {
            try directions.append(ch);
        } else {
            transition_line[transition_line_i] = ch;
            transition_line_i += 1;
        }
    }
    return 42;
}
