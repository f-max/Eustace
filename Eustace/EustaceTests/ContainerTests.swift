//
//  ContainerTests.swift
//  EustaceTests
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import XCTest
@testable import Eustace

class ContainerTests: XCTestCase {
    var sut: Container!

    override func setUp() {
        sut = Container()
    }

    // MARK: - Key function tests
    
    func test_key_typeIsClass_producesExpextedString() {
        XCTAssertEqual(Container.key(service: String.self), "String.Type")
    }
    
    func test_key_typeIsProtocol_producesExpextedString() {
        XCTAssertEqual(Container.key(service: SomeProtocol.self), "SomeProtocol.Protocol")
    }
    
    func test_keyWithDependencies_typeIsClass_depenciesIsNil_producesExpextedString() {
        let value = Container.key(service: String.self, dependencyTypes: nil)
        XCTAssertEqual(value, "String.Type")
    }
    
    func test_keyWithDependencies_typeIsProtocol_depenciesIsNil_producesExpextedString() {
        let value = Container.key(service: SomeProtocol.self, dependencyTypes: nil)
        XCTAssertEqual(value, "SomeProtocol.Protocol")
    }
    
    func test_keyWithDependencies_typeIsClass_depenciesIsEmpty_producesExpextedString() {
        let value = Container.key(service: String.self, dependencyTypes: [Any]())
        XCTAssertEqual(value, "String.Type")
    }
    
    func test_keyWithDependencies_typeIsProtocol_depenciesIsEmpty_producesExpextedString() {
        let value = Container.key(service: SomeProtocol.self, dependencyTypes: [Any]())
        XCTAssertEqual(value, "SomeProtocol.Protocol")
    }
    
    func test_keyWithDependencies_typeIsClass_depenciesIsNonEmpty_producesExpextedString() {
        let value = Container.key(service: String.self, dependencyTypes: [SomeProtocol.self])
        XCTAssertEqual(value, "String.Type|SomeProtocol.Protocol")
    }
    
    func test_keyWithDependencies_typeIsProtocol_depenciesIsNonEmpty_producesExpextedString() {
        let value = Container.key(service: SomeProtocol.self, dependencyTypes:  [SomeProtocol.self])
        XCTAssertEqual(value, "SomeProtocol.Protocol|SomeProtocol.Protocol")
    }
    
    // MARK: -  Register-resolve cycles no dependencies
    
    func test_doNotRegisterAnything_resolveAType_returnsNil() {
        let result = try! sut.resolve(serviceType: SomeOtherProtocol.self)
        XCTAssertNil(result)
    }
    
    func test_registerAType_resolveADifferentType_returnsNil() {
        sut.register(serviceType: SomeOtherProtocol.self) {
            SomeOtherClass() 
        }
        let result = try! sut.resolve(serviceType: SomeProtocol.self)
        XCTAssertNil(result)
    }
    
    func test_registerAType_resolveSameType_returnsCorrectInstance() {
        
        sut.register(serviceType: SomeProtocol.self) {
            return SomeClass()
        }
        let result = try! sut.resolve(serviceType: SomeProtocol.self)
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeClass.self)
    }
    
    // MARK: -  Register-resolve cycles with dependencies
    
    func test_doNotRegisterAnything_resolveATypeWithEmptyDependencies_returnsNil() {
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [Any](), dependencies: [Any]())
        XCTAssertNil(result)
    }
    
    func test_registerATypeWithDependencies_resolveADifferentTypeWithSameDependencies_returnsNil() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [String.self]) { _ in
            SomeClass()
        }
        let result = sut.resolve(serviceType: SomeOtherProtocol.self, dependencyTypes: [String.self], dependencies: [""])
        XCTAssertNil(result)
    }
    
    func test_registerATypeWithDependencies_resolveSameTypeWithDifferentDependencies_returnsNil() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [String.self]) { _ in
            SomeClass()
        }
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [Int.self], dependencies: [3])
        XCTAssertNil(result)
    }
    
    func test_registerATypeWithDependencies_resolveSameTypeWithSameDependencies_returnsCorrectInstance() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [String.self]) { _ in
            SomeClass()
        }
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [String.self], dependencies: [""])
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeClass.self)
    }
    
    func test_registerATypeWithDependencies_resolveSameTypeWithSameDependencies_returnsCorrectInstance_case2() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self]) { _ in
            SomeClass()
        }
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self], dependencies: [""])
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeClass.self)
    }
    
    // MARK: -  Register-dispose-resolve cycles no dependencies
    
    func test_registerAType_disposeType_resolveSameType_returnsNil() {
        sut.register(serviceType: SomeOtherProtocol.self) {
            SomeOtherClass()
        }
        sut.dispose(serviceType: SomeOtherProtocol.self)
        let result = try! sut.resolve(serviceType: SomeOtherProtocol.self)
        XCTAssertNil(result)
    }
    
    func test_registerAType_disposeDifferentType_resolveSameType_returnsCorrectInstance() {
        sut.register(serviceType: SomeOtherProtocol.self) {
            SomeOtherClass()
        }
        sut.dispose(serviceType: SomeProtocol.self)
        let result = try! sut.resolve(serviceType: SomeOtherProtocol.self)
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeOtherClass.self)
    }
    
    func test_registerAType_disposeAll_resolveSameType_returnsNil() {
        sut.register(serviceType: SomeOtherProtocol.self) {
            SomeOtherClass()
        }
        sut.disposeAll()
        let result = try! sut.resolve(serviceType: SomeOtherProtocol.self)
        XCTAssertNil(result)
    }
    
    // MARK: -  Register-dispose-resolve cycles with dependencies
    
    func test_registerATypeWithDependencies_disposeType_resolveSameType_returnsNil() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self]) { _ in
            SomeClass()
        }
        sut.dispose(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self])
        let result = sut.resolve(serviceType:  SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self], dependencies: [SomeOtherClass()])
        XCTAssertNil(result)
    }
    
    func test_registerATypeWithDependencies_disposeDifferentType_resolveSameType_returnsCorrectInstance() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self]) { _ in
            SomeClass()
        }
        sut.dispose(serviceType: SomeOtherProtocol.self, dependencyTypes: [SomeOtherProtocol.self])

        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self], dependencies: [SomeOtherClass()])
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeClass.self)
    }

    func test_registerATypeWithDependencies_disposeAll_resolveSameType_returnsNil() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self]) { _ in
            SomeClass()
        }
        sut.disposeAll()
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [SomeOtherProtocol.self], dependencies: [SomeOtherClass()])
        XCTAssertNil(result)
    }
    
    // MARK: -  Circular dependency detection
    
    func test_resolveServiceType_withTwoWaysCircularDepenedency_throwsAppropriateError() {
        sut.register(serviceType: ProtocolA.self) { [weak self] in
            guard let self = self else {
                return nil
            }
            var b = try self.sut.resolve(serviceType: ProtocolB.self)
            let a = ClassA()
            a.b = b
            b?.a = a
            return a
        }
        sut.register(serviceType: ProtocolB.self) { [weak self] in
            guard let self = self else {
                return nil
            }
            var a = try self.sut.resolve(serviceType: ProtocolA.self)
            let b = ClassB()
            b.a = a
            a?.b = b
            return b
        }
        
        XCTAssertThrowsError(try sut.resolve(serviceType: ProtocolA.self)) { error in
            XCTAssertTrue(error is Container.Errors)
            XCTAssertEqual(error as? Container.Errors, .circularDependency)
        }
    }
    
    func test_resolveServiceType_withThreeWaysCircularDepenedency_throwsAppropriateError() {
        sut.register(serviceType: ProtocolAA.self) { [weak self] in
            guard let self = self else {
                return nil
            }
            let a = ClassAA()

            var b = try self.sut.resolve(serviceType: ProtocolBB.self)
            var c = try self.sut.resolve(serviceType: ProtocolCC.self)
            a.b = b
            b?.c = c
            c?.a = a
            
            return a
        }
        sut.register(serviceType: ProtocolBB.self) { [weak self] in
            guard let self = self else {
                return nil
            }
            let b = ClassBB()

            var a = try self.sut.resolve(serviceType: ProtocolAA.self)
            var c = try self.sut.resolve(serviceType: ProtocolCC.self)
            a?.b = b
            b.c = c
            c?.a = a
          
            return b
        }
        sut.register(serviceType: ProtocolCC.self) { [weak self] in
            guard let self = self else {
                return nil
            }
            let c = ClassCC()

            var a = try self.sut.resolve(serviceType: ProtocolAA.self)
            var b = try self.sut.resolve(serviceType: ProtocolBB.self)
            a?.b = b
            b?.c = c
            c.a = a
          
            return c
        }
                    
        XCTAssertThrowsError(try sut.resolve(serviceType: ProtocolAA.self)) { error in
            XCTAssertTrue(error is Container.Errors)
            XCTAssertEqual(error as? Container.Errors, .circularDependency)
        }
    }
}

// MARK: -  Helpers

private protocol SomeProtocol {
    func doStuff()
}

private class SomeClass: SomeProtocol {
    func doStuff() {
        print("doSomeStuff")
    }
}

private protocol SomeOtherProtocol {
    func doStuff()
}

private class SomeOtherClass: SomeOtherProtocol {
    func doStuff() {
        print("doSomeOtherStuff")
    }
}

// MARK: - Helpers for two ways circular dependency

private protocol ProtocolA {
    var b: ProtocolB?  { get set }
}

private protocol ProtocolB {
    var a: ProtocolA?  { get set }
}

private class ClassA: ProtocolA {
    var b: ProtocolB?
}

private class ClassB: ProtocolB {
    var a: ProtocolA?
}

// MARK: - Helpers for three ways circular dependency

private protocol ProtocolAA {
    var b: ProtocolBB?  { get set }
}

private protocol ProtocolBB {
    var c: ProtocolCC?  { get set }
}

private protocol ProtocolCC {
    var a: ProtocolAA?  { get set }
}

private class ClassAA: ProtocolAA {
    var b: ProtocolBB?
}

private class ClassBB: ProtocolBB {
    var c: ProtocolCC?
}

private class ClassCC: ProtocolCC {
    var a: ProtocolAA?
}



