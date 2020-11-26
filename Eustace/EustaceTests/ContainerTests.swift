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
        let result = sut.resolve(serviceType: SimpleProtocol.self)
        XCTAssertNil(result)
    }
    
    func test_registerAType_resolveADifferentType_returnsNil() {
        sut.register(serviceType: SimpleProtocol.self) {
            SimpleClass() 
        }
        let result = sut.resolve(serviceType: SomeProtocol.self)
        XCTAssertNil(result)
    }
    
    func test_registerAType_resolveSameType_returnsCorrectInstance() {
        
        sut.register(serviceType: SimpleProtocol.self) {
            return SimpleClass()
        }
        let result = sut.resolve(serviceType: SimpleProtocol.self)
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SimpleClass.self)
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
        let result = sut.resolve(serviceType: SimpleProtocol.self, dependencyTypes: [String.self], dependencies: [""])
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
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self]) { _ in
            SomeClass()
        }
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self], dependencies: [""])
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeClass.self)
    }
    
    // MARK: -  Register-dispose-resolve cycles no dependencies
    
    func test_registerAType_disposeType_resolveSameType_returnsNil() {
        sut.register(serviceType: SimpleProtocol.self) {
            SimpleClass()
        }
        sut.dispose(serviceType: SimpleProtocol.self)
        let result = sut.resolve(serviceType: SimpleProtocol.self)
        XCTAssertNil(result)
    }
    
    func test_registerAType_disposeDifferentType_resolveSameType_returnsCorrectInstance() {
        sut.register(serviceType: SimpleProtocol.self) {
            SimpleClass()
        }
        sut.dispose(serviceType: SomeProtocol.self)
        let result = sut.resolve(serviceType: SimpleProtocol.self)
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SimpleClass.self)
    }
    
    func test_registerAType_disposeAll_resolveSameType_returnsNil() {
        sut.register(serviceType: SimpleProtocol.self) {
            SimpleClass()
        }
        sut.disposeAll()
        let result = sut.resolve(serviceType: SimpleProtocol.self)
        XCTAssertNil(result)
    }
    
    // MARK: -  Register-dispose-resolve cycles with dependencies
    
    func test_registerATypeWithDependencies_disposeType_resolveSameType_returnsNil() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self]) { _ in
            SomeClass()
        }
        sut.dispose(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self])
        let result = sut.resolve(serviceType:  SomeProtocol.self, dependencyTypes: [SimpleProtocol.self], dependencies: [SimpleClass()])
        XCTAssertNil(result)
    }
    
    func test_registerATypeWithDependencies_disposeDifferentType_resolveSameType_returnsCorrectInstance() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self]) { _ in
            SomeClass()
        }
        sut.dispose(serviceType: SimpleProtocol.self, dependencyTypes: [SimpleProtocol.self])

        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self], dependencies: [SimpleClass()])
        XCTAssertNotNil(result)
        XCTAssert(type(of: result!) == SomeClass.self)
    }

    func test_registerATypeWithDependencies_disposeAll_resolveSameType_returnsNil() {
        sut.register(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self]) { _ in
            SomeClass()
        }
        sut.disposeAll()
        let result = sut.resolve(serviceType: SomeProtocol.self, dependencyTypes: [SimpleProtocol.self], dependencies: [SimpleClass()])
        XCTAssertNil(result)
    }
}

// MARK: -  Helpers


private protocol SomeProtocol {
    
}

private class SomeClass: SomeProtocol {
    
}

private protocol SimpleProtocol {
    func doStuff()
}

private class SimpleClass: SimpleProtocol {
    func doStuff() {
        print("doStuff")
    }
}

private class SimplerClass: SimpleProtocol {
    func doStuff() {
        print("doSimplerStuff")
    }
}
