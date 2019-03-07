//
//  common.swift
//  CheckWriter
//
//  Created by lip on 3/7/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

import Foundation
func fixRegisterText(_ s:String) -> String {
    var q = ""
    for char in s { char == ":" ? q.append("-") : q.append(char)}
    return q
}
