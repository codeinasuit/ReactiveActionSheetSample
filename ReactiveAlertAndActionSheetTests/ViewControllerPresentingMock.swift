//
// Created by Adam Borek on 29.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import UIKit
@testable import ReactiveAlertAndActionSheet

final class ViewControllerPresentingMock: UIViewController {
    var shownViewController: UIViewController?
    var dismissedViewController: UIViewController?
    
    override func present(_ viewController: UIViewController) {
        shownViewController = viewController
        super.present(viewController)
    }
    
    override func dismiss(_ viewController: UIViewController) {
        dismissedViewController = viewController
        super.dismiss(viewController)
    }
}
