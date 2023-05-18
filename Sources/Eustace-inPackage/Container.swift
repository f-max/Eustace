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
    private var repoWithDependencies = [AnyHashable: (Any)throws->Any?]()
    private var resolvedTypes  = [String]()
    
    public init() {}
    
    static func key<ServiceType>(serviceType: ServiceType) -> String {
        return String(describing: ServiceType.self)
    }
    
    static func key<ServiceType, CreatorParameterType>(service: ServiceType, creatorParameterType: CreatorParameterType) -> String {
        return String(describing: ServiceType.self) + "|" + String(describing: CreatorParameterType.self)
    }
    
    // MARK: - register/resolve/dispose - with no dependencies
    
    /// Register: before using the container to produce an istance of a given type, that type must be registered.
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - creator: the block which is supposed to return the instance which implements the serviceType above. This block will be called when calling 'resolve'
    public func register<Service>(serviceType: Service.Type, creator: @escaping (()throws->Service?) ) {
        let key = Container.key(serviceType: serviceType)
        repo[key] = creator
    }
    
    /// Resolve: use resolve to get new instances of a given service type. The container will `resolve` the provided service type to a specific concrete implementation, according to the instructions previously provided by `register`. Throws un error unable to find a match for the provided service type.
    /// - Parameter serviceType: the service type we want to resolve, the returned instance will assumably belong/subclass/conform to the provided service type
    public func resolve<Service>(serviceType: Service.Type) throws -> Service? {
        guard repo.count > 0 else {
            throw Errors.emptyContainerUse 
        }
        
        let key = Container.key(serviceType: serviceType)
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
    
    /// Dispose: opposite as register: it cleans the container removing the entry related to the provided service type. Once done that, if that service is not re-registered, calling resolve with the same service type will result in throwing an error
    /// - Parameter serviceType: the service type associated to the entry we want to remove from the container, it is used as a `key` to find the entry to remove
    public func dispose<Service>(serviceType: Service) {
        let key = Container.key(serviceType: serviceType)
        repo[key] = nil
    }
}

public extension Container {
    
    // MARK: - register/resolve/dispose - with parameter

    /// Register with provided dependencies. Same as `register` but the creator block we provide takes a parameter
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - creatorParameterType: this type is used as a `key`, along with `serviceType`, to identify and store the creator block
    ///   - creator: the block which is supposed to return the instance which implements the serviceType above. This block will be called when calling 'resolve'. The block should take as input parameter an instance of the types of which should conform/subclass/adopt the types provided in `CreatorParameterType`
    func register<Service, CreatorParameterType>(serviceType: Service.Type, creatorParameterType: CreatorParameterType.Type, creator: @escaping (CreatorParameterType)throws->Service?) {
      let key = Container.key(service: serviceType, creatorParameterType: creatorParameterType)
        let castedCreator: (Any)throws->Any? = { parameter in
            guard let parameter = parameter as? CreatorParameterType else {
                return nil
            }
            return try creator(parameter)
        }
        repoWithDependencies[key] = castedCreator
    }
        
    /// Resolve with provided dependency. Same as `resolve` but the right creator block to be used will be found by using the `dependency` type as a `key`, along with `serviceType`
    /// - Parameters:
    ///   - serviceType: the type which we want to register, typically a protocol, but it can also be a class or any other type. e.g. SomeProtocol.self
    ///   - dependency: the parameter to be used in the creator block. Its type is also used as a key along with `serviceType`
    func resolve<Service, ParameterType>(serviceType: Service.Type, parameter: ParameterType) throws -> Service? {
        guard repoWithDependencies.count > 0 else {
            throw Errors.emptyContainerUse
        }
        
      let key = Container.key(service: serviceType, creatorParameterType: ParameterType.self)
        
        guard resolvedTypes.contains(key) == false else {
            throw Errors.circularDependency
        }
        guard let creator = repoWithDependencies[key] else {
            throw Errors.resolvingUnregisteredService
        }
        resolvedTypes.append(key)
        let instance = try creator(parameter) as? Service
        resolvedTypes.removeLast()
        return instance
    }
    
    /// Dispose with provided dependency type: same as `dispose` but using the `dependencyType` parameter as a `key` to find which entry in the container needs to be removed
    /// - Parameters:
    ///   - serviceType: the service type associated to the entry we want to remove from the container, it is used as a `key`, along with `dependencyTypes` to find the entry to remove
    ///   - creatorParameterType: it is used as a `key`, along with `serviceType` to find the entry to remove
    func dispose<Service, Dependency>(serviceType: Service, dependencyType: Dependency) {
      let key = Container.key(service: serviceType, creatorParameterType: dependencyType)
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
