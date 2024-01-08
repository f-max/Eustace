//
//  Containing.swift
//  Eustace
//
//  Created by Massimiliano Faustini on 08/01/24.
//  Copyright © 2024 Massimiliano Faustini. All rights reserved.
//

import Foundation

protocol Containing {
  func register<Service>(serviceType: Service.Type, creator: @escaping (()throws->Service?))
  func resolve<Service>(serviceType: Service.Type) throws -> Service?
  func register<Service, CreatorParameterType>(serviceType: Service.Type, creatorParameterType: CreatorParameterType.Type, creator: @escaping (CreatorParameterType)throws->Service?)
  func resolve<Service, ParameterType>(serviceType: Service.Type, parameter: ParameterType) throws -> Service?
}

extension Container: Containing {}
