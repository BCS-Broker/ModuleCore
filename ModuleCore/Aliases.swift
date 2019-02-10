//
//  Aliases.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 02/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import ReactorKit
public typealias Scene = UIViewController
public typealias SceneView = View
public typealias SceneReactor = Reactor
public typealias FullReactor = BaseReactor & SceneReactor & Coordinatable & Interactable

extension Scene : AssociatedStore {}

public struct InterruptedError: Error {
    public init() {}
}
