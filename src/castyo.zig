const std = @import("std");
const builtin = std.builtin;

pub fn I64(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 64, .signed) {
    return I(64, v);
}

pub fn I32(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 32, .signed) {
    return I(32, v);
}

pub fn I16(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 16, .signed) {
    return I(16, v);
}

pub fn I8(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 8, .signed) {
    return I(8, v);
}

pub fn U64(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 64, .unsigned) {
    return U(64, v);
}

pub fn U32(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 32, .unsigned) {
    return U(32, v);
}

pub fn U16(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 16, .unsigned) {
    return U(16, v);
}

pub fn U8(v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), 8, .unsigned) {
    return U(8, v);
}

//-----------------------------------------------------------
//

pub fn F128(v: anytype) FloatReturnType(@typeInfo(@TypeOf(v)), f128) {
    return Float(f128, v);
}

pub fn F80(v: anytype) FloatReturnType(@typeInfo(@TypeOf(v)), f80) {
    return Float(f80, v);
}

pub fn F64(v: anytype) FloatReturnType(@typeInfo(@TypeOf(v)), f64) {
    return Float(f64, v);
}

pub fn F32(v: anytype) FloatReturnType(@typeInfo(@TypeOf(v)), f32) {
    return Float(f32, v);
}

pub fn F16(v: anytype) FloatReturnType(@typeInfo(@TypeOf(v)), f16) {
    return Float(f16, v);
}

pub fn U(bits: comptime_int, v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), bits, .unsigned) {
    return Int(bits, v, .unsigned);
}

pub fn I(bits: comptime_int, v: anytype) IntReturnType(@typeInfo(@TypeOf(v)), bits, .signed) {
    return Int(bits, v, .signed);
}

/// return type info or child_type info in case of vector
/// support only for vectors and numeric types
fn internalTypeInfo(T: type) builtin.Type {
    const t_info = @typeInfo(T);
    switch (t_info) {
        .vector  => return @typeInfo(t_info.vector.child),
        .@"enum" => return @typeInfo(t_info.@"enum".tag_type),
        .int, .float => return t_info,

        else => @compileError("Unsuported Type " ++ @typeName(T)),
    }
    return t_info;
}

/// return type int/vector(int) from the destination int infos
/// support only for vectors(int) and int
fn IntReturnType(comptime src_info: builtin.Type, dest_bits: comptime_int, dest_sign: builtin.Signedness) type {
    //TODO: type check to see if the conversion is actually
    //possible instead of just assuming it always works
    const NewIntT = @Type(.{ .int = .{ .signedness = dest_sign, .bits = dest_bits } });

    if (src_info == .vector) {
        return @Vector(src_info.vector.len, NewIntT);
    }
    return NewIntT;
}

//Cast any int/vector(int) to any (u/i(bits))/(vector(u/i(bits)))
//int to uint conv sign extend when smaller and trucate when bigger
//so if the numbers fit they are the same (bitwise): -32 == U64(-32)
pub fn Int(bits: comptime_int, v: anytype, comptime sign: builtin.Signedness) IntReturnType(@typeInfo(@TypeOf(v)), bits, sign) {
    const DestTu = IntReturnType(@typeInfo(@TypeOf(v)), bits, .unsigned);
    const DestTi = IntReturnType(@typeInfo(@TypeOf(v)), bits, .signed);
    const DestT = if (sign == .unsigned) DestTu else DestTi;

    const T = @TypeOf(v);
    const t_name = @typeName(T);
    const t_info = @typeInfo(T);

    if (T == DestT or T == comptime_int) return @as(DestT, v);

    const internal_t_info = internalTypeInfo(T);

    if(t_info == .@"enum") {
        const TmpT = @typeInfo(T).@"enum".tag_type;
        const tmp_val: TmpT = @intFromEnum(v);
        return Int(bits, tmp_val, sign);
    }

    switch (internal_t_info) {
        .int => |int_info| {
            if (sign == .unsigned) {
                //i/u(origin bits) to u(bits) - where (origin bits) < (bits)
                if (int_info.bits < bits) return @as(DestT, @bitCast(@as(DestTi, @intCast(v))));

                //i(origin bits) to u(bits) - where (origin bits) == (bits)
                if (int_info.bits == bits) return @as(DestT, @bitCast(v));

                switch (int_info.signedness) {
                    //i(origin bits) to u(bits) - where (origin bits) > (bits)
                    .signed => return @as(DestT, @bitCast(@as(DestTi, @truncate(v)))),
                    //u(origin bits) to u(bits) - where (origin bits) > (bits)
                    .unsigned => return @as(DestT, @truncate(v)),
                }
            } else {
                //i/u(origin bits) to i(bits) - where (origin bits) < (bits)
                if (int_info.bits < bits) return @as(DestT, v);

                //u(origin bits) to i(bits) - where (origin bits) == (bits)
                if (int_info.bits == bits) return @as(DestT, @bitCast(v));

                switch (int_info.signedness) {
                    //i(origin bits) to i(bits) - where (origin bits) > (bits)
                    .signed => return @as(DestT, @truncate(v)),

                    //u(origin bits) to i(bits) - where (origin bits) > (bits)
                    .unsigned => return @as(DestT, @bitCast(@as(DestTu, @truncate(v)))),
                }
            }
        },
        .float => |float_info|{
            //this is an int with the same amount of bits as the float which is mostly std ints
            const TIntTmp = IntReturnType(@typeInfo(@TypeOf(v)), float_info.bits, .signed);

            if (sign == .unsigned) {
                //OBS: 5 is the min number of bits in a float exponent

                //f(origins bits) to u(bits) - where (origin bits-5) <= (bits)
                if (float_info.bits-5 <= bits) return @as(DestT, @bitCast(@as(DestTi, @intFromFloat(v))));

                //f(origins bits) to u(bits) - where (origin bits-5) > (bits)
                return @as(DestT, @bitCast(@as(DestTi, @truncate(@as(TIntTmp, @intFromFloat(v))))));
            }
            else {
                //f(origins bits) to i(bits) - where (origin bits-5) <= (bits)
                if (float_info.bits-5 <= bits) return @bitCast(@as(DestTi, @intFromFloat(v)));

                //f(origins bits) to i(bits) - where (origin bits-5) > (bits)
                return @as(DestTi, @truncate(@as(TIntTmp, @intFromFloat(v))));
            }
        },
        else => {
            const err_msg = if (sign == .unsigned)
                std.fmt.comptimePrint("U{d}(): Cannot cast from {s} to u{d}\n", .{ bits, t_name, bits })
            else
                std.fmt.comptimePrint("I{d}(): Cannot cast from {s} to i{d}\n", .{ bits, t_name, bits });

            @compileError(err_msg);
        },
    }
    return v;
}

/// return type float/vector(float) from the destination Type infos
/// support only for vectors(float) and float
fn FloatReturnType(comptime src_info: builtin.Type, DestT: type) type {
    //TODO: type check to see if the conversion is actually
    //possible instead of just assuming it always works
    const NewFloatT = DestT;

    if (src_info == .vector) {
        return @Vector(src_info.vector.len, NewFloatT);
    }
    return NewFloatT;
}

/// Cast any numeric/vector(numeric) to any supported float type
/// it just maps either floatCast or floatFromInt, which never error
/// but may have some loss so be mindful
pub fn Float(DestT: type, v: anytype) FloatReturnType(@typeInfo(@TypeOf(v)), DestT) {
    //as floating types casts never *explode* there is no need for magic
    const t_info = @typeInfo(@TypeOf(v));

    const internal_t_info = internalTypeInfo(@TypeOf(v));
    const RetT = FloatReturnType(t_info, DestT);


    if(t_info == .@"enum") {
        const TmpT = t_info.@"enum".tag_type;
        const tmp_val: TmpT = @intFromEnum(v);
        return Float(DestT, tmp_val);
    }

    if (internal_t_info == .float) {
        return @as(RetT, @floatCast(v));
    }
    if (internal_t_info == .int) {
        return @as(RetT, @floatFromInt(v));
    }

    @compileError("unsupported type" ++ @typeName(@TypeOf(v)) ++ "for Float conversion");
}

pub fn main() !void {}

test "I32(): int test" {
    var nr: i32 = 0;

    const n1: i64 = -1;
    const n2: u64 = 1;

    const n3: i32 = -1;
    const n4: u32 = 1;

    const n5: u34 = 1;
    const n6: u30 = 1;

    const n7: i34 = -1;
    const n8: i30 = -1;

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
    var nr: i64 = 0;

    const n1: i64 = -1;
    const n2: u64 = 1;

    const n3: i32 = -1;
    const n4: u32 = 1;

    const n5: u66 = 1;
    const n6: u60 = 1;

    const n7: i66 = -1;
    const n8: i60 = -1;

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
    var nr: u64 = 0;

    const n1: i64 = -1;
    const n2: u64 = 1;

    const n3: i32 = -1;
    const n4: u32 = 1;

    const n5: u66 = 1;
    const n6: u60 = 1;

    const n7: i66 = -1;
    const n8: i60 = -1;

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
    var nr: u32 = 0;

    const n1: i64 = -1;
    const n2: u64 = 1;

    const n3: i32 = -1;
    const n4: u32 = 1;

    const n5: u36 = 1;
    const n6: u30 = 1;

    const n7: i36 = -1;
    const n8: i30 = -1;

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
    var nru: @Vector(3, u32) = @splat(0);
    var nri: @Vector(3, i32) = @splat(0);

    const n1: @Vector(3, i64) = @splat(-1);
    const n2: @Vector(3, u64) = @splat(1);

    const n3: @Vector(3, i32) = @splat(-1);
    const n4: @Vector(3, u32) = @splat(1);

    const n5: @Vector(3, u36) = @splat(1);
    const n6: @Vector(3, u30) = @splat(1);

    const n7: @Vector(3, i36) = @splat(-1);
    const n8: @Vector(3, i30) = @splat(-1);

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

test "U32/I32(): float test" {
    var nri: i32 = 0;
    var nru: u32 = 0;

    const n1: f64 = -1.5;
    const n2: f64 = 1.5;

    const n3: f32 = -1.5;
    const n4: f32 = 1.5;

    const n5: f16 = -1.5;
    const n6: f16 = 1.5;

    nru +%= U32(n1);
    nru +%= U32(n2);
    nru +%= U32(n3);
    nru +%= U32(n4);
    nru +%= U32(n5);
    nru +%= U32(n6);

    nri += I32(n1);
    nri += I32(n2);
    nri += I32(n3);
    nri += I32(n4);
    nri += I32(n5);
    nri += I32(n6);

    try std.testing.expect(nri == 0);
    try std.testing.expect(nru == 0);
}

test "U32/I32(): Vector(float) test" {
    var nri: @Vector(3, i32) = @splat(0);
    var nru: @Vector(3, u32) = @splat(0);

    const n1: @Vector(3, f64) = @splat(-1.5);
    const n2: @Vector(3, f64) = @splat(1.5);

    const n3: @Vector(3, f32) = @splat(-1.5);
    const n4: @Vector(3, f32) = @splat(1.5);

    const n5: @Vector(3, f16) = @splat(-1.5);
    const n6: @Vector(3, f16) = @splat(1.5);

    nru +%= U32(n1);
    nru +%= U32(n2);
    nru +%= U32(n3);
    nru +%= U32(n4);
    nru +%= U32(n5);
    nru +%= U32(n6);

    nri += I32(n1);
    nri += I32(n2);
    nri += I32(n3);
    nri += I32(n4);
    nri += I32(n5);
    nri += I32(n6);

    try std.testing.expect(@reduce(.Add, nri) == 0);
    try std.testing.expect(@reduce(.Add, nru) == 0);
}

test "U32: enum test" {
    const TestEnum = enum(i8) {
        test0 = -1,
        test1 = 10,
        test2 = -10,
        test3,
        test4,
    };

    var nr: u32 = 1;

    nr +%= U32(TestEnum.test0);

    try std.testing.expect(nr == 0);
    try std.testing.expect(U32(TestEnum.test1) +% U32(TestEnum.test2) == 0);
}

test "F32(): int test" {
    var nr: f32 = 1.0;

    const n1: u64 = 2;
    const n2: i64 = 2;
    const n3: u32 = 2;
    const n4: i32 = 2;
    const n5: u16 = 2;
    const n6: i16 = 2;

    nr *= F32(n1);
    nr /= F32(n2);
    nr *= F32(n3);
    nr /= F32(n4);
    nr *= F32(n5);
    nr /= F32(n6);

    try std.testing.expect(nr == 1.0);
}

test "F32(): float test" {
    var nr: f32 = 1.0;

    const n1: f16  = 2.0;
    const n2: f64  = 2.0;
    const n3: f80  = 2.0;
    const n4: f128 = 2.0;

    nr *= F32(n1);
    nr /= F32(n2);
    nr *= F32(n3);
    nr /= F32(n4);

    try std.testing.expect(nr == 1.0);
}

test "F32(): vector(int) test" {
    var nr: @Vector(3, f32) = @splat(1.0);

    const n1: @Vector(3, u64) = @splat(2);
    const n2: @Vector(3, i64) = @splat(2);
    const n3: @Vector(3, u32) = @splat(2);
    const n4: @Vector(3, i32) = @splat(2);
    const n5: @Vector(3, u16) = @splat(2);
    const n6: @Vector(3, i16) = @splat(2);

    nr *= F32(n1);
    nr /= F32(n2);
    nr *= F32(n3);
    nr /= F32(n4);
    nr *= F32(n5);
    nr /= F32(n6);

    try std.testing.expect(@reduce(.Add, nr) == 3.0);
    try std.testing.expect(@reduce(.Mul, nr) == 1.0);
}

test "F32(): vector(float) test" {
    var nr: @Vector(3, f32) = @splat(1.0);

    const n1: @Vector(3, f16)  = @splat(2.0);
    const n2: @Vector(3, f64)  = @splat(2.0);
    const n3: @Vector(3, f80)  = @splat(2.0);
    const n4: @Vector(3, f128) = @splat(2.0);

    nr *= F32(n1);
    nr /= F32(n2);
    nr *= F32(n3);
    nr /= F32(n4);

    try std.testing.expect(@reduce(.Add, nr) == 3.0);
    try std.testing.expect(@reduce(.Mul, nr) == 1.0);
}

test "F32: enum test" {
    const TestEnum = enum(i8) {
        test0 = -1,
        test1 = 10,
        test2 = 5,
        test3,
        test4,
    };

    var nr: f32 = 1;

    nr += F32(TestEnum.test0);

    try std.testing.expect(nr == 0);
    try std.testing.expect(F32(TestEnum.test1) / F32(TestEnum.test2) == 2);
}

test "README examples" {
    var result: i64 = 10;

    const n1: u64 = 10;
    const n2: i128 = -20;

    const n3: f64 = 10.306;
    const n4: f64 = -10.306;

    const n6: i8 = -1;
    const n7: f64 = 2.5;
    const n8: f64 = 2.5 * F64(n6);

    result += I64(n1) + I64(n2);
    result += I64(n3) + I64(n4);
    result += I64(n7) + I64(n8);

    try std.testing.expect(result == 0);
}
