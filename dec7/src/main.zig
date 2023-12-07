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
    var ranked = std.mem.zeroes([n]Line);
    var n_ranked: usize = 0;
    for (lines) |line| {
        var position = 0;
        while (beats(line.hand, ranked[position].hand) and (position <= n_ranked)) {
            position += 1;
        }
        for (position..n_ranked) |i| {
            ranked[i + 1] = ranked[i];
        }
        ranked[position] = line;
        n_ranked += 1;
    }
    var sum: u64 = 0;
    for (0..n) |i| {
        sum += ranked[i].bid * i;
    }
    return sum;
}

fn beats(a: [5]u8, b: [5]u8) bool {
    const a_class = assignClass(a);
    const b_class = assignClass(b);
    if (a_class > b_class) {
        return true;
    }
    if (a_class < b_class) {
        return false;
    }
    return beatsGivenSameClass(a, b);
}

fn assignClass(a: [5]u8) u8 {
    if (n_of_a_kind(a, 5)) return 7;
    if (n_of_a_kind(a, 4)) return 6;
    if (full_house(a)) return 5;
    if (n_of_a_kind(a, 3)) return 4;
    if (n_pair(a, 2)) return 3;
    if (n_pair(a, 1)) return 2;
    return 1;
}

fn n_of_a_kind(a: [5]u8, n: u8) bool {
    var n_same: usize = 0;
    for (0..5) |card_i| {
        const card = a[card_i];
        var matches = false;
        for (0..card_i) |other_card_i| {
            const other_card = a[other_card_i];
            if (card == other_card) {
                matches = true;
                break;
            }
        }
        if (matches) {
            n_same += 1;
        }
    }
    return n_same == n;
}

fn full_house(a: [5]u8) bool {
    var n_l1: usize = 0;
    var n_l2: usize = 0;
    const l1 = a[0];
    var l2 = 0;
    for (a) |card| {
        if (card != l1) {
            l2 = card;
            break;
        }
    }
    if (l2 == 0) return false;
    for (a) |card| {
        _ = card;
        if (a == l1) n_l1 += 1;
        if (a == l2) n_l2 += 1;
    }
    return ((n_l1 == 2) and (n_l2 == 3)) or ((n_l1 == 3) and (n_l2 == 2));
}

fn n_pair(a: [5]u8, n: u8) bool {
    _ = n;
    _ = a;
}
