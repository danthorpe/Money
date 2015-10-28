//
//  Currency.swift
//  Money
//
//  Created by Daniel Thorpe on 28/10/2015.
//
//

import Foundation

public protocol CurrencyType {
    static var sharedInstance: Self { get }

    var locale: NSLocale { get }
    var formatter: NSNumberFormatter { get }
}

extension CurrencyType {

    public static var formatter: NSNumberFormatter {
        return sharedInstance.formatter
    }

    public static var scale: Int {
        return formatter.maximumFractionDigits
    }

    public static var decimalNumberBehavior: NSDecimalNumberBehaviors {
        return NSDecimalNumberHandler(
            roundingMode: .RoundBankers,
            scale: Int16(scale),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
    }
}

/**
 # Currency
 A namespace for currency related types.
*/
public struct Currency { }

extension Currency {

    public class BaseCurrency {

        public let formatter: NSNumberFormatter
        public let locale: NSLocale

        init(locale: NSLocale) {
            self.formatter = {
                let fmtr = NSNumberFormatter()
                fmtr.numberStyle = .CurrencyStyle
                fmtr.locale = locale
                return fmtr
                }()
            self.locale = locale
        }

        convenience init(code: String) {
            self.init(locale: NSLocale(localeIdentifier: NSLocale.localeIdentifierFromComponents([NSLocaleCurrencyCode: code])))
        }
    }

    public final class Local: BaseCurrency, CurrencyType {
        public static var sharedInstance = Local(locale: NSLocale.currentLocale())
    }
    
}

extension Currency {
    enum Code: String {
        case ADP = "ADP"
        case AED = "AED"
        case AFA = "AFA"
        case AFN = "AFN"
        case ALK = "ALK"
        case ALL = "ALL"
        case AMD = "AMD"
        case ANG = "ANG"
        case AOA = "AOA"
        case AOK = "AOK"
        case AON = "AON"
        case AOR = "AOR"
        case ARA = "ARA"
        case ARL = "ARL"
        case ARM = "ARM"
        case ARP = "ARP"
        case ARS = "ARS"
        case ATS = "ATS"
        case AUD = "AUD"
        case AWG = "AWG"
        case AZM = "AZM"
        case AZN = "AZN"
        case BAD = "BAD"
        case BAM = "BAM"
        case BAN = "BAN"
        case BBD = "BBD"
        case BDT = "BDT"
        case BEC = "BEC"
        case BEF = "BEF"
        case BEL = "BEL"
        case BGL = "BGL"
        case BGM = "BGM"
        case BGN = "BGN"
        case BGO = "BGO"
        case BHD = "BHD"
        case BIF = "BIF"
        case BMD = "BMD"
        case BND = "BND"
        case BOB = "BOB"
        case BOL = "BOL"
        case BOP = "BOP"
        case BOV = "BOV"
        case BRB = "BRB"
        case BRC = "BRC"
        case BRE = "BRE"
        case BRL = "BRL"
        case BRN = "BRN"
        case BRR = "BRR"
        case BRZ = "BRZ"
        case BSD = "BSD"
        case BTN = "BTN"
        case BUK = "BUK"
        case BWP = "BWP"
        case BYB = "BYB"
        case BYR = "BYR"
        case BZD = "BZD"
        case CAD = "CAD"
        case CDF = "CDF"
        case CHE = "CHE"
        case CHF = "CHF"
        case CHW = "CHW"
        case CLE = "CLE"
        case CLF = "CLF"
        case CLP = "CLP"
        case CNX = "CNX"
        case CNY = "CNY"
        case COP = "COP"
        case COU = "COU"
        case CRC = "CRC"
        case CSD = "CSD"
        case CSK = "CSK"
        case CUC = "CUC"
        case CUP = "CUP"
        case CVE = "CVE"
        case CYP = "CYP"
        case CZK = "CZK"
        case DDM = "DDM"
        case DEM = "DEM"
        case DJF = "DJF"
        case DKK = "DKK"
        case DOP = "DOP"
        case DZD = "DZD"
        case ECS = "ECS"
        case ECV = "ECV"
        case EEK = "EEK"
        case EGP = "EGP"
        case EQE = "EQE"
        case ERN = "ERN"
        case ESA = "ESA"
        case ESB = "ESB"
        case ESP = "ESP"
        case ETB = "ETB"
        case EUR = "EUR"
        case FIM = "FIM"
        case FJD = "FJD"
        case FKP = "FKP"
        case FRF = "FRF"
        case GBP = "GBP"
        case GEK = "GEK"
        case GEL = "GEL"
        case GHC = "GHC"
        case GHS = "GHS"
        case GIP = "GIP"
        case GMD = "GMD"
        case GNF = "GNF"
        case GNS = "GNS"
        case GQE = "GQE"
        case GRD = "GRD"
        case GTQ = "GTQ"
        case GWE = "GWE"
        case GWP = "GWP"
        case GYD = "GYD"
        case HKD = "HKD"
        case HNL = "HNL"
        case HRD = "HRD"
        case HRK = "HRK"
        case HTG = "HTG"
        case HUF = "HUF"
        case IDR = "IDR"
        case IEP = "IEP"
        case ILP = "ILP"
        case ILR = "ILR"
        case ILS = "ILS"
        case INR = "INR"
        case IQD = "IQD"
        case IRR = "IRR"
        case ISJ = "ISJ"
        case ISK = "ISK"
        case ITL = "ITL"
        case JMD = "JMD"
        case JOD = "JOD"
        case JPY = "JPY"
        case KES = "KES"
        case KGS = "KGS"
        case KHR = "KHR"
        case KMF = "KMF"
        case KPW = "KPW"
        case KRH = "KRH"
        case KRO = "KRO"
        case KRW = "KRW"
        case KWD = "KWD"
        case KYD = "KYD"
        case KZT = "KZT"
        case LAK = "LAK"
        case LBP = "LBP"
        case LKR = "LKR"
        case LRD = "LRD"
        case LSL = "LSL"
        case LSM = "LSM"
        case LTL = "LTL"
        case LTT = "LTT"
        case LUC = "LUC"
        case LUF = "LUF"
        case LUL = "LUL"
        case LVL = "LVL"
        case LVR = "LVR"
        case LYD = "LYD"
        case MAD = "MAD"
        case MAF = "MAF"
        case MCF = "MCF"
        case MDC = "MDC"
        case MDL = "MDL"
        case MGA = "MGA"
        case MGF = "MGF"
        case MKD = "MKD"
        case MKN = "MKN"
        case MLF = "MLF"
        case MMK = "MMK"
        case MNT = "MNT"
        case MOP = "MOP"
        case MRO = "MRO"
        case MTL = "MTL"
        case MTP = "MTP"
        case MUR = "MUR"
        case MVP = "MVP"
        case MVR = "MVR"
        case MWK = "MWK"
        case MXN = "MXN"
        case MXP = "MXP"
        case MXV = "MXV"
        case MYR = "MYR"
        case MZE = "MZE"
        case MZM = "MZM"
        case MZN = "MZN"
        case NAD = "NAD"
        case NGN = "NGN"
        case NIC = "NIC"
        case NIO = "NIO"
        case NLG = "NLG"
        case NOK = "NOK"
        case NPR = "NPR"
        case NZD = "NZD"
        case OMR = "OMR"
        case PAB = "PAB"
        case PEI = "PEI"
        case PEN = "PEN"
        case PES = "PES"
        case PGK = "PGK"
        case PHP = "PHP"
        case PKR = "PKR"
        case PLN = "PLN"
        case PLZ = "PLZ"
        case PTE = "PTE"
        case PYG = "PYG"
        case QAR = "QAR"
        case RHD = "RHD"
        case ROL = "ROL"
        case RON = "RON"
        case RSD = "RSD"
        case RUB = "RUB"
        case RUR = "RUR"
        case RWF = "RWF"
        case SAR = "SAR"
        case SBD = "SBD"
        case SCR = "SCR"
        case SDD = "SDD"
        case SDG = "SDG"
        case SDP = "SDP"
        case SEK = "SEK"
        case SGD = "SGD"
        case SHP = "SHP"
        case SIT = "SIT"
        case SKK = "SKK"
        case SLL = "SLL"
        case SOS = "SOS"
        case SRD = "SRD"
        case SRG = "SRG"
        case SSP = "SSP"
        case STD = "STD"
        case SUR = "SUR"
        case SVC = "SVC"
        case SYP = "SYP"
        case SZL = "SZL"
        case THB = "THB"
        case TJR = "TJR"
        case TJS = "TJS"
        case TMM = "TMM"
        case TMT = "TMT"
        case TND = "TND"
        case TOP = "TOP"
        case TPE = "TPE"
        case TRL = "TRL"
        case TRY = "TRY"
        case TTD = "TTD"
        case TWD = "TWD"
        case TZS = "TZS"
        case UAH = "UAH"
        case UAK = "UAK"
        case UGS = "UGS"
        case UGX = "UGX"
        case USD = "USD"
        case USN = "USN"
        case USS = "USS"
        case UYI = "UYI"
        case UYP = "UYP"
        case UYU = "UYU"
        case UZS = "UZS"
        case VEB = "VEB"
        case VEF = "VEF"
        case VND = "VND"
        case VNN = "VNN"
        case VUV = "VUV"
        case WST = "WST"
        case XAF = "XAF"
        case XAG = "XAG"
        case XAU = "XAU"
        case XBA = "XBA"
        case XBB = "XBB"
        case XBC = "XBC"
        case XBD = "XBD"
        case XCD = "XCD"
        case XDR = "XDR"
        case XEU = "XEU"
        case XFO = "XFO"
        case XFU = "XFU"
        case XOF = "XOF"
        case XPD = "XPD"
        case XPF = "XPF"
        case XPT = "XPT"
        case XRE = "XRE"
        case XSU = "XSU"
        case XTS = "XTS"
        case XUA = "XUA"
        case XXX = "XXX"
        case YDD = "YDD"
        case YER = "YER"
        case YUD = "YUD"
        case YUM = "YUM"
        case YUN = "YUN"
        case YUR = "YUR"
        case ZAL = "ZAL"
        case ZAR = "ZAR"
        case ZMK = "ZMK"
        case ZMW = "ZMW"
        case ZRN = "ZRN"
        case ZRZ = "ZRZ"
        case ZWL = "ZWL"
        case ZWR = "ZWR"
        case ZWD = "ZWD"
    }
}
