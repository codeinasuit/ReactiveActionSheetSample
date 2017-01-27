//
// Created by Adam Borek on 28.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import RxSwift
import Action

protocol ActionType {
    associatedtype InputType
    associatedtype ElementType

    func execute(_ value: InputType) -> Observable<ElementType>
}

extension ActionType where InputType == Void {
    func execute() -> Observable<ElementType> {
        return execute(())
    }
}

extension Action: ActionType {
    typealias InputType = Input
    typealias ElementType = Element
}
