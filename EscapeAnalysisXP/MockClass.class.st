Class {
	#name : 'MockClass',
	#superclass : 'Object',
	#category : 'EscapeAnalysisXP-MockObject',
	#package : 'EscapeAnalysisXP',
	#tag : 'MockObject'
}

{ #category : 'as yet unclassified' }
MockClass >> aMethodUsesSelfInBLock [

	| temp1 temp2 temp3 |
	temp2 := 1.
	temp3 := 4.
	temp1 := [
	         | temp2 |
	         temp2 := 1 + 1.
	         temp2 := temp3.
	         temp3 ].
	self returnBlockWithVariable: [ :e | e ].
	temp3 := 3.
	^ temp1 value
]

{ #category : 'as yet unclassified' }
MockClass >> aMethodUsesSelfInBLockMessage [

	|temp1 temp2 temp3 |
	temp2:=1.
	temp3:= 4.
	temp1:= self returnBlockWithVariable: temp3.
	temp3:= 3.
	^temp1 value.
]

{ #category : 'as yet unclassified' }
MockClass >> returnBlockWithVariable: tmp [


^ [ | temp2 |
		temp2:=	1+1.
		temp2:= tmp.	
		tmp.
		  ].

]

{ #category : 'as yet unclassified' }
MockClass >> twoBlocksWithSameCode [

	| a b tmp |
	tmp := 1.
	a := [ ^ tmp ].
	b := [ ^ tmp ]
]
