const std = @import("std");
const builtin = std.builtin;

fn I64(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 64, .signed) {
    return I(64, v);
}

fn I32(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 32, .signed) {
    return I(32, v);
}

fn I16(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 16, .signed) {
    return I(16, v);
}

fn I8(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 8, .signed) {
    return I(8, v);
}

fn U64(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 64, .unsigned) {
   return U(64, v);
}

fn U32(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 32, .unsigned) {
    return U(32, v);
}

fn U16(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 16, .unsigned) {
    return U(16, v);
}

fn U8(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 8, .unsigned) {
    return U(8, v);
}

fn U(bits : comptime_int, v: anytype)
        IntReturnType(@typeInfo(@TypeOf(v)), bits, .unsigned)
    {
    return Int(bits, v, .unsigned);
}

fn I(bits : comptime_int, v: anytype)
        IntReturnType(@typeInfo(@TypeOf(v)), bits, .signed)
    {
    return Int(bits, v, .signed);
}

/// return type info or child_type info in case of vector
/// support only for vectors and numeric types
fn internalTypeInfo(T: type) builtin.Type {
    const tInfo = @typeInfo(T);
    switch(tInfo) {
        .Vector => return @typeInfo(tInfo.Vector.child),
        .Int, .Float, .Bool => return tInfo,

        else => @compileError("Unsuported Type " ++ @typeName(T)),
    }
    return tInfo;
}

/// return type int/vector(int) from the destination int infos
/// support only for vectors(int) and int
fn IntReturnType(comptime srcInfo: builtin.Type,
                          destBits: comptime_int,
                          destSign: builtin.Signedness) type {

    const NewIntT = @Type(.{.Int = .{.signedness = destSign, .bits = destBits}});

    if(srcInfo == .Vector) {
        return @Vector(srcInfo.Vector.len, NewIntT);
    }
    return NewIntT;
}

//Cast any int/vector(int) to any (u/i(bits))/(vector(u/i(bits)))
//int to uint conv sign extend when smaller and trucate when bigger
//so if the numbers fit they are the same (bitwise): -32 == U64(-32)
fn Int(bits : comptime_int, v: anytype, comptime sign: builtin.Signedness)
        IntReturnType(@typeInfo(@TypeOf(v)), bits, sign)
    {
    const DestTu = IntReturnType(@typeInfo(@TypeOf(v)), bits, .unsigned);
    const DestTi = IntReturnType(@typeInfo(@TypeOf(v)), bits, .signed);
    const DestT = if(sign == .unsigned) DestTu else DestTi;

    const T = @TypeOf(v);
    const tName = @typeName(T);

    if(T == DestT or T == comptime_int) return @as(DestT, v);

    const internalT = internalTypeInfo(T);

    switch (internalT){
        .Int => |tInt| {
            if(sign == .unsigned) {
                //i/u(origin bits) to u(bits) - where (origin bits) < (bits)
                if(tInt.bits < bits)  return @as(DestT, @bitCast(@as(DestTi, @intCast(v))));

                //i(origin bits) to u(bits) - where (origin bits) == (bits)
               if(tInt.bits == bits) return @as(DestT, @bitCast(v));

                switch(tInt.signedness) {
                    //i(origin bits) to u(bits) - where (origin bits) > (bits)
                    .signed   => return @as(DestT, @bitCast(@as(DestTi, @truncate(v)))),

                    //u(origin bits) to u(bits) - where (origin bits) > (bits)
                    .unsigned => return @as(DestT, @truncate(v)),
                }
            } else {
                //i/u(origin bits) to i(bits) - where (origin bits) < (bits)
                if(tInt.bits < bits)  return @as(DestT, v);

                //u(origin bits) to i(bits) - where (origin bits) == (bits)
                if(tInt.bits == bits) return @as(DestT, @bitCast(v));

                switch(tInt.signedness) {
                    //i(origin bits) to i(bits) - where (origin bits) > (bits)
                    .signed   => return @as(DestT, @intCast(v)),

                    //u(origin bits) to i(bits) - where (origin bits) > (bits)
                    .unsigned => return @as(DestT, @bitCast(@as(DestTu, @truncate(v)))),
                }
            }
        },
        else => {
            const errMsg = if(sign == .unsigned)
                std.fmt.comptimePrint("U{d}(): Cannot cast from {s} to u{d}\n", .{bits, tName, bits})
            else
                std.fmt.comptimePrint("I{d}(): Cannot cast from {s} to i{d}\n", .{bits, tName, bits});

            @compileError(errMsg);
        }
    }
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

test "U32/I32(): Vector(int) test" {
    var nru : @Vector(3, u32) = @splat(0);
    var nri : @Vector(3, i32) = @splat(0);

    const n1 : @Vector(3, i64)= @splat(-1);
    const n2 : @Vector(3, u64)= @splat(1);

    const n3 : @Vector(3, i32)= @splat(-1);
    const n4 : @Vector(3, u32)= @splat(1);

    const n5 : @Vector(3, u36)= @splat(1);
    const n6 : @Vector(3, u30)= @splat(1);

    const n7 : @Vector(3, i36)= @splat(-1);
    const n8 : @Vector(3, i30)= @splat(-1);

    nru +%= U32(n1);
    nri +%= I32(n1);
    nru +%= U32(n2);
    nri +%= I32(n2);
    nru +%= U32(n3);
    nri +%= I32(n3);
    nru +%= U32(n4);
    nri +%= I32(n4);
    nru +%= U32(n5);
    nri +%= I32(n5);
    nru +%= U32(n6);
    nri +%= I32(n6);
    nru +%= U32(n7);
    nri +%= I32(n7);
    nru +%= U32(n8);
    nri +%= I32(n8);

    try std.testing.expect(@reduce(.Add, nri) == 0);
    try std.testing.expect(@reduce(.Add, nru) == 0);
}

test "README examples" {

    var result: i64 = 10;

    const n1: u64 = 10;
    const n2: i128 = -20;

    result += I64(n1) + I64(n2);

    try std.testing.expect(result == 0);
}
