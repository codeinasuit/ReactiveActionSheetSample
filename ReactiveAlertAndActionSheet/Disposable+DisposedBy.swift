//
// Created by Adam Borek on 28.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import RxSwift

/**
* `disposed(by bag: DisposeBag)` will be used in newest release of RxSwift ;)
*/
extension Disposable {
    public func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}
