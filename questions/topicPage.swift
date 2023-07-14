//
//  Created by Jacob Brain
//

import UIKit

// Use a UITableViewCell to access button from within the cell view
class BtnAccessTableViewCell: UITableViewCell {
    @IBOutlet weak var acceptButton: UIButton!
}

class topicPage: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var topics: [Topics] = []
    
    var title_var: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        load_data()
        self.title = title_var
    }
    
    var topic_IDs: [Int] = []
    
    func load_data(){
        // Retrieving the list of topic IDs from UserDefaults
        if let storedTopicIDs = UserDefaults.standard.array(forKey: "topicIDs") as? [Int] {
            topic_IDs = storedTopicIDs
        }
    }
    
    // Retrieves list from UserDefaults, adds value to list and resaves list
    func save_value(new_value: Int){
        // Retrieve existing list from UserDefaults
        if var savedTopicIDs = UserDefaults.standard.array(forKey: "topicIDs") as? [Int] {
            savedTopicIDs.append(new_value)
            UserDefaults.standard.set(savedTopicIDs, forKey: "topicIDs")
        } else {
            // If the list doesn't exist yet, create it and add the new value
            UserDefaults.standard.set([new_value], forKey: "topicIDs")
        }
    }
    
    // Retrieve existing list from UserDefaults, removes value from list and resaves it
    func removeValue(remove_value: Int) {
        // Retrieve existing list from UserDefaults
        if var savedTopicIDs = UserDefaults.standard.array(forKey: "topicIDs") as? [Int] {
            // Check if the value to remove exists in the array
            if let indexToRemove = savedTopicIDs.firstIndex(of: remove_value) {
                savedTopicIDs.remove(at: indexToRemove)
                UserDefaults.standard.set(savedTopicIDs, forKey: "topicIDs")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topic_cell", for: indexPath) as! BtnAccessTableViewCell

        // Retrieve points
        let LectureLab = cell.viewWithTag(5) as! UILabel
        let main_view = cell.viewWithTag(2)!
        let check_button = cell.viewWithTag(3) as! UIButton
        
        // Round off view
        main_view.layer.cornerRadius = 10
        
        if topic_IDs.contains(topics[indexPath.row].topicID) {
            check_button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            check_button.tintColor = UIColor.systemTeal
        } else {
            check_button.setImage(UIImage(systemName: "square"), for: .normal)
            check_button.tintColor = UIColor.white
        }

        LectureLab.text = topics[indexPath.row].topicName

        return cell
    }
    
    @IBAction func clickAccept(_ sender: UIButton) {
        guard let buttonPosition = sender.superview?.convert(sender.frame.origin, to: tableView) else {
            return
        }
        
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            let topicID = topics[indexPath.row].topicID // Get the topic ID for the selected row
            
            if sender.currentImage == UIImage(systemName: "square") {

                save_value(new_value: topicID) // Call save_value with
                sender.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
                sender.tintColor = UIColor.systemTeal
    
            } else {

                removeValue(remove_value: topicID) // Call removeValue with the topic ID to remove it from UserDefaults
                sender.setImage(UIImage(systemName: "square"), for: .normal)
                sender.tintColor = UIColor.white

            }
        }
    }
}
