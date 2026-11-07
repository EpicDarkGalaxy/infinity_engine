class Parent {
  void run() {
    hello();
  }

  void hello() {
    print('hello');
  }
}

class Child extends Parent {
  @override
  void hello() {
    print('hello from child');
  }
}

void main() {
  final parent = Parent();
  parent.run();
}
