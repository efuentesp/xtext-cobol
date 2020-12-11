package com.softtek.analyzer.cobol.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import com.softtek.analyzer.cobol.cobol.Model
import com.softtek.analyzer.cobol.cobol.WorkingStorageSection
import com.softtek.analyzer.cobol.cobol.DataDescriptionEntry
import java.util.ArrayList
import com.softtek.analyzer.cobol.cobol.FileSection
import com.softtek.analyzer.cobol.cobol.DataBaseSection
import com.softtek.analyzer.cobol.cobol.DataDivisionSection
import com.softtek.analyzer.cobol.cobol.LinkageSection
import com.softtek.analyzer.cobol.cobol.CommunicationSection
import com.softtek.analyzer.cobol.cobol.LocalStorageSection
import com.softtek.analyzer.cobol.cobol.ScreenSection
import com.softtek.analyzer.cobol.cobol.ReportSection
import com.softtek.analyzer.cobol.cobol.ProgramLibrarySection
import com.softtek.analyzer.cobol.cobol.DataDescriptionEntryFormat1
import com.softtek.analyzer.cobol.cobol.DataRedefinesClause
import com.softtek.analyzer.cobol.cobol.DataExternalClause
import com.softtek.analyzer.cobol.cobol.DataPictureClause
import com.softtek.analyzer.cobol.cobol.DataGlobalClause
import com.softtek.analyzer.cobol.cobol.DataIntegerStringClause
import com.softtek.analyzer.cobol.cobol.DataTypeDefClause
import com.softtek.analyzer.cobol.cobol.DataThreadLocalClause
import com.softtek.analyzer.cobol.cobol.DataCommonOwnLocalClause
import com.softtek.analyzer.cobol.cobol.DataTypeClause
import com.softtek.analyzer.cobol.cobol.DataUsingClause
import com.softtek.analyzer.cobol.cobol.DataUsageClause
import com.softtek.analyzer.cobol.cobol.DataValueClause
import com.softtek.analyzer.cobol.cobol.DataReceivedByClause
import com.softtek.analyzer.cobol.cobol.DataOccursClause
import com.softtek.analyzer.cobol.cobol.DataSignClause
import com.softtek.analyzer.cobol.cobol.DataSynchronizedClause
import com.softtek.analyzer.cobol.cobol.DataJustifiedClause
import com.softtek.analyzer.cobol.cobol.DataBlankWhenZeroClause
import com.softtek.analyzer.cobol.cobol.DataWithLowerBoundsClause
import com.softtek.analyzer.cobol.cobol.DataAlignedClause
import com.softtek.analyzer.cobol.cobol.DataRecordAreaClause

class DataDivision {
	
	def doGenerate(Resource resource, IFileSystemAccess2 fsa){
		var model  = resource.contents.head as Model
		var vars = '';
		
		for (pUnit : model.programUnit){
			var dDivision = pUnit.dataDivision.dataDivisionSection
			
			if(dDivision !== null){
				for(section: dDivision){
					vars = vars + getSection(section)
				}
			}

		}
		
		return 'WORKING-STORAGE SECTION.\n' + vars
	}
	// SECTIONS
	
	def dispatch getSection(FileSection fileSection){}
	def dispatch getSection(DataBaseSection dbSection){}
	def dispatch getSection(WorkingStorageSection wStorageSection)'''
		«IF wStorageSection.dataDescriptionEntry !== null»
			«FOR vars: wStorageSection.dataDescriptionEntry»
			    
				«vars.level» «vars.dataName» «FOR formatType : vars.data»«getVarProperty(formatType.data)»«ENDFOR»
			«ENDFOR»
		«ENDIF»
	'''
    def dispatch getSection(LinkageSection lSection){}
   	def dispatch getSection(CommunicationSection cSection){}
   	def dispatch getSection(LocalStorageSection  lStorageSection){}
   	def dispatch getSection(ScreenSection sSection){}
   	def dispatch getSection(ReportSection rSection){}
   	def dispatch getSection(ProgramLibrarySection pLibrarySection){}
   	
   
   	
//   	def dispatch getFormat(DataDescriptionEntryFormat2 dataDescriptionEntryFormat2){}
//   	def dispatch getFormat(DataDescriptionEntryFormat3 dataDescriptionEntryFormat3){}
//	def dispatch getFormat(DataDescriptionEntryExecSql dataDescriptionEntryFormat3){}
	
	// VARS
	def dispatch getVarProperty(DataDescriptionEntryFormat1 dataDescriptionEntryFormat1)''''''
	def dispatch getVarProperty(DataRedefinesClause dataRedefinesClause)''''''
	def dispatch getVarProperty(DataIntegerStringClause dataIntegerStringClause)''''''
	def dispatch getVarProperty(DataExternalClause dataExternalClause)''''''
	def dispatch getVarProperty(DataGlobalClause dataGlobalClause)''''''
	def dispatch getVarProperty(DataTypeDefClause dataTypeDefClause)''''''
	def dispatch getVarProperty(DataThreadLocalClause dataThreadLocalClause)''''''
	def dispatch getVarProperty(DataPictureClause dataPictureClause)'''
		«IF dataPictureClause!==null» PIC «dataPictureClause.pictureString» «ENDIF»
	'''
	def dispatch getVarProperty(DataCommonOwnLocalClause dataCommonOwnLocalClause)''''''
	def dispatch getVarProperty(DataTypeClause dataTypeClause)''''''
	def dispatch getVarProperty(DataUsingClause dataUsingClause)''''''
	def dispatch getVarProperty(DataUsageClause dataUsageClause)''''''
	def dispatch getVarProperty(DataValueClause dataValueClause)''''''
	def dispatch getVarProperty(DataReceivedByClause dataReceivedByClause)''''''
	def dispatch getVarProperty(DataOccursClause dataOccursClause)''''''
	def dispatch getVarProperty(DataSignClause dataSignClause)''''''
	def dispatch getVarProperty(DataSynchronizedClause dataSynchronizedClause)''''''
	def dispatch getVarProperty(DataJustifiedClause dataJustifiedClause)''''''
	def dispatch getVarProperty(DataBlankWhenZeroClause dataBlankWhenZeroClause)''''''
	def dispatch getVarProperty(DataWithLowerBoundsClause dataWithLowerBoundsClause)''''''
	def dispatch getVarProperty(DataAlignedClause dataAlignedClause)''''''
	def dispatch getVarProperty(DataRecordAreaClause dataRecordAreaClause)''''''
}