class Matrix<T> {
	let width: Int, height: Int
	private(set) var grid: [T]

	init(width: Int, height: Int, repeatValue: T) {
		self.width = width
		self.height = height

		grid = [T](repeating: repeatValue, count: width * height)
	}

	init<U: Sequence where U.Iterator.Element == T>(width: Int, height: Int, elements: U) {
		self.width = width
		self.height = height

		self.grid = [T](elements)
	}

	subscript(x: Int, y: Int) -> T {
		get {
			// Sanity check
			assert(x >= 0 && x < self.width, "x needs to be larger or equal to zero and smaller than the width of the matrix.")
			assert(y >= 0 && y < self.height, "y needs to be larger or equal to zero and smaller than the height of the matrix.")

			return grid[(x * height) + y]
		}
		set {
			// Sanity check
			assert(x >= 0 && x < self.width, "x needs to be larger or equal to zero and smaller than the width of the matrix.")
			assert(y >= 0 && y < self.height, "y needs to be larger or equal to zero and smaller than the height of the matrix.")

			grid[(x * height) + y] = newValue
		}
	}
}

extension Matrix : Sequence {
	func makeIterator() -> MatrixGenerator<T> {
		return MatrixGenerator(matrix: self)
	}
}

struct MatrixGenerator<T> : IteratorProtocol {
	private let matrix: Matrix<T>
	private var x = 0
	private var y = 0

	init(matrix: Matrix<T>) {
		self.matrix = matrix
	}

	mutating func next() -> (x:Int, y:Int, element: T)? {
		// Sanity check
		if self.x >= matrix.width { return nil }
		if self.y >= matrix.height { return nil }

		// Extract the element and increase the counters
		let returnValue = (self.x, self.y, matrix[self.x, self.y])

		// Increase the counters
		self.x += 1
		if self.x >= matrix.width {
			self.x = 0
			self.y += 1
		}

		return returnValue
	}
}
