Class {
	#name : 'ObjectInlining',
	#superclass : 'Object',
	#instVars : [
		'escapeAnalyzer',
		'objectInlineCandidates'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'adding' }
ObjectInlining >> addOIcandidate: anAssignmentNode [

	objectInlineCandidates add: anAssignmentNode .
]

{ #category : 'as yet unclassified' }
ObjectInlining >> initialize [

	escapeAnalyzer := EscapeAnalyzer new.
	objectInlineCandidates := OrderedCollection new
]

{ #category : 'as yet unclassified' }
ObjectInlining >> lookForNewStatementsNotEscaped: aMethod [

	escapeAnalyzer escapeAnalyze: aMethod.
	escapeAnalyzer variablesTable keysAndValuesDo: [ :key :value |
		(value isMemberOf: False) ifTrue: [
			aMethod ast body assignmentNodes do: [ :node |
				(node references: key) ifTrue: [
					(node parent isAssignment and: [ node parent value selector = #new ])
						ifTrue: [ self addOIcandidate: node parent ] ] ] ] ]
]

{ #category : 'parsing' }
ObjectInlining >> parseAllMethodsInPackage [

	| packages methods dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.
	packages := PackageOrganizer default packages select: [ :e |
		            e name = 'EscapeAnalysisXP' ].

	methods := packages flatCollect: #methods.
	methods:= FixtureEscapeAnalysis methods select:[:e | ( e selector = #callMethodWithDifferentArgNameTwoLevelIndirection) or: ((e selector = #foo:) or: (e selector = #fooCandidateIO:))].
	methods do: [ :m |
		self lookForNewStatementsNotEscaped: m.
		dictionaryOIcandidatesPerMethod at: m put: objectInlineCandidates.
		objectInlineCandidates := OrderedCollection new ].

	^ dictionaryOIcandidatesPerMethod
]
