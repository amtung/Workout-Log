//
//  Entry+Addition.swift
//  WorkoutLog
//
//  Created by Annie Tung on 12/22/16.
//  Copyright © 2016 Annie Tung. All rights reserved.
//

import Foundation

extension Entry {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var dateString: String? {
        return date.map { Entry.dateFormatter.string(from: $0 as Date) }
    }
    
      // MARK: - Section Names
    private static let sectionNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MMMM-DD"
        return formatter
    }()
    
    private static let sectionTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static func sectionTitle(for sectionName: String?) -> String? {
        let date = sectionName.flatMap { Entry.sectionNameFormatter.date(from: $0) }
        return date.map { Entry.sectionTitleFormatter.string(from: $0) }
    }
    
    var sectionName: String? {
        return date.map { Entry.sectionNameFormatter.string(from: $0 as Date) }
    }
}
