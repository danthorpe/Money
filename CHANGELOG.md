# 2.0.0
1. [[MNY-63](https://github.com/danthorpe/Money/pull/63)]: Updates to Swift 3.0.

# 1.8.0
1. [[MNY-61](https://github.com/danthorpe/Money/pull/61)]: Updates to Swift 2.3.

# 1.7.0
1. [[MNY-47](https://github.com/danthorpe/Money/pull/47)]: Updates to Swift 2.2.

# 1.6.2
1. [[MNY-45](https://github.com/danthorpe/Money/pull/45)]: Fixes a serious bug where `Money` did not have the correct currency scale.

# 1.6.1
1. [[MNY-42](https://github.com/danthorpe/Money/pull/42)]: Removes all the example projects to [danthorpe/Examples](https://github.com/danthorpe/Examples). This is done mostly to avoid an issue where Carthage attempts to build all Xcode projects it can find in a repository.
2. [[MNY-43](https://github.com/danthorpe/Money/pull/43)]: Switch the code coverage reporting tool to [Coveralls](https://coveralls.io/github/danthorpe/Money), and got the coverage back to 100%.

# 1.6.0
1. [[MNY-39](https://github.com/danthorpe/Money/pull/39)]: Updates the spelling of CocoaPods, thanks [https://github.com/ReadmeCritic](@ReadmeCritic)!
2. [[MNY-34](https://github.com/danthorpe/Money/pull/34)]: Refactors `CurrencyType` to remove the formatter property, and include a default `CurrencyStyle`. This update makes it a lot easier to make custom currency types, and overall improves or fixes bugs with the ISO currency types. If you have custom currencies you may need to perform some slight refactoring, but it shouldn’t be too complex.

# 1.5.1
Cleans up a few issues related to updating to the latest Carthage, and the example project.

# 1.5.0
1. [[MNY-38](https://github.com/danthorpe/Money/pull/38)]: Removes the FX functionality from this framework.

# 1.4.2
1. [[MNY-39](https://github.com/danthorpe/Money/pull/30)]: Updates to the latest version of [Result](https://github.com/antitypical/Result/releases/tag/1.0.1) dependency. Thanks to [@mrdavey](https://github.com/mrdavey) and [@hsoi](https://github.com/hsoi) for spotting this!

# 1.4.1
1. [[MNY-28](https://github.com/danthorpe/Money/pull/28)]: Documentation is now hosted at [docs.danthorpe.me](http://docs.danthorpe.me/money/1.4.1/).

# 1.4.0
1. [[MNY-25](https://github.com/danthorpe/Money/pull/25)]: Adds convenience initializers to `DecimalNumberType` for `Int` (including all the variants) and `Double` parameters. Although not technically needed, (as it’s integer and float convertible) this makes it a lot easier to construct `Money` types.
2. [[MNY-24](https://github.com/danthorpe/Money/pull/26)]: Refactors the localized string formatting APIs. Fixed a few bugs which may have rendered string incorrectly formatted in some locales. Also added the ability to format `MoneyType` values using specific language and country locales. See the README for more info.
3. [[MNY-27](https://github.com/danthorpe/Money/pull/27)]: Finally got Jazzy to generate the documentation, and have created a config for the project. Hopefully now CocoaDocs will correctly parse the framework and generate docs. Documentation coverage is 96%.  

# 1.3.0
1. [[MNY-21](https://github.com/danthorpe/Money/pull/21), [MNY-22](https://github.com/danthorpe/Money/pull/22)]: Adds support for initializing `MoneyType`s with minor units. Thanks to [@jlalvarez18](https://github.com/jlalvarez18).
2. [[MNY-23](https://github.com/danthorpe/Money/pull/23)]: Adds some convenience extensions to create  pay payment requests using an array of `PaymentSummaryItem` which is a new type generic over `MoneyType`. This is only available on iOS, and it allows consumers to use `Money` directly with  pay APIs.
 
# 1.2.1
1. [[MNY-19](https://github.com/danthorpe/Money/pull/19)]: Fixes a bunch of miscellaneous spelling mistakes in the README and code documentation.
2. [[MNY-20](https://github.com/danthorpe/Money/pull/20)]: Fixes a mistake where DVR which is only needed for the test suit was not in a private Cartfile. Also switches to the official @venmo DVR after recent merges in their project. Thanks to @dasmer for this.

# 1.2.0
1. [[MNY-18](https://github.com/danthorpe/Money/pull/18)]: Adds Bitcoin currency types and support for % commission with FX.
	* Creates `BTC` and `XBT` types.
	* Refactors `FXQuote` into a struct (no longer subclass-able) but with a percentage commission property. Commission defaults to 0%.
	* FX method `quote`, now returns `FXTransaction` as the value of the `Result`. This new value type composes the original base money, commission (in the same base money currency), the exchange rate, and the counter money. The type supports `ValueCoding`.
	* A new FX provider, CEX.IO get support for buying and selling bitcoin using `USD`, `EUR` and `RUB`. 

# 1.1.0
1. [[MNY-16](https://github.com/danthorpe/Money/pull/16)]: Grab bag of minor issues post 1.0 release.
	* Cleans up some minor mistakes (spelling etc). 
	* Adds `NSCoding` conformance to `FXQuote` - so it can be persisted if needed.
	* Adds `FXRemoteProviderType.quote(: BaseMoney, completion: Result<(BaseMoney, FXQuote, CounterMoney), FXError> -> Void) -> NSURLSessionDataTask` API. This is the nuts and bolts of the FX provider now. It returns as its result, the base money (i.e. the input), the quote (which includes the rate), and the counter money (i.e. the output). The `fx` method still exists, and it just unwraps the tuple to return the counter money. See the updated README.
2. [[MNY-17](https://github.com/danthorpe/Money/pull/17)]: There was an oversight in the functions in `DecimalNumberType` which accepts `NSDecimalNumberBehaviors` as an argument. These were unnecessary so I’ve removed them. Hence the minor version bump.

# 1.0.0
🎉🐝 Initial release of Money.

- [x] DecimalNumberType with full support for mathematics operators
- [x] Strongly typed ISO currencies
- [x] Strongly typed ISO money type which conforms to DecimalNumberType
- [x] Generic Foreign Exchange APIs
- [x] Yahoo FX provider
- [x] OpenExchangeRates.org FX provider 
- [x] 100% of code covered by tests 
