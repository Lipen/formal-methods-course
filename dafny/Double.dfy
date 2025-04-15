method Double(x: int) returns (r: int)
  requires x >= 0
  ensures r == 2 * x
{
  if x == 0 {
    r := 0;
  } else {
    var t := Double(x - 1);
    r := t + 2;
  }
}
