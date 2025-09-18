Class {
	#name : 'DeoptimizeInlining',
	#superclass : 'Object',
	#instVars : [
		'cmOriginalASTs'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'initialization' }
DeoptimizeInlining >> initialize [

	cmOriginalASTs := Dictionary new
]

{ #category : 'as yet unclassified' }
DeoptimizeInlining >> saveOriginalAst: aCompiledMethod [

	cmOriginalASTs at: aCompiledMethod  ifAbsentPut: aCompiledMethod ast.
	
]
