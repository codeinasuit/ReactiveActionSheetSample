# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def rx_swift()
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxSwiftExt'
  pod 'NSObject+Rx'
  pod 'Action'
end

target 'ReactiveAlertAndActionSheet' do
  use_frameworks!
  rx_swift

  target 'ReactiveAlertAndActionSheetTests' do
    inherit! :search_paths
    pod 'RxTest'
    pod 'RxBlocking'
    pod 'MockUIAlertController'
  end

end
