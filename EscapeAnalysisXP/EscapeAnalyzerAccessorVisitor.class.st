Class {
	#name : 'EscapeAnalyzerAccessorVisitor',
	#superclass : 'EscapeAnalyzerVisitor',
	#instVars : [
		'accessorSelector'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'accessing' }
EscapeAnalyzerAccessorVisitor >> accessorSelector: aSelector [

	accessorSelector := aSelector
]

{ #category : 'analyse' }
EscapeAnalyzerAccessorVisitor >> escapeAnalyze: method [

	| next tempVariables currentTrackVarsTable messagesWithSentVars |
	
	topLevel := true.
	context associatedMethod: method.
	( method ast body
			                sentMessages includes: accessorSelector ) ifFalse: [ ^ self ] ifTrue: [ 
	messagesWithSentVars := ( method ast body allChildren select: [:n | n isMessage and: [ n selector = accessorSelector ] ]).
	variablesTable := context trackVariables: messagesWithSentVars.
	"variablesTable add: (context trackVariable: 'self')." 
	workList := context extendWorkinglist: method.

	"	self addCurrentMethodReturnStatus: true."

	currentTrackVarsTable := variablesTable.
	self context: self removeFirstCtx.
	1 halt.
	[
	self context isNotNil and: [
		(next := context currentMethod) isNotNil ] ] whileTrue: [
		self reduceTrackNodesInContext.
		self checkContexStillTracksAnyVar
			ifTrue: [
				(self isMethodTreated: next)
					ifTrue: [
						"(self retrieveHistoryOf: next given: self currentTrackedVars)
							ifFalse: ["
								self analyzeMethod: next.
								eaHistory addHistory: self context for: next "]" ]
					ifFalse: [
						self analyzeMethod: next.
						eaHistory addHistory: self context for: next ].

				ctxListLog add: self context ]
			ifFalse: [ "here is the point the debug the context is not treated"
			 ].
		self context: self removeFirstCtx.

		" create a test with two calls for the same method implementeed once , with different tracking statuses for each argument at a time "
		topLevel := false ].

	self addStat: ctxCounter copy of: method.

	self context: savedFirstCtxRef
	]
]

{ #category : 'testing' }
EscapeAnalyzerAccessorVisitor >> findVariableByName: anAccessorMessageNode [

	anAccessorMessageNode isMessage ifFalse: [ ^ nil ].
	^ context findVariableByName: anAccessorMessageNode asString
]

{ #category : 'testing' }
EscapeAnalyzerAccessorVisitor >> trackVariable: anAccessorMessage [

	(anAccessorMessage isMessage and:[ anAccessorMessage isUnary ]) ifTrue: [
		^ context trackVariable: anAccessorMessage selector ].
	(self isTrackedNode: anAccessorMessage selector) ifTrue: [ ^ context findVariableByName: anAccessorMessage selector ] ifFalse: [ ^ nil ].

	
]

{ #category : 'visiting' }
EscapeAnalyzerAccessorVisitor >> visitMessageNode: aMessageNode [

	| implementors nodesToTreat listOfNewTrackedVariableTables followTheseNodes |
	
	
	self flag:
		' check nodes states before stacking a method to the worklist'.
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { aMessageNode receiver } , aMessageNode arguments.
	
	self reduceAssignments: nodesToTreat.
	  iVarEscapeVisitor mainVisitor . 
	implementors  := self implementorsOfAstMessage: aMessageNode.
	listOfNewTrackedVariableTables := OrderedCollection new.
	followTheseNodes := self selectFollowedAstNodes: nodesToTreat.
	followTheseNodes isNotEmpty ifTrue: [
		(self isSpecialMethod: aMessageNode selector)
			ifFalse: [
				(self shouldConsiderImplementors: implementors)
					ifTrue: [
						self
							updateReturnFlagAndWorklistOfMessage: aMessageNode
							with: implementors
							andNodes: nodesToTreat 
							]
					ifFalse: [
						(nodesToTreat select: [ :n |
							 (self findVariableByName: n) isNotNil ]) do: [ :node |
							self markVariableAsEscaped: node ] ] ]
			ifTrue: [
				aMessageNode selector = #value ifTrue: [
					self markVariableAsEscaped: aMessageNode receiver ] ] ].

	aMessageNode children do: [ :node | node acceptVisitor: self ]
]
