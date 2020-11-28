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
let cheapCar = try? container.resolve(serviceType: CarProtocol.self)

container.setup(power: .sports, optionals: .luxury)
let funkyCar = try? container.resolve(serviceType: CarProtocol.self)

container.setup(power: .supersports, optionals: .luxury)
let superFunkyCar = try container.resolve(serviceType: CarProtocol.self)

container.setup(power: .standard, optionals: .medium, chassisSerialNumber: "xyz")
let registeredCar = try container.resolve(serviceType: CarProtocol.self)

print("Cheap car: \(cheapCar!.engine.powerHP) hp, \(cheapCar!.interiors.seats.description())")
print("Funky car: \(funkyCar!.engine.powerHP) hp, \(funkyCar!.interiors.seats.description())")
print("Superfunky car: \(superFunkyCar!.engine.powerHP) hp, \(superFunkyCar!.interiors.seats.description())")
print("Registered car: \(registeredCar!.chassis.serialNumber!)")

// MARK: - Example 2
print("\n\n- Example 2\n")

container.disposeAll()
container.register(serviceType: ChassisProtocol.self, dependencyType: String.self) { serialNumber in
    return Chassis(serialNumber: serialNumber, mountedInCar: nil)
 }

let chassis_1 = try! container.resolve(serviceType: ChassisProtocol.self, dependency: "abc_1")
let chassis_2 = try! container.resolve(serviceType: ChassisProtocol.self, dependency: "xyz_2")
print("Chassis #1: \(chassis_1!.serialNumber!)")
print("Chassis #2: \(chassis_2!.serialNumber!)")

print("\n\n----------")
