
# SOUQIUBA SDKVideoPlayer for iOS

[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)
[![Platform](https://img.shields.io/badge/Platforms-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`SDKVideoPlayer` is a feature-rich video player for iOS applications developed using Swift. It provides a seamless video playback experience with a focus on customization and ease of use.

## Features

- Fullscreen and inline playback support.
- Play videos from various sources (URL, local files, and network streams).
- Customizable controls and UI elements.
- Support for subtitles and closed captions.
- Picture-in-Picture support.
- AirPlay compatibility.
- External display support.

## Requirements

- iOS 13.0+
- Xcode 11+
- Swift 5.0+

## Installation

### CocoaPods

To install `SDKVideoPlayer` using CocoaPods, add the following line to your `Podfile`:

```ruby

# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'SDKVideoPlayer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SDKVideoPlayer
  
  pod 'SwiftIcons', '~> 3.0'
  
  pod 'FirebaseCrashlytics'
  
  
#---------- from github
  pod 'Libass', :git => 'https://github.com/nicolastinkl/FFmpegKit', :branch => 'main'
  pod 'Libmpv', :git => 'https://github.com/nicolastinkl/FFmpegKit', :branch => 'main'
  pod 'FFmpegKit', :git => 'https://github.com/nicolastinkl/FFmpegKit', :branch => 'main'

#---------- from local folder
#  pod 'Libass', :path => '/Users/abc123456/Documents/ios/FFmpegKit'
#  pod 'Libmpv', :path => '/Users/abc123456/Documents/ios/FFmpegKit'
#  pod 'FFmpegKit', :path => '/Users/abc123456/Documents/ios/FFmpegKit'


#  pod 'DisplayCriteria', :path => './KSPlayer/'
#  pod 'SwiftLoader', :path => './SwiftLoader/'
#  pod 'KSPlayer' , :path => './KSPlayer/'
#  pod 'SwiftWebVC'




  target 'SDKVideoPlayerTests' do
    inherit! :search_paths
    # Pods for testing
  
  end

  target 'SDKVideoPlayerUITests' do
    # Pods for testing
  end

end

```

## Aug 5st update new features
1 ：优化 UI，增加电影浏览功能
2 ：可以支持 youtube 在线浏览电影简介
3 : 修复 bug
![](ScreenShots/combined_image08-05_19-00.jpeg)

 1. 修复本地文件无法播放的问题 
 2. 修复加载提示退出不转动的问题
 3. 修复数据问题，确保可以加载成功
![](ScreenShots/combined_image08-06_15-51.jpeg)
