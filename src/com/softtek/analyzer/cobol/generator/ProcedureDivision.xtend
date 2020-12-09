package com.softtek.analyzer.cobol.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import com.softtek.analyzer.cobol.cobol.Model
import com.softtek.analyzer.cobol.cobol.PerformStatement
import com.softtek.analyzer.cobol.cobol.IfStatement
import com.softtek.analyzer.cobol.cobol.DisplayStatement
import com.softtek.analyzer.cobol.cobol.AcceptStatement
import com.softtek.analyzer.cobol.cobol.MoveStatement

class ProcedureDivision {
	def doGenerate(Resource resource, IFileSystemAccess2 fsa){
		var model  = resource.contents.head as Model
		
		var procs = ''
		
		for(pUnit : model.programUnit){
			var procedures = pUnit.procedureDivision
			
			for(p:procedures.procedureDivisionBody.paragraphs.paragraph){
			 print(p.paragraphName.id)
			   for(s:p.sentence){
			   	 for(st:s.statement){
			   	 	procs=procs+getStatement(st,'  ')
			   	 }
			   }
			 }
		}
		
		return "PROCEDURE DIVISION.\n" + procs
	}
	
	//def getStatement(Statement st) '''
	//'''
	
	def dispatch getStatement(IfStatement st, String spaces) '''
	 IF «st.condition.toString()» 
	 «IF st.ifThen.statement!==null»
	   «FOR stm:st.ifThen.statement»
        «spaces» «getStatement(stm,spaces)»
	   «ENDFOR»
	 «ENDIF»
	 «IF st.ifElse!==null»
	     ELSE
	     «FOR stm:st.ifElse.statement»
         «spaces» «getStatement(stm,spaces)»
	     «ENDFOR»
	 «ENDIF»
	'''
	
	def dispatch getStatement(DisplayStatement st,String spaces) '''
	 DISPLAY
	'''
	
	def dispatch getStatement(AcceptStatement st,String spaces) '''
	 ACCEPT
	'''
	
	def dispatch getStatement(MoveStatement st,String spaces) '''
	 MOVE
	'''
	 
	def dispatch getStatement(PerformStatement st, String spaces) '''
	  PERFORM «(st.performInlineStatement.performType.performTimes.times)» TIMES
	  «FOR stm:st.performInlineStatement.statement»
	     «spaces» «getStatement(stm,spaces)»
	  «ENDFOR» 
	  END PERFORM.
	'''
}