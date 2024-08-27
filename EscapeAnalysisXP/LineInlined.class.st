Class {
	#name : 'LineInlined',
	#superclass : 'Object',
	#instVars : [
		'x1',
		'x2',
		'y1',
		'y2'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'as yet unclassified' }
LineInlined class >> p1: aPoint1 p2: aPoint2 [

	| line |
	line := self new.
	line lineX1: aPoint1 pointX.
	line lineY1: aPoint1 pointY.
	line lineX2: aPoint2 pointX.
	line lineY2: aPoint2 pointY.
	^ line
]

{ #category : 'accessing' }
LineInlined >> lineLength [

	^ ((x2 - x1 )squared + (y2 - y1 ) squared )sqrt
]

{ #category : 'as yet unclassified' }
LineInlined >> lineX1: aNumber [

	x1 := aNumber
]

{ #category : 'accessing' }
LineInlined >> lineX2: aNumber [

	x2 := aNumber
]

{ #category : 'accessing' }
LineInlined >> lineY1: aNumber [

	y1 := aNumber
]

{ #category : 'accessing' }
LineInlined >> lineY2: aNumber [

	y2 := aNumber
]
