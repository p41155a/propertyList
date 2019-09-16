//
//  ListViewController.swift
//  CustomPlist
//
//  Created by MC975-107 on 17/09/2019.
//  Copyright © 2019 comso. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var account: UITextField!
    @IBOutlet var name: UILabel!
    @IBOutlet var gender: UISegmentedControl!
    @IBOutlet var married: UISwitch!
    // 메인 번들에 정의된 PList 내용을 저장할 딕셔너리
    var defaultPList: NSDictionary!
    
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex // 0-남자, 1-여자
        // 저장 로직
        let customPlist = "\(self.account.text!).plist" // 커스텀 프로퍼티 파일명
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPList)
        data.setValue(value, forKey: "gender")
        data.write(toFile: plist, atomically: true)
    }
    
    @IBAction func changeMarried(_ sender: UISwitch) {
        let value = sender.isOn // true-기혼, false-미혼
        // 저장 로직
        let customPlist = "\(self.account.text!).plist" // 커스텀 프로퍼티 파일명
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary()
        data.setValue(value, forKey: "married")
        data.write(toFile: plist, atomically: true)
        // 파일이 저장된 경로 확인을 위하여
        print("custom plist \(plist)")
    }
    
    var accountlist = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 메인 번들에 UserInfo.plist 파일이 있으면 읽어와 딕셔너리에 넣음
        if let defaultPListPath = Bundle.main.path(forResource: "UserInfo", ofType: "plist") {
            self.defaultPList = NSDictionary(contentsOfFile: defaultPListPath)
        }
        // 피커뷰
        let picker = UIPickerView()
        picker.delegate = self
        self.account.inputView = picker // 텍스트 필드 입력 방식을 키보드 대신 피커 뷰로 설정
        // 툴 바
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = .lightGray
        self.account.inputAccessoryView = toolbar // 액세서리 뷰 영역에 툴 바 표시
        // 툴 바에 버튼 추가
        let done = UIBarButtonItem()
        done.title = "Done"
        done.target = self
        done.action = #selector(pickerDone)
        // 툴 바 가변 폭 버튼 정의
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // 신규 계정 추가 버튼
        let new = UIBarButtonItem()
        new.title = "New"
        new.target = self
        new.action = #selector(newAccount)
        // 버튼을 툴 바에 추가
        toolbar.setItems([new, flexSpace, done], animated: true)
        // 기본 저장소 객체 불러오기
        let plist = UserDefaults.standard
        // 불러온 값 설정
        self.name.text = plist.string(forKey: "name")
        self.married.isOn = plist.bool(forKey: "married")
        self.gender.selectedSegmentIndex = plist.integer(forKey: "gender")
        // 앱이 종료해도 저장됨
        let accountlist = plist.array(forKey: "accountlist") as? [String] ?? [String]()
        self.accountlist = accountlist
        if let account = plist.string(forKey: "selectedAccount") {
            self.account.text = account
        }
        // 저장된 커스텀 프로퍼티 파일을 꺼내어 화면에 값을 표시해 봅시다
        if let account = plist.string(forKey: "selectedAccount") {
            self.account.text = account
            let customPlist = "\(account).plist" // 읽어올 파일명
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: clist)
            
            self.name.text = data?["name"] as? String
            self.gender.selectedSegmentIndex = data?["gender"] as? Int ?? 0
            self.married.isOn = data?["married"] as? Bool ?? false
        }
        // 사용자 계정이 비어있다면 값을 설정하지 못함
        if (self.account.text?.isEmpty)! {
            self.account.placeholder = "등록된 계정이 없습니다."
            self.gender.isEnabled = false
            self.married.isEnabled = false
        }
        // 내비게이션 바에 버튼 추가하고 newAccount 메서드와 연결
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(newAccount(_:)))
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    @objc func pickerDone(_ sender: Any) {
        self.view.endEditing(true)
        // 선택된 계정에 대한 커스텀 프로퍼티 파일을 읽어와 세팅한다
        if let _account = self.account.text {
            let customPlist = "\(_account).plist" // 읽어올 파일명
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: clist)
            
            self.name.text = data?["name"] as? String
            self.gender.selectedSegmentIndex = data?["gender"] as? Int ?? 0
            self.married.isOn = data?["married"] as? Bool ?? false
        }
    }
    
    @objc func newAccount(_ sender: Any) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "새 계정을 입력하세요", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            $0.placeholder = "ex) abc@gmail.com"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            if let account = alert.textFields?[0].text {
                self.accountlist.append(account)
                self.account.text = account
                // 컨트롤 값 초기화
                self.name.text = ""
                self.gender.selectedSegmentIndex = 0
                self.married.isOn = false
                
                // 계정 목록을 저장
                let plist = UserDefaults.standard
                plist.set(self.accountlist, forKey: "accountlist")
                plist.set(account, forKey: "selectedAccount")
                plist.synchronize()
            }
        })
        self.present(alert, animated: false)
    }
    
    // 생성할 컴포넌트의 개수 정의
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 컴포넌트가 가질 목록의 길이
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.accountlist.count
    }
    
    // 컴포넌트의 목록 각 행에 출력될 내용
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.accountlist[row]
    }
    
    // 컴포넌트의 행을 선택했을 때 실행할 액션
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 선택된 계정을 텍스트 필드에 입력
        let account = self.accountlist[row] // 선택된 계정
        self.account.text = account
        // 선택한 계정 저장
        let plist = UserDefaults.standard
        plist.set(account, forKey: "selectedAccount")
        plist.synchronize()
    }
    // 테이블의 각 행을 클릭했을 때
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && !(self.account.text?.isEmpty)! {
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
            // 텍스트필드 추가
            alert.addTextField(configurationHandler: {
                $0.text = self.name.text // name 레이블의 텍스트를 기본값으로 넣음
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                // OK 버튼을 누르면 입력 필드의 값을 저장
                let value = alert.textFields?[0].text
                // 저장 로직 시작
                let customPlist = "\(self.account.text!).plist" // 읽어올 파일명
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // 앱 내에 생성된 문서 디렉터리 경로를 구합니다
                let path = paths[0] as NSString
                let plist = path.strings(byAppendingPaths: [customPlist]).first!
                let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPList) // 읽어온 파일을 딕셔너리 객체로 변환합니다. 만약 해당 위치에 파일이 없다면 새로운 딕셔너리 객체를 생성합니다.
                data.setValue(value, forKey: "name")
                data.write(toFile: plist, atomically: true) // 딕셔너리 객체를 커스텀 프로퍼티 파일로 저장합니다.
                // 수정된 값을 레이블에 적용
                self.name.text = value
                // 입력 항목을 활성화
                self.gender.isEnabled = true
                self.married.isEnabled = true
            })
            self.present(alert, animated: false)
        }
    }
}
