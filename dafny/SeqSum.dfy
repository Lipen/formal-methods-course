function SeqSum(s: seq<int>, lo: nat, hi: nat): int
  requires 0 <= lo <= hi <= |s|
  decreases hi - lo
{
  if lo == hi then 0
  else s[lo] + SeqSum(s, lo + 1, hi)
}
