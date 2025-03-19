Extension { #name : 'OCProgramNode' }

{ #category : '*EscapeAnalysisXP' }
OCProgramNode >> allTemporaryVariablesButOnesInBlocks [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into:
			[:vars :each |
			each isBlock ifFalse: [ vars ] ifTrue: [ vars addAll: each allTemporaryVariables;
				yourself. ].
			
				"self haltIf: each allTemporaryVariables first = #parents ."
				]
]
