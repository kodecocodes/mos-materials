import Cocoa

extension String {
  // String extension to decode HTML entities
  var decoded: String {
    let attr = try? NSAttributedString(
      data: Data(utf8),
      options: [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
      ],
      documentAttributes: nil)

    return attr?.string ?? self
  }
}


enum EventType: String {
  case events = "Events"
  case births = "Births"
  case deaths = "Deaths"
}

class AppState: ObservableObject {
  @Published var days: [String: Day] = [:]

  func getDataFor(month: Int, day: Int) -> Day? {
    let monthName = Calendar.current.monthSymbols[month - 1]
    let dateString = "\(monthName) \(day)"
    return days[dateString]
  }
}

struct Day: Decodable {
  let date: String
  let data: [String: [Event]]

  var displayDate: String {
    date.replacingOccurrences(of: "_", with: " ")
  }

  var events: [Event] { data[EventType.events.rawValue] ?? [] }
  var births: [Event] { data[EventType.births.rawValue] ?? [] }
  var deaths: [Event] { data[EventType.deaths.rawValue] ?? [] }
}

struct Event: Decodable, Identifiable {
  let id: UUID
  let year: String
  let text: String
  let links: [EventLink]

  enum CodingKeys: String, CodingKey {
    case text
    case links
  }

  init(from decoder: Decoder) throws {
    id = UUID()

    let values = try decoder.container(keyedBy: CodingKeys.self)

    let rawText = try values.decode(String.self, forKey: .text)
    var textParts = rawText.components(separatedBy: " &#8211; ")
    if textParts.count == 1 {
      textParts = rawText.components(separatedBy: " – ")
    }
    if textParts.count > 1 {
      year = textParts[0]
      text = textParts[1].decoded
    } else {
      year = "?"
      text = textParts[0].decoded
    }

    let allLinks = try values.decode([String: [String: String]].self, forKey: .links)
    var processedLinks: [EventLink] = []
    for (_, link) in allLinks {
      if let title = link["2"], let address = link["1"], let url = URL(string: address) {
        processedLinks.append(EventLink(id: UUID(), title: title, url: url))
      }
    }
    links = processedLinks
  }
}

struct EventLink: Decodable, Identifiable {
  let id: UUID
  let title: String
  let url: URL
}


enum FetchError: Error {
  case badUrl
  case badResponse
  case badJson
}

func getDataForDay(month: Int, day: Int) async throws -> Day {
  let address = "https://apizen.date/api/\(month)/\(day)"
  guard let url = URL(string: address) else {
    throw FetchError.badUrl
  }
  let request = URLRequest(url: url)

  let (data, response) = try await URLSession.shared.data(for: request)
  guard let response = response as? HTTPURLResponse, response.statusCode < 400 else {
    throw FetchError.badResponse
  }

  // If you do not still have the sample data file from the Starter
  // un-comment this next section to get it again.

  if let jsonString = String(data: data, encoding: .utf8) {
    saveSampleData(json: jsonString)
  }

  do {
    print("Decoding lots of data takes a while in a playground - scroll up to see it happening.")
    let day = try JSONDecoder().decode(Day.self, from: data)
    return day
  } catch {
    throw FetchError.badJson
  }
}

let appState = AppState()
let monthNum = 2
let dayNum = 29

func testData() {
  if let day = appState.getDataFor(month: monthNum, day: dayNum) {
    print(day.displayDate)
    print("\(day.births.count) births")
  } else {
    print("No data available for that month & day.")
  }
}

// Use live data

Task {
  do {
    let day = try await getDataForDay(month: monthNum, day: dayNum)
    appState.days[day.displayDate] = day
    testData()
  } catch {
    print(error)
  }
}

// Use saved sample data

//  if let data = readSampleData() {
//    do {
//      print("Decoding lots of data takes a while in a playground - scroll up to see it happening.")
//      let day = try JSONDecoder().decode(Day.self, from: data)
//      appState.days[day.displayDate] = day
//      testData()
//    } catch {
//      print(error)
//    }
//  }
