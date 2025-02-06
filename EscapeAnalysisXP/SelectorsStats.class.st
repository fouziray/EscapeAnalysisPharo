Class {
	#name : 'SelectorsStats',
	#superclass : 'Object',
	#category : 'EscapeAnalysisXP-Objects',
	#package : 'EscapeAnalysisXP',
	#tag : 'Objects'
}

{ #category : 'as yet unclassified' }
SelectorsStats >> findSingleSelectors [

^ Set newFrom: ( SystemNavigation default allMethods  collect: [ :m | m selector ])

]

{ #category : 'as yet unclassified' }
SelectorsStats >> findSingleSelectorsWithNumberOfImplementation [
| dictionary|
dictionary:= Dictionary new.

 (SystemNavigation default allMethods  collect: [ :m | m selector ] ) do: [ :e | dictionary at: e update: [ :v | v+1 ]  initial: 1    ].

^ dictionary

]
