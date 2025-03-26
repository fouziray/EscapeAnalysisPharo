Class {
	#name : 'FixtureEvilQuad',
	#superclass : 'Object',
	#instVars : [
		'instVar'
	],
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'polymorphism' }
FixtureEvilQuad >> polyEscapeOrNot: arg [
"this escapes"
	instVar:= self.
]
