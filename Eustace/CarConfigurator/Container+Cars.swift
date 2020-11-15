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
        self.register(serviceType: ChassisProtocol.self) {
            Chassis(serialNumber: chassisSerialNumber, mountedInCar: nil)
        }
        
        self.register(serviceType: SteeringWheelProtocol.self) {
            SteeringWheel()
        }
        self.register(serviceType: SeatsProtocol.self) {
            TissueSeats()
        }
        self.register(serviceType: WheelsProtocol.self) {
            StandardWheels()
        }
        self.register(serviceType: GearBoxProtocol.self) {
            GearBox()
        }
        
        switch power {
        case .standard:
            break
        default:
            self.register(serviceType: WheelsProtocol.self) {
                LargeWheels()
            }
        }
        
        switch power {
        case .standard:
            self.register(serviceType: EngineProtocol.self) {
                StandardEngine()
            }
        case .sports:
            self.register(serviceType: EngineProtocol.self) {
                SportsEngine()
            }
            self.register(serviceType: SeatsProtocol.self) {
                LeatherSeats()
            }
        case .supersports:
            self.register(serviceType: EngineProtocol.self) {
                SupersportsEngine()
            }
            self.register(serviceType: SeatsProtocol.self) {
                AerospacelSeats()
            }
        }
        
    
        register(serviceType: InteriorsProtocol.self) {
            guard let seats = self.resolve(serviceType: SeatsProtocol.self) as? SeatsProtocol, let steeringWheel = self.resolve(serviceType: SteeringWheelProtocol.self) as? SteeringWheelProtocol  else {
                return nil
            }
            return Interiors(seats: seats, steeringWheel: steeringWheel)
        }
       
        register(serviceType: CarProtocol.self) {
            
            guard let chassis = self.resolve(serviceType: ChassisProtocol.self) as? ChassisProtocol,
                let wheels = self.resolve(serviceType: WheelsProtocol.self) as? WheelsProtocol,
                let engine = self.resolve(serviceType: EngineProtocol.self) as? EngineProtocol,
                let gearBox = self.resolve(serviceType: GearBoxProtocol.self) as? GearBoxProtocol,
                let interiors = self.resolve(serviceType: InteriorsProtocol.self) as? InteriorsProtocol else {
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
