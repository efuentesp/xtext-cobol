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
import com.softtek.analyzer.cobol.cobol.AndOrCondition
import com.softtek.analyzer.cobol.cobol.AddStatement
import com.softtek.analyzer.cobol.cobol.AlterStatement
import com.softtek.analyzer.cobol.cobol.CancelStatement
import com.softtek.analyzer.cobol.cobol.ContinueStatement
import com.softtek.analyzer.cobol.cobol.DisableStatement
import com.softtek.analyzer.cobol.cobol.DivideStatement
import com.softtek.analyzer.cobol.cobol.EnableStatement
import com.softtek.analyzer.cobol.cobol.EntryStatement
import com.softtek.analyzer.cobol.cobol.EvaluateStatement
import com.softtek.analyzer.cobol.cobol.ExhibitStatement
import com.softtek.analyzer.cobol.cobol.ExecCicsStatement
import com.softtek.analyzer.cobol.cobol.ExitStatement
import com.softtek.analyzer.cobol.cobol.GenerateStatement
import com.softtek.analyzer.cobol.cobol.GobackStatement
import com.softtek.analyzer.cobol.cobol.GoToStatement
import com.softtek.analyzer.cobol.cobol.InitializeStatement
import com.softtek.analyzer.cobol.cobol.InitiateStatement
import com.softtek.analyzer.cobol.cobol.InspectStatement
import com.softtek.analyzer.cobol.cobol.MergeStatement
import com.softtek.analyzer.cobol.cobol.MultiplyStatement
import com.softtek.analyzer.cobol.cobol.PurgeStatement
import com.softtek.analyzer.cobol.cobol.ReceiveStatement
import com.softtek.analyzer.cobol.cobol.ReleaseStatement
import com.softtek.analyzer.cobol.cobol.ReturnStatement
import com.softtek.analyzer.cobol.cobol.SearchStatement
import com.softtek.analyzer.cobol.cobol.SendStatement
import com.softtek.analyzer.cobol.cobol.SetStatement
import com.softtek.analyzer.cobol.cobol.SortStatement
import com.softtek.analyzer.cobol.cobol.StartStatement
import com.softtek.analyzer.cobol.cobol.StringStatement
import com.softtek.analyzer.cobol.cobol.SubtractStatement
import com.softtek.analyzer.cobol.cobol.TerminateStatement
import com.softtek.analyzer.cobol.cobol.UnstringStatement
import com.softtek.analyzer.cobol.cobol.IfThen

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
«spaces»IF «getCondition(st.condition, st.ifThen)»
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
	
	def dispatch getStatement(AddStatement st,String spaces) ''''''
	def dispatch getStatement(AlterStatement st,String spaces) ''''''
	def dispatch getStatement(CancelStatement st,String spaces) ''''''
	def dispatch getStatement(ContinueStatement st,String spaces) ''''''
	def dispatch getStatement(DisableStatement st,String spaces) ''''''
	def dispatch getStatement(DivideStatement st,String spaces) ''''''
	def dispatch getStatement(EnableStatement st,String spaces) ''''''
	def dispatch getStatement(EntryStatement st,String spaces) ''''''
	def dispatch getStatement(EvaluateStatement st,String spaces) ''''''
	def dispatch getStatement(ExhibitStatement st,String spaces) ''''''
	def dispatch getStatement(ExecCicsStatement st,String spaces) ''''''
	def dispatch getStatement(ExitStatement st,String spaces) ''''''
	def dispatch getStatement(GenerateStatement st,String spaces) ''''''
	def dispatch getStatement(GobackStatement st,String spaces) ''''''
	def dispatch getStatement(GoToStatement st,String spaces) ''''''
	def dispatch getStatement(InitializeStatement st,String spaces) ''''''
	def dispatch getStatement(InitiateStatement st,String spaces) ''''''
	def dispatch getStatement(InspectStatement st,String spaces) ''''''
	def dispatch getStatement(ComputeStatement st, String spaces) ''''''
	def dispatch getStatement(MergeStatement st, String spaces) ''''''
	def dispatch getStatement(MultiplyStatement st, String spaces) ''''''
	def dispatch getStatement(PurgeStatement st, String spaces) ''''''
	def dispatch getStatement(ReceiveStatement st, String spaces) ''''''
	def dispatch getStatement(ReleaseStatement st, String spaces) ''''''
	def dispatch getStatement(ReturnStatement st, String spaces) ''''''
	def dispatch getStatement(SearchStatement st, String spaces) ''''''
	def dispatch getStatement(SendStatement st, String spaces) ''''''
	def dispatch getStatement(SetStatement st, String spaces) ''''''
	def dispatch getStatement(SortStatement st, String spaces) ''''''
	def dispatch getStatement(StartStatement st, String spaces) ''''''
	def dispatch getStatement(StringStatement st, String spaces) ''''''
	def dispatch getStatement(SubtractStatement st, String spaces) ''''''
	def dispatch getStatement(TerminateStatement st, String spaces) ''''''
	def dispatch getStatement(UnstringStatement st, String spaces) ''''''
	
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
	
	def dispatch getCondition(Condition cond, IfThen IfThen)'''
	«getCombinableCondition(cond,IfThen)»
	'''
	
	def getCombinableCondition(Condition cond, IfThen IfThen)'''
	  «IF cond.combinable.simpleCondition.relationCondition !== null»«getLeftOp(cond)» «getOperator(cond)» «getRightOp(cond)» «IF IfThen.then !== null»THEN«ENDIF»«ENDIF»
	  «IF cond.combinable.simpleCondition.classCondition !== null»«getLeftOpClass(cond)» «getOperatorClass(cond)» «getRightOpClass(cond)» «IF IfThen.then !== null»THEN«ENDIF»«ENDIF»
	'''
	
	def getAndOrCondition(Condition cond, IfThen IfThen)'''
	  «IF cond.andOrCondition !== null»«FOR c:cond.andOrCondition» «c.andOr»  «getLeftOpComb(c)» «getOperatorComb(c)» «getRightOpComb(c)» «ENDFOR» «IF IfThen.then !== null»THEN«ENDIF»«ENDIF»
	'''
		
	
	def getLeftOpComb(AndOrCondition cond){
		cond.combinableCondition.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal
	}
	
	def getRightOpComb(AndOrCondition cond){
		cond.combinableCondition.simpleCondition.relationCondition.relationArithmeticComparison.arithR.multDivs.powers.basis.literal
	}
	
	def getOperatorComb(AndOrCondition cond){
		cond.combinableCondition.simpleCondition.relationCondition.relationArithmeticComparison.relationalOperator
	}
	
	
	def getLeftOp(Condition cond){
//		print(cond.combinable.simpleCondition.relationCondition.relationSignCondition.arithmeticExpression)
		
		if(cond.combinable.simpleCondition.relationCondition.relationSignCondition !== null){
			return cond.combinable.simpleCondition.relationCondition.relationSignCondition.arithmeticExpression.multDivs.powers.basis.literal
		}
		
		if(cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal !== null){
			return cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal
		}
		
//		if(cond.combinable.simpleCondition.relationCondition.relationSignCondition !== null){
//			cond.combinable.simpleCondition.relationCondition.relationSignCondition//.arithmeticExpression.multDivs.powers.basis.literal
//		}
		
		
	}
	
	def getRightOp(Condition cond){
		
		if(cond.combinable.simpleCondition.relationCondition.relationSignCondition !== null){
			if (cond.combinable.simpleCondition.relationCondition.relationSignCondition.sign !== null)
				return cond.combinable.simpleCondition.relationCondition.relationSignCondition.sign
		}
		
		if (cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison !== null){
			if(cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithR.multDivs.powers.basis.literal !== null)
				return cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithR.multDivs.powers.basis.literal
		}
	}
	
	def getOperator(Condition cond){
		var op=''
		
		if (cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison !== null){
			if (cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.relationalOperator !== null)
				return cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.relationalOperator
		}
		
		if(cond.combinable.simpleCondition.relationCondition.relationSignCondition !== null){
			if (cond.combinable.simpleCondition.relationCondition.relationSignCondition.is !== null)
				op=cond.combinable.simpleCondition.relationCondition.relationSignCondition.is
			if (cond.combinable.simpleCondition.relationCondition.relationSignCondition.not !== null)
				op=op+cond.combinable.simpleCondition.relationCondition.relationSignCondition.not
		}
		return op

		
	}
	
	def getLeftOpClass(Condition cond){
		if (cond.combinable.simpleCondition.classCondition.identifier.qualifiedDataName !== null){
			return cond.combinable.simpleCondition.classCondition.identifier.qualifiedDataName
			
		}
		if (cond.combinable.simpleCondition.classCondition.identifier.specialRegister !== null){
			return cond.combinable.simpleCondition.classCondition.identifier.specialRegister
		}
		if(cond.combinable.simpleCondition.classCondition.identifier.tableCall !== null){
			return cond.combinable.simpleCondition.classCondition.identifier.tableCall
		}
		if(cond.combinable.simpleCondition.classCondition.identifier.functionCall !== null){
			return cond.combinable.simpleCondition.classCondition.identifier.functionCall
		}
	}
	
	def getRightOpClass(Condition cond){
	    cond.combinable.simpleCondition.classCondition.typeCondition
	}
	
	
	def getOperatorClass(Condition cond){
	 var op=''
	 if (cond.combinable.simpleCondition.classCondition.is!==null)
	   op=cond.combinable.simpleCondition.classCondition.is 
	 if (cond.combinable.simpleCondition.classCondition.not!==null)
	   op=op + cond.combinable.simpleCondition.classCondition.not
	  return op 
	}
	
}