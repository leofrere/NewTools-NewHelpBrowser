Class {
	#name : #MDSpNewHelpBrowserPresenterTest,
	#superclass : #TestCase,
	#instVars : [
		'filesystem',
		'window'
	],
	#category : #'NewTools-MDNewHelpBrowser-Tests'
}

{ #category : #resources }
MDSpNewHelpBrowserPresenterTest class >> spDirectoryName [

	^ 'tests'
]

{ #category : #resources }
MDSpNewHelpBrowserPresenterTest class >> spFd1 [

	^ '# Chapitre Bar
Un paragraphe sur Bar

## 1
_Un paragraphe 1_

## 2
Un paragraphe 2

# Chapitre Foo

un paragraphe sur Foo'
]

{ #category : #resources }
MDSpNewHelpBrowserPresenterTest class >> spFd2 [

	^ '# Chapitre 3
Un paragraphe sur 3'
]

{ #category : #resources }
MDSpNewHelpBrowserPresenterTest class >> spFileContentsOneSection [

	^ '# Section 1
This is a test'
]

{ #category : #resources }
MDSpNewHelpBrowserPresenterTest class >> spFileName [

	^ 'test.md'
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> helpTopicClass [

	^ MDNodeHelpTopic
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> presenterClass [

	^ MDSpNewHelpBrowserPresenter
]

{ #category : #running }
MDSpNewHelpBrowserPresenterTest >> setUp [
	super setUp.
	filesystem := FileSystem memory.
	
]

{ #category : #running }
MDSpNewHelpBrowserPresenterTest >> tearDown [ 

	window ifNotNil: [ window close ].
	super tearDown.
]

{ #category : #'tests - interaction' }
MDSpNewHelpBrowserPresenterTest >> testClickOnFirstTopicExpandTree [

	| browser |
	self skip.
	"waiting for new release of Spec20 with fix/Expand integrated."
	browser := self presenterClass new.
	window := browser openWithSpec.

	browser topicList expandPath: #( 1 2 ).

	self assert: (browser topicList isExpanded: #( 1 2 ))
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> testFoundNoWords [

	| browser topics |
	self skip.
	browser := self presenterClass new.
	topics := OrderedCollection new.
	topics
		add: (self helpTopicClass named: 'section1');
		add: (self helpTopicClass named: 'part 2');
		add: (self helpTopicClass named: 'section 3').
	(topics at: 2) addSubtopic: (self helpTopicClass named: 'section2').
	self assert: (browser search: 'aWord' into: topics) size equals: 0
]

{ #category : #'tests - cache' }
MDSpNewHelpBrowserPresenterTest >> testHelpCache [

	| docFolder file cache save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'this is a text' ].
	self presenterClass internalizeHelpFrom: docFolder.
	cache := self presenterClass helpCache.
	self assert: cache basenameWithoutExtension equals: 'doc'.
	self
		assert: cache children first basenameWithoutExtension
		equals: 'file' ] ensure: [ self presenterClass helpCache: save ]
]

{ #category : #'tests - cache' }
MDSpNewHelpBrowserPresenterTest >> testHelpCacheHandleShittyFiles [

	| docFolder file cache save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'this is a text' ].

	file := filesystem workingDirectory / 'doc' / '.DS_Store'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'crap crap' ].
	self presenterClass internalizeHelpFrom: docFolder.
	cache := self presenterClass helpCache.
	self assert: cache basenameWithoutExtension equals: 'doc'.
	self assert: cache children size equals: 1 ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #'tests - cache' }
MDSpNewHelpBrowserPresenterTest >> testHelpCacheOnlyAcceptFolderAndMicFiles [

	| docFolder file cache save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'this is a text' ].

	file := filesystem workingDirectory / 'doc' / 'Stupid.txt'.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: 'This is a stupid mistyped extension text' ].

	filesystem createDirectory: 'doc/Epicea'.
	file := filesystem workingDirectory / 'doc' / 'Epicea' / 'fileEp.mic'.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: 'this is a text about Epicea' ].
	self presenterClass internalizeHelpFrom: docFolder.
	cache := self presenterClass helpCache.
	self assert: cache children size equals: 2.
	self assert: cache allChildren size equals: 4 ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #'tests - cache' }
MDSpNewHelpBrowserPresenterTest >> testHelpCacheReturnFileReferenceEmptyIfNil [

	| cache |
	cache := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	self assert: self presenterClass helpCache hasChildren not.
	self presenterClass helpCache: cache
]

{ #category : #'tests - interaction' }
MDSpNewHelpBrowserPresenterTest >> testOpenIsWorkingSmokeTest [

	| browser |
	browser := self presenterClass new.
	window := browser openWithSpec
]

{ #category : #'tests - interaction' }
MDSpNewHelpBrowserPresenterTest >> testOpenIsWorkingSmokeTestOnSpecificHelp [

	| browser topic |
	topic := HelpTopic named: 'Test'.
	browser := self presenterClass on: topic.
	self assert: browser rootTopic equals: topic.
	window := browser openWithSpec
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnCustomHelp2 [

	| browser rootTopic |
	browser := self presenterClass on: CustomHelp2 asHelpTopic.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: 'Help'.
	self assert: rootTopic icon isNotNil.
	window := browser openWithSpec
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnCustomHelpWithClass [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp: self presenterClass.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnCustomHelpWithDescription [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp: SUnitTutorial.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: 'Tutorial'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnCustomHelpWithMethod [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp:
		           self presenterClass >> #rootTopic:.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnCustomHelpWithObject [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp: Object new.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnCustomHelpWithString [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnCustomHelp:
		           self presenterClass >> #rootTopic:.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnDoesNotExistFolder [

	| browser rootTopic save |
	[ 
	save := self presenterClass helpCache.
	self presenterClass emptyHelpCache.
	browser := self presenterClass openOnHelpFolder:
		           FileSystem workingDirectory
		           / 'ojdoajdjvsaidqsjkjfzeuican'.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: '/'.
	window := browser window ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testOpenOnSystemHelp2 [

	| browser rootTopic |
	browser := self presenterClass on: SystemHelp2 asHelpTopic.
	rootTopic := browser rootTopic.
	self assert: rootTopic title equals: 'Help'.
	self assert: rootTopic icon isNil.
	window := browser openWithSpec
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> testSearchList [

	| browser text topics |
	self skip.
	browser := self presenterClass new.
	text := '# section 1
this is a paragraphe
## section 2
this is a paragraphe
## section 3
nothing
#section 4
this is a paragraphe'.
	topics := (browser helpTopicVisitor new start:
		           (MicroDownParser parse: text) asPillar) rootTopics.
	self assert: (browser searchList: 'para' into: topics) size equals: 3
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> testSearchWordInTopics [

	| browser topics text |
	self skip.
	browser := self presenterClass new.
	text := '# section 1
this is a paragraphe
## section 2
blabla
# part 3
lala'.
	topics := (browser helpTopicVisitor new start:
		           (MicroDownParser parse: text) asPillar) rootTopics.
	self assert: (browser search: 'la' into: topics) size equals: 2
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> testSearchWordInTopicsTitle [

	| browser topics |
	self skip.
	browser := self presenterClass new.
	topics := OrderedCollection new.
	topics
		add: (self helpTopicClass named: 'section1');
		add: (self helpTopicClass named: 'part 2');
		add: (self helpTopicClass named: 'section 3').
	(topics at: 2) addSubtopic: (self helpTopicClass named: 'section2').
	self assert: (browser search: 'section' into: topics) size equals: 3
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserGotHelpTopicVisitorPerDefault [

	| visitor browser |
	browser := self presenterClass new.
	visitor := browser helpTopicVisitor.
	self assert: visitor equals: MDTopicBuilderVisitor
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserGotHelpTopicVisitorThatISpecify [

	| visitor browser |
	browser := self presenterClass new.
	browser helpTopicVisitor: PRVisitor.
	visitor := browser helpTopicVisitor.
	self assert: visitor equals: PRVisitor
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserGotRootTopicThatISpecify [

	| topic browser |
	browser := self presenterClass new.
	topic := HelpTopic named: 'Test'.
	browser rootTopic: topic.
	self assert: browser rootTopic equals: topic
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserGotTopicsPerDefault [

	| topic browser |
	browser := self presenterClass new.
	topic := browser rootTopic.
	self assert: topic title equals: 'Help'
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserGotTopicsThatISpecify [

	| topic browser |
	browser := self presenterClass new.
	browser rootTopic: (HelpTopic named: 'foo').
	topic := browser rootTopic.
	self assert: topic title equals: 'foo'
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserPresenterDocTopicFromFileSystemOnFile [

	| file browser rootTopic |
	file := filesystem workingDirectory / 'fd1.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].
	browser := self presenterClass new.
	rootTopic := browser createTopicsFromFileOrFolder: file.
	self assert: rootTopic size equals: 2
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserPresenterDocTopicFromSystem [

	| file directory browser rootTopic |
	filesystem createDirectory: 'test'.
	directory := filesystem workingDirectory / 'test'.
	file := filesystem workingDirectory / 'test/fd1.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].
	browser := self presenterClass new.
	rootTopic := (browser createRootTopicFromFolder: directory) rootTopic.
	self assert: rootTopic subtopics size equals: 2
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserPresenterOpenADirectory [

	| directory browser |
	directory := filesystem workingDirectory / self class spDirectoryName.
	filesystem createDirectory: self class spDirectoryName.
	browser := self presenterClass new.
	browser createRootTopicFromFolder: directory.

	self
		assert: browser rootTopic title
		equals: directory basenameWithoutExtension capitalized
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserPresenterTopicFromSystemOnDirectoryWithFiles [

	| directory file1 file2 browser rootTopic |
	filesystem createDirectory: 'test'.
	directory := filesystem workingDirectory / 'test'.


	file1 := filesystem workingDirectory / 'test/fd1.mic'.
	file1 writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].

	file2 := filesystem workingDirectory / 'test/fd2.mic'.
	file2 writeStreamDo: [ :stream | stream nextPutAll: self class spFd2 ].

	browser := self presenterClass new.
	rootTopic := (browser createRootTopicFromFolder: directory) rootTopic.
	self assert: rootTopic subtopics size equals: 3
]

{ #category : #tests }
MDSpNewHelpBrowserPresenterTest >> testSpHelpBrowserPresenterTopicFromSystemOnFile [

	| file browser rootTopic |
	file := filesystem workingDirectory / 'fd1.mic'.
	file writeStreamDo: [ :stream | stream nextPutAll: self class spFd1 ].
	browser := self presenterClass new.
	rootTopic := (browser createRootTopicFromFolder: file) rootTopic.
	self assert: rootTopic subtopics size equals: 2
]

{ #category : #'tests - cache' }
MDSpNewHelpBrowserPresenterTest >> testTopicsWithCacheFrom [

	| docFolder file browser save |
	[ 
	save := self presenterClass helpCache.

	filesystem createDirectory: 'doc'.
	docFolder := filesystem workingDirectory / 'doc'.
	file := filesystem workingDirectory / 'doc' / 'file.mic'.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: '# section
this is a text' ].
	self presenterClass internalizeHelpFrom: docFolder.
	browser := self presenterClass open.
	window := browser window.
	self assert: browser rootTopic title equals: 'Doc'.
	self assert: browser rootTopic subtopics size equals: 1 ] ensure: [ 
		self presenterClass helpCache: save ]
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> testWordInNode [

	| browser text topic |
	self skip.
	browser := self presenterClass new.
	text := '# section 1
this is a paragraphe'.
	topic := (browser helpTopicVisitor new start:
		          (MicroDownParser parse: text) asPillar) rootTopics first.
	self assert: (browser word: 'para' in: topic)
]

{ #category : #'tests - search' }
MDSpNewHelpBrowserPresenterTest >> testWordNotInNode [

	| browser text topic |
	self skip.
	browser := self presenterClass new.
	text := '# section 1
this is a paragraphe'.
	topic := (browser helpTopicVisitor new start:
		          (MicroDownParser parse: text) asPillar) rootTopics first.
	self assert: (browser word: 'nothing' in: topic) not
]
