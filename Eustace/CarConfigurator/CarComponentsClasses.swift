//
//  CarComponents.swift
//  CarConfigurator
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation


class Car: CarProtocol {
    var chassis: ChassisProtocol
    var wheels: WheelsProtocol
    var engine: EngineProtocol
    var gearBox: GearBoxProtocol
    var interiors: InteriorsProtocol
    init(chassis: ChassisProtocol, wheels: WheelsProtocol, engine: EngineProtocol, gearBox: GearBoxProtocol, interiors: InteriorsProtocol) {
        self.chassis = chassis
        self.wheels = wheels
        self.engine = engine
        self.gearBox = gearBox
        self.interiors = interiors
    }
}

class Chassis: ChassisProtocol {
    var serialNumber: String?
    weak var car: CarProtocol?
    init(serialNumber: String? = nil, mountedInCar: CarProtocol? = nil) {
        self.serialNumber = serialNumber
        self.car = mountedInCar
    }
}

class LargeWheels: WheelsProtocol {
    
}

class StandardWheels: WheelsProtocol {
    
}

class StandardEngine: EngineProtocol {
    let powerHP: Double = 100.0
}

class SportsEngine: EngineProtocol {
    let powerHP: Double = 200.0
}

class SupersportsEngine: EngineProtocol {
    var powerHP: Double = 300.0
}

class SteeringWheel: SteeringWheelProtocol {
    
}

class TissueSeats: SeatsProtocol {
    func description() -> String {
        return "simple tissue seats"
    }
}
 
class LeatherSeats: SeatsProtocol {
    func description() -> String {
        return "comfy leather seats"
    }
}

class AerospacelSeats: SeatsProtocol {
    func description() -> String {
        return "zero gravity rocket seats"
    }
}


class Interiors: InteriorsProtocol {
    var seats: SeatsProtocol
    var steeringWheel: SteeringWheelProtocol
    init(seats: SeatsProtocol, steeringWheel: SteeringWheelProtocol) {
        self.seats = seats
        self.steeringWheel = steeringWheel
    }
}

class GearBox: GearBoxProtocol {
    
}
