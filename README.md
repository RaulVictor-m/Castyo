# Castyo

Castyo is a library that is supposed to help with zig casting situation
by providing easier functions for casting in between numeric types, while
its going to make a lot of decisions for you and the casting is not going to be
as explicit as zig intended it to be, it will definetely make casting less verbose
and more user friendly, which is going to help alot for prototyping.

## Situation

Well the library is not ready just yet and does not support floats by any extention,
but you are already able to do any int to int
conversion with only one single function like "U64(n)" or "I32(n)", and
as a bonus everything that works for integers also works for Vector(x, int).

## How to

The best way to understand and use this library is to just go to the code and look at the tests
there you will find a few examples on how the library should work but for gist of it you can rely
on these example:

```
    var result: i64 = 10;

    const n1: u64 = 10;
    const n2: i128 = -20;

    result += I64(n1) + I64(n2);

    try std.testing.expect(result == 0);
```

## Installation

As far as installation is concerned there is no secret to it, just download *src/castyo.zig*
and use it in you project as you please.

I personally don't like package managers for programming languages, and I like it
even less when it comes to very simple things so I myself am not going to be adding
a *build.zig.zon* to these project.
