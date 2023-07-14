//
//  Created by Jacob Brain
//

import UIKit

struct DecodedJSON: Codable{
    let lectures: [Lecture]
    let topics: [Topics]
}

struct Lecture: Codable {
    let lectureDurationMinutes: Int
    let lectureID: Int
    let lectureIconURL: String
    let lectureName: String
    let topics: [Int]
}

struct Topics: Codable {
    let topicID: Int
    let topicName: String
}

struct TimeFormatter {
    static func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        let formattedTime = String(format: "%dh:%02dm", hours, remainingMinutes)
        return formattedTime
    }
}

class lecturePage: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var lectureData: [Lecture] = []
    var topicData: [Topics] = []

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isScrollEnabled = false

        // Load JSON data
        readLocalJSONFile()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let totalNum = lectureData.count
        
        // Get cell height
        let cell_height: Int = 90
        
        // Set tableview height
        let newHeight = CGFloat(totalNum * cell_height)
        
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Enable scrolling if tables overlap screen max size
        if screenHeight < newHeight {
            tableView.isScrollEnabled = true
            heightConstraint.constant = screenHeight - CGFloat(cell_height)
        }else{
            heightConstraint.constant = CGFloat(cell_height * totalNum)
        }
        
        return totalNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "lecture_names", for: indexPath)
        
        let LectureLab = cell.viewWithTag(5) as! UILabel
        let LectureTime = cell.viewWithTag(3) as! UILabel
        let main_view = cell.viewWithTag(1)!
        
        main_view.layer.cornerRadius = 10
        main_view.layer.masksToBounds = true
        
        main_view.clipsToBounds = true // This is
        
        let LectureImg = cell.viewWithTag(2) as? UIImageView
        
        if !lectureData.isEmpty {
            
            let lecture_name = lectureData[indexPath.row].lectureName
            LectureLab.text = lecture_name
            
            let time_in_mins =  lectureData[indexPath.row].lectureDurationMinutes
            
            LectureTime.text = TimeFormatter.formatTime(time_in_mins)
            
            // Now sort out img load
            let imageURLString = lectureData[indexPath.row].lectureIconURL

            downloadImage(from: imageURLString) { image in
                DispatchQueue.main.async {
                    // Check if the cell is still visible at this index path
                    if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                        // Set the downloaded image to the UIImageView
                        LectureImg?.image = image // Set the image of the UIImageView
                        LectureImg?.contentMode = .scaleAspectFill // Set the contentMode
                    }
                }
            }
        }

        return cell

        
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil) // Return nil if the URL is invalid
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            if let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }

    
    
    func readLocalJSONFile() {
        if let path = Bundle.main.path(forResource: "lectures", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let response = try decoder.decode(DecodedJSON.self, from: data)
                
                lectureData = response.lectures
                topicData = response.topics

                DispatchQueue.main.async {
                    self.tableView.reloadData() // Reload the table view with the updated data
                }
            } catch {
                // Handle error
                print("Error reading JSON file: \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lecturePageSegue",
           let destinationVC = segue.destination as? topicPage, let selectedTopicIndex = tableView.indexPathForSelectedRow?.row {
            
            var segue_topics = [Topics]()

            // Create a set of topic IDs from the lecture's topics for faster lookups
            let lectureTopicIDs = Set(lectureData[selectedTopicIndex].topics)

            // Filter the topicData array to extract matching topics
            segue_topics = topicData.filter { topic in
                return lectureTopicIDs.contains(topic.topicID)
            }

            destinationVC.topics = segue_topics
            destinationVC.title_var = lectureData[selectedTopicIndex].lectureName
            
            
        }

        
    }
    
}
