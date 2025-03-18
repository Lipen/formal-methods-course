method MaxSum(x: int, y: int)
  returns (s: int, m: int)
  ensures s == x + y
  ensures m == x || m == y
  ensures m >= x && m >= y
{
  s := x + y;
  if x >= y {
    m := x;
  } else {
    m := y;
  }
}

method ReconstructFromMaxSum(s: int, m: int)
  returns (x: int, y: int)
  requires s <= 2 * m
  ensures s == x + y
  ensures m == x || m == y
  ensures m >= x && m >= y
{
  x := m;
  y := s - m;
}

method TestMaxSum(x: int, y: int) {
  var s, m := MaxSum(x, y);
  var xx, yy := ReconstructFromMaxSum(s, m);
  assert (xx == x && yy == y) || (xx == y && yy == x);
}
