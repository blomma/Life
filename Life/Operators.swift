precedencegroup LeftAssociativePrecedence {
    associativity: left
    lowerThan: RangeFormationPrecedence
}

infix operator !~=: LeftAssociativePrecedence
func !~= <Bound>(pattern: CountableClosedRange<Bound>, value: Bound) -> Bool {
    return !(pattern ~= value)
}
