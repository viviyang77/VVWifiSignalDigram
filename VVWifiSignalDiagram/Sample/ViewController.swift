//
//  ViewController.swift
//  VVWifiSignalDiagram
//
//  Created by Vivi on 2021/3/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "VVWifiSignalDigram Sample"
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        
        let suffix = " GHz Diagram"
        
        switch indexPath.row {
        case 0: cell.textLabel?.text = "2.4" + suffix
        case 1: cell.textLabel?.text = "5" + suffix
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: String(describing: TestDiagramViewController.self))
                as? TestDiagramViewController
        else { return }
        
        switch indexPath.row {
        case 0: vc.type = .twoGHz
        case 1: vc.type = .fiveGHz
        default: return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
