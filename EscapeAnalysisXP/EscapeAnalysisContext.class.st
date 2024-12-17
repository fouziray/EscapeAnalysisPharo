Class {
	#name : 'EscapeAnalysisContext',
	#superclass : 'Object',
	#instVars : [
		'currentBlock',
		'scope',
		'trackedVariablesTable',
		'currentTrackedVars',
		'next',
		'workingList',
		'workingListIndex',
		'associatedMethod'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> TVNames [

	^ currentTrackedVars collect: [ :n | n name ]
]

{ #category : 'accessing' }
EscapeAnalysisContext >> appendTrackedVariablesTable: aTrackedVariablesTable [

	trackedVariablesTable add: aTrackedVariablesTable.
	^ trackedVariablesTable
]

{ #category : 'accessing' }
EscapeAnalysisContext >> associatedMethod [

	^ associatedMethod
]

{ #category : 'accessing' }
EscapeAnalysisContext >> associatedMethod: aCompiledMethod [

	associatedMethod := aCompiledMethod
]

{ #category : 'accessing' }
EscapeAnalysisContext >> currentBlock [

	^ currentBlock
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> currentBlock: aBlockNode [

	currentBlock := aBlockNode
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> currentMethod [

	^ next
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> extendWorkinglist: aMethod [

	workingList add: aMethod.
	^ workingList
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> findVariableByName: aName [

	^ (currentTrackedVars select: [ :v | v name = aName ])
		  ifNotEmpty: [ :e | ^ e first ]
		  ifEmpty: [ ^ nil ]
]

{ #category : 'initialization' }
EscapeAnalysisContext >> initialize [

	super initialize.
	workingList := OrderedCollection new.
	workingListIndex := 1.
	currentTrackedVars := OrderedCollection new.
	trackedVariablesTable := OrderedCollection new.
	trackedVariablesTable add: currentTrackedVars
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> isVariableEscaped: aName [

	^ (self findVariableByName: aName) escapeStatus
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> nextMethod [

	[
	next := workingList at: workingListIndex.
	workingListIndex := workingListIndex + 1 ]
		on:  SubscriptOutOfBounds 
		do: [ next := nil ].

	^ next
]

{ #category : 'accessing' }
EscapeAnalysisContext >> scope [

	^ scope
]

{ #category : 'accessing' }
EscapeAnalysisContext >> scope: anAst [

	scope := anAst
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> trackVariable: aTrackedVariable [

	| aTrackedVariableNode |
	aTrackedVariableNode := TrackedVariable new name: aTrackedVariable.
	currentTrackedVars add: aTrackedVariableNode.

	^ aTrackedVariableNode
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> trackVariables: aCollectionOfTrackedVariableNames [

	aCollectionOfTrackedVariableNames do: [ :singleVariableName |
		self trackVariable: singleVariableName ].
	^ currentTrackedVars
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedMethodArgs [

	^ currentTrackedVars
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedVariablesTable [

	trackedVariablesTable
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedVariablesTable: aTrackedVariablesTable [

	trackedVariablesTable := aTrackedVariablesTable
]

{ #category : 'accessing' }
EscapeAnalysisContext >> workingList [

	^ workingList
]

{ #category : 'accessing' }
EscapeAnalysisContext >> workingListIndex [

	^ workingListIndex
]
