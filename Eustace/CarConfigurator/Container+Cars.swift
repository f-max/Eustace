//
//  Container+CheapCar.swift
//  CarConfigurator
//
//  Created by Massimiliano Faustini on 14/11/2020.
//  Copyright © 2020 Massimiliano Faustini. All rights reserved.
//

import Foundation
import Eustace

extension Container {
    enum  CarPower {
        case standard
        case sports
        case supersports
    }
    
    enum CarOptionals {
        case standard
        case medium
        case luxury
    }
    
    func setup(power: CarPower, optionals: CarOptionals, chassisSerialNumber: String? = nil) {
        self.register(service: ChassisProtocol.self) {
            Chassis(serialNumber: chassisSerialNumber, mountedInCar: nil)
        }
        
        self.register(service: SteeringWheelProtocol.self) {
            SteeringWheel()
        }
        self.register(service: SeatsProtocol.self) {
            TissueSeats()
        }
        self.register(service: WheelsProtocol.self) {
            StandardWheels()
        }
        self.register(service: GearBoxProtocol.self) {
            GearBox()
        }
        
        switch power {
        case .standard:
            break
        default:
            self.register(service: WheelsProtocol.self) {
                LargeWheels()
            }
        }
        
        switch power {
        case .standard:
            self.register(service: EngineProtocol.self) {
                StandardEngine()
            }
        case .sports:
            self.register(service: EngineProtocol.self) {
                SportsEngine()
            }
            self.register(service: SeatsProtocol.self) {
                LeatherSeats()
            }
        case .supersports:
            self.register(service: EngineProtocol.self) {
                SupersportsEngine()
            }
            self.register(service: SeatsProtocol.self) {
                AerospacelSeats()
            }
        }
        
    
        register(service: InteriorsProtocol.self) {
            guard let seats = self.resolve(service: SeatsProtocol.self) as? SeatsProtocol, let steeringWheel = self.resolve(service: SteeringWheelProtocol.self) as? SteeringWheelProtocol  else {
                return nil
            }
            return Interiors(seats: seats, steeringWheel: steeringWheel)
        }
       
        register(service: CarProtocol.self) {
            
            guard let chassis = self.resolve(service: ChassisProtocol.self) as? ChassisProtocol,
                let wheels = self.resolve(service: WheelsProtocol.self) as? WheelsProtocol,
                let engine = self.resolve(service: EngineProtocol.self) as? EngineProtocol,
                let gearBox = self.resolve(service: GearBoxProtocol.self) as? GearBoxProtocol,
                let interiors = self.resolve(service: InteriorsProtocol.self) as? InteriorsProtocol else {
                    return nil
            }
            
            
            let car = Car(chassis: chassis,
                          wheels: wheels,
                          engine: engine,
                          gearBox: gearBox,
                          interiors: interiors)
            chassis.car = car
            
            return car
        }
    }
}
