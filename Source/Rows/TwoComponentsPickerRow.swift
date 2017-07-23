//
//  TwoComponentsPickerRow.swift
//  Eureka
//
//  Created by 吴浠 on 2017/7/23.
//  Copyright © 2017年 Xmartlabs. All rights reserved.
//

import Foundation

open class TwoComponentsPickerCell<T> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate where T:Equatable{
    
    @IBOutlet public weak var picker: UIPickerView!
    
    private var pickerRow: _TwoComponentsPickerRow<T>? { return row as? _TwoComponentsPickerRow<T> }

    deinit {
        picker?.delegate = nil
        picker?.dataSource = nil
    }
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let pickerView = UIPickerView()
        self.picker = pickerView
        self.picker?.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(pickerView)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": pickerView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": pickerView]))
    }
    
    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType = .none
        height = { UITableViewAutomaticDimension }
        picker.delegate = self
        picker.dataSource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        picker.reloadAllComponents()
        if let selectedValue = pickerRow?.value, let index = pickerRow?.options.index(of: selectedValue) {
            picker.selectRow(index, inComponent: 0, animated: true)
        }
        if let secondSelectedValue = pickerRow?.secondValue, let index = pickerRow?.secondOptions.index(of: secondSelectedValue){
            picker.selectRow(index, inComponent: 1, animated: true)
        }
    }
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return pickerRow?.options.count ?? 0
        }else{
            return pickerRow?.secondOptions.count ?? 0
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return pickerRow?.options[row] as? String

        }else{
            return pickerRow?.secondOptions[row] as? String
        }
    }
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0{
            if let picker = pickerRow, !picker.options.isEmpty {
                picker.value = picker.options[row]
            }
        }else{
            if let picker = pickerRow, !picker.secondOptions.isEmpty{
                picker.secondValue = picker.secondOptions[row]
            }
        }
    }

}

open class _TwoComponentsPickerRow<T>: Row<TwoComponentsPickerCell<T>> where T: Equatable{
    open var options = [T]()
    
    open var secondOptions = [T]()
    
    open var secondValue:T?{
        set (newValue) {
            _secondValue = newValue
            guard let _ = section?.form else { return }
            wasChanged = true
            if validationOptions.contains(.validatesOnChange) || (wasBlurred && validationOptions.contains(.validatesOnChangeAfterBlurred)) ||  (!isValid && validationOptions != .validatesOnDemand) {
                validate()
            }
        }
        get {
            return _secondValue
        }
    }
    private var _secondValue: T? {
        didSet {
            guard _secondValue != oldValue else { return }
            guard let form = section?.form else { return }
            if let delegate = form.delegate {
                delegate.valueHasBeenChanged(for: self, oldValue: oldValue, newValue: secondValue)
                callbackOnChange?()
            }
            guard let t = tag else { return }
            form.tagToValues[t] = (secondValue != nil ? secondValue! : NSNull())
            if let rowObservers = form.rowObservers[t]?[.hidden] {
                for rowObserver in rowObservers {
                    (rowObserver as? Hidable)?.evaluateHidden()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.disabled] {
                for rowObserver in rowObservers {
                    (rowObserver as? Disableable)?.evaluateDisabled()
                }
            }
        }
    }
   
    
    
    required public init(tag: String?){
        super.init(tag :tag)
    }
}

public final class TwoComponentsPickerRow<T>: _TwoComponentsPickerRow<T>, RowType where T: Equatable  {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
}
