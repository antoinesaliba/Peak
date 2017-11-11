use_frameworks!
platform :ios, '10.3'

target 'Peak' do
  use_frameworks!
  pod 'DZNEmptyDataSet'
  pod 'Charts'
  pod 'FoldingCell'
  pod 'PopupDialog', '~> 0.5'
  pod 'Persei', '~> 3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.2'
    end
  end
end
