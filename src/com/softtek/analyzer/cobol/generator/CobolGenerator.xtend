/*
 * generated by Xtext 2.18.0.M3
 */
package com.softtek.analyzer.cobol.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.softtek.analyzer.cobol.cobol.Model
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CobolGenerator extends AbstractGenerator {
	
	@Inject IdentificationDivision identificationDivision
	
	@Inject EnvironmentDivision environmentDivision
	
	@Inject DataDivision dataDivision
	
	@Inject ProcedureDivision procedureDivision
	

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		var iDivision = identificationDivision.doGenerate(resource, fsa)
		
		var eDivision = environmentDivision.doGenerate(resource, fsa)
		
		var dDivision = dataDivision.doGenerate(resource, fsa)
		
		var pDivision = procedureDivision.doGenerate(resource, fsa)
		
		
		var fileName = resource.URI.segments.last()
		fsa.generateFile("output/" + fileName, iDivision + eDivision + dDivision + pDivision)
	}
}
