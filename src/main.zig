const std = @import("std");

fn I64(v: anytype) i64 {
    return I(64, v);
}

fn I32(v: anytype) i32 {
    return I(32, v);
}

fn I16(v: anytype) i16 {
    return I(16, v);
}

fn I8(v: anytype) i8 {
    return I(8, v);
}

/// sign extand small signed its and trucate bigger ints
fn U64(v: anytype) u64 {
   return U(64, v);
}

/// sign extand small signed its and trucate bigger ints
fn U32(v: anytype) u32 {
    return U(32, v);
}

/// sign extand small signed its and trucate bigger ints
fn U16(v: anytype) u16 {
    return U(16, v);
}

/// sign extand small signed its and trucate bigger ints
fn U8(v: anytype) u8 {
    return U(8, v);
}


fn U(n : comptime_int, v: anytype) ReturnType: {
        const T = @TypeOf(v);
        const tInfo = @typeInfo(T);

        const NewIntT = @Type(.{.Int = .{.signedness = .unsigned, .bits = n}});

        if(tInfo == .Vector) {
            break : ReturnType @Vector(tInfo.len, NewIntT);
        }
        break : ReturnType NewIntT;
    } {

    const DestT =  @Type(.{.Int = .{.signedness = .unsigned, .bits = n}});
    const DestTi = @Type(.{.Int = .{.signedness = .signed, .bits = n}});

    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);

    if(T == DestT or T == comptime_int) return @as(DestT, v);

    if(tInfo == .Int) {
        const tInt = tInfo.Int;
        if(tInt.bits < n)  return @as(DestT, @bitCast(@as(DestTi, @intCast(v))));//i|u16
        if(tInt.bits == n) return @as(DestT, @bitCast(v));                       //i64

        switch(tInt.signedness) {
            .signed   => return @as(DestT, @bitCast(@as(DestTi, @truncate(v)))), //>i64
            .unsigned => return @as(DestT, @truncate(v)),                        //>u64
        }

    }

    const errMsg =
    std.fmt.comptimePrint("U{d}(): Cannot cast from {s} to u{d}\n", .{n, tName, n});
    @compileError(errMsg);
}

fn I(n : comptime_int, v: anytype)
    @Type(.{.Int = .{.signedness = .signed, .bits = n}}) {

    const DestT =  @Type(.{.Int = .{.signedness = .signed, .bits = n}});
    const DestTu = @Type(.{.Int = .{.signedness = .unsigned, .bits = n}});

    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);

    if(T == DestT or T == comptime_int) return @as(DestT, v);

    if(tInfo == .Int) {
        const tInt = tInfo.Int;
        if(tInt.bits < n)  return @as(DestT, v);                                 //i|u16
        if(tInt.bits == n) return @as(DestT, @bitCast(v));                       //u64

        switch(tInt.signedness) {
            .signed   => return @as(DestT, @intCast(v)),                         //>i64
            .unsigned => return @as(DestT, @bitCast(@as(DestTu, @truncate(v)))), //>u64
        }

    }
    const errMsg =
    std.fmt.comptimePrint("I{d}(): Cannot cast from {s} to i{d}\n", .{n, tName, n});
    @compileError(errMsg);
}

pub fn main() !void {
}

test "I32(): int test" {
    var nr : i32 = 0;

    const n1 : i64 = -1;
    const n2 : u64 = 1;

    const n3 : i32 = -1;
    const n4 : u32 = 1;

    const n5 : u34 = 1;
    const n6 : u30 = 1;

    const n7 : i34 = -1;
    const n8 : i30 = -1;

    nr += I32(n1);
    nr += I32(n2);
    nr += I32(n3);
    nr += I32(n4);
    nr += I32(n5);
    nr += I32(n6);
    nr += I32(n7);
    nr += I32(n8);

    try std.testing.expect(nr == 0);
}

test "I64(): int test" {
    var nr : i64 = 0;

    const n1 : i64 = -1;
    const n2 : u64 = 1;

    const n3 : i32 = -1;
    const n4 : u32 = 1;

    const n5 : u66 = 1;
    const n6 : u60 = 1;

    const n7 : i66 = -1;
    const n8 : i60 = -1;

    nr += I64(n1);
    nr += I64(n2);
    nr += I64(n3);
    nr += I64(n4);
    nr += I64(n5);
    nr += I64(n6);
    nr += I64(n7);
    nr += I64(n8);

    try std.testing.expect(nr == 0);
}

test "U64(): int test" {
    var nr : u64 = 0;

    const n1 : i64 = -1;
    const n2 : u64 = 1;

    const n3 : i32 = -1;
    const n4 : u32 = 1;

    const n5 : u66 = 1;
    const n6 : u60 = 1;

    const n7 : i66 = -1;
    const n8 : i60 = -1;

    nr +%= U64(n1);
    nr +%= U64(n2);
    nr +%= U64(n3);
    nr +%= U64(n4);
    nr +%= U64(n5);
    nr +%= U64(n6);
    nr +%= U64(n7);
    nr +%= U64(n8);

    try std.testing.expect(nr == 0);
}

test "U32(): int test" {
    var nr : u32 = 0;

    const n1 : i64 = -1;
    const n2 : u64 = 1;

    const n3 : i32 = -1;
    const n4 : u32 = 1;

    const n5 : u36 = 1;
    const n6 : u30 = 1;

    const n7 : i36 = -1;
    const n8 : i30 = -1;

    nr +%= U32(n1);
    nr +%= U32(n2);
    nr +%= U32(n3);
    nr +%= U32(n4);
    nr +%= U32(n5);
    nr +%= U32(n6);
    nr +%= U32(n7);
    nr +%= U32(n8);

    try std.testing.expect(nr == 0);
}
