Class {
	#name : 'ObjectInlining',
	#superclass : 'Object',
	#instVars : [
		'escapeAnalyzer',
		'objectInlineCandidates',
		'deoptimizer',
		'renamingVisitor'
	],
	#category : 'EscapeAnalysisXP-testInlining',
	#package : 'EscapeAnalysisXP',
	#tag : 'testInlining'
}

{ #category : 'as yet unclassified' }
ObjectInlining class >> detectFalsePositives [

	<script: 'self detectFalsePositives'>
	
	| results |
	
	results := OrderedCollection new.
	results inspect
]

{ #category : 'as yet unclassified' }
ObjectInlining class >> getNewSendsAssignmentsFor: methodAst [

	^ methodAst sendNodes select: [ :m |
			  m selector = #new and: [
				  m parent isNotNil and: [ m parent isAssignment ] ] ]
]

{ #category : 'accessing' }
ObjectInlining class >> replaceNewNodesWithObject: sendNodes in: method [

	| rewriter |
	rewriter := RBParseTreeRewriter new.

	"Rewriting the method AST"
	sendNodes collect: [ :n |
			n value receiver isGlobalVariable ifTrue: [
					rewriter replaceTree: n withTree: (RBLiteralValueNode value:
							 (method compiler evaluate: n value sourceCode)) ] ]
]

{ #category : 'accessing' }
ObjectInlining class >> transform: method [

	| rewriter methodAst sendNodes newMethod |
	"Arguments"
	methodAst := method parseTree.

	"Collecting new nodes"
	sendNodes := self getNewSendsAssignmentsFor: methodAst.


	"Replacing new nodes with objects"
	self replaceNewNodesWithObject: sendNodes in: method.

	"Compiles the new method"
	newMethod := methodAst generateMethod.

	"Installs the newly compiled method in its class of origin"
	^ newMethod
]

{ #category : 'accessing' }
ObjectInlining class >> transform: method withGivenNewNodes: newNodes [

	| rewriter methodAst sendNodes newMethod |
	"Arguments"
	methodAst := method parseTree.

	"Collecting new nodes"
	sendNodes := newNodes.


	"Replacing new nodes with objects"
	self replaceNewNodesWithObject: sendNodes in: method.

	"Compiles the new method"
	newMethod := methodAst generateMethod.

	"Installs the newly compiled method in its class of origin"
	^ newMethod
]

{ #category : 'adding' }
ObjectInlining >> addOIcandidate: anAssignmentNode [

	objectInlineCandidates add: anAssignmentNode .
]

{ #category : 'as yet unclassified' }
ObjectInlining >> allmessagesOf: copyAst havingArg: trackedV [

	^ Set newFrom: (copyAst body allChildren select: [ :e |
			   | args |
			   e isMessage
				   ifTrue: [
					   args := OrderedCollection withAll: e arguments.
					   args add: e receiver.
					   args anySatisfy: [ :e |
						   e isVariable and: [ e name = trackedV name ] ] ]
				   ifFalse: [ false ] ])
]

{ #category : 'accessing' }
ObjectInlining >> allowedDepth: aNumber [

	escapeAnalyzer allowedDepth: aNumber
]

{ #category : 'as yet unclassified' }
ObjectInlining >> allowedWorklistSize: aSize [

	escapeAnalyzer setWorklistLimitation: aSize 
]

{ #category : 'as yet unclassified' }
ObjectInlining >> argsOfContext: contextOfMethod referencing: aTrackedVariable [

	^ contextOfMethod trackedMethodArgs select: [ :argVariable |
		  argVariable referencesTrackedVariable: aTrackedVariable ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> assignObjectCreatedInlineToTmp: method [
1 halt.
	method ast 
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

{ #category : 'parsing' }
ObjectInlining >> findCandidatesOfSet: aMethods [

	| dictionaryOIcandidatesPerMethod |
	dictionaryOIcandidatesPerMethod := Dictionary new.
	aMethods do: [ :aMethod |
		self lookForNonEscapingNewStatements: aMethod.
		dictionaryOIcandidatesPerMethod at: aMethod put: objectInlineCandidates copy.
	escapeAnalyzer reset.
			 ].
		^ dictionaryOIcandidatesPerMethod
]

{ #category : 'as yet unclassified' }
ObjectInlining >> findEnclosingStatementNodeFor: aNode [

	| statementNode sequenceNode |
	statementNode := aNode.

	[ statementNode parent isSequence not ] whileTrue: [
		statementNode := statementNode parent ].

	^ statementNode
]

{ #category : 'as yet unclassified' }
ObjectInlining >> initialize [

	escapeAnalyzer := EscapeAnalyzerVisitor new.
	escapeAnalyzer allowedDepth: 8.
	objectInlineCandidates := OrderedCollection new.
	deoptimizer := DeoptimizeInlining new.
	renamingVisitor := ASTCodeRefactoringVisitor new.
]

{ #category : 'tests' }
ObjectInlining >> inlineRefactorCandidateObject: aSingleCandidate in: aCompiledMethod [

	| astClone astCloneChildren inlinedObjectClass |
	astClone := aCompiledMethod ast copy.
	astCloneChildren := astClone allChildren.

	inlinedObjectClass := SmalltalkImage current globals at: aSingleCandidate key value receiver name.

	(astCloneChildren select: [ :e | e = aSingleCandidate key ]) do: [ :aCandidate |

		aCandidate value isMessage ifTrue: [
			self
				mergeMethodsOfContainedObjectClass: inlinedObjectClass
				inContainer: aCompiledMethod classBinding value
				tv: aSingleCandidate value ].
			aCandidate value replaceWith: (ASTVariableNode named: 'self') 
	].

	self
		renamecallSitesOfAst: astClone
		withArgument: aSingleCandidate value
		inlinedTo: inlinedObjectClass
		in: aCompiledMethod classBinding value .
			
	astClone selector: #inlined , astClone selector.
	FixtureEscapeAnalysis compile: astClone asString

]

{ #category : 'tests' }
ObjectInlining >> inlineRefactorCandidateObjects: aListOfCandidateAssociation in: aCompiledMethod [

	| astClone inlinedObject astCloneChildren |
	astClone := aCompiledMethod ast copy.
	astCloneChildren := astClone allChildren.
	aListOfCandidateAssociation do: [ :candidate |
		| inlinedObjectClass |
		inlinedObjectClass := SmalltalkImage current globals at:
			                      candidate key value receiver name.
		(astCloneChildren select: [ :e | e = candidate key ]) do: [
			:aCandidate |

			aCandidate value isMessage ifTrue: [
				self
					mergeMethodsOfContainedObjectClass: inlinedObjectClass
					inContainer: aCompiledMethod classBinding value
					tv: candidate value ].

			aCandidate value replaceWith: (ASTVariableNode named: 'self') ].

		self
			renamecallSitesOfAst: astClone
			withArgument: candidate value
			inlinedTo: inlinedObjectClass
			in: aCompiledMethod classBinding value  ].
	astClone selector: #inlined , astClone selector.
	FixtureEscapeAnalysis compile: astClone asString


	"aListOfCandidateAssociation do: [:candidate |
		| classOfObjectToInline |
		classOfObjectToInline := SmalltalkImage current globals at: aListOfCandidateAssociation key value receiver name.

		self inlineRefactorClass: classOfObjectToInline withCandidate: candidate in: aCompiledMethod 	
	]."

]

{ #category : 'tests' }
ObjectInlining >> inlineRefactorCandidateObjectsUsingVisitor: inliningCandidates in: aCompiledMethod [

	| astClone inlinedObject astCloneChildren |
	astClone := aCompiledMethod ast copy.


	renamingVisitor
		renamecallSitesOfAst: astClone
		withArgument: inliningCandidates
		inside: aCompiledMethod classBinding value.
	astClone selector: #inlined , astClone selector.
	FixtureEscapeAnalysis compile: astClone asString
]

{ #category : 'tests' }
ObjectInlining >> inlineRefactorClass: aInlinedObjectClass withCandidate: aSingleCandidate in: aCompiledMethod [

	| astClone astCloneChildren |
	astClone := aCompiledMethod ast copy.
	astCloneChildren := astClone allChildren.
	
	(astCloneChildren select: [ :e | e = aSingleCandidate key ]) do: [ :aCandidate |

		aCandidate value isMessage ifTrue: [
			self
				mergeMethodsOfContainedObjectClass: aInlinedObjectClass
				inContainer: aCompiledMethod classBinding value
				tv: aSingleCandidate value ].
			aCandidate value replaceWith: (ASTVariableNode named: 'self') 
	].

	self
		renamecallSitesOfAst: astClone
		withArgument: aSingleCandidate value
		inlinedTo: aInlinedObjectClass
		in: aCompiledMethod classBinding value .
			
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
	objectInlineCandidates := OrderedCollection new.
	escapeAnalyzer escapeAnalyze: aMethod.
	escapeAnalyzer resetContxtCounterForCurrentMethod.

	methodAssignmentNodes := aMethod ast body assignmentNodes.
	escapeAnalyzer getNonEscapingVariables do: [ :nonEscapingNode |
			methodAssignmentNodes do: [ :assignemntNode |
					((assignemntNode references:
						  (escapeAnalyzer unravelLocalName: nonEscapingNode name)) and: [
							 assignemntNode value isMessage
								 ifTrue: [ assignemntNode value selector includesSubstring: #new ]
								 ifFalse: [ false ] ]) ifTrue: [
						self addOIcandidate: assignemntNode ] ] ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> mergeMethod: singleMethod of: inlinedObject in: containerClass tv: aTrackedVariable [

	| copyAst contextOfMethod rewriter |
	copyAst := singleMethod ast copy.
	
	copyAst selector:
		#inlined_ , inlinedObject name , #_ , singleMethod selector.
	copyAst instanceVariableNodes do: [ :instVar |
		| newInstanceVarName |
		newInstanceVarName := self
			                      prefixInlinedObject: inlinedObject name
			                      to: instVar name.
	
		rewriter := ASTParseTreeRewriter new.
		rewriter replace: instVar name with: newInstanceVarName.
		rewriter executeTree: copyAst.
		(containerClass hasInstVarNamed: newInstanceVarName) ifFalse: [
			containerClass addInstVarNamed: newInstanceVarName ] ].
	(contextOfMethod := escapeAnalyzer history restituteContextOf:
		                    singleMethod) isNotNil ifTrue: [
		(self argsOfContext: contextOfMethod referencing: aTrackedVariable )
			do: [ :trackedV |
				"1 haltIf:(( singleMethod== (LineInlined class  >> #p1:p2: )) or:[ singleMethod== (FixtureEscapeAnalysis  >> #inlined_LineInlined_p1:p2:)] )."
				self renamecallSitesOfAst: copyAst withArgument: trackedV inlinedTo: inlinedObject in: containerClass.
				 ] ].
	^ containerClass compile: copyAst newSource
]

{ #category : 'as yet unclassified' }
ObjectInlining >> mergeMethods: methods of: inlinedObject in: containerClass tv: aTrackedVariable [

	^ methods do: [ :singleMethod |
		  self
			  mergeMethod: singleMethod
			  of: inlinedObject
			  in: containerClass
			  tv: aTrackedVariable ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> mergeMethodsOfContainedObjectClass: inlinedObject inContainer: containerClass tv: aTrackedVariable [

	|  methods |
	
	methods := inlinedObject methods asOrderedCollection.
	methods addAll: inlinedObject class methods.
	self
		mergeMethods: methods 
		of:inlinedObject 
		in: containerClass
		tv: aTrackedVariable
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

{ #category : 'renaming' }
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
ObjectInlining >> renamecallSitesOfAst: copyAst withArgument: trackedV inlinedTo: inlinedObject in: containerClassName [

	^ (self allmessagesOf: copyAst havingArg: trackedV) do: [
		  :messageNode |
		  | inlinedMessageCall conditionalClassBranch enclosingMessageNode |
		  enclosingMessageNode := messageNode.
		  inlinedMessageCall := messageNode copy selector:
			                        (self
				                         prefixInlinedObject: inlinedObject name
				                         to: messageNode selector).
		  messageNode receiver isGlobalVariable
			  ifTrue: [
				  | otherClassToInline |
				  otherClassToInline := SmalltalkImage current globals at:
					                        messageNode receiver name.
				  conditionalClassBranch := messageNode copy selector: (self
						                             prefixInlinedObject:
						                             messageNode receiver name
						                             to: messageNode selector).
				  conditionalClassBranch receiver: (ASTVariableNode named: 'self').

				  self
					  mergeMethod:
					  (otherClassToInline classSide compiledMethodAt:
						   messageNode selector)
					  of: otherClassToInline
					  in: containerClassName
					  tv: trackedV.
				  messageNode parent
					  replaceNode: messageNode
					  withNode: conditionalClassBranch ]
			  ifFalse: [
				  | enclosingMessageNodeParentCopy rewritingParser |
				(messageNode receiver name == trackedV name) ifTrue: [ 
			|possibleRuntimeTypesOfTV|
			possibleRuntimeTypesOfTV := (containerClassName methods collect: #selector) select: [ :s | (s beginsWith: 'inlined') and: [s endsWith: messageNode selector ]  ].
			inlinedMessageCall selector: possibleRuntimeTypesOfTV first.
			].
		
				  enclosingMessageNode := self findEnclosingStatementNodeFor:
					                          messageNode.
				  enclosingMessageNodeParentCopy := enclosingMessageNode copy.
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
						                             containerClassName name) }.

				  rewritingParser := ASTParseTreeRewriter new.
				  rewritingParser
					  replaceTree: messageNode
					  withTree: inlinedMessageCall.
				  rewritingParser executeTree: enclosingMessageNode.
				  enclosingMessageNode parent
					  replaceNode: messageNode
					  withNode: inlinedMessageCall.
				  conditionalClassBranch := ASTMessageNode
					                            receiver: conditionalClassBranch
					                            selector: #ifTrue:ifFalse:
					                            arguments: (OrderedCollection
							                             with:
								                             (ASTBlockNode body:
									                              (ASTSequenceNode statements:
										                               (OrderedCollection with:
											                                enclosingMessageNode)))
							                             with:
								                             (ASTBlockNode body:
									                              (ASTSequenceNode statements:
										                               (OrderedCollection with:
											                                enclosingMessageNodeParentCopy)))).


				  copyAst body
					  replaceNode: enclosingMessageNode
					  withNode: conditionalClassBranch ] ]
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
		  copyAst body replaceNode: messageNode withNode: conditionalClassBranch.
		 ]
]

{ #category : 'as yet unclassified' }
ObjectInlining >> saveOriginalAst: aCompiledMethod [

	deoptimizer saveOriginalAst: aCompiledMethod
]
