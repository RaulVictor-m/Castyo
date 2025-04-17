const std = @import("std");

/// sign extand small signed its and trucate bigger ints
fn U32(v: anytype) u32 {
    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);
    if(T == u32 or T == comptime_int) return @as(u32, v);

    if(tInfo == .Int) {
        const tInt = tInfo.Int;
        if(tInt.bits < 32)  return @as(u32, @bitCast(@as(i32, @intCast(v))));//i|u16
        if(tInt.bits == 32) return @as(u32, @bitCast(v));                    //i32

        switch(tInt.signedness) {
            .signed   => return @as(u32, @bitCast(@as(i32, @truncate(v)))), //>i32
            .unsigned => return @as(u32, @truncate(v)),                     //>u32
        }

    } else @compileError("U32(): Cannot cast from " ++ tName ++ " to u32\n");

    return v;
}

/// sign extand small signed its and trucate bigger ints
fn U64(v: anytype) u64 {
    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);
    if(T == u64 or T == comptime_int) return @as(u64, v);

    if(tInfo == .Int) {
        const tInt = tInfo.Int;
        if(tInt.bits < 64)  return @as(u64, @bitCast(@as(i64, @intCast(v))));//i|u16
        if(tInt.bits == 64) return @as(u64, @bitCast(v));                    //i64

        switch(tInt.signedness) {
            .signed   => return @as(u64, @bitCast(@as(i64, @truncate(v)))), //>i64
            .unsigned => return @as(u64, @truncate(v)),                     //>u64
        }

    } else @compileError("U64(): Cannot cast from " ++ tName ++ " to u64\n");

    return v;
}

// fn I(n : comptime_int, v: anytype) {
//     const DestT = @Type(std

//     const T = @TypeOf(v);
//     const tInfo = @typeInfo(T);
//     const tName = @typeName(T);
//     if(T == i64 or T == comptime_int) return @as(i64, v);
// }

fn I64(v: anytype) i64 {
    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);
    if(T == i64 or T == comptime_int) return @as(i64, v);

    if(tInfo == .Int) {
        const tInt = tInfo.Int;
        if(tInt.bits < 64)  return @as(i64, v);                             //i|u16
        if(tInt.bits == 64) return @as(i64, @bitCast(v));                   //u64

        switch(tInt.signedness) {
            .signed   => return @as(i64, @intCast(v)),                      //>i64
            .unsigned => return @as(i64, @bitCast(@as(u64, @truncate(v)))), //>u64
        }

    }else @compileError("I64(): Cannot cast from " ++ tName ++ " to i64\n");

    return v;
}

fn I32(v: anytype) i32 {
    const T = @TypeOf(v);
    const tInfo = @typeInfo(T);
    const tName = @typeName(T);
    if(T == i32 or T == comptime_int) return @as(i32, v);

    if(tInfo == .Int) {
        const tInt = tInfo.Int;
        if(tInt.bits < 32)  return @as(i32, v);                             //i|u16
        if(tInt.bits == 32) return @as(i32, @bitCast(v));                   //u32

        switch(tInt.signedness) {
            .signed   => return @as(i32, @intCast(v)),                      //i64
            .unsigned => return @as(i32, @bitCast(@as(u32, @truncate(v)))), //u64
        }

    }else @compileError("I32(): Cannot cast from " ++ tName ++ " to i32\n");

    return v;
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
