Class {
	#name : 'Example',
	#superclass : 'Object',
	#instVars : [
		'inst',
		'inst2'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'accessing' }
Example >> foo [

	| t1 t2 |
	t1 := Point x: 4 y: 8.
	inst := t1.
	inst2 := OrderedCollection new.
	t1 message
]
