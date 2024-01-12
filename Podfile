# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TodoApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TodoApp
  pod 'R.swift', '5.1.0'
  pod 'RxGRDB', '2.0.0'
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'APIKit', '5.4.0'
  pod 'MBProgressHUD', '1.2.0'
  pod 'ReachabilitySwift', '5.0.0'

  target 'TodoAppTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '6.5.0'
    pod 'RxTest', '6.5.0'
  end
  
  post_install do |installer|
      installer.generated_projects.each do |project|
        project.targets.each do |target|
          target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
          end
        end
      end
      
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXCLUDED_ARCHS'] = ''
        end
      end
  end
end
