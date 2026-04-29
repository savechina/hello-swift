func unsafePointerSample() {
    print("--- unsafePointerSample start ---")
    
    let array: [Int] = [10, 20, 30, 40, 50]
    
    array.withUnsafeBufferPointer { buffer in
        guard let base = buffer.baseAddress else { return }
        print("First element: \(base.pointee)")
        
        var sum = 0
        for i in 0..<buffer.count {
            sum += buffer[i]
        }
        print("Sum via pointer: \(sum)")
    }
    
    var value: Int32 = 42
    withUnsafePointer(to: &value) { ptr in
        print("Value via pointer: \(ptr.pointee)")
    }
    
    print("Int size: \(MemoryLayout<Int>.size) bytes")
    print("Int stride: \(MemoryLayout<Int>.stride) bytes")
    print("Int alignment: \(MemoryLayout<Int>.alignment) bytes")
    
    struct Point {
        var x: Double
        var y: Double
    }
    print("Point size: \(MemoryLayout<Point>.size) bytes")
    
    print("--- unsafePointerSample end ---")
}
