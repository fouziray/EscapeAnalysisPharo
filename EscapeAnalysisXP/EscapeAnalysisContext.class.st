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
		'associatedMethod',
		'analysisDepth',
		'returnStatus',
		'eaContext',
		'unassignedObjMap',
		'callSiteMessage'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> TVNames [

	^ currentTrackedVars collect: [ :n | n name ]
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> TVs [

	^ currentTrackedVars 
]

{ #category : 'accessing' }
EscapeAnalysisContext >> analysisDepth [

	^ analysisDepth
]

{ #category : 'accessing' }
EscapeAnalysisContext >> analysisDepth: depth [

	analysisDepth := depth
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

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> callSiteMessage [

	^ callSiteMessage
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> callSiteMessage: aMessageNode [

	callSiteMessage := aMessageNode
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

	^ associatedMethod 
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> extendWorkinglist: aMethod [

	workingList add: aMethod.
	^ workingList
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> findVariableByName: aName [

	| globallyDistinctName |
	globallyDistinctName := self globallyDistinctName: aName.
	^ (currentTrackedVars select: [ :v | v name = globallyDistinctName ])
		  ifNotEmpty: [ :e | ^ e first ]
		  ifEmpty: [ ^ nil ]
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> globallyDistinctName: aTrackedVariableName [

| firstClassnamePrefix |
 (self currentMethod isClassSide) ifTrue:[
	firstClassnamePrefix :=	(self currentMethod classBinding value name splitOn: ' ') joinUsing: ''
	] ifFalse: [
	firstClassnamePrefix := self currentMethod classBinding name.
	].
	^  firstClassnamePrefix ,'_'
	  , self currentMethod selector , '_' , aTrackedVariableName
]

{ #category : 'initialization' }
EscapeAnalysisContext >> initialize [

	super initialize.
	workingList := OrderedCollection new.
	workingListIndex := 1.
	currentTrackedVars := OrderedCollection new.
	trackedVariablesTable := OrderedCollection new.
	trackedVariablesTable add: currentTrackedVars.
	unassignedObjMap := Dictionary new.
	callSiteMessage := nil
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> isVariableEscaped: aName [

	^ (self findVariableByName: aName) escapeStatus
]

{ #category : 'to remove as soon as possible' }
EscapeAnalysisContext >> nextMethod [

	[
	next := workingList at: workingListIndex.
	workingListIndex := workingListIndex + 1 ]
		on:  SubscriptOutOfBounds 
		do: [ next := nil ].

	^ next
]

{ #category : 'accessing' }
EscapeAnalysisContext >> returnStatus [

	^ returnStatus
]

{ #category : 'accessing' }
EscapeAnalysisContext >> returnStatus: aBoolean [

	^ returnStatus := aBoolean
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
	aTrackedVariableNode := TrackedVariable new name:
		                        (self globallyDistinctName: aTrackedVariable).
	aTrackedVariableNode associatedMethod: self associatedMethod.
	currentTrackedVars add: aTrackedVariableNode.

	^ aTrackedVariableNode
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> trackVariables: aCollectionOfTrackedVariableNames [

	aCollectionOfTrackedVariableNames do: [ :singleVariableName |
		self trackVariable: singleVariableName asString ].
	^ currentTrackedVars
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedMethodArgs [

	^ currentTrackedVars
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedMethodArgs: aCollection [

	currentTrackedVars := aCollection
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedVariablesTable [

	trackedVariablesTable
]

{ #category : 'accessing' }
EscapeAnalysisContext >> trackedVariablesTable: aTrackedVariablesTable [

	trackedVariablesTable := aTrackedVariablesTable
]

{ #category : 'as yet unclassified' }
EscapeAnalysisContext >> unTrackVariable: anASTNode [

	currentTrackedVars remove: (self findVariableByName: anASTNode name) ifAbsent: [].
	
]

{ #category : 'accessing' }
EscapeAnalysisContext >> unassignedObjAt: astObjectNew put: newTrackedVar [

	unassignedObjMap at: astObjectNew put: newTrackedVar.
]

{ #category : 'accessing' }
EscapeAnalysisContext >> workingList [

	^ workingList
]

{ #category : 'accessing' }
EscapeAnalysisContext >> workingListIndex [

	^ workingListIndex
]
