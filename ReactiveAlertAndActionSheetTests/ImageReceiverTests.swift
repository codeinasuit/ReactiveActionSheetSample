//
// Created by Adam Borek on 25.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import MockUIAlertController
@testable import ReactiveAlertAndActionSheet
import Photos

final class ImageReceiverTests: XCTestCase {
    private var subject: ImageSourceChooser!
    private var presenter: ViewControllerPresentingMock!
    private var galleryReader: GalleryReadingMock!
    var source1: DummyImageSource!
    var source2: DummyImageSource!
    var disposeBag: DisposeBag! = DisposeBag()

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        galleryReader = GalleryReadingMock()
        presenter = ViewControllerPresentingMock()
        source1 = DummyImageSource(description: "source1")
        source2 = DummyImageSource(description: "source2")
        subject = ImageSourceChooser(sources: [source1, source2])
        subject.presenter = presenter
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        subject = nil
    }

    func test_presentActionSheetController_onSubscribing() {
        subject.image.subscribe(onNext: { _ in }).disposed(by: disposeBag)
        XCTAssertNotNil(presenter.shownViewController)
        let actionSheet = presenter.shownViewController as? UIAlertController
        XCTAssertEqual(actionSheet?.preferredStyle, .actionSheet)
    }

    func test_presentedActionSheet_hasProperOptions() {
        let alertVerifier = QCOMockAlertVerifier()
        subject.image.subscribe(onNext: { _ in }).disposed(by: disposeBag)
        XCTAssertEqual((alertVerifier?.actionTitles as? [String])!, [source1.description, source2.description, "Cancel"])
    }

    func test_propagateObservableEventsFromSelectedOption() {
        let expectedImage = UIImage()
        source1.image = .just(expectedImage)
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(UIImage.self)
        let alertVerifier = QCOMockAlertVerifier()

        subject.image.subscribe(observer)
            .disposed(by: disposeBag)

        alertVerifier?.executeActionForButton(withTitle: "source1")
        XCTAssertEqual(observer.events, [next(0, expectedImage), completed(0)])
    }
}

final class DummyImageSource: ImageSource {
    var image: Observable<UIImage>
    var description: String

    init(image: UIImage, description: String) {
        self.image = .just(image)
        self.description = description
    }

    convenience init(description: String) {
        self.init(image: UIImage(), description: description)
    }
}

final class GalleryReadingMock: GalleryReading {
    var expectedImage: UIImage? = nil

    var lastPhotoTaken: Observable<UIImage> {
        guard let image = expectedImage else {
            return .empty()
        }
        return .just(image)
    }
}
