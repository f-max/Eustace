//
//  Container.swift
//  Eustace
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation

public class Container {
    enum Errors: Error {
        case circularDependency
    }
    
    private var repo = [AnyHashable: ()throws->Any?]()
    private var repoWithDependencies = [AnyHashable: ([Any])->Any?]()
    private var resolvedTypes  = [String]()
    
    public init() {}
    
    static func key<ServiceType>(service: ServiceType, dependencyTypes: [Any]? = nil) -> String {
        guard let dependencyTypes = dependencyTypes else {
            return String(describing: ServiceType.self)
        }
        return String(describing: ServiceType.self) + dependencyTypes.reduce("") { (partial, next) in
            partial + "|" + String(describing:type(of: next))
        }
    }
    
    // MARK: - register/resolve/dispose - with no dependencies
    
    /// Register: before using the container to produce an istance of a given type, that type must be registered.
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - creator: the block which is supposed to return the instance which implements the serviceType above. This block will be called when calling 'resolve'
    public func register<ServiceType>(serviceType: ServiceType.Type, creator: @escaping (()throws->ServiceType?) ) {
        let key = Container.key(service: serviceType)
        repo[key] = creator
    }
    
    /// Resolve: use resolve to get new instances of a given service type. The container will `resolve` the provided service type to a specific concrete implementation, according to the instructions previously provided by `register`. Returns nil if unable to find a match for the provided service type.
    /// - Parameter serviceType: the service type we want to resolve, the returned instance will assumably belong/subclass/conform to the provided service type
    public func resolve<ServiceType>(serviceType: ServiceType.Type) throws -> ServiceType? {
        print("resolving")
        let key = Container.key(service: serviceType)

        guard resolvedTypes.contains(key) == false else {
            throw Errors.circularDependency
        }
        
        if let creator = repo[key] {
            resolvedTypes.append(key)
            let instance = try creator() as? ServiceType
            resolvedTypes.removeLast()
            return instance
        }
        return nil
    }
    
    /// Dispose: opposite as register: it cleans the container removing the entry related to the provided service type. Once done that, if that service is not re-registered, calling resolve with the same service type will result in returning nil
    /// - Parameter serviceType: the service type associated to the entry we want to remove from the container, it is used as a `key` to find the entry to remove
    public func dispose<ServiceType>(serviceType: ServiceType) {
        let key = Container.key(service: serviceType)
        repo[key] = nil
    }
}

public extension Container {
    
    // MARK: - register/resolve/dispose - with dependencies

    /// Register with provided dependencies. Same as `register` but the creator block we provide takes an array of generic parameters
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - dependencyTypes: this array of types is used as a `key`, along with `serviceType`, to identify and store the creator block
    ///   - creator: the block which is supposed to return the instance which implements the serviceType above. This block will be called when calling 'resolve'. The block should take as input parameters a sequence of instances the types of which should conform/subclass/adopt the types provided in `dependencyTypes`
    func register<ServiceType>(serviceType: ServiceType.Type, dependencyTypes: [Any], creator: @escaping ([Any])->ServiceType?) {
        let key = Container.key(service: serviceType, dependencyTypes: dependencyTypes)
        repoWithDependencies[key] = creator
    }
    
    /// Resolve with provided dependencies. Same as `resolve` but the right creator block to be used will be found by using the `dependencyTypes` array as a `key`, along with `serviceType`
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - dependencyTypes: this array of types, along with `serviceType`, is used as a `key` to identify and retrieve the block to be used to create the required new instance
    ///   - dependencies: the parameters to be used in the creator block. Unlike `dependencyTypes` these are not types, these are actual instances, the types of which should match with `dependencyTypes`
    func resolve<ServiceType>(serviceType: ServiceType.Type, dependencyTypes: [Any], dependencies: [Any]) -> ServiceType? {
        let key = Container.key(service: serviceType, dependencyTypes: dependencyTypes)
        if let creator = repoWithDependencies[key] {
            return creator(dependencies) as? ServiceType
        }
        return nil
    }
    
    /// Dispose with provided dependency types: same as `dispose` but using the `dependencyTypes` parameter as a `key` to find which entry in the container needs to be removed
    /// - Parameters:
    ///   - serviceType: the service type associated to the entry we want to remove from the container, it is used as a `key`, along with `dependencyTypes` to find the entry to remove
    ///   - dependencyTypes: it is used as a `key`, along with `serviceType` to find the entry to remove
    func dispose<ServiceType>(serviceType: ServiceType, dependencyTypes: [Any]) {
        let key = Container.key(service: serviceType, dependencyTypes: dependencyTypes)
        repoWithDependencies[key] = nil
    }
}

public extension Container {
    
    // MARK: - extra

    /// Resets the container to its initial state, all registered items are removed.
    func disposeAll() {
        repo = [:]
        repoWithDependencies = [:]
    }
}
