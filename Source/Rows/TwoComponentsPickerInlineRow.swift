//
//  TwoComponentsPickerInlineRow.swift
//  Eureka
//
//  Created by 吴浠 on 2017/7/23.
//  Copyright © 2017年 Xmartlabs. All rights reserved.
//

import UIKit

open class TwoComponentsPickerInlineCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType =  .none
    }
    
    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

open class _TwoComponentsPickerInlineRow<T> : Row<TwoComponentsPickerInlineCell<T>>, NoValueDisplayTextConformance where T: Equatable {
    
    public typealias InlineRow = TwoComponentsPickerRow<T>
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
    open var noValueDisplayText: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class TwoComponentsPickerInlineRow<T> : _TwoComponentsPickerInlineRow<T>, RowType, InlineRowType where T: Equatable {
    
    
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
    
    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.options = self.options
        inlineRow.secondOptions = self.secondOptions
        inlineRow.secondValue = self.secondValue
        inlineRow.displayValueFor = self.displayValueFor
    }
}
