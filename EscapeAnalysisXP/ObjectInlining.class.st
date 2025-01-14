Class {
	#name : 'ObjectInlining',
	#superclass : 'Object',
	#instVars : [
		'escapeAnalyzer',
		'objectInlineCandidates',
		'deoptimizer'
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
	objectInlineCandidates := OrderedCollection new.
	deoptimizer := DeoptimizeInlining new
]

{ #category : 'tests' }
ObjectInlining >> inlineCandidateObjects: inliningCandidates in: aCompiledMethod [

	| astClone inlinedObject astCloneChildren |
	astClone := aCompiledMethod ast copy.
	astCloneChildren := astClone allChildren.
	inliningCandidates do: [ :candidate |
		(astCloneChildren select: [ :e | e = candidate ]) do: [ :aCandidate |
			
			aCandidate value isMessage ifTrue: [
				| inlinedObjectClass|
				inlinedObjectClass := (SmalltalkImage current globals at: inlinedObject value name asSymbol).
				inlinedObject := aCandidate value receiver.
				self mergeMethodsOfContainedObjectClass: inlinedObjectClass   inContainer: aCompiledMethod classBinding value .
				self renameInlinedMessages: inlinedObjectClass in: astClone.
				 ].
			
			aCandidate value replaceWith: (ASTVariableNode named: 'self') ].

		astClone selector: #inlined , astClone selector ].

	FixtureEscapeAnalysis compile: astClone asString
]

{ #category : 'tests' }
ObjectInlining >> inlineRefactorCandidateObjects: inliningCandidates in: aCompiledMethod [

	| astClone inlinedObject astCloneChildren |
	astClone := aCompiledMethod ast copy.
	astCloneChildren := astClone allChildren.
	inliningCandidates do: [ :candidate |
		| inlinedObjectClass |
		inlinedObjectClass := SmalltalkImage current globals at:
			                      candidate key value receiver name.
		(astCloneChildren select: [ :e | e = candidate key ]) do: [
			:aCandidate |
			1 halt.
			aCandidate value isMessage ifTrue: [
				self
					mergeMethodsOfContainedObjectClass: inlinedObjectClass
					inContainer: aCompiledMethod classBinding value
					tv: candidate value ].

			aCandidate value replaceWith: (ASTVariableNode named: 'self') ].
		self
			renamecallSitesOfAst: astClone
			withReceiverVariable: candidate value
			inlinedTo: inlinedObjectClass
			in: aCompiledMethod classBinding value name  ].
	astClone selector: #inlined , astClone selector.

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

{ #category : 'as yet unclassified' }
ObjectInlining >> mergeMethodsOfContainedObjectClass: inlinedObject inContainer: aCompiledMethod [

	| containerClass contextOfMethod|
	containerClass := aCompiledMethod .
	inlinedObject methods do: [ :singleMethod |
		| copyAst rewriter contextHistory |
		copyAst := singleMethod ast copy.
		copyAst selector:
			#inlined_ , inlinedObject name , #_ , singleMethod selector.

		copyAst instanceVariableNodes do: [ :instVar |
			| newInstanceVarName |
			newInstanceVarName := self
				                      prefixInlinedObject: inlinedObject name
				                      to: instVar name.
			rewriter := RBParseTreeRewriter new.
			rewriter replace: instVar name with: newInstanceVarName.
			rewriter executeTree: copyAst.
			(containerClass hasInstVarNamed: newInstanceVarName) ifFalse: [
				containerClass addInstVarNamed: newInstanceVarName ] ].
		
"		(contextOfMethod :=  escapeAnalyzer restituteContextOf: singleMethod ) isNotNil ifTrue:[
			contextOfMethod trackedMethodArgs select: [ :argVariable | argVariable referencesTrackedVariable:   argVariable  ].
			 ]."
		containerClass compile: copyAst newSource ].

]

{ #category : 'as yet unclassified' }
ObjectInlining >> mergeMethodsOfContainedObjectClass: inlinedObject inContainer: aCompiledMethod tv: aTrackedVariable [

	| containerClass contextOfMethod methods |

	containerClass := aCompiledMethod.
	methods := inlinedObject methods asOrderedCollection.
	methods addAll: inlinedObject class methods.
	( methods ) do: [ :singleMethod |
		| copyAst rewriter contextHistory |
		copyAst := singleMethod ast copy.
		copyAst selector:
			#inlined_ , inlinedObject name , #_ , singleMethod selector.

		copyAst instanceVariableNodes do: [ :instVar |
			| newInstanceVarName |
			newInstanceVarName := self
				                      prefixInlinedObject: inlinedObject name
				                      to: instVar name.
			rewriter := RBParseTreeRewriter new.
			rewriter replace: instVar name with: newInstanceVarName.
			rewriter executeTree: copyAst.
			(containerClass hasInstVarNamed: newInstanceVarName) ifFalse: [
				containerClass addInstVarNamed: newInstanceVarName ] ].

		(contextOfMethod := escapeAnalyzer history restituteContextOf: singleMethod)
			isNotNil ifTrue: [
			(contextOfMethod trackedMethodArgs select: [ :argVariable |
				 argVariable referencesTrackedVariable: aTrackedVariable ]) do: [
				:trackedV |
				| messageSendNodes |
				self
					renamecallSitesOfAst: copyAst
					withReceiverVariable: trackedV
					inlinedTo: inlinedObject 
					in: containerClass name.
					] ].

		containerClass compile: copyAst newSource ]
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

{ #category : 'as yet unclassified' }
ObjectInlining >> prefixInlinedObject: className to: aName [

	^ #inlined_ , className , #_ , aName
]

{ #category : 'tests' }
ObjectInlining >> refactorCandidateObjectsNames: inliningCandidates in: aCompiledMethod [

	| astClone inlinedObject |
	astClone := aCompiledMethod ast copy.
	inliningCandidates do: [ :candidate |
		(astClone allChildren select: [ :e | e = candidate ]) do: [
			:aCandidate |
			aCandidate value isMessage ifTrue: [
				inlinedObject := aCandidate value receiver ].
		
			aCandidate value replaceWith: (ASTVariableNode named: 'self') ].

		astClone selector: #inlined , astClone selector ].
	aCompiledMethod classBinding value  compile: astClone asString
]

{ #category : 'as yet unclassified' }
ObjectInlining >> refactorOccurencesOf: trackedVariables [

	| astClone inlinedObject |
	trackedVariables do: [ :tv |
		astClone := tv associatedMethod ast copy.

		tv name = #self ifFalse: [
			self saveOriginalAst: tv associatedMethod.
			astClone := tv associatedMethod ast copy.


			(astClone allChildren select: [ :e | e name = tv name ]) do: [
				:aCandidate |
				aCandidate replaceWith: (ASTVariableNode named: 'self').
				self refactorOccurencesOf: aCandidate trackedVarsReferencingSelf ].

			tv associatedMethod classBinding value compile: astClone asString ] ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> renamecallSitesOfAst: copyAst withReceiverVariable: trackedV inlinedTo: inlinedObject [

	^ (Set newFrom: (copyAst body allChildren select: [ :e |
			    e isMessage and: [ e receiver name = trackedV name ] ])) do: [
		  :messageNode |
		  | inlinedMessageCall conditionalClassBranch |
		  1 halt.
		  inlinedMessageCall := messageNode copy selector:
			                        (self
				                         prefixInlinedObject: inlinedObject name
				                         to: messageNode selector).
		  conditionalClassBranch := ASTMessageNode
			                            receiver: messageNode receiver
			                            selector: #class.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #name.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #'=='
			                            arguments:
			                            { (ASTLiteralValueNode value:
				                             inlinedObject name) }.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #ifTrue:
			                            arguments:
				                            { (ASTBlockNode body:
					                             (ASTSequenceNode statements:
						                              (OrderedCollection with:
							                               inlinedMessageCall))) }.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #ifFalse:
			                            arguments: { (ASTBlockNode body:
					                             (ASTSequenceNode statements:
						                              (OrderedCollection with:
							                               messageNode))) }.
		  messageNode replaceWith: conditionalClassBranch ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> renamecallSitesOfAst: copyAst withReceiverVariable: trackedV inlinedTo: inlinedObject in: containerClassName [

	^ (Set newFrom: (copyAst body allChildren select: [ :e |
			    e isMessage and: [ e receiver name = trackedV name ] ])) do: [
		  :messageNode |
		  | inlinedMessageCall conditionalClassBranch |
		  inlinedMessageCall := messageNode copy selector:
			                        (self
				                         prefixInlinedObject: inlinedObject name
				                         to: messageNode selector).
		  conditionalClassBranch := ASTMessageNode
			                            receiver: messageNode receiver
			                            selector: #class.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #name.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #'=='
			                            arguments:
			                            { (ASTLiteralValueNode value:
				                             containerClassName) }.
		  conditionalClassBranch := ASTMessageNode
			                            receiver: conditionalClassBranch
			                            selector: #ifTrue:ifFalse:
			                            arguments: (OrderedCollection
					                             with:
						                             (ASTBlockNode body:
							                              (ASTSequenceNode statements:
								                               (OrderedCollection with:
									                                inlinedMessageCall)))
					                             with: (ASTBlockNode body:
							                              (ASTSequenceNode statements:
								                               (OrderedCollection with:
									                                messageNode)))).
		  1 halt.
		  messageNode replaceWith: conditionalClassBranch ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> saveOriginalAst: aCompiledMethod [

	deoptimizer saveOriginalAst: aCompiledMethod
]
