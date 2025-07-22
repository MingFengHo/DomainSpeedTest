import Foundation
import UIKit

class DomainSpeedTester {
    
    private var speedResults: [[String: Any]] = []
    
    
    private let domains = ["a.com", "b.com", "c.com"]
    
    
    func downloadImg(domain: String) async -> Double {
        guard let url = URL(string: "https://\(domain)/test-img") else {
            return 0
        }
        
        let startTime = Date()
        
        do {
            let (_, _) = try await URLSession.shared.data(from: url)
            let endTime = Date()
            return endTime.timeIntervalSince(startTime) * 1000
        } catch {
            return 0
        }
    }
    
    
    func set(results: [[String: Any]]) {
        speedResults = results.sorted { 
            let time1 = $0["time"] as? Double ?? 0
            let time2 = $1["time"] as? Double ?? 0
            return time1 < time2
        }
    }
    
   
    func get() -> [[String: Any]] {
        return speedResults
    }
    
    
    func startBackgroundSpeedTest() async {
        var results: [[String: Any]] = []
        
        for domain in domains {
            let downloadTime = await downloadImg(domain: domain)
            let result = ["domain": domain, "time": downloadTime]
            results.append(result)
        }
        
        await MainActor.run {
            self.set(results: results)
        }
    }
    
}
