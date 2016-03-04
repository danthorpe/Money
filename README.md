![](https://raw.githubusercontent.com/danthorpe/Money/development/header.png)

[![Build status](https://badge.buildkite.com/265eb9670a2ef6b73eebf37769a8455c402509f71f09c4f51e.svg?branch=development)](https://buildkite.com/blindingskies/money?branch=development)
[![Coverage Status](https://coveralls.io/repos/github/danthorpe/Money/badge.svg?branch=development)](https://coveralls.io/github/danthorpe/Money?branch=development)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Money.svg)](https://img.shields.io/cocoapods/v/Money.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Money.svg?style=flat)](http://cocoadocs.org/docsets/Money)

# Money

Money is a Swift framework for iOS, watchOS, tvOS and OS X. It provides types and functionality to represent, calculate and convert money in the 298 [ISO currencies](https://en.wikipedia.org/wiki/ISO_4217). 

---

## Usage

The Money framework defines the type `Money`, which represents money in the device’s current locale. The following code:

```swift
import Money

let money: Money = 100
print("I'll give \(money) to charity.”)
```

will print out

> I'll give $100.00 to charity 

when the region is set to United States

> I'll give £100.00 to charity

when the region is set to United Kingdom

> I'll give CN¥100.00 to charity

when the region is set to China

You get the idea. See [Localized Formatting](#localized-formatting) for more info.

`Money` is `IntegerLiteralConvertible` and  `FloatLiteralConvertible`. Which means values can be initialized using literal `Int`s and `Double`s as shown in these code snippets.

## Specific Currency

Under the hood, `Money` is a `typealias` for `_Money<Currency.Local>` where `Currency.Local` is a specific `CurrencyType` which represents the currency for the current locale. This means that it is strongly typed to the local currency.

In a similar way, there are 298 foreign currency types supported.

```swift
let pounds: GBP = 99.99
let euros: EUR = 149.50

print(“You have \(pounds / 2) and \(euros + 30)”)
```

> You have £ 50.00 and € 179.50

Because the currencies are typed, it means that they cannot be combined together.

```swift
let money = pounds + euros
```
> Binary operator '+' cannot be applied to operands of type 'GBP' (aka '_Money&lt;Currency.GBP&gt;') and 'EUR' (aka '_Money&lt;Currency.EUR&gt;')

Of course, `Money` supports the usual suspects of decimal arithmetic operators, so you can add, subtract, multiply, divide values of the same type, and values with `Int` and `Double` with the expected limitations.

## Convenience initializers

`Money` (and its friends) can be initialized with `Int`s (and friends) and`Double`s.

```swift
let anIntegerFromSomewhereElse: Int = getAnInteger()
let money = Money(anIntegerFromSomewhereElse)

let aDoubleFromSomewhere: Double = getAnotherDouble()
let pounds = GBP(aDoubleFromSomewhere)
```

### Minor Units

`Money` can be initialized using the smallest units of currency:

```swift
let dollars = USD(minorUnits: 3250)
let yuen = JPY(minorUnits: 3000)

print(“You have \(dollars) and \(yuen)”)
```

> You have $32.50 and ¥3,000

## Localized Formatting

When displaying money values, it is important that they be correctly localized for the user. In general, it’s best to use the `Money` type to always work in currency of the user’s current locale.

When printing a `MoneyType` value, the `.description` uses the current locale with `.CurrencyStyle` number style, in conjunction with [`NSNumberFormatter`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNumberFormatter_Class/index.html). The code snippets throughout this README uses `.description` whenever the value of money is printed.

However, to specify a different style for the number formatter, use the `formattedWithStyle` method, like this:

```swift
let money: Money = 99.99
print("She has \(money.formattedWithStyle(.CurrencyPluralStyle))")
```

For an American in Russia, this would print out:
>She has 99,99 Russian roubles

### Working with Locales

A *locale* is the codification of associated regional and linguistic attributes. A locale varies by language and region. Each locale has an [identifier](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes), which is the concatenation of language, country and modifier codes. 

The language code is two or three lowercase letters. English is `en`, French is `fr`. There is a [long list](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes). Some languages are spoken in more than one country, in which case a country code (two uppercase letters) is appended (with an underscore). For example, English in the United States is `en_US`, which is the default locale in the iOS Simulator. English in the United Kingdom is `en_GB`. 

Lastly, a locale identifier can be modified, say for example to set the currency code to “USD”, for Portuguese speaking user in Brazil, the locale identifier would be `pt_BR@currency=USD`.

In total, `NSLocale` has support for ~ 730 distinct locales. Typically when creating a specific `NSLocale` it is done with the locale identifier. The `NSLocale` is like a dictionary with an `objectForKey` method which returns `AnyObject!`.

### Formatting for specific Locale

I think `NSLocale` is an amazing class, but it’s very easy to make mistakes, and not that easy to construct. Therefore, to support arbitrary locales, but remove the need for framework consumers to construct locale identifiers, a new `Locale` type is provided. This is an enum which means that it is type safe, and indexable for code completion in Xcode. Its cases are all the languages which `NSLocale` supports. For those languages which are spoken in more than one country, there is an associated value of country names of only those counties.

To format money for a specific locale we can use the `Locale` enum. The following code uses `Locale.Chinese(.China)` to represent the `"zh_CN"` locale.

```swift
let money: Money = 99.99
print("She has \(money.formattedWithStyle(.CurrencyPluralStyle, forLocale: .Chinese(.China)))")
```

Now, for our American in Russia, (or any user with a region set to Russia) we get:
>She has 99.99俄罗斯卢布

In this case, because our type is `Money`, and the user’s region is set to Russia, we’re working with `RUB` currency. But equally, if we need money in a specific currency, we can. Here’s Australian dollars, for a SwissGerman speaking user, in France.

```swift
let dollars: AUD = 39.99
print("You’ll need \((dollars / 2.5).formattedWithStyle(.CurrencyPluralStyle, forLocale: .SwissGerman(.France)))")
``` 
Regardless of the user’s current locale, this will print out:
>You’ll need 16.00 Auschtralischi Dollar

##  Pay

On iOS (not watchOS, tvOS or OS X), there is support in Money for using `Money` with  Pay.

Create a `PaymentSummaryItem` in lieu of `PKPaymentSummaryItem` with a suitable `MoneyType`:

```swift
import PassKit

typealias DollarItem = PaymentSummaryItem<USD>

let items = [
    DollarItem(label: "Something fancy.", cost: 9.99),
    DollarItem(label: "Something less fancy.", cost: 5.99)
]

let request = PKPaymentRequest(items: items, sellerName: "Acme, Inc.")
```

The convenience initializer receives an array of `PaymentSummaryItem` values and a seller name. It sets the currency code and payment summary items. Following the  Pay guidelines, will append a total summary item using the provided seller name.

`PaymentSummaryItem` conforms to `Hashable` and [`ValueCoding`](https://github.com/danthorpe/ValueCoding).

## Bitcoin

Money has support for Bitcoin types, the popular `BTC` and the unofficial ISO 4217 currency code `XBT`.

In [November 2015](http://www.coindesk.com/bitcoin-unicode-symbol-approval/), the Unicode consortium accepted U+20BF as the Bitcoin symbol. However, right now that means it is not available in Foundation. Therefore, currently the Bitcoin currency type(s) use Ƀ, which is also a popular symbol and available already within Unicode.

To work with Bitcoin, use the following:

```swift
let bitcoin: BTC = 0.1234_5678
print(“You have \(bitcoin)”)
```
> You have Ƀ0.12345678

## Foreign Exchange (FX)

The FX support which was previously part of this framework has been moved into its own, called [FX](https://github.com/danthorpe/FX).

# Creating custom currencies

If your app has its own currency e.g. ⭐️s or 💎s or even 🐝s, you might want to consider making a type for it.

Lets imagine we’re making *Hive.app* - where you compete with your friends to see who can get the biggest hive (measured in number of 🐝s).

To create a custom currency, just conform to `CurrencyType`. 

```swift
protocol HiveCurrencyType: CustomCurrencyType { }

extension Currency {
    final class Bee: HiveCurrencyType {

        static let code: String = "BEES"
        static let symbol: String = "🐝"
        static let scale: Int  = 0
    }
}

typealias Bees = _Money<Currency.Bee>
```

Just make sure that your currency code doesn’t clash with a real one - make it more than three characters to be sure.

Now it’s possible to work with your own app’s currency as a proper money type.

```swift
let bees: Bees = 10_000
print(“I have \(bees)”)
```
> I have 🐝10,000

And of course if you have an IAP for purchasing in-app currency, then I’m sure a custom FX provider would be handy.

Take a look at the example project, [Custom Money](https://github.com/danthorpe/Examples/tree/development/Money/Custom%20Money), for an example of a custom local FX provider to exchange your 🐝s.

## Installation
Money builds as a cross platform (iOS, OS X, watchOS) extension compatible framework. It is compatible with [Carthage](https://github.com/carthage/carthage). It is also available via CocoaPods.

```ruby
pod ‘Money’
```

At of writing there are some issues with the CocoaDocs generator for pure Swift 2 projects. This means that the project doesn’t have a page/docs in CocoaPods sites, however they are available through Xcode. 

---

## Architectural style
Swift is designed to have a focus on safety, enabled primarily through strong typing. This framework fully embraces this ethos and uses generics heavily to achieve this goal. 

At the highest level *currency* is modeled as a protocol, `CurrencyType`. The protocol defines a few static properties like its symbol, and currency code. Therefore *money* is represented as a decimal number with a generic currency. Additionally, we make `CurrencyType` refine the protocol which defines how the decimal number behaves.

Finally, we auto-generate the code which defines all the currencies and money typealiases.

## Implementation Details

Cocoa has two type which can perform decimal arithmetic, these are `NSDecimalNumber` and `NSDecimal`. `NSDecimal` is faster, but is trickier to work with, and doesn’t have support for limiting the scale of the numbers (which is pretty important when working with currencies).

`DecimalNumberType` is a protocol which refines `SignedNumberType` and defines its own functions, `add`, `subtract` etc to support the arithmetic. It is generic over two types, the underlying storage, and the behaviors.

`DecimalNumberType.DecimalStorageType` exists so that conforming types can utilize either `NSDecimalNumber` or `NSDecimal` as their underling storage type.

`DecimalNumberBehavior` is a protocol which exposes a  [`NSDecimalNumberBehaviors`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSDecimalNumberBehaviors_Protocol/) which should be used in calculations. This includes rounding style, scale, and when to throw exceptions.

### `_Decimal`

Which leads us to `_Decimal<Behavior: DecimalNumberBehavior>` which is a value type implementing `DecimalNumberType` with an `NSDecimalNumber` storage type.

There are two public typealiases for convenience.

```swift
/// `Decimal` with plain decimal number behavior
public typealias Decimal = _Decimal<DecimalNumberBehavior.Plain>

/// `BankersDecimal` with banking decimal number behavior
public typealias BankersDecimal = _Decimal<DecimalNumberBehavior.Bankers>
```

This means, that `Decimal` is more than likely the type to use for most things.

### `_Money`
The `_Money<C: CurrencyType>` type composes a `_Decimal<C>`. Its behavior is provided via its generic `CurrencyType` which refines `DecimalNumberBehavior`. `_Money` also conforms to `DecimalNumberType` which means that it can also be used with the operators.

### Why not use `NSDecimal`?
`NSDecimal` would be a better storage type for `_Decimal`, however it doesn’t have the full `NSDecimalNumberBehaviors` support that `NSDecimalNumber` enjoys. In particular, specifying the scale is problematic. If anyone has any smart ideas, please get in touch. I’ve added an equivalent extension on `NSDecimal` as for `NSDecimalNumber`.

### `ValueCoding`
Both `_Decimal`, `_Money` and `FXTransaction` all conform to [`ValueCoding`](https://github.com/danthorpe/ValueCoding) which means they can be encoded and stored inside archives.


## Author
Daniel Thorpe [@danthorpe](https://twitter.com/danthorpe). 

Feel free to get in contact if you have questions, queries, suggestions, or need help. Especially get in contact via an Issue here or on Twitter if you want to add support for another FX service provider.

I wrote an introductory blog post about money [here](http://danthorpe.me/posts/money.html).

## License

Money is available under the MIT license. See the LICENSE file for more info.

## Disclaimer

Usage of this framework prevents the author, Daniel Thorpe, from being held liable for any losses incurred by the user through their use of the framework.
