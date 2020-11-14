//
//  Container.swift
//  Eustace
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation

public typealias Creator = ()->Any?
public typealias CreatorWithDependencies = ([Any])->Any?

public class Container {
    private var repo = [AnyHashable: Creator]()
    private var repoWithDependencies = [AnyHashable: CreatorWithDependencies]()
    
    public init() {}
    
    static func key<ServiceType>(service: ServiceType, dependencyTypes: [Any]? = nil) -> String {
        guard let dependencyTypes = dependencyTypes else {
            return String(describing: ServiceType.self)
        }
        return String(describing: ServiceType.self) + dependencyTypes.reduce("") { (partial, next) in
            partial + "|" + String(describing:type(of: next))
        }
    }
    
    public func register<ServiceType>(service: ServiceType, creator: @escaping Creator) {
        let key = Container.key(service: service)
        repo[key] = creator
    }
    
    public func resolve<ServiceType>(service: ServiceType) -> Any? {
        let key = Container.key(service: service)
        if let creator = repo[key] {
            return creator()
        }
        return nil
    }
    
    public func dispose<ServiceType>(service: ServiceType) {
        let key = Container.key(service: service)
        repo[key] = nil
    }
    
    public func dispose<ServiceType>(service: ServiceType, dependencyTypes: [Any]) {
        let key = Container.key(service: service, dependencyTypes: dependencyTypes)
        repoWithDependencies[key] = nil
    }
}

extension Container {
    public func register<ServiceType>(service: ServiceType, dependencyTypes: [Any], creator: @escaping CreatorWithDependencies) {
        let key = Container.key(service: service, dependencyTypes: dependencyTypes)
        repoWithDependencies[key] = creator
    }
    
    public func resolve<ServiceType>(service: ServiceType, dependencyTypes: [Any], dependencies: [Any]) -> Any? {
        let key = Container.key(service: service, dependencyTypes: dependencyTypes)
        if let creator = repoWithDependencies[key] {
            // possibly implement dependency types conformance check here
            return creator(dependencies)
        }
        return nil
    }
}

extension Container {
    func disposeAll() {
        repo = [AnyHashable: Creator]()
        repoWithDependencies = [AnyHashable: CreatorWithDependencies]()
    }
}
