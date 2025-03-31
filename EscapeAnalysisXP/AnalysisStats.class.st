Class {
	#name : 'AnalysisStats',
	#superclass : 'Object',
	#instVars : [
		'logOfAllWorklist',
		'numberOfFFI',
		'numberOfPrim',
		'numberOfReflection'
	],
	#category : 'EscapeAnalysisXP-Objects',
	#package : 'EscapeAnalysisXP',
	#tag : 'Objects'
}

{ #category : 'adding' }
AnalysisStats >> addStat: anArrayOfStats of: acompiledMethod [

	logOfAllWorklist at: acompiledMethod put: anArrayOfStats
]

{ #category : 'adding' }
AnalysisStats >> incrNumberOfFFI [

	numberOfFFI := numberOfFFI + 1
]

{ #category : 'adding' }
AnalysisStats >> incrNumberOfPrim [

	numberOfPrim := numberOfPrim + 1
]

{ #category : 'adding' }
AnalysisStats >> incrNumberOfReflection [

	numberOfReflection := numberOfReflection + 1
]

{ #category : 'initialization' }
AnalysisStats >> initialize [

	logOfAllWorklist := Dictionary new.
	numberOfPrim := 0.
	numberOfFFI := 0.
	numberOfReflection := 0
]

{ #category : 'accessing' }
AnalysisStats >> logOfAllWorklist [

	^ logOfAllWorklist
]

{ #category : 'adding' }
AnalysisStats >> numberOfFFI [

	^ numberOfFFI
]

{ #category : 'adding' }
AnalysisStats >> numberOfPrim [

	^ numberOfPrim
]

{ #category : 'adding' }
AnalysisStats >> numberOfReflection [

	^ numberOfReflection
]
