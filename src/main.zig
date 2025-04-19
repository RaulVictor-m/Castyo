const std = @import("std");
const builtin = std.builtin;

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

fn IntReturnType(bits: comptime_int, tInfo: builtin.Type, sign: builtin.Signedness) type {
    const NewIntT = @Type(.{.Int = .{.signedness = sign, .bits = bits}});

    if(tInfo == .Vector) {
        return @Vector(tInfo.len, NewIntT);
    }
    return NewIntT;
}

fn U(bits : comptime_int, v: anytype)
        IntReturnType(bits, @typeInfo(@TypeOf(v)), .unsigned)
    {

    const DestT = IntReturnType(bits, @typeInfo(@TypeOf(v)), .unsigned);
    const DestTi = IntReturnType(bits, @typeInfo(@TypeOf(v)), .signed);

    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);

    if(T == DestT or T == comptime_int) return @as(DestT, v);

    const internalInt: ?builtin.Type.Int = internalIntResult: {
        if(tInfo == .Int) {
            break: internalIntResult tInfo.Int;
        }
        if(tInfo == .Vector) {
            break: internalIntResult @typeInfo(tInfo.Vector.child);
        }

        break: internalIntResult null;
    };


    if(internalInt) |tInt| {
        if(tInt.bits < bits)  return @as(DestT, @bitCast(@as(DestTi, @intCast(v))));//i|u16
        if(tInt.bits == bits) return @as(DestT, @bitCast(v));                       //i64

        switch(tInt.signedness) {
            .signed   => return @as(DestT, @bitCast(@as(DestTi, @truncate(v)))), //>i64
            .unsigned => return @as(DestT, @truncate(v)),                        //>u64
        }
    }

    const errMsg =
    std.fmt.comptimePrint("U{d}(): Cannot cast from {s} to u{d}\n", .{bits, tName, bits});
    @compileError(errMsg);
}

fn I(bits : comptime_int, v: anytype)
        IntReturnType(bits, @typeInfo(@TypeOf(v)), .signed)
    {

    const DestT = IntReturnType(bits, @typeInfo(@TypeOf(v)), .signed);
    const DestTu = IntReturnType(bits, @typeInfo(@TypeOf(v)), .unsigned);

    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);

    if(T == DestT or T == comptime_int) return @as(DestT, v);

    const internalInt: ?builtin.Type.Int = internalIntResult: {
        if(tInfo == .Int) {
            break: internalIntResult tInfo.Int;
        }
        if(tInfo == .Vector) {
            break: internalIntResult @typeInfo(tInfo.Vector.child);
        }

        break: internalIntResult null;
    };


    if(internalInt) |tInt| {
        if(tInt.bits < bits)  return @as(DestT, v);                                 //i|u16
        if(tInt.bits == bits) return @as(DestT, @bitCast(v));                       //u64

        switch(tInt.signedness) {
            .signed   => return @as(DestT, @intCast(v)),                         //>i64
            .unsigned => return @as(DestT, @bitCast(@as(DestTu, @truncate(v)))), //>u64
        }

    }
    const errMsg =
    std.fmt.comptimePrint("I{d}(): Cannot cast from {s} to i{d}\n", .{bits, tName, bits});
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
