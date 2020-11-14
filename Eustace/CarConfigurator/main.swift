//
//  main.swift
//  CarConfigurator
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation
import Eustace


let container = Container()


// MARK: - Example 1
print("- Example 1\n")
container.setup(power: .standard, optionals: .standard)
let cheapCar = container.resolve(service: CarProtocol.self) as? CarProtocol

container.setup(power: .sports, optionals: .luxury)
let funkyCar = container.resolve(service: CarProtocol.self) as? CarProtocol

container.setup(power: .supersports, optionals: .luxury)
let superFunkyCar = container.resolve(service: CarProtocol.self) as? CarProtocol

container.setup(power: .standard, optionals: .medium, chassisSerialNumber: "xyz")
let registeredCar = container.resolve(service: CarProtocol.self) as? CarProtocol

print("Cheap car: \(cheapCar!.engine.powerHP) hp, \(cheapCar!.interiors.seats.description())")
print("Funky car: \(funkyCar!.engine.powerHP) hp, \(funkyCar!.interiors.seats.description())")
print("Superfunky car: \(superFunkyCar!.engine.powerHP) hp, \(superFunkyCar!.interiors.seats.description())")

// MARK: - Example 2
print("\n\n- Example 2\n")

container.disposeAll()
container.register(service: ChassisProtocol.self, dependencyTypes: [String.self]) { dependencies in
    guard dependencies.count == 1, let serialNumber = dependencies.first as? String else {
        return nil
    }
    return Chassis(serialNumber: serialNumber, mountedInCar: nil)
 }

let chassis_1 = container.resolve(service: ChassisProtocol.self, dependencyTypes: [String.self], dependencies: ["abc_1"]) as? ChassisProtocol
let chassis_2 = container.resolve(service: ChassisProtocol.self, dependencyTypes: [String.self], dependencies: ["xyz_2"]) as? ChassisProtocol
print("Chassis #1: \(chassis_1!.serialNumber!)")
print("Chassis #2: \(chassis_2!.serialNumber!)")

print("\n\n----------")
