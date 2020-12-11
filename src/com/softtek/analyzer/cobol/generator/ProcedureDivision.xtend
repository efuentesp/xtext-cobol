package com.softtek.analyzer.cobol.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import com.softtek.analyzer.cobol.cobol.Model
import com.softtek.analyzer.cobol.cobol.PerformStatement
import com.softtek.analyzer.cobol.cobol.IfStatement
import com.softtek.analyzer.cobol.cobol.DisplayStatement
import com.softtek.analyzer.cobol.cobol.AcceptStatement
import com.softtek.analyzer.cobol.cobol.MoveStatement
import com.softtek.analyzer.cobol.cobol.StopStatement
import com.softtek.analyzer.cobol.cobol.CloseStatement
import com.softtek.analyzer.cobol.cobol.OpenStatement
import com.softtek.analyzer.cobol.cobol.RewriteStatement
import com.softtek.analyzer.cobol.cobol.ReadStatement
import com.softtek.analyzer.cobol.cobol.WriteStatement
import com.softtek.analyzer.cobol.cobol.DeleteStatement
import com.softtek.analyzer.cobol.cobol.CallStatement
import com.softtek.analyzer.cobol.cobol.PerformType
import com.softtek.analyzer.cobol.cobol.MoveToStatement

class ProcedureDivision {
	def doGenerate(Resource resource, IFileSystemAccess2 fsa){
		var model  = resource.contents.head as Model
		
		var procs = ''
		
		for(pUnit : model.programUnit){
			var procedures = pUnit.procedureDivision
			
			for(p:procedures.procedureDivisionBody.paragraphs.paragraph){
			  // print(p.paragraphName.id)
			   procs=procs+p.paragraphName.id+"\n"
			   for(s:p.sentence){
			   	 for(st:s.statement){
			   	 	procs=procs+getStatement(st,'  ')
			   	 }
			   }
			 }
		}
		
		return "PROCEDURE DIVISION.\n" + procs
	}
	
	
	def dispatch getStatement(IfStatement st, String spaces) '''
«spaces»IF «st.condition.toString()» 
	 «IF st.ifThen.statement!==null»
	   «FOR stm:st.ifThen.statement»
        «spaces» «getStatement(stm,spaces)»
	   «ENDFOR»
	 «ENDIF»
	 «IF st.ifElse!==null»
«spaces»ELSE
	     «FOR stm:st.ifElse.statement»
         «spaces» «getStatement(stm,spaces)»
	     «ENDFOR»
	 «ENDIF»
	'''
	
	def dispatch getStatement(DisplayStatement st,String spaces) '''
«spaces»DISPLAY «FOR op:st.displayOperand» «op.literal» «ENDFOR»
	'''
	
	def dispatch getStatement(MoveStatement st,String spaces) '''
«spaces»MOVE «(st.moveTo as MoveToStatement).from» TO «FOR to:(st.moveTo as MoveToStatement).to» «to» «ENDFOR»
	'''
	
	def dispatch getStatement(AcceptStatement st,String spaces) '''
«spaces»ACCEPT «st.id»  «IF st.acceptFromDateStatement!==null» «st.acceptFromDateStatement» «ENDIF»
	'''
	
	def dispatch getStatement(StopStatement st,String spaces) '''
«spaces»STOP 
	'''
	
	def dispatch getStatement(OpenStatement st,String spaces) '''
«spaces»OPEN 
	'''
	
	def dispatch getStatement(CloseStatement st,String spaces) '''
«spaces»CLOSE «st.closeFile.fileName»
	'''
	
	def dispatch getStatement(ReadStatement st,String spaces) '''
«spaces»READ «st.fileName»
	'''
	
	def dispatch getStatement(WriteStatement st,String spaces) '''
«spaces»WRITE «st.recordName»
	'''
	
	def dispatch getStatement(RewriteStatement st,String spaces) '''
«spaces»REWRITE
	'''
	
	def dispatch getStatement(DeleteStatement st,String spaces) '''
«spaces»DELETE «st.fineName»
	'''
	
	def dispatch getStatement(CallStatement st,String spaces) '''
«spaces»CALL «st.literal»
	'''
	
	 
	def dispatch getStatement(PerformStatement st, String spaces) '''	  
«spaces»PERFORM «st.performProcedureStatement.procedureName»  «««performTimes(st.performProcedureStatement.performType)»
	  «IF st.performInlineStatement!==null»
	  «FOR stm:st.performInlineStatement.statement»
	     «spaces» «getStatement(stm,spaces)»
	  «ENDFOR» 
	  «ENDIF»
	  
	'''
	
	def performTimes(PerformType pt)'''
	«IF pt.performTimes!==null»
	 «(pt.performTimes.times)» TIMES
	«ENDIF»
	'''
}