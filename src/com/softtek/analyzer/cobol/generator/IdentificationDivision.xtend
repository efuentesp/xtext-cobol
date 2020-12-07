package com.softtek.analyzer.cobol.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import com.softtek.analyzer.cobol.cobol.Model

class IdentificationDivision{
	
	def doGenerate(Resource resource, IFileSystemAccess2 fsa){
		var model  = resource.contents.head as Model
		
		var idProgramName = ''
		
		for(pUnit : model.programUnit){
			idProgramName = pUnit.identification.programIdParaGraph.programName
		}
		
		return "IDENTIFICATION DIVISION.\nPROGRAM-ID. " + idProgramName + '.\n'
	}
}