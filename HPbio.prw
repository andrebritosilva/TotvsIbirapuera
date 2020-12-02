#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"   

//--------------------------------------------------
/*/{Protheus.doc} TIBCSV
Exporta dados de títulos a pagar para .CSV (StilGraf)
Projeto Risco Sacado

@author André Brito
@since 11/02/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

User Function HPBio()		

Local aRet      := {}
Local aPWiz	    := {}
Local aRetWiz   := {}

TmpExpCsv()

Return .T.

//--------------------------------------------------
/*/{Protheus.doc} TibExpCSV
Exporta dados de títulos a pagar para .CSV (StilGraf)
Projeto Risco Sacado

@author André Brito
@since 11/02/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

Function TibExpCSV(lEnd, oProcess, cArq, aTables, aStruTab)
Local aStruct	:=	{}
Local aCpoSel	:=	{}
Local cLin		:=	""
Local aArea		:= GetArea()
Local aAreaAux
Local cAux
Local nX,nY
Local nRec,nTot
Local cID

SAVEINTER()

If At('.',cArq) == 0
	cArq	:=	AllTrim(cArq)+'.CSV'
EndIf	
 	If (nHandle := FCreate(cArq))== -1
	Alert("Erro na criacao do arquivo!")
	Return
EndIf

FWrite(nHandle,cLin,Len(cLin))

oProcess:SetRegua1(len(aTables)*2)

For nY := 1 to len(aTables)
	oProcess:IncRegua1("Lendo estrutura da tabela"+' '+aTables[nY,1]) 

	FWrite(nHandle,cLin,Len(cLin))
	
	aAreaAux := (aTables[nY,1])->(GetArea())
	DbSelectArea(aTables[nY,1])
	DbSetOrder(aTables[nY,2])
	DbGoTop()
	nTot := 0
	nRec := 0
	dbEval( {|x| nTot++ },,{|| !Eof()} )
	
	oProcess:IncRegua1("Exportando tabela"+' '+aTables[nY,1]) //"Exportando tabela"
	oProcess:SetRegua2(nTot)
	DbGoTop()
	Do While !Eof()
		cLin := "2"
		For nX := 1 To Len(aStruTab)
			Do Case
				Case aStruTab[nX,2] == "C"
					cLin += ';'+FieldGet(FieldPos(aStruTab[nX,1]))
				Case aStruTab[nX,2] == "L"
					cLin += ';'+IIf(FieldGet(FieldPos(aStruTab[nX,1])),"T","F")
				Case aStruTab[nX,2] == "D"
					cLin += ';'+DTOC(FieldGet(FieldPos(aStruTab[nX,1])))
				Case aStruTab[nX,2] == "N"
					cLin += ';'+Str(FieldGet(FieldPos(aStruTab[nX,1])))
				Otherwise
					cLin += ';'
			EndCase					
		Next
		cLin += CRLF
		FWrite(nHandle,cLin,Len(cLin))                          	
		DbSkip()
		nRec++
		oProcess:IncRegua2(Alltrim(Str(nRec))+'/'+Alltrim(Str(nTot)))
	EndDo
	RestArea(aAreaAux)
Next

FClose(nHandle)

Aviso("Finalizado","Exportacao gerada com sucesso",{"Ok"})

RestInter()

RestArea(aArea)

Return .T.


//--------------------------------------------------
/*/{Protheus.doc} TmpExpCsv
Monta Tabela Temporária (StilGraf)
Projeto Risco Sacado

@author André Brito
@since 11/02/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

Function TmpExpCsv()

Local aFields   := {}
Local oTempTable
Local nI
Local cAlias    := "AliasCsv"
Local cQuery    := ""
Local aRet      := {}
Local aStruTab  := {}
Local cArqTmp   := "AliasCsv"
Local aEmpDados := {}
Local cAliAux   := GetNextAlias()
Local aCampos   := {}

Default cFilDe   := ""
Default cFilAte  := ""
Default dDataIn  := ""
Default dDataFim := "" 
Default cNumDe   := "" 
Default cNumAte  := "" 
Default cPrefDe  := "" 
Default cPrefAte := ""
Default cForDe   := ""
Default cForAte  := ""

aDadosEmp := EmpDados()

AADD(aCampos,{"B1_COD"      ,"C",20,0})
AADD(aCampos,{"B1_CAHPB"    ,"C",20,0})
AADD(aCampos,{"B1_DESC"     ,"C",30,0})
AADD(aCampos,{"B1_TIPO"     ,"C",5,0})
AADD(aCampos,{"X5_DESCRI"   ,"C",40,0})
AADD(aCampos,{"B1_GRUPO"    ,"C",5,0})
AADD(aCampos,{"BM_DESC"     ,"C",30,0})
AADD(aCampos,{"A5_FORNECE"  ,"C",20,0})
AADD(aCampos,{"A5_LOJA"     ,"D",2,0})
AADD(aCampos,{"A5_NOMEFOR"  ,"C",20,0})
AADD(aCampos,{"BM_DESC"     ,"C",30,0})


cQuery := "SELECT B1_COD,B1_CAHPB,B1_DESC,B1_TIPO,B1_GRUPO,BM_DESC, X5_DESCRI,A5_FORNECE,A5_LOJA,A5_NOMEFOR"
cQuery += "FROM SB1010 B1, SBM010 BM, SA5010 A5, SX5010 X5"
cQuery += "WHERE B1.D_E_L_E_T_ = ' '"
cQuery += " AND BM.D_E_L_E_T_ = ' '"
cQuery += " AND A5.D_E_L_E_T_ = ' '"
cQuery += " AND X5.D_E_L_E_T_ = ' '"
cQuery += " AND B1_COD = A5_PRODUTO"
cQuery += " AND B1_GRUPO = BM_GRUPO"
cQuery += " AND X5_TABELA = '02'"
cQuery += " AND X5_CHAVE = B1_TIPO"
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cAlias := "SE2TRB"

_oTIB:Delete() 

// Criando o objeto do arquivo temporário
_oTIB := FwTemporaryTable():New("SE2TRB")

// Criando a estrutura do objeto  
_oTIB:SetFields(aCampos)

// Criando o indice da tabela
_oTIB:AddIndex("1",{"E2_NUM"})

_oTIB:Create()

DbselectArea("SE2")
dbGoTop()

Do While !(cAliAux)->(Eof())
	RecLock("SE2TRB",.T.)
	SE2TRB->B1_COD        := (cAliAux)->B1_COD 
	SE2TRB->B1_CAHPB      := (cAliAux)->B1_CAHPB 
	SE2TRB->B1_DESC       := (cAliAux)->B1_DESC
	SE2TRB->B1_TIPO       := (cAliAux)->B1_TIPO 
	SE2TRB->B1_GRUPO      := (cAliAux)->B1_GRUPO
	SE2TRB->BM_DESC       := (cAliAux)->BM_DESC
	SE2TRB->A5_FORNECE    := (cAliAux)->A5_FORNECE 
	SE2TRB->A5_LOJA       := (cAliAux)->A5_LOJA
	SE2TRB->A5_NOMEFOR    := (cAliAux)->A5_NOMEFOR 
	SE2TRB->BM_DESC       := (cAliAux)->BM_DESC
	MsUnLock()
	(cAliAux)->(dbskip())
Enddo

DbSelectArea("SB1")

If ParamBox({{6,"Estrutura de títulos",padr("",150),"",,"",90 ,.T.,"Arquivo .CSV |*.CSV","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrut. de plano de contas"###"Arquivo .CSV |*.CSV"
		"Exportar para estrutura de títulos(Risco Sacado)",@aRet) 

	oProcess:= MsNewProcess():New( {|lEnd| TibExpCSV( lEnd, oProcess, aRet[1], { {"SE2TRB",1} }, aCampos)} )
	oProcess:Activate()

EndIf

RestInter()

Return .T.


//--------------------------------------------------
/*/{Protheus.doc} EmpDados
Carrega dados da empresa no Sigamat (StilGraf)
Projeto Risco Sacado

@author André Brito
@since 11/02/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

Function EmpDados()

Local aSaveArea	:= GetArea()
Local aDadosEmp	:= {}

DbSelectArea("SM0")
DbSetOrder(1)
DbSeek(cEmpAnt+cFilAnt)
Aadd(aDadosEmp,ALLTRIM(SM0->M0_NOMECOM))
Aadd(aDadosEmp, SUBSTR(SM0->M0_CGC,1,20)) 
                               
RestArea(aSaveArea)

Return aDadosEmp

