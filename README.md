# JIRAMobileKit

[![CI Status](http://img.shields.io/travis/willpowell8/JIRAMobileKit.svg?style=flat)](https://travis-ci.org/willpowell8/JIRAMobileKit)
[![Version](https://img.shields.io/cocoapods/v/JIRAMobileKit.svg?style=flat)](http://cocoapods.org/pods/JIRAMobileKit)
[![License](https://img.shields.io/cocoapods/l/JIRAMobileKit.svg?style=flat)](http://cocoapods.org/pods/JIRAMobileKit)
[![Platform](https://img.shields.io/cocoapods/p/JIRAMobileKit.svg?style=flat)](http://cocoapods.org/pods/JIRAMobileKit)

JIRA Mobile KIT is a plugin written from the group up in swift to enable fast 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JIRAMobileKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```swift
pod "JIRAMobileKit"
```

To start JIRA you can setup the JIRA connection using the following command:

```swift
JIRA.shared.setup(host: "[[JIRA_URL]]", project: "[[PROJECT_KEY]]", defaultIssueType: "[[DEFAULT_ISSUE_TYPE]]")
```
The parameters you should use:
- [[JIRA_URL]] - this is the url of where to your jira instance is located. Eg for a cloud JIRA install it is https://company.atlassian.net
- [[PROJECT_KEY]] - this is the short key related to your project. Note your tickets for a project get created like [[PROJECT_KEY]]-TicketNumber
- [[DEFAULT_ISSUE_TYPE]] - (optional) this is the name of your ticket type. By default it is set as Bug.

Then to raise a JIRA issue:
```swift
JIRA.shared.raise()
```


## Author

willpowell8, willpowell8@gmail.com

## License

JIRAMobileKit is available under the MIT license. See the LICENSE file for more info.
