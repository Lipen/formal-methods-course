datatype BYTree =
  | BlueLeaf
  | YellowLeaf
  | Node(left: BYTree, right: BYTree)

function BlueCount(t: BYTree): nat {
  match t {
    case BlueLeaf => 1
    case YellowLeaf => 0
    case Node(left, right) => BlueCount(left) + BlueCount(right)
  }
}

method LeftDepth_method(t: BYTree) returns (d: int)
  ensures d >= 0
{
  d:= LeftDepth(t);
}

function LeftDepth(t: BYTree): (d: int)
  ensures match t
          case Node(_, _) => d > 0
          case _ => d == 0
{
  match t
  case BlueLeaf => 0
  case YellowLeaf => 0
  case Node(left, _) => 1 + LeftDepth(left)
}

function ReverseColors(t: BYTree): BYTree {
  match t
  case BlueLeaf => YellowLeaf
  case YellowLeaf => BlueLeaf
  case Node(left, right) => Node(ReverseColors(left), ReverseColors(right))
}

method {:test} TestReverseColors() {
  var a := Node(BlueLeaf, Node(YellowLeaf, BlueLeaf));
  var b := Node(YellowLeaf, Node(BlueLeaf, YellowLeaf));
  assert(ReverseColors(a) == b);
  assert(ReverseColors(b) == a);
}

function Oceanize(t: BYTree): BYTree {
  match t
  case BlueLeaf => BlueLeaf
  case YellowLeaf => BlueLeaf
  case Node(left, right) => Node(Oceanize(left), Oceanize(right))
}

predicate IsNode(t: BYTree) {
  match t
  case Node(_, _) => true
  case _ => false
}

function GetLeft(t: BYTree): BYTree
  requires t.Node?
{
  t.left
}
