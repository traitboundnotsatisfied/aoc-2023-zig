const std = @import("std");

pub fn main() !void {
    const input = [_]struct { u64, u64 }{
        .{ 59707878, 430121812131276 },
    };
    var product: u64 = 1;
    for (input) |item| {
        product *= numWaysToBeatRecord(item[0], item[1]);
    }
    std.debug.print("{d}\n", .{product});
}

fn numWaysToBeatRecord(time: u64, record_dist: u64) u64 {
    var count: u64 = 0;
    for (1..time) |time_button| {
        if (beatsRecord(time_button, time - time_button, record_dist)) {
            count += 1;
        }
    }
    return count;
}

fn beatsRecord(speed: u64, time_left: u64, record_dist: u64) bool {
    return (time_left * speed) > record_dist;
}
