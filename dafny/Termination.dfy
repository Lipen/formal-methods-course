method m()
{
  var i, n := 0, 20;
  while i < n
    invariant 0 <= i <= n
    decreases n - i // auto
  {
    i := i + 1;
  }
}

function fib(n: nat): nat
  decreases n // auto
{
  if n == 0 then 0
  else if n == 1 then 1
  else fib(n - 1) + fib(n - 2)
}
