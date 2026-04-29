protocol Shape {
    func area() -> Double
}

struct Circle: Shape {
    let radius: Double
    func area() -> Double { .pi * radius * radius }
}

struct Square: Shape {
    let side: Double
    func area() -> Double { side * side }
}

func makeShape() -> some Shape {
    Circle(radius: 5)
}

func makeShapes() -> [any Shape] {
    [Circle(radius: 5), Square(side: 10)]
}

func opaqueTypeSample() {
    print("--- opaqueTypeSample start ---")
    
    let shape = makeShape()
    print("Opaque shape area: \(shape.area())")
    
    let shapes = makeShapes()
    for s in shapes {
        print("  Shape area: \(s.area())")
    }
    
    let circle = Circle(radius: 3)
    let square = Square(side: 4)
    let mixed: [any Shape] = [circle, square]
    let totalArea = mixed.reduce(0) { $0 + $1.area() }
    print("Total area of mixed shapes: \(totalArea)")
    
    print("--- opaqueTypeSample end ---")
}
