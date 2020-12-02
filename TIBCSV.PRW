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

User Function TIBCSV()		

Local aRet      := {}
Local aPWiz	    := {}
Local aRetWiz   := {}

SaveInter()

aAdd(aPWiz,{ 1,"Filial de: "      ,Space(6),"","","SM0","",9 ,.T.})
aAdd(aPWiz,{ 1,"Filial ate: "     ,Space(6),"","","SM0","",9 ,.T.})
aAdd(aPWiz,{ 1,"Fornecedor de: "  ,Space(6),"","","FOR","",9 ,.T.})
aAdd(aPWiz,{ 1,"Loja de: "        ,Space(6),"","","","",9 ,.T.})
aAdd(aPWiz,{ 1,"Fornecedor ate: " ,Space(6),"","","FOR","",9 ,.T.})
aAdd(aPWiz,{ 1,"Loja ate: "       ,Space(6),"","","","",9 ,.T.})
aAdd(aPWiz,{ 1,"Data de: "        ,Ctod(""),"","","",  ,60,.F.})
aAdd(aPWiz,{ 1,"Data ate: "       ,Ctod(""),"","","",  ,60,.F.}) 
aAdd(aPWiz,{ 1,"Número de: "      ,Space(6),"","","","",9 ,.F.})
aAdd(aPWiz,{ 1,"Número ate: "     ,Space(6),"","","","",9 ,.F.})
aAdd(aPWiz,{ 1,"Prefixo de: "     ,Space(6),"","","","",9 ,.F.})
aAdd(aPWiz,{ 1,"Prefixo ate: "    ,Space(6),"","","","",9 ,.F.})
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))
aAdd(aRetWiz,Space(9))

ParamBox(aPWiz,"Parametros Risco Sacado",@aRetWiz,,,,,,)  

TmpExpCsv(aRetWiz[1],aRetWiz[2],aRetWiz[3],aRetWiz[4],aRetWiz[5],aRetWiz[6],aRetWiz[7],aRetWiz[8],aRetWiz[9],aRetWiz[10],aRetWiz[11],aRetWiz[12])



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
					cLin += ';'+Alltrim(FieldGet(FieldPos(aStruTab[nX,1])))
				Case aStruTab[nX,2] == "L"
					cLin += ';'+Alltrim(IIf(FieldGet(FieldPos(aStruTab[nX,1])),"T","F"))
				Case aStruTab[nX,2] == "D"
					cLin += ';'+DTOC(FieldGet(FieldPos(aStruTab[nX,1])))
				Case aStruTab[nX,2] == "N"
					cLin += ';'+Alltrim(Str(FieldGet(FieldPos(aStruTab[nX,1]))))
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

Function TmpExpCsv(cFilDe, cFilAte, cForDe, cLojaDe, cForAte,cLojaAte, dDataIn, dDataFim, cNumDe, cNumAte, cPrefDe, cPrefAte)

Local aFields   := {}
Local _oTIB  := Nil
Local nI
Local cAlias    := "AliasCsv"
Local cQuery    := ""
Local aRet      := {}
Local aStruTab  := {}
Local cArqTmp   := "AliasCsv"
Local aEmpDados := {}
Local cAliAux   := GetNextAlias()
Local aCampos   := {}
Local cCgc      := ""

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

AADD(aCampos,{"E2_CNPJ"     ,"C",TamSX3("E2_CNPJRET")[1],0})
AADD(aCampos,{"E2_FORAGE"   ,"C",TamSX3("E2_FORAGE" )[1],0})
AADD(aCampos,{"E2_FORCTA"   ,"C",TamSX3("E2_FORCTA" )[1],0})
AADD(aCampos,{"E2_NOMEMP"   ,"C",TamSX3("E2_NOMFOR" )[1],0})
AADD(aCampos,{"E2_NOMFOR"   ,"C",TamSX3("E2_NOMFOR" )[1],0})
AADD(aCampos,{"E2_CNPJRET"  ,"C",TamSX3("E2_CNPJRET")[1],0})
AADD(aCampos,{"E2_EMISSAO"  ,"D",TamSX3("E2_EMISSAO")[1],0})
AADD(aCampos,{"E2_NUM"      ,"C",TamSX3("E2_NUM"    )[1],0})
AADD(aCampos,{"E2_USOEMP"   ,"C",2                      ,0})
AADD(aCampos,{"E2_VALOR"    ,"C",TamSX3("E2_VALOR"  )[1],2})
AADD(aCampos,{"E2_VENCTO"   ,"D",TamSX3("E2_VENCTO" )[1],0})

cQuery := "SELECT * FROM "
cQuery += RetSqlName("SE2") + " SE2 "
cQuery += " WHERE "
cQuery += " E2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND E2_FORNECE  Between '" + cForDe    + "' AND '" + cForAte  + "' " 
cQuery += " AND E2_LOJA  Between '" + cLojaDe    + "' AND '" + cLojaAte + "' " 
cQuery += " AND E2_VENCTO   Between '" + DTOS(dDataIn)   + "' AND '" + DTOS(dDataFim)  + "' " 
cQuery += " AND E2_NUM      Between '" + cNumDe    + "' AND '" + cNumAte  + "' " 
cQuery += " AND E2_PREFIXO  Between '" + cPrefDe   + "' AND '" + cPrefAte + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cAlias := "SE2TRB"

If _oTIB <> Nil
	_oTIB:Delete() 
	_oTIB := Nil
EndIf



// Criando o objeto do arquivo temporário
_oTIB := FwTemporaryTable():New("SE2TRB")

// Criando a estrutura do objeto  
_oTIB:SetFields(aCampos)

// Criando o indice da tabela
_oTIB:AddIndex("1",{"E2_NUM"})

_oTIB:Create()

DbselectArea("SE2")
dbGoTop()

cCgc := DadosFor(cForDe, cLojaDe)

Do While !(cAliAux)->(Eof())
	RecLock("SE2TRB",.T.)
	SE2TRB->E2_CNPJ      := Alltrim(aDadosEmp[2])
	SE2TRB->E2_FORAGE    := "1012" 
	SE2TRB->E2_FORCTA    := "573059"
	SE2TRB->E2_NOMEMP    := Alltrim(aDadosEmp[1])
	SE2TRB->E2_NOMFOR    := Alltrim((cAliAux)->E2_NOMFOR)
	SE2TRB->E2_CNPJRET   := Alltrim(cCgc)//Val((cAliAux)->E2_CNPJRET)
	SE2TRB->E2_EMISSAO   := STOD((cAliAux)->E2_EMISSAO)
	SE2TRB->E2_NUM       := Alltrim((cAliAux)->E2_NUM)
	SE2TRB->E2_USOEMP    := ""
	SE2TRB->E2_VALOR     := Alltrim(RetPts((cAliAux)->E2_VALOR))
	SE2TRB->E2_VENCTO    := STOD((cAliAux)->E2_VENCTO)
	MsUnLock()
	(cAliAux)->(dbskip())
Enddo

DbSelectArea("SE2")

If ParamBox({{6,"Estrutura de títulos",padr("",150),"",,"",90 ,.T.,"Arquivo .CSV |*.CSV","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrut. de plano de contas"###"Arquivo .CSV |*.CSV"
		"Exportar para estrutura de títulos(Risco Sacado)",@aRet) 

	oProcess:= MsNewProcess():New( {|lEnd| TibExpCSV( lEnd, oProcess, aRet[1], { {"SE2TRB",1} }, aCampos)} )
	oProcess:Activate()
	
	If MSGYESNO( "Deseja visualizar em Excel?", "Imprimir em Excel") 
		StilExc(cAlias)
	EndIf

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

//--------------------------------------------------
/*/{Protheus.doc} DadosFor
Carrega CNPJ Fornecedor (StilGraf)
Projeto Risco Sacado

@author André Brito
@since 11/02/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

Function DadosFor(cCod, cLoja)

Local aSaveArea	:= GetArea()
Local cForn	    := {}

Default cCod  := ""
Default cLoja := ""

DbSelectArea("SA2")
DbSetOrder(1)
If SA2->( DbSeek( xFilial('SA2') + cCod + cLoja ) )
	cForn := SA2->A2_CGC 
EndIf
                               
RestArea(aSaveArea)

Return cForn

//--------------------------------------------------
/*/{Protheus.doc} DadosFor
Exporta para Excel (StilGraf)
Projeto Risco Sacado

@author André Brito
@since 11/02/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

Function StilExc(cAlias)

Local cArquivo  := "RISCO_SACADO.XLS"
Local oExcelApp := Nil
Local cPath     := "C:\Planilha"
Local nTotal    := 0
Local oExcel
Local oExcelApp

aColunas := {}
aLocais  := {} 
oBrush1  := TBrush():New(, RGB(193,205,205))
 
// Verifica se o Excel está instalado na máquina
 
If !ApOleClient("MSExcel")

    MsgAlert("Falha ao abrir Excel!")
    Return

EndIf

oExcel  := FWMSExcel():New()
cAba    := "Risco Sacado"
cTabela := "Titulos"

// Criação de nova aba 
oExcel:AddworkSheet(cAba)

// Criação de tabela
oExcel:AddTable (cAba,cTabela)

// Criação de colunas 
oExcel:AddColumn(cAba,cTabela,"CNPJ"        ,1,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"AGEN. FOR."  ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"CONTA FOR."  ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"EMPRESA"     ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"NOME FOR."   ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"CNPJ FOR."   ,1,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"EMISSAO"     ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"USO EMP."    ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"NUMERO"      ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"VALOR"       ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"VENCIMENTO"  ,3,2,.F.) 

DbselectArea(cAlias)
dbGoTop()

While !(cAlias)->(Eof())
 
    // Criação de Linhas 
    oExcel:AddRow(cAba,cTabela, { (cAlias)->E2_CNPJ,;
                                  (cAlias)->E2_FORAGE  ,; 
                                  (cAlias)->E2_FORCTA ,; 
                                  (cAlias)->E2_NOMEMP,;
                                  (cAlias)->E2_NOMFOR ,;
                                  (cAlias)->E2_CNPJRET,;
                                  (cAlias)->E2_EMISSAO,;
                                  (cAlias)->E2_USOEMP,;
                                  (cAlias)->E2_NUM ,;
                                  (cAlias)->E2_VALOR ,;
                                  (cAlias)->E2_VENCTO})

    (cAlias)->(dbSkip())

End

If !Empty(oExcel:aWorkSheet)

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)
 
    CpyS2T("\SYSTEM\"+cArquivo, cPath)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath + "\" + cArquivo) // Abre a planilha
    oExcelApp:SetVisible(.T.)

EndIf


Function RetPts(nValX)

Local  cValX  := ""
Default nValX := ""

cValX := Str(nValX)
cValX := StrTran(cValX, '.', '')

Return Alltrim(cValx)

Function RetTrc(cCtaX)

Default cCtaX := ""

cCtaX := StrTran(cCtaX, '-', '')

Return Alltrim(cCtaX)