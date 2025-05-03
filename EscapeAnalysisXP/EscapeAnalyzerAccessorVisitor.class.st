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

	| next tempVariables currentTrackVarsTable |
	
	topLevel := true.
	context associatedMethod: method.
	( method ast body
			                sentMessages includesAny: accessorSelector ) ifFalse: [ ^ self ] ifTrue: [ 
				1 halt.
	variablesTable := context trackVariables:
		                  ( method ast body allChildren select: [:n | n isMessage and: [ n selector = accessorSelector ] ]) .
	"variablesTable add: (context trackVariable: 'self')."
	workList := context extendWorkinglist: method.

	"	self addCurrentMethodReturnStatus: true."

	currentTrackVarsTable := variablesTable.
	self context: self removeFirstCtx.
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
	^ context findVariableByName: anAccessorMessageNode selector
]

{ #category : 'testing' }
EscapeAnalyzerAccessorVisitor >> trackVariable: anAccessorMessage [

	(anAccessorMessage isMessage and:[ anAccessorMessage isUnary ]) ifTrue: [
		^ context trackVariable: anAccessorMessage selector ].
	(self isTrackedNode: anAccessorMessage selector) ifTrue: [ ^ context findVariableByName: anAccessorMessage selector ] ifFalse: [ ^ nil ].

	
]
