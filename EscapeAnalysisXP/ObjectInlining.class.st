Class {
	#name : 'ObjectInlining',
	#superclass : 'Object',
	#instVars : [
		'escapeAnalyzer',
		'objectInlineCandidates'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'adding' }
ObjectInlining >> addOIcandidate: anAssignmentNode [

	objectInlineCandidates add: anAssignmentNode .
]

{ #category : 'as yet unclassified' }
ObjectInlining >> initialize [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer setWorkListReturnStatus: OrderedCollection new.
	objectInlineCandidates := OrderedCollection new
]

{ #category : 'as yet unclassified' }
ObjectInlining >> lookForNewStatementsNotEscaped: aMethod [

	self initialize.
	escapeAnalyzer escapeAnalyze: aMethod.
	escapeAnalyzer variablesTable keysAndValuesDo: [ :key :value |
		(value isMemberOf: False) ifTrue: [
			aMethod ast body assignmentNodes do: [ :node |
				((node references: key) and: [ node value isMessage ]) ifTrue: [
					node value selector = #new ifTrue: [ self addOIcandidate: node ] ] ] ] ]
]

{ #category : 'parsing' }
ObjectInlining >> parseAllCertainMethods [

	^ self 
]

{ #category : 'parsing' }
ObjectInlining >> parseAllMethodsInPackage [

	| packages methods dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.
	packages := PackageOrganizer default packages select: [ :e |
		            e name = 'EscapeAnalysisXP' ].

	methods := packages flatCollect: #methods.
	methods := FixtureEscapeAnalysis methods select: [ :e |
		           e selector
		           = #callMethodWithDifferentArgNameTwoLevelIndirection or:
			           (e selector = #foo: or: e selector = #fooCandidateIO:) ].
	methods := FixtureEscapeAnalysis methods.
	methods do: [ :m |
		self lookForNewStatementsNotEscaped: m.
		dictionaryOIcandidatesPerMethod at: m put: objectInlineCandidates.
		objectInlineCandidates := OrderedCollection new ].

	^ dictionaryOIcandidatesPerMethod
]
