const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const BufferSize = 1024;
const LF = '\n';
const LineDelimiter = "\r\n";

const InitialPosition: i32 = 50;
const DialSize: u16 = 100;

const Direction = enum { left, right };

pub fn main() !void {
    print("🎄 Day 01: secret-entrance 🎄\n", .{});

    var in_buffer: [BufferSize]u8 = undefined;
    var in_reader = std.fs.File.stdin().reader(&in_buffer);

    var position: i32 = InitialPosition;
    var count: u32 = 0;
    var total_count_per_click: u32 = 0;

    while (try in_reader.interface.takeDelimiter(LF)) |line| {
        const trimmed_line = std.mem.trimEnd(u8, line, LineDelimiter);

        const direction = switch (trimmed_line[0]) {
            'L' => Direction.left,
            'R' => Direction.right,
            else => undefined,
        };

        const distance = try std.fmt.parseInt(u16, trimmed_line[1..], 10);

        print("rotating the dial {d} clicks to the {s}\n", .{ distance, std.enums.tagName(Direction, direction).? });

        const prev_position: i32 = position;

        const rotation: i16 = switch (direction) {
            Direction.left => -@as(i16, @intCast(distance)),
            Direction.right => @intCast(distance),
        };

        position = @mod(prev_position + rotation, DialSize);

        if (position == 0) {
            count += 1;
        }

        // brute-force
        var zero_count_per_click: u16 = distance / DialSize;
        const position_by_rem: i32 = prev_position + @rem(rotation, DialSize);
        if (distance % DialSize != 0 and
            ((prev_position > 0 and position_by_rem <= 0) or position_by_rem >= DialSize))
        {
            zero_count_per_click += 1;
        }

        // analytical
        const zero_count_per_click_calc: u32 = if (rotation > 0)
            //@abs(@divFloor(prev_position + rotation, DialSize) - @divFloor(prev_position, DialSize))
            // since prev_position >= 0 and prev_position < DialSize
            @abs(@divFloor(prev_position + rotation, DialSize))
        else
            @abs(try std.math.divCeil(i32, prev_position + rotation, DialSize) - try std.math.divCeil(i32, prev_position, DialSize));

        assert(zero_count_per_click == zero_count_per_click_calc);

        print("position: {d} -> {d} (pointed at zero {d} times)\n", .{ prev_position, position, zero_count_per_click_calc });

        total_count_per_click += zero_count_per_click_calc;
    }

    print("the number of times the dial is left pointing at 0: {d}\n", .{count});
    print("the number of times any click causes the dial to point at 0: {d}\n", .{total_count_per_click});
}
