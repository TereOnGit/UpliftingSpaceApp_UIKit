import Foundation

struct Launch: Identifiable, Decodable {
    var id: String
    var dateUnix: Date
    var name: String
    var details: String?
    var links: Links
    var upcoming: Bool
    
    struct Links: Decodable, Hashable {
        var webcast: URL?
        var wikipedia: URL?
    }
}


extension Launch {
    static var launchWithDetails = Launch(id: "123", dateUnix: Date(), name: "Test", details: "Funguje", links: Launch.Links(webcast: nil, wikipedia: URL(string: "https://en.wikipedia.org/wiki/DemoSat")), upcoming: false)
    static var launchWithoutDetails = Launch(id: "123", dateUnix: Date(), name: "Test", details: nil, links: Launch.Links(webcast: nil, wikipedia: URL(string: "https://en.wikipedia.org/wiki/DemoSat")), upcoming: false)
}
