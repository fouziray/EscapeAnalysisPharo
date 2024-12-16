Class {
	#name : 'PointInlined',
	#superclass : 'Object',
	#instVars : [
		'x',
		'y'
	],
	#category : 'EscapeAnalysisXP-Fixture',
	#package : 'EscapeAnalysisXP',
	#tag : 'Fixture'
}

{ #category : 'as yet unclassified' }
PointInlined >> pointX [

	^ x
]

{ #category : 'as yet unclassified' }
PointInlined >> pointX: anInteger [

	x := anInteger
]

{ #category : 'as yet unclassified' }
PointInlined >> pointY [

	^ y
]

{ #category : 'as yet unclassified' }
PointInlined >> pointY: anInteger [

	y := anInteger
]
