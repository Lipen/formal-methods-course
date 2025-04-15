function fib(n: nat): nat
{
  if n == 0 then 0
  else if n == 1 then 1
  else fib(n - 1) + fib(n - 2)
}

method ComputeFib(n: nat) returns (b: nat)
  ensures b == fib(n)
{
  if n == 0 { return 0; }
  var i := 1;
  var a := 0;
  b := 1;
  while i < n
    invariant 0 < i <= n
    invariant a == fib(i - 1)
    invariant b == fib(i)
  {
    a, b := b, a + b;
    i := i + 1;
  }
}

method ComputeFib2(n: nat) returns (b: nat)
  ensures b == fib(n)
{
  b := 0;
  var c := 1;
  var i := 0;
  while i < n
    invariant 0 <= i <= n
    invariant b == fib(i)
    invariant c == fib(i + 1)
  {
    b, c := c, b + c;
    i := i + 1;
  }
}
