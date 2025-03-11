Class {
	#name : 'FixtureEscapeAnalysisEvilTwin',
	#superclass : 'FixtureEscapeAnalysis',
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'nested calls' }
FixtureEscapeAnalysisEvilTwin >> localMessage: agr [

	self fooSetterToGlobal: agr
]

{ #category : 'nested calls' }
FixtureEscapeAnalysisEvilTwin >> receiverMessage [
]

{ #category : 'nested calls' }
FixtureEscapeAnalysisEvilTwin >> twoImplementationMethods [
]
