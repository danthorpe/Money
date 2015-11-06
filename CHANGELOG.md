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
