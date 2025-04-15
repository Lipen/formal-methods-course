method BadDouble(x: int) returns (y: int)
  requires x >= 0
  ensures y == 2 * x
{
  var t := BadDouble(x - 1);
  y := t + 2;
}

method BadIdentity(x: int) returns (y: int)
  ensures y == x
{
  if x % 2 == 2 {
    y := x;
  } else {
    y := BadIdentity(x);
  }
}
