const std = @import("std");

pub fn main() !void {
    try test_process("test.txt", 5, 5905);
    const real_sum = try process("input.txt", 1000);
    std.debug.print("The answer for part 2 is {d}.\n", .{real_sum});
}

fn test_process(filename: []const u8, comptime n: comptime_int, answer: u64) !void {
    const test_sum = try process(filename, n);
    if (!beats("33332".*, "2AAAA".*)) return error.YourMom;
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
                .hand = pickJokerValues(hand),
                .bid = bid,
            };
            lines_i += 1;
            // std.debug.print("{s} -> {s}\n", .{ hand, ([_][]const u8{
            //     "<nothing>",
            //     "high card",
            //     "1 pair",
            //     "2 pair",
            //     "3 of a kind",
            //     "full house",
            //     "4 of a kind",
            //     "5 of a kind",
            // })[assignClass(hand)] });
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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("MEMORY LEAK");
    }
    for (lines) |line| {
        var position: usize = 0;
        while ((position < n_ranked) and beats(line.hand, ranked[position].hand)) {
            position += 1;
        }
        {
            var indices_to_shift = try alloc.alloc(usize, n_ranked - position);
            defer alloc.free(indices_to_shift);
            var index_index: usize = 0;
            for (position..n_ranked) |i| {
                indices_to_shift[index_index] = i;
                index_index += 1;
            }
            while (index_index > 0) {
                index_index -= 1;
                const i = indices_to_shift[index_index];
                ranked[i + 1] = ranked[i];
            }
        }
        ranked[position] = line;
        n_ranked += 1;
        std.debug.print("\r{d}/{d}             ", .{ n_ranked, n });
    }
    std.debug.print("\n", .{});
    var sum: u64 = 0;
    for (0..n) |i| {
        sum += ranked[i].bid * (i + 1);
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

fn beatsGivenSameClass(a: [5]u8, b: [5]u8) bool {
    for (0..5) |i| {
        if (cardBeats(a[i], b[i])) return true;
        if (cardBeats(b[i], a[i])) return false;
    }
    return false;
}

fn cardBeats(a: u8, b: u8) bool {
    return cardAsNumeric(a) > cardAsNumeric(b);
}

fn cardAsNumeric(a: u8) u8 {
    if (a >= '0' and a <= '9') {
        return a - '0';
    }
    return switch (a) {
        'T' => 10,
        'J' => 0,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        else => 255,
    };
}

fn pickJokerValues(a: [5]u8) [5]u8 {
    var max_val: u8 = 0;
    var best = std.mem.zeroes([5]u8);
    for (possibilities(a[0])) |c0| {
        for (possibilities(a[1])) |c1| {
            for (possibilities(a[2])) |c2| {
                for (possibilities(a[3])) |c3| {
                    for (possibilities(a[4])) |c4| {
                        const jokerless = [5]u8{
                            c0, c1, c2, c3, c4,
                        };
                        //std.debug.print("~> {d}\n", .{jokerless});
                        const val = assignClass(jokerless);
                        if (val > max_val) {
                            max_val = val;
                            best = jokerless;
                        }
                        if (a[4] != 'J') break;
                    }
                    if (a[3] != 'J') break;
                }
                if (a[2] != 'J') break;
            }
            if (a[1] != 'J') break;
        }
        if (a[0] != 'J') break;
    }
    return best;
}

fn possibilities(a: u8) [12]u8 {
    if (a == 'J') {
        return [12]u8{
            '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A',
        };
    } else {
        return [12]u8{
            a,
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
    }
}

fn assignClass(a: [5]u8) u8 {
    if (n_of_a_kind(a, 5)) return 7;
    if (n_of_a_kind(a, 4)) return 6;
    if (full_house(a)) return 5;
    if (n_of_a_kind(a, 3)) return 4;
    if (n_pair_oneortwo(a, 2)) return 3;
    if (n_pair_oneortwo(a, 1)) return 2;
    return 1;
}

fn n_of_a_kind(a: [5]u8, n: u8) bool {
    var n_same_max: usize = 0;
    for (0..5) |matching_on_i| {
        const matching_on = a[matching_on_i];
        var n_same: usize = 0;
        for (0..5) |card_i| {
            const card = a[card_i];
            if (card == matching_on) {
                n_same += 1;
            }
        }
        if (n_same > n_same_max) n_same_max = n_same;
    }
    return n_same_max == n;
}

fn full_house(a: [5]u8) bool {
    var n_l1: usize = 0;
    var n_l2: usize = 0;
    const l1 = a[0];
    var l2: u8 = 0;
    for (a) |card| {
        if (card != l1) {
            l2 = card;
            break;
        }
    }
    if (l2 == 0) return false;
    for (a) |card| {
        if (card == l1) n_l1 += 1;
        if (card == l2) n_l2 += 1;
    }
    return ((n_l1 == 2) and (n_l2 == 3)) or ((n_l1 == 3) and (n_l2 == 2));
}

fn n_pair_oneortwo(a: [5]u8, n: u8) bool {
    var n_same: usize = 0;
    var other_one: u8 = undefined;
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
        if (matches and n_same == 0) {
            n_same += 1;
            other_one = card;
        }
        if (matches and n_same == 1) {
            if (card != other_one) {
                n_same += 1;
            }
        }
    }
    return n_same == n;
}
