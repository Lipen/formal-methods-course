datatype Expr =
  | Const(nat)
  | Var(string)
  | Node(op: Op, args: List<Expr>)

datatype Op = Add | Mul

datatype List<T> = Nil | Cons(head: T, tail: List<T>)

type Env = map<string, nat>

// Eval and EvalList are mutually recursive
function Eval(e: Expr, env: Env): nat
  // requires env contains all necessary keys
  requires GoodEnv(e, env)
{
  match e {
    case Const(n) => n
    // case Var(x) => if x in env.Keys then env[x] else 0
    case Var(x) => env[x]
    case Node(op, args) => EvalList(op, args, env)
  }
}

function EvalList(op: Op, args: List<Expr>, env: Env): nat
  decreases args
  requires GoodEnvList(op, args, env)
{
  match args {
    case Nil => match op {
      case Add => 0
      case Mul => 1
    }
    case Cons(head, tail) => match op {
      case Add => Eval(head, env) + EvalList(op, tail, env)
      case Mul => Eval(head, env) * EvalList(op, tail, env)
    }
  }
}

predicate GoodEnv(e: Expr, env: Env) {
  match e {
    case Const(n) => true
    case Var(x) => x in env.Keys
    case Node(op, args) => GoodEnvList(op, args, env)
  }
}

predicate GoodEnvList(op: Op, args: List<Expr>, env: Env)
  decreases args
{
  match args {
    case Nil => true
    case Cons(head, tail) => GoodEnv(head, env) && GoodEnvList(op, tail, env)
  }
}
