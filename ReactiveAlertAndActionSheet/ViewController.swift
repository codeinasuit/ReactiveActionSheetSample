//
//  ViewController.swift
//  ReactiveAlertAndActionSheet
//
//  Created by Adam Borek on 23.01.2017.
//  Copyright © 2017 Adam Borek. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import NSObject_Rx

final class AvatarViewController: UIViewController {
    private enum Strings {
        static let errorTitle = "Error"
    }

    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder is not available")
    }

    let viewModel: AvatarViewModel

    init() {
        let imagePickerInteractor = ImagePickerInteractor()
        let imageSources: [ImageSource] = [LastImageTakenImageSource(), LibraryImageSource(imagePickerInteractor: imagePickerInteractor)]
        let imageReceiver = ImageSourceChooser(sources: imageSources)
        viewModel = AvatarViewModel(imageReceiver: imageReceiver)

        super.init(nibName: AvatarViewController.nibName, bundle: nil)
        imageReceiver.presenter = self
        imagePickerInteractor.presenter = self
    }

    override func viewDidLoad() {
        chooseImageButton.rx.tap.subscribe(onNext: { [weak self] in
            _ = self?.viewModel.imageRetrievingAction.execute()
        }).disposed(by: rx_disposeBag)

        viewModel.image.drive(onNext: { [weak self] image in
            self?.imageView.image = image
        }).disposed(by: rx_disposeBag)

        viewModel.errorMessage.drive(onNext: { [weak self] message in
            self?.showError(with: message)
        }).disposed(by: rx_disposeBag)
    }

    private func showError(with message: String) {
        let alertController = UIAlertController(title: Strings.errorTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak alertController] _ in
            alertController?.dismiss(animated: true, completion: nil)
        })
        present(alertController)
    }
}

extension AvatarViewController: HavingNib {
    static let nibName = "ViewController"
}
