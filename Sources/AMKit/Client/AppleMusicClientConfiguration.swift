import Foundation
import AsyncHTTPClient
import NIOCore

/// Modern configuration for Apple Music API client with AsyncHTTPClient integration
public struct AppleMusicClientConfiguration: Sendable {
    public let baseURL: String
    public let timeout: TimeAmount
    public let httpClient: HTTPClient?
    
    public init(
        baseURL: String = "https://api.music.apple.com/v1",
        timeout: TimeAmount = .seconds(30),
        httpClient: HTTPClient? = nil
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.httpClient = httpClient
    }
    
    /// Default configuration using HTTPClient.shared singleton for optimal performance
    public static let `default` = AppleMusicClientConfiguration()
    
    /// Configuration optimized for browser-like behavior
    public static let browserLike = AppleMusicClientConfiguration(
        timeout: .seconds(60) // Longer timeout for better user experience
    )
    
    /// Internal method to get the appropriate HTTPClient
    internal var effectiveHTTPClient: HTTPClient {
        httpClient ?? HTTPClient.shared
    }
}

public enum AppleMusicStorefront: String, CaseIterable, Sendable {
    case us = "us"
    case gb = "gb"
    case ca = "ca"
    case au = "au"
    case de = "de"
    case fr = "fr"
    case jp = "jp"
    case br = "br"
    case mx = "mx"
    case es = "es"
    case it = "it"
    case nl = "nl"
    case se = "se"
    case no = "no"
    case dk = "dk"
    case fi = "fi"
    case ch = "ch"
    case at = "at"
    case be = "be"
    case ie = "ie"
    case nz = "nz"
    case za = "za"
    case sg = "sg"
    case hk = "hk"
    case my = "my"
    case th = "th"
    case ph = "ph"
    case id = "id"
    case vn = "vn"
    case tw = "tw"
    case kr = "kr"
    case `in` = "in"
    case ae = "ae"
    case sa = "sa"
    case kw = "kw"
    case qa = "qa"
    case bh = "bh"
    case om = "om"
    case il = "il"
    case tr = "tr"
    case eg = "eg"
    case ru = "ru"
    case ua = "ua"
    case pl = "pl"
    case cz = "cz"
    case sk = "sk"
    case hu = "hu"
    case ro = "ro"
    case bg = "bg"
    case hr = "hr"
    case si = "si"
    case ee = "ee"
    case lv = "lv"
    case lt = "lt"
    case mt = "mt"
    case cy = "cy"
    case lu = "lu"
    case `is` = "is"
    case pt = "pt"
    case gr = "gr"
    case cl = "cl"
    case ar = "ar"
    case co = "co"
    case pe = "pe"
    case ec = "ec"
    case uy = "uy"
    case py = "py"
    case bo = "bo"
    case cr = "cr"
    case gt = "gt"
    case hn = "hn"
    case ni = "ni"
    case pa = "pa"
    case sv = "sv"
    case `do` = "do"
    case jm = "jm"
    case tt = "tt"
    case bb = "bb"
    case ag = "ag"
    case bs = "bs"
    case bz = "bz"
    case dm = "dm"
    case gd = "gd"
    case gy = "gy"
    case kn = "kn"
    case lc = "lc"
    case sr = "sr"
    case vc = "vc"
}

// MARK: - Apple Music Localization

/// Represents supported localization languages for Apple Music API requests.
///
/// This enum provides type-safe access to commonly used language-region combinations
/// supported by the Apple Music API for localized responses.
public enum AppleMusicLocalization: String, CaseIterable, Sendable {
    // English variants
    case enUS = "en-US"
    case enGB = "en-GB"
    case enCA = "en-CA"
    case enAU = "en-AU"
    
    // Spanish variants
    case esES = "es-ES"
    case esMX = "es-MX"
    case esAR = "es-AR"
    case esCL = "es-CL"
    case esCO = "es-CO"
    case esPE = "es-PE"
    
    // French variants
    case frFR = "fr-FR"
    case frCA = "fr-CA"
    case frCH = "fr-CH"
    case frBE = "fr-BE"
    
    // German variants
    case deDE = "de-DE"
    case deAT = "de-AT"
    case deCH = "de-CH"
    
    // Italian variants
    case itIT = "it-IT"
    case itCH = "it-CH"
    
    // Portuguese variants
    case ptBR = "pt-BR"
    case ptPT = "pt-PT"
    
    // Japanese
    case jaJP = "ja-JP"
    
    // Korean
    case koKR = "ko-KR"
    
    // Chinese variants
    case zhCN = "zh-CN"
    case zhTW = "zh-TW"
    case zhHK = "zh-HK"
    
    // Dutch variants
    case nlNL = "nl-NL"
    case nlBE = "nl-BE"
    
    // Nordic languages
    case svSE = "sv-SE"
    case noNO = "no-NO"
    case daDK = "da-DK"
    case fiFI = "fi-FI"
    case isIS = "is-IS"
    
    // Eastern European
    case ruRU = "ru-RU"
    case plPL = "pl-PL"
    case csCZ = "cs-CZ"
    case skSK = "sk-SK"
    case huHU = "hu-HU"
    case roRO = "ro-RO"
    case bgBG = "bg-BG"
    case hrHR = "hr-HR"
    case slSI = "sl-SI"
    case etEE = "et-EE"
    case lvLV = "lv-LV"
    case ltLT = "lt-LT"
    
    // Other European
    case elGR = "el-GR"
    case trTR = "tr-TR"
    case ukUA = "uk-UA"
    
    // Middle East
    case arSA = "ar-SA"
    case arAE = "ar-AE"
    case arEG = "ar-EG"
    case heIL = "he-IL"
    
    // Asia Pacific
    case thTH = "th-TH"
    case viVN = "vi-VN"
    case idID = "id-ID"
    case msMY = "ms-MY"
    case hiIN = "hi-IN"
    
    // Common combinations for specific storefronts
    public static let common: [AppleMusicLocalization] = [
        .enUS, .enGB, .esES, .esMX, .frFR, .deDE, .itIT, .ptBR, .jaJP, .koKR, .zhCN
    ]
}