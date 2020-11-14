
// Container definition
typealias Creator = ()->Any?
typealias CreatorWithDependencies = ([Any])->Any?

class Container {
    var repo = [AnyHashable: Creator]()
    var repoWithDependencies = [AnyHashable: CreatorWithDependencies]()
    
    static func key<ServiceType>(service: ServiceType, dependencyTypes: [Any]? = nil) -> String {
        guard let dependencyTypes = dependencyTypes else {
            return String(describing: ServiceType.self)
        }
        return String(describing: ServiceType.self) + dependencyTypes.reduce("") { (partial, next) in
            partial + "|" + String(describing:type(of: next))
        }
    }
    
    func register<ServiceType>(service: ServiceType, creator: @escaping Creator) {
        let key = Container.key(service: service)
        repo[key] = creator
    }
    func resolve<ServiceType>(service: ServiceType) -> Any? {
        let key = Container.key(service: service)
        if let creator = repo[key] {
            return creator()
        }
        return nil
    }
    func dispose<ServiceType>(service: ServiceType) {
        
    }
}

// Container use, simple test case
print("- 1")

protocol SimpleProtocol {
    func doStuff()
}
class SimpleClass: SimpleProtocol {
    func doStuff() {
        print("doStuff")
    }
}
class SimplerClass: SimpleProtocol {
    func doStuff() {
        print("doSimplerStuff")
    }
}
let container = Container()

container.register(service: SimpleProtocol.self) {
    SimpleClass()
}
let simpleClass: SimpleProtocol = container.resolve(service: SimpleProtocol.self) as! SimpleProtocol
simpleClass.doStuff()

container.register(service: SimpleProtocol.self) {
    SimplerClass()
}
let simplerClass: SimpleProtocol = container.resolve(service: SimpleProtocol.self) as! SimpleProtocol
simplerClass.doStuff()


// Container use, resolve call within register block example
print("\n- 2")

protocol ProtocolA: class {
    var b: ProtocolB { get }
    func doAStuff()
}
protocol ProtocolB: class {
}

class ClassA: ProtocolA {
    let b: ProtocolB
    init(b: ProtocolB) {
        self.b = b
    }
    func doAStuff() {
        print("doingAStuff")
    }
}

class ClassB: ProtocolB {
}

container.register(service: ProtocolA.self) { [weak container] in
    guard let container = container else {
        return nil
    }
    return ClassA(b: (container.resolve(service: ProtocolB.self) as! ProtocolB))
}
container.register(service: ProtocolB.self) {
    ClassB()
}

let a: ProtocolA? = container.resolve(service: ProtocolA.self) as? ProtocolA
a?.doAStuff()


// Container use, circular dependency, solved by container user
print("\n- 3")

protocol ProtocolAA: class {
    var b: ProtocolBB { get }
    func doAAStuff()
}
protocol ProtocolBB: class {
    var a: ProtocolAA? { get set }
    func doBBStuff()
}
class ClassAA: ProtocolAA {
    var b: ProtocolBB
    init(b: ProtocolBB) {
        self.b = b
    }
    func doAAStuff() {
        print("doingAAStuff")
    }
}
class ClassBB: ProtocolBB {
    weak var a: ProtocolAA?
    func doBBStuff() {
        print("doingBBStuff")
    }
}
container.register(service: ProtocolBB.self) {
    ClassBB()
}
container.register(service: ProtocolAA.self) { [weak container] in
    guard let container = container else {
        return nil
    }
    let b = container.resolve(service: ProtocolBB.self) as! ProtocolBB
    let a = ClassAA(b: b)
    a.b = b
    b.a = a
    return a
}

let aa: ProtocolAA = container.resolve(service: ProtocolAA.self) as! ProtocolAA

aa.doAAStuff()
aa.b.doBBStuff()


// get container support passing dependencies
print("\n- 4")
extension Container {
    func register<ServiceType>(service: ServiceType, dependencyTypes: [Any], creator: @escaping CreatorWithDependencies) {
        let key = Container.key(service: service, dependencyTypes: dependencyTypes)
        repoWithDependencies[key] = creator
    }
    
    func resolve<ServiceType>(service: ServiceType, dependencyTypes: [Any], dependencies: [Any]) -> Any? {
        let key = Container.key(service: service, dependencyTypes: dependencyTypes)
        if let creator = repoWithDependencies[key] {
            // possibly implement dpendency types conformance check here
            return creator(dependencies)
        }
        return nil
       }
}

container.register(service: ProtocolAA.self, dependencyTypes: [ProtocolBB.self]) { dependencies in
    guard dependencies.count == 1, let bb = dependencies.first as? ProtocolBB else {
        return nil
    }
    let a = ClassAA(b: bb)
    a.b = bb
    bb.a = a
    return a
}

let bbToProvide = container.resolve(service: ProtocolBB.self)!
let aaWithProvidedB: ProtocolAA = container.resolve(service: ProtocolAA.self, dependencyTypes: [ProtocolBB.self], dependencies: [bbToProvide]) as! ProtocolAA

aaWithProvidedB.b.doBBStuff()
