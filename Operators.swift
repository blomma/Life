//
//  Operators.swift
//  gameoflife
//
//  Created by Mikael Hultgren on 19/06/16.
//  Copyright © 2016 Mikael Hultgren. All rights reserved.
//

infix operator !~= { associativity left precedence 130 }
func !~= <Bound>(pattern: CountableClosedRange<Bound>, value: Bound) -> Bool {
	return !(pattern ~= value)
}
