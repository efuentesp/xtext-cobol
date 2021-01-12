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
import com.softtek.analyzer.cobol.cobol.RelationCondition
import com.softtek.analyzer.cobol.cobol.ClassCondition
import com.softtek.analyzer.cobol.cobol.SubtractFromStatement
import com.softtek.analyzer.cobol.cobol.QualifiedDataName
import com.softtek.analyzer.cobol.cobol.QualifiedDataNameFormat1
import com.softtek.analyzer.cobol.cobol.StringForPhrase
import com.softtek.analyzer.cobol.cobol.Identifier

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
«spaces»IF «getCondition(st.condition).toString().replace('\n','').replace('\r','')»«IF st.ifThen.then !== null» THEN«ENDIF»
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
«spaces»MOVE  «IF (st.moveTo as MoveToStatement).fromIdentifier!==null»FUNCTION «(st.moveTo as MoveToStatement).fromIdentifier.functionCall.functionName»(«FOR e:(st.moveTo as MoveToStatement).fromIdentifier.functionCall.args»«e.arithmeticExpression.multDivs.powers.basis.literal»«ENDFOR») «ENDIF» «(st.moveTo as MoveToStatement).from» TO «FOR to:(st.moveTo as MoveToStatement).to»«to»«ENDFOR»
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
«spaces»READ «st.fileName» «IF st.notAtEndPhrase!==null» «FOR s:st.notAtEndPhrase.statement» «getStatement(s,'  ')»«ENDFOR»«ENDIF» 
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
	
	def dispatch getStatement(AddStatement st,String spaces) '''
	ADD «FOR s:st.add.addFrom» «s.literal» «ENDFOR»TO«FOR s:st.add.addTo» «s.id» «ENDFOR»
	'''
	def dispatch getStatement(AlterStatement st,String spaces) ''''''
	def dispatch getStatement(CancelStatement st,String spaces) ''''''
	def dispatch getStatement(ContinueStatement st,String spaces) ''''''
	def dispatch getStatement(DisableStatement st,String spaces) ''''''
	def dispatch getStatement(DivideStatement st,String spaces) ''''''
	def dispatch getStatement(EnableStatement st,String spaces) ''''''
	def dispatch getStatement(EntryStatement st,String spaces) ''''''
	
	def dispatch getStatement(EvaluateStatement st,String spaces) '''
«spaces»EVALUATE «IF st.evaluateSelect.literal!==null»«st.evaluateSelect.literal»«ENDIF» «FOR w:st.evaluateWhenPhrase BEFORE ' '  SEPARATOR '\n'»WHEN «w.evaluateWhen.evaluateCondition.evaluateValue.arith.multDivs.powers.basis.literal» «ENDFOR»
	'''
	
	def dispatch getStatement(ExhibitStatement st,String spaces) ''''''
	def dispatch getStatement(ExecCicsStatement st,String spaces) ''''''
	def dispatch getStatement(ExitStatement st,String spaces) ''''''
	def dispatch getStatement(GenerateStatement st,String spaces) ''''''
	def dispatch getStatement(GobackStatement st,String spaces) ''''''
	def dispatch getStatement(GoToStatement st,String spaces) ''''''
	def dispatch getStatement(InitializeStatement st,String spaces) ''''''
	def dispatch getStatement(InitiateStatement st,String spaces) ''''''
	def dispatch getStatement(InspectStatement st,String spaces) '''
	INSPECT «st.id» «IF st.inspectTallyingPhrase !== null»TALLYING «FOR c: st.inspectTallyingPhrase.inspectFor»  «ENDFOR»«ENDIF»
	'''
	def dispatch getStatement(ComputeStatement st, String spaces) '''
	COMPUTE «FOR c:st.computeStore» «c.id»«ENDFOR» = «st.arithmeticExpression.multDivs.powers.basis.literal» «FOR c: st.arithmeticExpression.plusMinus»«c.plusMinus» «c.multDivs.powers.basis.literal»«ENDFOR»
	'''
	def dispatch getStatement(MergeStatement st, String spaces) ''''''
	def dispatch getStatement(MultiplyStatement st, String spaces) ''''''
	def dispatch getStatement(PurgeStatement st, String spaces) ''''''
	def dispatch getStatement(ReceiveStatement st, String spaces) ''''''
	def dispatch getStatement(ReleaseStatement st, String spaces) '''
	 RELEASE «st.recordName.qualifiedDataName.qualifiedDataNameFormat1.dataName» «IF st.from !==null» FROM «st.from.qualifiedDataNameFormat1.dataName» «ENDIF»
	'''
	def dispatch getStatement(ReturnStatement st, String spaces) '''
	 RETURN «st.fileName» «IF st.record!==null» «st.record» «ENDIF» «IF st.notAtEndPhrase!==null» NOT AT END «FOR s:st.notAtEndPhrase.statement» «getStatement(s,'')»«ENDFOR»«ENDIF» «IF st.atEndPhrase!==null» AT END «FOR s:st.atEndPhrase.statement» «getStatement(s,'')»«ENDFOR»«ENDIF»
	'''
	def dispatch getStatement(SearchStatement st, String spaces) '''
	SEARCH «st.qualifiedDataName.qualifiedDataNameFormat1.dataName» «IF st.atEndPhrase!==null» AT END «FOR s:st.atEndPhrase.statement» «getStatement(s,'')»«ENDFOR»«ENDIF» WHEN «FOR s:st.searchWhen» «getCondition(s.condition)» «ENDFOR»
	'''
	def dispatch getStatement(SendStatement st, String spaces) ''''''
	def dispatch getStatement(SetStatement st, String spaces) '''
	 SET «FOR s:st.setToStatement»«FOR setto: s.setTo» «setto.id» «ENDFOR» TO «FOR settov: s.setToValue»  «settov.literal» «ENDFOR»«ENDFOR»
	'''
	def dispatch getStatement(SortStatement st, String spaces) '''
	SORT «st.filename»
	«FOR c:st.sortOnKeyClause SEPARATOR '\n'»«IF c.on !== null» ON «ENDIF»«c.asc»«IF c.key !== null» «c.key» «ENDIF»«FOR q: c.qualifiedDataName» «q.qualifiedDataNameFormat1.dataName» «ENDFOR»«ENDFOR»
	«IF st.sortInputProcedurePhrase !== null»INPUT PROCEDURE«IF st.sortInputProcedurePhrase.is !== null» IS «ENDIF» «st.sortInputProcedurePhrase.procedureName» «IF st.sortInputProcedurePhrase.sortInputThrough!==null» «st.sortInputProcedurePhrase.sortInputThrough.thru» «st.sortInputProcedurePhrase.sortInputThrough.procedureName»«ENDIF»«ENDIF»
	«IF st.sortOutputProcedurePhrase !== null»OUTPUT PROCEDURE«IF st.sortOutputProcedurePhrase.is !== null» IS «ENDIF» «st.sortOutputProcedurePhrase.procedureName»  «IF st.sortOutputProcedurePhrase.sortOutputThrough!==null» «st.sortOutputProcedurePhrase.sortOutputThrough.thru» «st.sortOutputProcedurePhrase.sortOutputThrough.procedureName»«ENDIF»«ENDIF»
	'''
	def dispatch getStatement(StartStatement st, String spaces) ''''''
	def dispatch getStatement(StringStatement st, String spaces) '''
	STRING «FOR c:st.stringSendingPhrase»«FOR s:c.stringSending SEPARATOR '\n'» «s.literal» «ENDFOR» «getStringPhrase(c.stringPhrase as StringForPhrase)»«ENDFOR» INTO «st.stringIntoPhra.id»
	«IF st.onOverflowPhrase !== null» «IF st.onOverflowPhrase.on !== null» ON «ENDIF» OVERFLOW «FOR s : st.onOverflowPhrase.statement» «getStatement(s,'')» «ENDFOR»«ENDIF»
	«IF st.notOnOverflowPhrase !== null»NOT «IF st.notOnOverflowPhrase.on !== null»ON«ENDIF» OVERFLOW «FOR s : st.notOnOverflowPhrase.statement» «getStatement(s,'')» «ENDFOR»«ENDIF»
	'''
	def dispatch getStatement(SubtractStatement st, String spaces) '''
	SUBTRACT «getSubtrahend(st).toString().replace('\n','').replace('\r','')» FROM «getMinuend(st).toString().replace('\n','').replace('\r','')» 
	'''
	def dispatch getStatement(TerminateStatement st, String spaces) ''''''
	
	def dispatch getStatement(UnstringStatement st, String spaces) '''
	UNSTRING «st.unstringSendingPhrase.id» «IF st.unstringSendingPhrase.unstringDelimitedByPhrase !== null»DELIMITED«IF st.unstringSendingPhrase.unstringDelimitedByPhrase.by !== null» BY «ENDIF»«IF st.unstringSendingPhrase.unstringDelimitedByPhrase.all !== null» ALL «ENDIF»«st.unstringSendingPhrase.unstringDelimitedByPhrase.literal»«ENDIF» INTO «FOR c : st.unstringIntoPhrase.unstringInto SEPARATOR '\n'» «c.id» «ENDFOR» «IF st.onOverflowPhrase !== null»
	«IF st.onOverflowPhrase.on !== null» ON «ENDIF» OVERFLOW «FOR s : st.onOverflowPhrase.statement» «getStatement(s,'')» «ENDFOR»«ENDIF» 
	«IF st.notOnOverflowPhrase !== null»NOT «IF st.notOnOverflowPhrase.on !== null»ON«ENDIF» OVERFLOW «FOR s : st.notOnOverflowPhrase.statement» «getStatement(s,'')» «ENDFOR»«ENDIF»
	'''
	
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
	
	// String Phrase
	
	def dispatch getStringPhrase(StringForPhrase sp)'''
	FOR «sp.literal»
	'''
	
	
	//Conditions
	
//	IF com.softtek.analyzer.cobol.cobol.impl.QualifiedDataNameFormat1Impl@1bcac030 (reportDescriptionGlobalClause: null) (dataName: WKS-SELECCION-USUARIO, qualifiedInData: null)ISALPHABETIC THEN
	
	def dispatch getCondition(Condition cond)'''
	«getCombinableCondition(cond)»«getAndOrCondition(cond)»
	'''
	
	def getCombinableCondition(Condition cond)'''
	  «IF cond.combinable.simpleCondition.relationCondition !== null»«getLeftOp(cond)»«getOperator(cond)»«getRightOp(cond)»«ENDIF»
	  «IF cond.combinable.simpleCondition.classCondition !== null»«getLeftOpClass(cond)»«getOperatorClass(cond)»«getRightOpClass(cond)»«ENDIF»
	'''
	
	def getAndOrCondition(Condition cond)'''
	  «IF cond.andOrCondition !== null»«FOR c:cond.andOrCondition» «c.andOr» «getLeftOpComb(c)»«getOperatorComb(c)»«getRightOpComb(c)»«ENDFOR»«ENDIF»
	'''
		
	
	def getLeftOpComb(AndOrCondition cond){
		if (cond.combinableCondition.simpleCondition.relationCondition!==null)
		 return cond.combinableCondition.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal
		
	}
	
	def getRightOpComb(AndOrCondition cond){
		if (cond.combinableCondition.simpleCondition.relationCondition!==null)
		 return cond.combinableCondition.simpleCondition.relationCondition.relationArithmeticComparison.arithR.multDivs.powers.basis.literal
	    
	}
	
	def getOperatorComb(AndOrCondition cond){
		if (cond.combinableCondition.simpleCondition.relationCondition!==null)
		 return cond.combinableCondition.simpleCondition.relationCondition.relationArithmeticComparison.relationalOperator
		 
	    if (cond.combinableCondition.simpleCondition.condition!==null)
		  '('+getCondition(cond.combinableCondition.simpleCondition.condition)+')'
	}
	
	
	def getLeftOp(Condition cond){
		if(cond.combinable.simpleCondition.relationCondition.relationSignCondition !== null){
			return cond.combinable.simpleCondition.relationCondition.relationSignCondition.arithmeticExpression.multDivs.powers.basis.literal
		}
		
		if(cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal !== null){
			return cond.combinable.simpleCondition.relationCondition.relationArithmeticComparison.arithL.multDivs.powers.basis.literal
		}
		
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
			if (cond.combinable.simpleCondition.classCondition.identifier.qualifiedDataName.qualifiedDataNameFormat1 !== null){
				return cond.combinable.simpleCondition.classCondition.identifier.qualifiedDataName.qualifiedDataNameFormat1.dataName
			}
			
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
	   op= ' ' + cond.combinable.simpleCondition.classCondition.is + ' '
	 if (cond.combinable.simpleCondition.classCondition.not!==null)
	   op=op + cond.combinable.simpleCondition.classCondition.not
	  return op 
	}
	
	def getSubtrahend(SubtractStatement st)'''
		«FOR s:(st.subtract as SubtractFromStatement).subtractSubtrahend» «s.literal» «ENDFOR»
	'''
	
	def getMinuend(SubtractStatement st)'''
		«FOR s:(st.subtract as SubtractFromStatement).subtractMinuend» «s.id» «ENDFOR»
	'''
}