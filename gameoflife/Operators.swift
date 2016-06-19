infix operator !~= { associativity left precedence 130 }
func !~= <Bound>(pattern: CountableClosedRange<Bound>, value: Bound) -> Bool {
	return !(pattern ~= value)
}
