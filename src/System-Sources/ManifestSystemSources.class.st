"
Support for source and changes files
"
Class {
	#name : #ManifestSystemSources,
	#superclass : #PackageManifest,
	#category : #'System-Sources-Manifest'
}

{ #category : #'meta-data - dependency analyser' }
ManifestSystemSources class >> manuallyResolvedDependencies [
	^ #(#'Collections-Streams' #Jobs #'Announcements-Core' #'Ring-Deprecated-Core-Kernel' #CodeExport #DeprecatedFileStream #'Collections-Abstract')
]
