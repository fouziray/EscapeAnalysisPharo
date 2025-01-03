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

{ #category : 'accessing' }
ObjectInlining >> allowedDepth: aNumber [

	escapeAnalyzer allowedDepth: aNumber
]

{ #category : 'accessing' }
ObjectInlining >> escapeAnalyzer [

	^ escapeAnalyzer
]

{ #category : 'parsing' }
ObjectInlining >> findCandidatesOf: aMethod [

	| dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.
	self lookForNonEscapingNewStatements: aMethod.
	^ objectInlineCandidates
]

{ #category : 'as yet unclassified' }
ObjectInlining >> initialize [

	escapeAnalyzer := EscapeAnalyzerVisitor new.
	escapeAnalyzer allowedDepth: 8.
	objectInlineCandidates := OrderedCollection new
]

{ #category : 'tests' }
ObjectInlining >> inlineCandidateObjects: inliningCandidates in: aCompiledMethod [

	| astClone inlinedObject |
	astClone := aCompiledMethod ast copy.
	inliningCandidates do: [ :candidate |
		(astClone allChildren select: [ :e | e = candidate ]) do: [
			:aCandidate |
			aCandidate value isMessage ifTrue: [
				inlinedObject := aCandidate value receiver ].
		
			aCandidate value replaceWith: (ASTVariableNode named: 'self') ].

		astClone selector: #inlined , astClone selector ].

	FixtureEscapeAnalysis compile: astClone asString
]

{ #category : 'testing' }
ObjectInlining >> isAssignedTwice: aVariableName in: aMethod [

	| precondition |
	precondition := ReSingleAssignmentCondition new.
	precondition
		variableName: aVariableName;
		definingNode: aMethod ast.
	^ precondition check
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
	self allowedDepth: 1.
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

{ #category : 'parsing' }
ObjectInlining >> parseAllMethodsInPackage: name [

	| packages methods dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.
	self allowedDepth: 1.
	packages := PackageOrganizer default packages select: [ :e |
		            e name = name ].

	methods := packages flatCollect: #methods.
	
	methods do: [ :m |
		self lookForNonEscapingNewStatements: m.
		dictionaryOIcandidatesPerMethod at: m put: objectInlineCandidates.
		objectInlineCandidates := OrderedCollection new ].

	^ dictionaryOIcandidatesPerMethod
]

{ #category : 'parsing' }
ObjectInlining >> parseAllMethodsOfHoneyGinger [

	| packages methods dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.

	methods := HGSimulator class methods.
	methods do: [ :m |
		self lookForNonEscapingNewStatements: m.
		dictionaryOIcandidatesPerMethod at: m put: objectInlineCandidates.
		objectInlineCandidates := OrderedCollection new ].

	^ dictionaryOIcandidatesPerMethod
]

{ #category : 'parsing' }
ObjectInlining >> parseOneMethodsOfHoneyGinger [

	| packages methods dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.
escapeAnalyzer allowedDepth: 50.
	
	methods := HGSimulator class >>#steampaint .
		self lookForNonEscapingNewStatements: methods.
		dictionaryOIcandidatesPerMethod at: methods put: objectInlineCandidates.
		objectInlineCandidates := OrderedCollection new .

	^ dictionaryOIcandidatesPerMethod
]
