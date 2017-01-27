//
//  imagePickerInteractorTests.swift
//  ReactiveAlertAndActionSheet
//
//  Created by Adam Borek on 29.01.2017.
//  Copyright © 2017 Adam Borek. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import ReactiveAlertAndActionSheet

final class imagePickerInteractorTests: XCTestCase {
    private var subject: ImagePickerInteractor!
    var presenter: ViewControllerPresentingMock!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        presenter = ViewControllerPresentingMock()
        subject = ImagePickerInteractor()
        subject.presenter = presenter
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        subject = nil
    }

    func test_presentImagePickerView_toChooseImageFromGallery() {
        subject.chooseImageFromLibrary().subscribe()
                .disposed(by: disposeBag)

        XCTAssertTrue(presenter.shownViewController is UIImagePickerController)
        guard let pickerController = presenter.shownViewController as? UIImagePickerController else { return }

        XCTAssertEqual(pickerController.sourceType, .photoLibrary)
    }

    func test_presentedImagePicker_hasDelegate() {
        subject.chooseImageFromLibrary().subscribe()
                .disposed(by: disposeBag)
        guard let pickerController = presenter.shownViewController as? UIImagePickerController else {
            return XCTFail("shownViewController is not UIImagePickerController")
        }

        XCTAssertNotNil(pickerController.delegate)
    }

    func test_sendSelectedImage_asNextEventOnlyOnce() {
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)
        subject.chooseImageFromLibrary().subscribe(observer)
                .disposed(by: disposeBag)
        let image = UIImage()

        subject.imagePickerController(UIImagePickerController(), didFinishPickingMediaWithInfo: [UIImagePickerControllerEditedImage: image])
        subject.imagePickerController(UIImagePickerController(), didFinishPickingMediaWithInfo: [UIImagePickerControllerEditedImage: image])

        XCTAssertEqual(observer.events, [next(0, image), completed(0)])
    }

    func test_sendCompletedEvent_ifImagePickerWasCancelled() {
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)
        subject.chooseImageFromLibrary().subscribe(observer)
                .disposed(by: disposeBag)
        guard let pickerController = presenter.shownViewController as? UIImagePickerController else {
            return XCTFail("shownViewController is not UIImagePickerController")
        }

        subject.imagePickerControllerDidCancel(pickerController)

        XCTAssertEqual(observer.events, [completed(0)])
    }

    func test_dismissImagePicker_onCanceling() {
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)
        subject.chooseImageFromLibrary().subscribe(observer)
                .disposed(by: disposeBag)

        subject.imagePickerControllerDidCancel(UIImagePickerController())

        XCTAssertNotNil(presenter.dismissedViewController)
    }

    func test_dismissPicker_afterReceivingImage() {
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)
        subject.chooseImageFromLibrary().subscribe(observer)
                .disposed(by: disposeBag)

        subject.imagePickerController(UIImagePickerController(), didFinishPickingMediaWithInfo: [UIImagePickerControllerEditedImage: UIImage()])

        XCTAssertNotNil(presenter.dismissedViewController)
    }
}
