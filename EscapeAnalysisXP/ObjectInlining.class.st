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

	escapeAnalyzer := EscapeAnalyzerVisitor new.
	escapeAnalyzer allowedDepth: 6.
	objectInlineCandidates := OrderedCollection new
]

{ #category : 'as yet unclassified' }
ObjectInlining >> lookForNonEscapingNewStatements: aMethod [

	| methodAssignmentNodes |
	self initialize.
	escapeAnalyzer escapeAnalyze: aMethod.
	methodAssignmentNodes := aMethod ast body assignmentNodes.
	escapeAnalyzer getNonEscapingVariables do: [ :nonEscapingNode |
		methodAssignmentNodes do: [ :assignemntNode |
			((assignemntNode references: nonEscapingNode name) and: [
				 assignemntNode value isMessage
	ifTrue: [ assignemntNode value selector = #new ]
	ifFalse: [ false ] ]) ifTrue: [
				self addOIcandidate: assignemntNode ] ] ]
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
		self lookForNonEscapingNewStatements: m.
		dictionaryOIcandidatesPerMethod at: m put: objectInlineCandidates.
		objectInlineCandidates := OrderedCollection new ].

	^ dictionaryOIcandidatesPerMethod
]
