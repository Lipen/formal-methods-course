method StudyPlan(n: nat)
  requires 1 <= n <= 40
  decreases 40 - n
{
  if n == 40 {
    // done
  } else {
    var hours := RequiredStudyTime(n);
    Learn(n, hours);
  }
}

method Learn(n: nat, h: nat)
  requires 1 <= n < 40
  decreases 40 - n, h
{
  if h == 0 {
    // done with class n, continue with the rest
    StudyPlan(n + 1);
  } else {
    // study for 1 hour
    Learn(n, h - 1);
  }
}

method RequiredStudyTime(c: nat) returns (hours: nat)
  ensures {:axiom} hours <= 200
