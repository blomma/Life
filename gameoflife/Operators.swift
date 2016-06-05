infix operator !~= { associativity left precedence 130 }
func !~= <I : IntervalType>(pattern: I, value: I.Bound) -> Bool {
	return !(pattern ~= value)
}
