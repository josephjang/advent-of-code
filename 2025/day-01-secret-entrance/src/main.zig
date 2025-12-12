const std = @import("std");
const print = std.debug.print;

const BufferSize = 1024;
const LF = '\n';
const LineDelimiter = "\r\n";

const InitialPosition: i32 = 50;
const DialSize: i32 = 100;

const Direction = enum { left, right };

pub fn main() !void {
    print("🎄 Day 01: secret-entrance 🎄\n", .{});

    var in_buffer: [BufferSize]u8 = undefined;
    var in_reader = std.fs.File.stdin().reader(&in_buffer);

    var position: i32 = InitialPosition;
    var count: u32 = 0;

    while (try in_reader.interface.takeDelimiter(LF)) |line| {
        const trimmed_line = std.mem.trimEnd(u8, line, LineDelimiter);

        const direction = switch (trimmed_line[0]) {
            'L' => Direction.left,
            'R' => Direction.right,
            else => undefined,
        };

        const distance = try std.fmt.parseInt(u16, trimmed_line[1..], 10);

        print("rotating the dial {d} clicks to the {s}\n", .{ distance, std.enums.tagName(Direction, direction).? });

        const prev_position = position;

        switch (direction) {
            Direction.left => position -= distance,
            Direction.right => position += distance,
        }

        position = @mod(position, DialSize);

        print("position: {d} -> {d}\n", .{ prev_position, position });

        if (position == 0) {
            count += 1;
        }
    }

    print("the number of times the dial is left pointing at 0: {d}\n", .{count});
}
