datatype Tree<T> =
  | Leaf(data: T)
  | Node(left: Tree<T>, right: Tree<T>)

datatype Color = Blue | Yellow | Red | Green

predicate AllBlue(t: Tree<Color>) {
  match t
  case Leaf(c) => c == Blue
  case Node(left, right) => AllBlue(left) && AllBlue(right)
}

function Size<T>(t: Tree<T>): nat
  ensures match t
          case Node(left, right) => (
            Size(t) > 0 &&
            Size(t) > Size(left) &&
            Size(t) > Size(right)
          )
          case _ => Size(t) == 1
  ensures Size(t) > 0
{
  match t
  case Leaf(_) => 1
  case Node(left, right) => Size(left) + Size(right)
}

function Mirror<T>(t: Tree<T>): Tree<T>
  // Mirror is idempotent:
  // ensures Mirror(Mirror(t)) == t
{
  match t
  case Leaf(c) => Leaf(c)
  case Node(l, r) => Node(Mirror(r), Mirror(l))
}

method {:test} TestMirror() {
  var t1 := Node(Leaf(1), Node(Leaf(2), Leaf(3)));
  var t2 := Mirror(Mirror(t1));
  assert t2 == t1;
}
