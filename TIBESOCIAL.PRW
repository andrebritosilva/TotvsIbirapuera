#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"   


User Function TIBESOCIAL()		

Local aRet      := {}
Local aPWiz	    := {}
Local aRetWiz   := {}

SaveInter()
aAdd(aPWiz,{ 1,"Data de: "        ,Ctod(""),"","",""   ,  ,60,.F.})
aAdd(aPWiz,{ 1,"Data ate: "       ,Ctod(""),"","",""   ,  ,60,.F.}) 

aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Ctod(""))

ParamBox(aPWiz,"Parametros Exportação E-Social",@aRetWiz,,,,,,)  

MsAguarde( { || TmpExpCsv(aRetWiz[1],aRetWiz[2]) },,"Criando Tabela Temporária...")

Return .T.


Function TmpExpCsv(dDataIn, dDataFim)

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
Local dDtRecep 
Local dDtProc  

AADD(aCampos,{"TPAMB"           ,"C",1    ,0})//SPED400 - AMBIENTE
AADD(aCampos,{"TPINSC"          ,"C",1    ,0})//CAMPO XMLRET
AADD(aCampos,{"NRINSC"          ,"C",18   ,0})//CAMPO XMLRET
AADD(aCampos,{"EVENTO"          ,"C",20   ,0})//SPED400
AADD(aCampos,{"IDEVENTO"        ,"C",40   ,0})//SPED400
AADD(aCampos,{"DHRECEP"         ,"C",20   ,0})//SPED400 - DTENTRADA
AADD(aCampos,{"DHPROCESS"       ,"C",20   ,0})//SPED400 - DTTRANS
AADD(aCampos,{"NRRECIBO"        ,"C",40   ,0})//CAMPO XMLRET
AADD(aCampos,{"NRPROTOCOL"      ,"C",40   ,0})//SPED400 - PROTOCOLO
AADD(aCampos,{"OPERACAO"        ,"C",2    ,0})//Verificar
AADD(aCampos,{"CHAVE"           ,"C",40   ,0})//SPED400 - CHAVE
AADD(aCampos,{"REC"             ,"N",4    ,0})//SPED400 - CHAVE 

cQuery := "SELECT R_E_C_N_O_,* FROM "
cQuery += " SPED4001" + " SPED4001 "
cQuery += " WHERE "
cQuery += " DTENTRADA   Between '" + DTOS(dDataIn)   + "' AND '" + DTOS(dDataFim)  + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cAlias := "SPED400"

If _oTIB <> Nil
	_oTIB:Delete() 
	_oTIB := Nil
EndIf

// Criando o objeto do arquivo temporário
_oTIB := FwTemporaryTable():New("SPED400")

// Criando a estrutura do objeto  
_oTIB:SetFields(aCampos)

// Criando o indice da tabela
_oTIB:AddIndex("1",{"CHAVE"})

_oTIB:Create()

DbselectArea("SPED400")
dbGoTop()

Do While !(cAliAux)->(Eof())
	RecLock("SPED400",.T.)
	
	dDtRecep := STOD(Alltrim((cAliAux)->DTENTRADA))
	dDtProc  := STOD(Alltrim((cAliAux)->DTTRANS))
	
	//ESocXml( cAliAux,(cAliAux)->R_E_C_N_O_)
	
	SPED400->TPAMB        := Alltrim((cAliAux)->AMBIENTE)
	SPED400->TPINSC       := ""//XML
	SPED400->NRINSC       := ""//XML
	SPED400->EVENTO       := Alltrim((cAliAux)->CODEVENTO)
	SPED400->IDEVENTO     := Alltrim((cAliAux)->ID)
	SPED400->DHRECEP      := DTOC(dDtRecep)+ " " + Alltrim((cAliAux)->HRENTRADA)
	SPED400->DHPROCESS    := DTOC(dDtProc) + " " + Alltrim((cAliAux)->HRTRANS)
	SPED400->NRRECIBO     := ""//XML
	SPED400->NRPROTOCOLO  := Alltrim((cAliAux)->PROTOCOLO)
	SPED400->OPERACAO     := ""//Verificar
	SPED400->CHAVE        := Alltrim((cAliAux)->CHAVE)
//	SPED400->XMLRET       := Alltrim((cAliAux)->XMLRET)
	MsUnLock()
	(cAliAux)->(dbskip())
Enddo

DbSelectArea("SPED400")

MsAguarde( { || SocialExc(cAlias) },,"Gerando Recibos em Excel...")

RestInter()

Return .T.


Function ESocXml(cAliAux, nRecno)

Local aSaveArea	:= GetArea()
Local cXml      := ""

DbselectArea("SPED4001")
SPED4001->(dbgoto(nRecno))

cXml 	:= SPED4001->XMLERP
                               
RestArea(aSaveArea)


Function SocialExc(cAlias)

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
cAba    := "Extracao de Eventos"
cTabela := "Recibos E-Social"

// Criação de nova aba 
oExcel:AddworkSheet(cAba)

// Criação de tabela
oExcel:AddTable (cAba,cTabela)

// Criação de colunas 
oExcel:AddColumn(cAba,cTabela,"TPAMB"          ,1,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"TPINSC"         ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"NRINSC"         ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"EVENTO"         ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"IDEVENTO"       ,3,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"DHRECEP"        ,1,2,.F.) 
oExcel:AddColumn(cAba,cTabela,"DHPROCESS"      ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"NRRECIBO"       ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"NRPROTOCOLO"    ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"OPERACAO"       ,2,1,.F.) 
oExcel:AddColumn(cAba,cTabela,"CHAVE_ESOCIAL"  ,3,2,.F.) 

DbselectArea(cAlias)
dbGoTop()

While !(cAlias)->(Eof())
 
    // Criação de Linhas 
    oExcel:AddRow(cAba,cTabela, { (cAlias)->TPAMB,;
                                  (cAlias)->TPINSC,; 
                                  (cAlias)->NRINSC,; 
                                  (cAlias)->EVENTO,;
                                  (cAlias)->IDEVENTO,;
                                  (cAlias)->DHRECEP,;
                                  (cAlias)->DHPROCESS,;
                                  (cAlias)->NRRECIBO,;
                                  (cAlias)->NRPROTOCOLO,;
                                  (cAlias)->OPERACAO,;
                                  (cAlias)->CHAVE})

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
