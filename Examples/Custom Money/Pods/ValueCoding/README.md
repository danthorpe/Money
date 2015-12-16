![](https://raw.githubusercontent.com/danthorpe/ValueCoding/development/header.png)

[![Build status](https://badge.buildkite.com/482fd5558d9ccf05b669c55f40450166033522f32314a1bbb2.svg)](https://buildkite.com/blindingskies/valuecoding)
[![codecov.io](http://codecov.io/github/danthorpe/ValueCoding/coverage.svg?branch=development)](http://codecov.io/github/danthorpe/ValueCoding?branch=development)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/ValueCoding.svg)](https://img.shields.io/cocoapods/v/ValueCoding.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/ValueCoding.svg?style=flat)](http://cocoadocs.org/docsets/ValueCoding)

# ValueCoding

ValueCoding is a simple pair of protocols to support the coding of Swift value types.

It works by allowing a value type, which must conform to `ValueCoding` to define via a typealias its *coder*. The coder is another type which implements the `CoderType` protocol. This type will typically be an `NSObject` which implements `NSCoding` and is an adaptor which is responsible for encoding and decoding the properties of the value.

A minimal example for a simple `struct` is shown below:

```swift
import ValueCoding

struct Foo: ValueCoding {
    typealias Coder = FooCoder
    let bar: String
}

class FooCoder: NSObject, NSCoding, CodingType {

    enum Keys: String {
        case Bar = "bar"
    }

    let value: Foo

    required init(_ v: Foo) {
        value = v
    }

    required init?(coder aDecoder: NSCoder) {
        let bar = aDecoder.decodeObjectForKey(Keys.Bar.rawValue) as? String
        value = Foo(bar: bar!)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(value.bar, forKey: Keys.Bar.rawValue)
    }
}
```

If you are converting existing models from classes to values types, the `NSCoding` methods should look familiar, and hopefully you are able to reuse your existing code.

The framework provides static methods and properties for types which conform to `ValueCoding` with valid coders. Therefore, given a value of `Foo`, you can encode it ready for archiving using `NSKeyedArchiver`.

```swift
let data = NSKeyedArchiver.archivedDataWithRootObject(foo.encoded)
```

and likewise, decoding from unarchiving can be done:

```swift
if let foo = Foo.decode(NSKeyedUnarchiver.unarchiveObjectWithData(data)) {
    // etc, unarchive returns optionals when working with a single item.
}
```

These methods can also be used if composing value types inside other types which require encoding.

When working with sequences of values, use the `encoded` property on the sequence.

```swift
let foos = Set(arrayLiteral: Foo(), Foo(), Foo())
let data = NSKeyedArchiver.archivedDataWithRootObject(foos.encoded)
```

When decoding an `NSArray`, perform a conditional cast to `[AnyObject]` before passing it to `decode`. The result will be an `Array<Foo>` which will be empty if the object was not cast successfully. In addition, any members of `[AnyObject]` which did not decode will be filtered from the result. This means that the length of the result will be less than the original encoded array if there was an issue decoding.

```swift
let foos = Foo.decode(NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [AnyObject])
```
### CoderType Examples

The [Money](https://github.com/danthorpe/Money) framework contains more examples of implementing `ValueCoding`. Including the generic type [`FXTransactionCoder`](https://github.com/danthorpe/Money/blob/development/Money/Shared/FX/FX.swift#L467).

The [YapDatabaseExtensions](https://github.com/danthorpe/YapDatabaseExtension) framework relies heavily on `ValueCoding`. For more examples of generic where constraints see its [Functional API](https://github.com/danthorpe/YapDatabaseExtensions/tree/development/YapDatabaseExtensions/Shared/Functional).

### Installation
ValueCoding builds as a cross platform (iOS, OS X, watchOS, tvOS) extension compatible framework. It is also available via CocoaPods

```ruby
pod 'ValueCoding'
```

