import Foundation

public func sampleFileUrl() -> URL? {
  let fileManager = FileManager.default

  do {
    let downloadsFolder = try fileManager.url(
      for: .downloadsDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true)
    let jsonFile = downloadsFolder.appendingPathComponent("SampleData.json")
    return jsonFile
  } catch {
    print(error)
    return nil
  }
}

public func saveSampleData(json: String) {
  guard let jsonFile = sampleFileUrl() else {
    print("Error getting URL of sample data file.")
    return
  }

  do {
    try json.write(to: jsonFile, atomically: true, encoding: .utf8)
    print("Sample JSON data saved to \(jsonFile.path)")
  } catch {
    print(error)
  }
}

public func readSampleData() -> Data? {
  guard let jsonFile = sampleFileUrl() else {
    print("Error getting URL of sample data file.")
    return nil
  }

  do {
    let data = try Data(contentsOf: jsonFile)
    return data
  } catch {
    print(error)
    return nil
  }
}
