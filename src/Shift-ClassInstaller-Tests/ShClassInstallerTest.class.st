Class {
	#name : #ShClassInstallerTest,
	#superclass : #TestCase,
	#instVars : [
		'newClass',
		'superClass',
		'subClass',
		'newClass2',
		'superClass2'
	],
	#category : #'Shift-ClassInstaller-Tests'
}

{ #category : #'instance creation' }
ShClassInstallerTest >> newClass: className slots: slots [
	^ self newClass: className superclass: Object slots: slots.
]

{ #category : #'instance creation' }
ShClassInstallerTest >> newClass: className superclass: aSuperclass slots: slots [
	^ ShiftClassInstaller
		make: [ :builder | 
			builder
				name: className;
				superclass: aSuperclass;
				slots: slots;
				sharedVariables: '';
				sharedPools: '';
				category: 'Shift-ClassInstaller-Tests';
				copyClassSlotsFromExistingClass ]
]

{ #category : #running }
ShClassInstallerTest >> tearDown [
	newClass ifNotNil: #removeFromSystem.
	newClass2 ifNotNil: #removeFromSystem.

	subClass ifNotNil: #removeFromSystem.
	superClass ifNotNil: #removeFromSystem.
	superClass2 ifNotNil: #removeFromSystem.
	
	super tearDown.
]

{ #category : #tests }
ShClassInstallerTest >> testChangingHierarchy [

	"Testing that the changes in the superclasses are propagated to the subclasses"

	superClass := self newClass:#ShCITestClass1 slots:#().
	newClass := self newClass:#ShCITestClass2 superclass: superClass slots:#(aSlot).

	self assert: newClass classLayout slotScope parentScope equals: superClass classLayout slotScope.

	superClass2 := self newClass:#ShCITestClass0 slots:#(anotherSlot).
	superClass := self newClass:#ShCITestClass1 superclass: superClass2 slots:#().
	
	self assert: newClass classLayout slotScope parentScope equals: superClass classLayout slotScope.
	self assert: superClass classLayout slotScope parentScope equals: superClass2 classLayout slotScope.
	
	self assertCollection: (newClass allSlots collect: #name) hasSameElements: #(aSlot anotherSlot)

]

{ #category : #tests }
ShClassInstallerTest >> testChangingSuperclassInTheHierarchy [

	superClass := self newClass:#ShCITestClass slots:#(var1 var2).
	superClass2 := self newClass:#ShCITestClass2 slots:#().
	subClass := self newClass:#ShCISubTestClass superclass: superClass2 slots:#().

   superClass2 := self newClass:#ShCITestClass2 superclass: superClass slots:#().

	self deny: superClass subclasses isEmpty.
	self assertCollection: superClass2 subclasses equals: { subClass }. 
	self assertCollection: superClass subclasses equals: { superClass2 }. 
	self assert: subClass superclass equals: superClass2.
	self assert: superClass2 superclass equals: superClass.

]

{ #category : #tests }
ShClassInstallerTest >> testChangingSuperclassToOther [

	superClass := self newClass:#ShCITestClass slots:#(var1).
	superClass2 := self newClass:#ShCITestClass2 slots:#().
	subClass := self newClass:#ShCISubTestClass superclass: superClass2 slots:#().

	subClass := 	self newClass:#ShCISubTestClass superclass: superClass slots:#().

   superClass2 := self newClass:#ShCITestClass2 superclass: superClass slots:#().

	self deny: superClass subclasses isEmpty.
	self assert: superClass2 subclasses isEmpty.
	self assertCollection: superClass subclasses equals: { subClass. superClass2 }. 
	self assert: subClass superclass equals: superClass.
	self assert: superClass2 superclass equals: superClass.

]

{ #category : #tests }
ShClassInstallerTest >> testClassWithComment [
	newClass := ShiftClassInstaller
		make: [ :builder | 
			builder
				name: #SHClassWithComment;
				superclass: Object;
				slots: #();
				sharedVariables: '';
				sharedPools: '';
				category: 'Shift-ClassInstaller-Tests';
				comment: 'I have a comment'; 
				commentStamp: 'anStamp';				
				copyClassSlotsFromExistingClass ].
	
	self assert: newClass comment equals: 'I have a comment'.
	self assert: newClass organization commentStamp equals: 'anStamp'.
]

{ #category : #tests }
ShClassInstallerTest >> testModifyingClassKeepsOrganizationOfMethods [
	newClass := self newClass: #ShCITestClass superclass: subClass slots: #().

	newClass compile: 'aMethod ^ 42' classified: #'useful-message' notifying: nil.
	newClass class compile: 'aClassMethod ^ 21' classified: #'useful-message' notifying: nil.

	self assert: (newClass >> #aMethod) protocol equals: #'useful-message'.
	self assert: (newClass class >> #aClassMethod) protocol equals: #'useful-message'.	
	
	newClass := self newClass: #ShCITestClass superclass: subClass slots: #(aSlot).

	self assert: (newClass >> #aMethod) protocol equals: #'useful-message'.
	self assert: (newClass class >> #aClassMethod) protocol equals: #'useful-message'.	

]

{ #category : #tests }
ShClassInstallerTest >> testModifyingClassSideInstances [
	superClass := self newClass:#ShCITestClass slots:#(anInstanceVariable).
	newClass := self newClass: #ShCITestSubClass superclass: superClass slots: #().
	
	superClass class addInstVarNamed: #aVariable.

	self assert: (superClass class hasSlotNamed: #aVariable).
	self assert: (newClass class hasSlotNamed: #aVariable)
]

{ #category : #tests }
ShClassInstallerTest >> testModifyingSuperclass [
	superClass := self newClass:#ShCITestClass slots:#(anInstanceVariable).
	newClass := self newClass: #ShCITestSubClass superclass: superClass slots: #().
	
	superClass new instVarNamed: #anInstanceVariable.
	newClass new instVarNamed: #anInstanceVariable.	
	
	superClass := self newClass:#ShCITestClass slots:#(anInstanceVariable otherVariable).

	superClass new instVarNamed: #anInstanceVariable.
	newClass new instVarNamed: #anInstanceVariable.	
	superClass new instVarNamed: #otherVariable.
	newClass new instVarNamed: #otherVariable.	

]

{ #category : #tests }
ShClassInstallerTest >> testModifyingSuperclassInOtherOrder [
	| obj |
	superClass := self newClass:#ShCITestClass slots:#(anInstanceVariable).
	subClass := self newClass:#ShCISubTestClass superclass: superClass slots:#(anSubInstanceVariable).
	newClass := self newClass: #ShCITestSubClass superclass: subClass slots: #().
	
	superClass new instVarNamed: #anInstanceVariable.
	newClass new instVarNamed: #anInstanceVariable.	

	obj := newClass new.	
	obj instVarNamed: #anInstanceVariable put: 7.
	obj instVarNamed: #anSubInstanceVariable put: 17.
			
	superClass := self newClass:#ShCITestClass slots:#(otherVariable anInstanceVariable).

	self assert: (obj instVarNamed: #anInstanceVariable) equals: 7.
	self assert: (obj instVarNamed: #anSubInstanceVariable) equals: 17

]

{ #category : #tests }
ShClassInstallerTest >> testTryingToModifyReadOnlyInstances [
	| obj obj2 |
	newClass := self newClass: #ShCITestClass slots: #(anInstanceVariable).
	
	obj := newClass new.	
	obj instVarNamed: #anInstanceVariable put: 7.
	obj beReadOnlyObject.
			
	obj2 := newClass new.	
	obj2 instVarNamed: #anInstanceVariable put: 17.

	self should: [self newClass:#ShCITestClass slots:#(otherVariable anInstanceVariable)] raise: Error.

]

{ #category : #tests }
ShClassInstallerTest >> testTryingToModifyReadOnlySubInstances [
	| obj obj2 |
	superClass := self newClass: #ShCITestSuperClass slots: #(aSuperVariable).
	newClass := self newClass: #ShCITestClass superclass: superClass slots: #(anInstanceVariable).
	
	obj := newClass new.	
	obj instVarNamed: #aSuperVariable put: 1.
	obj instVarNamed: #anInstanceVariable put: 7.
	obj beReadOnlyObject.
			
	obj2 := newClass new.	
	obj2 instVarNamed: #aSuperVariable put: 11.
	obj2 instVarNamed: #anInstanceVariable put: 17.

	self should: [self newClass:#ShCITestClass slots:#(otherVariable anInstanceVariable)] raise: Error.

]
