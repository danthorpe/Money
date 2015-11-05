![](header.png)

[![Build status](https://badge.buildkite.com/265eb9670a2ef6b73eebf37769a8455c402509f71f09c4f51e.svg)](https://buildkite.com/blindingskies/money?branch=development)
[![codecov.io](https://codecov.io/github/danthorpe/Money/coverage.svg?branch=development&token=gI70muNOjA)](https://codecov.io/github/danthorpe/Money?branch=development)
[![Doc-Percent](https://img.shields.io/cocoapods/metrics/doc-percent/Money.svg)](http://cocoadocs.org/docsets/Money/1.0.0)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Money.svg)](https://img.shields.io/cocoapods/v/Money.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Money.svg?style=flat)](http://cocoadocs.org/docsets/Money)

# Money

Money is a Swift framework for iOS, watchOS, tvOS and OS X. It provides types and functionality to represent, calculate and convert money in the 298 [ISO currencies](https://en.wikipedia.org/wiki/ISO_4217). 

## Usage

The Money framework defines the type, `Money` which represents money in the device’s current locale. The following code:

```swift
let money: Money = 100
print("I'll give \(money) to charity.”)
```

will print out

    I'll give $100.00 to charity // United States region
    I'll give £100.00 to charity // United Kingdom region
    I'll give CN¥100.00 to charity // China region

You get the idea.

## Specific Currency

Under the hood, `Money` is a `typealias` for `_Money<Currency.Local>` where `Currency.Local` is a specific `CurrencyType` which represents the currency for the current local. This means that it strongly typed to the local currency.

In a similar way, there are 298 foreign currency types supported.

```swift
let pounds: GBP = 99.99
let euros: EUR = 149.50

print(“You have \(pounds / 2) and \(euros + 30)”)
```

    You have £ 50.00 and € 179.50

Because the currencies are type, it means that they cannot be combined together as though they were `NSDecimalNumber`s.

```swift
let money = pounds + euros
```
    // Binary operator '+' cannot be applied to operands of type 'GBP' (aka '_Money<Currency.GBP>') and 'EUR' (aka '_Money<Currency.EUR>')

### Doing sums, etc

The `Money` type supports the usual suspects of decimal arithmetic operations, so you can add, subtract, multiply, divide etc.
 