package com.softtek.analyzer.cobol.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2

class EnvironmentDivision {
	
	def doGenerate(Resource resource, IFileSystemAccess2 fsa){
		return 'TEST \n'
	}
	
}