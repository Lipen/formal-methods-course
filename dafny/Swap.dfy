method Swap(a: array, i: int, j: int)
  modifies a
  requires 0 <= i < a.Length
  requires 0 <= j < a.Length
  ensures a[i] == old(a[j])
  ensures a[j] == old(a[i])
{
  var temp := a[i];
  a[i] := a[j];
  a[j] := temp;
}

method {:test} TestSwap(a: array, i: int, j: int)
  modifies a
  requires 0 <= i < a.Length
  requires 0 <= j < a.Length
{
  // Save original values at i and j
  var old_i := a[i];
  var old_j := a[j];
  Swap(a, i, j);
  // Assert that elements at i and j are swapped
  assert a[i] == old_j;
  assert a[j] == old_i;
}
