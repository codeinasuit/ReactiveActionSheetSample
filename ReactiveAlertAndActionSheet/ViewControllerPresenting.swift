//
// Created by Adam Borek on 25.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerPresenting: class {
    func present(_ viewController: UIViewController)
    func dismiss(_ viewController: UIViewController)
}

extension UIViewController: ViewControllerPresenting {
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func dismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
