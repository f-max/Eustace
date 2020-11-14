//
//  CarBreakdown.swift
//  CarConfigurator
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation

protocol CarProtocol: class {
    var chassis: ChassisProtocol { get }
    var engine: EngineProtocol { get set }
    var gearBox: GearBoxProtocol { get set }
    var wheels: WheelsProtocol { get set }
    var interiors: InteriorsProtocol { get set }
}

protocol ChassisProtocol: class {
    var serialNumber: String? { get set }
    var car: CarProtocol? { get set } // two-ways circular depenedncy
}

protocol WheelsProtocol: class {
    
}

protocol EngineProtocol: class {
    var powerHP: Double { get }
}

protocol GearBoxProtocol: class {
    
}

protocol InteriorsProtocol: class {
    var seats: SeatsProtocol { get set }
    var steeringWheel: SteeringWheelProtocol { get set }
}

protocol SeatsProtocol: class {
    func description() -> String
}

protocol SteeringWheelProtocol: class {
    
}


