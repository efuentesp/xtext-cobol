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
import com.softtek.analyzer.cobol.cobol.OpenIOStatement
import com.softtek.analyzer.cobol.cobol.OpenExtendStatement
import com.softtek.analyzer.cobol.cobol.OpenOutputStatement
import com.softtek.analyzer.cobol.cobol.OpenInputStatement
import com.softtek.analyzer.cobol.cobol.Condition
import com.softtek.analyzer.cobol.cobol.ComputeStatement

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
«spaces»IF «getCondition(st.condition)» 
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
«spaces»DISPLAY «FOR op:st.displayOperand»«op.literal»«ENDFOR»
	'''
	
	def dispatch getStatement(MoveStatement st,String spaces) '''
«spaces»MOVE «(st.moveTo as MoveToStatement).from» TO «FOR to:(st.moveTo as MoveToStatement).to» «to» «ENDFOR»
	'''
	
	def dispatch getStatement(AcceptStatement st,String spaces) '''
«spaces»ACCEPT «st.id»  «IF st.acceptFromDateStatement!==null» «st.acceptFromDateStatement» «ENDIF»
	'''
	
	def dispatch getStatement(StopStatement st,String spaces) '''
«spaces»STOP «IF st.run!==null» RUN «ENDIF»  «IF st.literal!==null» «st.literal» «ENDIF»
	'''
	
	def dispatch getStatement(OpenStatement st,String spaces) '''
«spaces»OPEN «FOR s:st.openStatement» «openInputOutput(s)» «ENDFOR»
	'''
	
	def dispatch getStatement(CloseStatement st,String spaces) '''
«spaces»CLOSE «st.closeFile.fileName»
	'''
	
	def dispatch getStatement(ReadStatement st,String spaces) '''
«spaces»READ «st.fileName» «IF st.notAtEndPhrase!==null» «getStatement(st.notAtEndPhrase.statement,'  ')» «ENDIF» 
     «IF st.notInvalidKeyPhrase!==null» 
     «FOR s: st.notInvalidKeyPhrase.statement»NOT INVALID KEY «getStatement(s,'  ')» «ENDFOR»
     «ENDIF»
     «IF st.invalidKeyPhrase!==null» 
     «FOR s: st.invalidKeyPhrase.statement»INVALID KEY «getStatement(s,'  ')» «ENDFOR»
     «ENDIF»
	'''
	
	def dispatch getStatement(WriteStatement st,String spaces) '''
«spaces»WRITE «st.recordName»
     «IF st.notInvalidKeyPhrase!==null» 
     «FOR s: st.notInvalidKeyPhrase.statement»NOT INVALID KEY «getStatement(s,'  ')» «ENDFOR»
     «ENDIF»
     «IF st.invalidKeyPhrase!==null» 
     «FOR s: st.invalidKeyPhrase.statement»INVALID KEY «getStatement(s,'  ')» «ENDFOR»
     «ENDIF»
	'''
	
	def dispatch getStatement(RewriteStatement st,String spaces) '''
«spaces»REWRITE «st.recordName» FROM «st.id»
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
	
	def dispatch getStatement(ComputeStatement st, String spaces) ''''''
	
	def performTimes(PerformType pt)'''
	«IF pt.performTimes!==null»
	 «(pt.performTimes.times)» TIMES
	«ENDIF»
	'''
	
	def dispatch openInputOutput(OpenInputStatement st)'''
	INPUT «FOR s:st.openInput» «s.fileName» «ENDFOR»
	'''
	
	def dispatch openInputOutput(OpenOutputStatement st)'''
	OUTPUT «FOR s:st.openOutput» «s.fileName» «ENDFOR»
	'''
	
	def dispatch openInputOutput(OpenIOStatement st)'''
	I-O «FOR f:st.fileName» «f» «ENDFOR»
	'''
	
	def dispatch openInputOutput(OpenExtendStatement st)'''
	EXTEND «FOR f:st.fileName» «f» «ENDFOR»
	'''
	//Conditions
	
	def dispatch getCondition(Condition cond)'''
	«IF cond !== null»
		«getLeftOp(cond)» «getOperator(cond)» «getRightOp(cond)»
	«ENDIF»
	'''
	
	def getLeftOp(Condition cond){
		cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal
	}
	
	def getRightOp(Condition cond){
		cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithR.multDivs.powers.basis.literal
	}
	
	def getOperator(Condition cond){
		cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.relationalOperator
	}
	
}