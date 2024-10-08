Class {
	#name : 'FixtureEscapeAnalysis',
	#superclass : 'Object',
	#instVars : [
		'x',
		'inst'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'class initialization' }
FixtureEscapeAnalysis class >> initialize [

	Smalltalk globals at: #FooGlobalVariable put: nil
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> foo3 [

	| h |
	h := nil.
	^ self toto: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> foo: point2 [

	| point1 line |
	point1 := PointInlined new.
	point1 pointX: 1.
	point1 pointY: 12.
	line := LineInlined p1: point1 p2: point2.
	line lineLength.
	^ line
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooNotReturn: point2 [

	| point1 line |
	point1 := PointInlined new.
	point1 pointX: 1.
	point1 pointY: 12.
	line := LineInlined p1: point1 p2: point2.
	^ line lineLength
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToGlobal [

	| h |
	h := nil.
	self fooSetterToGlobal: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToInstance [

	| h |
	h := nil.
	self fooSetterToInstance: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToTemp [

	| h |
	h := nil.
	self fooSetterToTemp: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetterToGlobal: h [

	FooGlobalVariable := h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetterToInstance: h [

	inst := h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetterToTemp: h [

	| aTemp |
	aTemp := h
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> method [

	| a |
	a := #value.
	^ self returnA: a
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> notUsedBlockReturnsTemp [

	| h tempo|
	h := [ ^ tempo ].
	^ self toto: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> notUsedBlockTemp [

	| h tempo |
	h := [ tempo ].
	^ self toto: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> objectEscaped [

	| xx y |
	xx := Object new.
	y := xx -> nil.
	^ self tata: y
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> returnA: a [

	^ a
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> tata: y [

	^ y
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> toto: h [

	^ 5 + 5
]
