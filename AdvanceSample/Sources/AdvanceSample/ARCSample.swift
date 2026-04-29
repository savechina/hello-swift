class Person {
    let name: String
    var pet: Pet?
    
    init(name: String) {
        self.name = name
        print("  Person \(name) initialized")
    }
    
    deinit {
        print("  Person \(name) deinitialized")
    }
}

class Pet {
    let name: String
    weak var owner: Person?
    
    init(name: String) {
        self.name = name
        print("  Pet \(name) initialized")
    }
    
    deinit {
        print("  Pet \(name) deinitialized")
    }
}

func arcSample() {
    print("--- arcSample start ---")
    
    var person: Person? = Person(name: "Alice")
    var pet: Pet? = Pet(name: "Fluffy")
    
    person?.pet = pet
    pet?.owner = person
    print("Cycle created (pet.owner is weak, so no retain cycle)")
    
    person = nil
    print("After person = nil")
    
    pet = nil
    print("After pet = nil")
    
    var localValue = 42
    let closure = { [localValue] in
        print("  Closure captured: \(localValue)")
    }
    closure()
    
    print("--- arcSample end ---")
}
