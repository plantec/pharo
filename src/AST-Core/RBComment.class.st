"
A RBComment represents a text comment associated to an AST node.

A RBComment is not an AST-Node (not subclass of program node). But its instance are just wrapping the comment text and (start-) position.

Due to the way the parser handles comments, the RBComment is assigned to its preceding (real) AST node, although we often write the comment prior to a statement.

For example:

foo
""method comment""

self firstStatement.

""comment about the return""
^ self

The ""method comment"" is assigned to the method node, the ""comment about the return"" is assigned
to the ""self firstStatement"" node!

instance variables
	contents 	<String> the comment text
	start	<Number> (start-) position within the method source

"
Class {
	#name : #RBComment,
	#superclass : #Object,
	#instVars : [
		'contents',
		'start'
	],
	#category : #'AST-Core-Nodes'
}

{ #category : #'instance creation' }
RBComment class >> with: aString at: startPosition [
	^ self new
		with: aString at: startPosition;
		yourself. 
	
]

{ #category : #accessing }
RBComment >> contents [
	^ contents
]

{ #category : #printing }
RBComment >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' "'.
	aStream nextPutAll: contents.
	aStream nextPutAll: '" '.
]

{ #category : #accessing }
RBComment >> size [
	^ contents size + 2 "must take into account quotation marks"
]

{ #category : #accessing }
RBComment >> start [
	^ start.
]

{ #category : #accessing }
RBComment >> stop [
	^ start + self size - 1
]

{ #category : #'initialize-release' }
RBComment >> with: aString at: startPosition [
	start := startPosition.
	contents := aString.

]
