//
//  CarBreakdown.swift
//  CarConfigurator
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation

protocol CarProtocol: AnyObject {
    var chassis: ChassisProtocol { get }
    var engine: EngineProtocol { get set }
    var gearBox: GearBoxProtocol { get set }
    var wheels: WheelsProtocol { get set }
    var interiors: InteriorsProtocol { get set }
}

protocol ChassisProtocol: AnyObject {
    var serialNumber: String? { get set }
    var car: CarProtocol? { get set } // two-ways circular depenedncy
}

protocol WheelsProtocol: AnyObject {
    
}

protocol EngineProtocol: AnyObject {
    var powerHP: Double { get }
}

protocol GearBoxProtocol: AnyObject {
    
}

protocol InteriorsProtocol: AnyObject {
    var seats: SeatsProtocol { get set }
    var steeringWheel: SteeringWheelProtocol { get set }
}

protocol SeatsProtocol: AnyObject {
    func description() -> String
}

protocol SteeringWheelProtocol: AnyObject {
    
}


