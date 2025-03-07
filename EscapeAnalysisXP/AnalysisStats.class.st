Class {
	#name : 'AnalysisStats',
	#superclass : 'Object',
	#instVars : [
		'logOfAllWorklist'
	],
	#category : 'EscapeAnalysisXP-Objects',
	#package : 'EscapeAnalysisXP',
	#tag : 'Objects'
}

{ #category : 'adding' }
AnalysisStats >> addStat: anArrayOfStats of: acompiledMethod [

	logOfAllWorklist at: acompiledMethod put: anArrayOfStats
]

{ #category : 'initialization' }
AnalysisStats >> initialize [

	logOfAllWorklist := Dictionary new
]

{ #category : 'accessing' }
AnalysisStats >> logOfAllWorklist [

	^ logOfAllWorklist
]
