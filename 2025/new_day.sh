#!/bin/bash

# Usage: ./new_day.sh <DAY> <NAME>
# Example: ./new_day.sh 01 secret-entrance

DAY=$1
NAME=$2

if [ -z "$DAY" ] || [ -z "$NAME" ]; then
    echo "Usage: ./new_day.sh <DAY> <NAME>"
    echo "Example: ./new_day.sh 01 secret-entrance"
    exit 1
fi

DIR_NAME="day-${DAY}-${NAME}"

if [ -d "$DIR_NAME" ]; then
    echo "Error: Directory '$DIR_NAME' already exists."
    exit 1
fi

echo "Creating Zig project (v0.15+): $DIR_NAME"
mkdir -p "$DIR_NAME/src"

# 1. Create build.zig
cat > "$DIR_NAME/build.zig" <<EOF
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "$DIR_NAME",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the solution");
    run_step.dependOn(&run_cmd.step);
}
EOF

# 2. Create src/main.zig
cat > "$DIR_NAME/src/main.zig" <<EOF
const std = @import("std");
const print = std.debug.print;

// Zig 0.15+ Security: Only files within the root module (src/) can be embedded
const input = std.mem.trim(u8, @embedFile("input.txt"), "\n");

pub fn main() !void {
    print("🎄 Day ${DAY}: ${NAME} 🎄\n", .{});
    print("Input Sample: {s}...\n", .{input[0..@min(input.len, 20)]});
    
    // TODO: Solve the puzzle!
}
EOF

# 3. Create empty input file (inside src/ to satisfy Zig 0.15+ security)
touch "$DIR_NAME/src/input.txt"

echo "Done! 🚀"
echo "1. Paste your input into $DIR_NAME/src/input.txt"
echo "2. cd $DIR_NAME && zig build run"