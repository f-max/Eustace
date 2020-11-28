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
        case emptyContainerUse
        case resolvingUnregisteredService
        case circularDependency
    }
    
    private var repo = [AnyHashable: ()throws->Any?]()
    private var repoWithDependencies = [AnyHashable: (Any)->Any?]()
    private var resolvedTypes  = [String]()
    
    public init() {}
    
    static func key<ServiceType>(service: ServiceType) -> String {
        return String(describing: ServiceType.self)
    }
    
    static func key<ServiceType, DependencyType>(service: ServiceType, dependencyType: DependencyType) -> String {
        return String(describing: ServiceType.self) + "|" + String(describing: DependencyType.self)
    }
    
    // MARK: - register/resolve/dispose - with no dependencies
    
    /// Register: before using the container to produce an istance of a given type, that type must be registered.
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - creator: the block which is supposed to return the instance which implements the serviceType above. This block will be called when calling 'resolve'
    public func register<Service>(serviceType: Service.Type, creator: @escaping (()throws->Service?) ) {
        let key = Container.key(service: serviceType)
        repo[key] = creator
    }
    
    /// Resolve: use resolve to get new instances of a given service type. The container will `resolve` the provided service type to a specific concrete implementation, according to the instructions previously provided by `register`. Returns nil if unable to find a match for the provided service type.
    /// - Parameter serviceType: the service type we want to resolve, the returned instance will assumably belong/subclass/conform to the provided service type
    public func resolve<Service>(serviceType: Service.Type) throws -> Service? {
        guard repo.count > 0 else {
            throw Errors.emptyContainerUse 
        }
        
        let key = Container.key(service: serviceType)
        guard resolvedTypes.contains(key) == false else {
            throw Errors.circularDependency
        }
        guard let creator = repo[key] else {
            throw Errors.resolvingUnregisteredService
        }
        resolvedTypes.append(key)
        let instance = try creator() as? Service
        resolvedTypes.removeLast()
        return instance
    }
    
    /// Dispose: opposite as register: it cleans the container removing the entry related to the provided service type. Once done that, if that service is not re-registered, calling resolve with the same service type will result in returning nil
    /// - Parameter serviceType: the service type associated to the entry we want to remove from the container, it is used as a `key` to find the entry to remove
    public func dispose<Service>(serviceType: Service) {
        let key = Container.key(service: serviceType)
        repo[key] = nil
    }
}

public extension Container {
    
    // MARK: - register/resolve/dispose - with dependencies

    /// Register with provided dependencies. Same as `register` but the creator block we provide takes a parameter
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - dependencyType: this type is used as a `key`, along with `serviceType`, to identify and store the creator block
    ///   - creator: the block which is supposed to return the instance which implements the serviceType above. This block will be called when calling 'resolve'. The block should take as input parameters a sequence of instances the types of which should conform/subclass/adopt the types provided in `dependencyTypes`
    func register<Service, Dependency>(serviceType: Service.Type, dependencyType: Dependency.Type, creator: @escaping (Dependency)->Service?) {
        let key = Container.key(service: serviceType, dependencyType: dependencyType)
        let castedCreator: (Any)->Any? = { dependency in
            guard let dependency = dependency as? Dependency else {
                return nil
            }
            return creator(dependency)
        }
        repoWithDependencies[key] = castedCreator
    }
        
    /// Resolve with provided dependency. Same as `resolve` but the right creator block to be used will be found by using the `dependency` type as a `key`, along with `serviceType`
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - dependency: the parameter to be used in the creator block. Its type is also used as a key along with `serviceType`
    func resolve<Service, Dependency>(serviceType: Service.Type, dependency: Dependency) -> Service? {
        // TODO: implement circular dependency detection AND implement throwing errors instead of returning nil instances, similar to other resolve function
        let key = Container.key(service: serviceType, dependencyType: Dependency.self)
        if let creator = repoWithDependencies[key] {
            return creator(dependency) as? Service
        }
        return nil
    }
    
    /// Dispose with provided dependency type: same as `dispose` but using the `dependencyType` parameter as a `key` to find which entry in the container needs to be removed
    /// - Parameters:
    ///   - serviceType: the service type associated to the entry we want to remove from the container, it is used as a `key`, along with `dependencyTypes` to find the entry to remove
    ///   - dependencyType: it is used as a `key`, along with `serviceType` to find the entry to remove
    func dispose<Service, Dependency>(serviceType: Service, dependencyType: Dependency) {
        let key = Container.key(service: serviceType, dependencyType: dependencyType)
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
