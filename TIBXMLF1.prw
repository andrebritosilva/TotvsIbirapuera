#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#include "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "XMLXFUN.CH"

// -----------------------------------------
// Diretorio Padrão de Arquivos em Trânsito
// -----------------------------------------
STATIC cTempDir := "\XML_TOTVS\TEMP\"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TIBXML001

TIB XML - Rotina responsável por apresentar um assistente de Triagem e Importação
de arquivos XML de orígem local ou e-mail previamente configurados.

@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------
User function TIBXMLF1()

Local oPanel
Local oNewPag
Local cNome   := ""
Local cFornec := ""
Local cCombo1 := ""
Local oStepWiz := nil
Local oPanelBkg
Local oFonte1
Local oFonte2

// ---------------------------------------------------------------------------------
// Ajusto a posição dos componetes para ficarem centralizados em qualquer resolução
// ---------------------------------------------------------------------------------
Local aSize	  := FWGetDialogSize( oMainWnd )
Local nWPanel := (((aSize[4]*0.5) - 380)/2)
Local nHPanel := (((aSize[3]*0.5) - 280)/2) + (((aSize[3]*0.5) - 280)/2) * 0.5

Private oDlg := nil
//Private DIRXML 		:= GetSrvProfString("Rootpath","") + IIF(GetRemoteType() <> 2 ,"\XML_TOTVS\","/XML_TOTVS/")	//Diretorio de armazenamento de arquivos do XML
Private DIRXML := "\XML_TOTVS\"
// -------------------------------------------------------------------------------
// Variáveis de Controle da Barra de Progresso da Tela1 - Triagem de Arquivos XML
// -------------------------------------------------------------------------------
Private o1Progress	:= Nil
Private o2Progress	:= Nil
Private o3Progress	:= Nil
Private o4Progress:= Nil

Private oSayTab1	:= Nil
Private oSayTab2	:= Nil
Private oSayTab3	:= Nil

Private oTBitmap1	:= Nil
Private oTBitmap2	:= Nil
Private oTBitmap3	:= Nil

Private cMsg1		:= "Aguardando confirmação..."
Private cMsg2		:= "Aguardando confirmação..."
Private cMsg3		:= "Aguardando confirmação..."

Private xlCkDir	  	:= .F.
Private xlCkMail	  	:= .F.

Private oCheck1, oGetDir , cGetDir  := Space(99)
Private oCheck2, oGetMail, cGetMail := Space(99)

Private aArqLog	 := {}
Private aCGCEmp	 := {}
Private aCGCFor   := {}
Private aCGCCli	  := {}

// -------------------------------------------------------------------------------
// GRUPO DE VARIÁVEIS UTILIZADAS PARA DETERMINAR OS TIPOS DE ARQUIVO A SEREM IMP.
// -------------------------------------------------------------------------------
Private lCheckNFS := .F.
Private lCheckNFE := .F.
Private lCheckCAN := .F.
Private lCheckINU := .F.
Private lCheckNFC := .F.
Private lCheckCTE := .F.
Private LCheckALL := .F.

// -------------------------------------------------------------------------------
// GRUPO DE PARÂMETROS UTILIZADOS DURANTE A EXECUÇÃO DA ROTINA DE IMPORTAÇÃO
// -------------------------------------------------------------------------------
Private cMailSrv :=	SuperGetMV('TI_MAILSRV',.F.,'pop3.bol.com.br'				)
Private cMailAcc :=	SuperGetMV('TI_MAILACC',.F.,'totvs.ibirapuera@bol.com.br'	)
Private cMailPsw :=	SuperGetMV('TI_MAILPSW',.F.,'nucleo@123'					)
Private nPopPort :=	SuperGetMV('TI_POPPORT',.F.,995								)
Private cProdPad := SuperGetMV('TI_PRODPAD',.F.,'0000002')

cGetMail:= cMailAcc

DEFINE DIALOG oDlg TITLE 'Totvs Ibirapuera - Importa XML'  FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL  STYLE nOR(WS_VISIBLE,WS_POPUP)

DEFINE FONT oFonte1 SIZE 10,22 BOLD
DEFINE FONT oFonte2 SIZE 07,16
DEFINE FONT oFonte3 BOLD

oPanelBkg:= tPanel():New(nHPanel,nWPanel,"",oDlg,,,,,,380, 280)
oPanelBkg:Align:= CONTROL_ALIGN_CENTER
oStepWiz:= FWWizardControl():New(oPanelBkg)//Instancia a classe FWWizard
oStepWiz:ActiveUISteps()

//----------------------------------
// WIZARD | PÁGINA 1 - APRESENTAÇÃO
//----------------------------------
oNewPag := oStepWiz:AddStep("1")
oNewPag:SetStepDescription("Apresentação")
oNewPag:SetConstruction({|Panel|cria_pg1(Panel, oFonte1, oFonte2)})
oNewPag:SetCancelAction({|| oDlg:End() , .T.})

//----------------------------------
// WIZARD | PÁGINA 2 - TRIAGEM
//----------------------------------
oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel)})
oNewPag:SetStepDescription("Triagem")
oNewPag:SetNextAction({|| TIBXMLFA() })
oNewPag:SetCancelAction({|| oDlg:End() , .T.})
oNewPag:SetPrevAction({|| .T. })
oNewPag:SetPrevTitle("Voltar")

//----------------------------------
// WIZARD | PÁGINA 1 - IMPORTAÇÃO
//----------------------------------
oNewPag := oStepWiz:AddStep("3", {|Panel|cria_pn3(Panel , oFonte3)})
oNewPag:SetStepDescription("Importação")
oNewPag:SetNextAction({||TIBXMLFD() , .T. , oDlg:End() })
oNewPag:SetCancelAction({|| oDlg:End() , .T.})
oNewPag:SetCancelWhen({||.F.})
oStepWiz:Activate()


ACTIVATE DIALOG oDlg CENTER

oStepWiz:Destroy()

Return

//--------------------------
// Construção da página 1
//--------------------------
Static Function cria_pg1(oPanel, oFonte1, oFonte2)

@ 010, 010 GROUP oGrpPar TO 165, 370 	PROMPT "" 		OF oPanel COLOR 0, 16777215 PIXEL

@ 025, 025 SAY   oSay01 PROMPT "Bem Vindo..."  SIZE 245, 011 OF oPanel COLORS 0, 16777215 PIXEL
oSay01:oFont:=oFonte1

@ 045, 025 SAY   oSay02 PROMPT "Este assistente irá lhe auxiliar no processo de Triagem e Importação de Arquivos XML. Clique em Avançar para começar..."  SIZE 350, 031 OF oPanel COLORS 0, 16777215 PIXEL
oSay02:oFont:=oFonte2

Return


//--------------------------
// Construção da página 2
//--------------------------
Static Function cria_pg2(oPanel, oFonte1)
Local lLib	  	:= .F.
Local cDir	  	:= Alltrim( SuperGetMV("TIB_DIRPAD",, 'C:\Totvs\XML') )
Local cTitulo 	:= "TIB XML | Triagem"
Local aButtons 	:= {}

// ---------------------------------------------------------------
// GRUPO DE CAMPOS REFERENTES À ORIGEM DE BUSCA DOS ARQUIVOS XML
// ---------------------------------------------------------------
@ 010, 010 GROUP 	oGrpPar TO 55, 370 	PROMPT "Origem dos Arquivos XML " 		OF oPanel COLOR 0, 16777215 PIXEL

oCheck1 := TCheckBox():New(25,16,'Diretório'	,{|| xlCkDir},oPanel,100,210,,{|| xlCkDir := !xlCkDir },,,,,,.T.,,,	{|| .T.})
@ 022, 052 MSGET  	oGetDir VAR    cGetDir When lLib SIZE 299, 010 OF oPanel PIXEL
oGetDir:lActive := .F.

@ 022, 356 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oPanel ACTION (fPegaDir(@oGetDir,@cGetDir)) PIXEL

oCheck2 := TCheckBox():New(39,16,'E-mail'		,{|| xlCkMail},oPanel,100,210,,{|| xlCkMail := !xlCkMail 	},,,,,,.T.,,,	{|| .T.})
@ 037, 052 MSGET  	oGetMail VAR    cGetMail When lLib SIZE 299, 010 OF oPanel PIXEL
oGetMail:lActive := .F.

// ---------------------------------------------------------------
// GRUPO DE CAMPOS REFERENTES AO PROCESSAMENTO DAS OPERAÇÕES
// ---------------------------------------------------------------

@ 060, 010 	GROUP oGrpCam TO 165, 370 	PROMPT "Progresso das Operações" 	OF oPanel  PIXEL

@ 072, 015 SAY   oSayTab1 PROMPT "[DIRETÓRIO] - " + cMsg1  SIZE 245, 011 OF oPanel COLORS 0, 16777215 PIXEL
o1Progress	:=	TMeter():New(080,15,, 50 ,oPanel ,335,15,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)

oTBitmap1 := TBitmap():New(081,352,50,50,,"\xml_totvs\img\TOTVS2.PNG",.T.,oGrpCam, {||Alert("Clique em TBitmap1")},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

@ 102, 015 SAY   oSayTab2 PROMPT "[E-MAIL] - " + cMsg2  SIZE 245, 011 OF oPanel COLORS 0, 16777215 PIXEL
o2Progress	:=	TMeter():New(110,15,, 50 ,oPanel ,335,15,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)

oTBitmap2 := TBitmap():New(111,352,50,50,,"\xml_totvs\img\TOTVS2.PNG",.T.,oGrpCam, {||Alert("Clique em TBitmap1")},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap2:lAutoSize := .T.

@ 132, 015 SAY   oSayTab3 PROMPT "[GRAVAÇÃO DE LOG] - " + cMsg3   SIZE 140, 011 OF oPanel COLORS 0, 16777215 PIXEL
o3Progress	:=	TMeter():New(140,15,, 50 ,oPanel ,335,15,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)

oTBitmap3 := TBitmap():New(141,352,50,50,,"\xml_totvs\img\TOTVS2.PNG",.T.,oGrpCam, {||Alert("Clique em TBitmap1")},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap2:lAutoSize := .T.
// ---------------------------------------------------------------
// GRUPO DE CAMPOS REFERENTES AOS HELPS DE CAMPOS DO DIALOG ATUAL
// ---------------------------------------------------------------
/*
oGetDir:bHelp 	:= {|| ShowHelpCpo( "cGetDir", 	{"Arquivo CSV ou TXT que será importado."+cEnter+"Exemplo: C:\teste.CSV"},2,{},2)}
oGetMail:bHelp 	:= {|| ShowHelpCpo( "cGetMail", {"Arquivo CSV ou TXT que será importado."+cEnter+"Exemplo: C:\teste.CSV"},2,{},2)}

o3Progress:SetTotal(200)
o3Progress:Set(200)
*/
Aadd( aButtons, {"CPLIPS"	, {|| Processa({|| U_TIBXMLFB() }, "Atualizando Diretórios...") 	}  	, "Atualiza Diretórios...", "Atualiza Diretórios" , {|| .T.}} )

Return


//----------------------------------------
// Validação do botão Próximo da página 2
//----------------------------------------
Static Function valida_pg2(cCombo1)
Local lRet := .F.
If cCombo1 == 'Item3'
	lRet := .T.
Else
	Alert("Você selecionou: " + cCombo1 + " para prossegir selecione Item3")
EndIf
Return lRet

//--------------------------
// Construção da página 3
//--------------------------
Static Function cria_pn3(oPanel,oFonte3)

@ 010, 010 GROUP oGrpPar TO 130, 370 	PROMPT "Selecione os Tipos de XML que deseja importar" 		OF oPanel COLOR 0, 16777215 PIXEL

oCheckNFS := TCheckBox():New(025,16,'Nota Fiscal de Saída'			,{|| lCheckNFS},oPanel,100,210,,{|| lCheckNFS := !lCheckNFS },,,,,,.T.,,,	{|| .T.})
oCheckNFE := TCheckBox():New(040,16,'Nota Fiscal de Entrada'		,{|| lCheckNFE},oPanel,100,210,,{|| lCheckNFE := !lCheckNFE },,,,,,.T.,,,	{|| .T.})
oCheckCAN := TCheckBox():New(055,16,'Eventos de Cancelamento'		,{|| lCheckCAN},oPanel,100,210,,{|| lCheckCAN := !lCheckCAN },,,,,,.T.,,,	{|| .T.})
oCheckINU := TCheckBox():New(070,16,'Eventos de Inutilização de NF'	,{|| lCheckINU},oPanel,100,210,,{|| lCheckINU := !lCheckINU },,,,,,.T.,,,	{|| .T.})
oCheckNFC := TCheckBox():New(085,16,'Nota Fiscal Complementar'		,{|| lCheckNFC},oPanel,100,210,,{|| lCheckNFC := !lCheckNFC },,,,,,.T.,,,	{|| .T.})
oCheckCTE := TCheckBox():New(100,16,'Conhecimento de Transporte'	,{|| lCheckCTE},oPanel,100,210,,{|| lCheckCTE := !lCheckCTE },,,,,,.T.,,,	{|| .T.})

oCheckALL := TCheckBox():New(117,16,'Considera Filiais?'			,{|| lCheckALL},oPanel,100,210,,{|| lCheckALL := !lCheckALL },,,,,,.T.,,,	{|| .T.})
oCheckALL:oFont:=oFonte3

@ 135, 010 GROUP oGrpPar TO 165	, 370 	PROMPT "Progresso da Importação" 		OF oPanel COLOR 0, 16777215 PIXEL

o4Progress	:=	TMeter():New(145,15,, 50 ,oPanel ,350,15,,.T.,/*oFtArialB*/,"",.T.,,,GetSysColor(13),GetSysColor(),.F.)


Return

Static Function TIBXMLFA()

Local lAtuDir  := SuperGetMV("TIB_ATUDIR",, .T.)
Local aFiles   := {}
Local aDados   := {}
Local i		   := 0
Local x		   := 0

cGetDir	:= Alltrim(cGetDir)

aFiles	:= Directory(cGetDir+"*.XML", "D")

// --------------------------------------------------
// Função Responsável por Criar os Diretórios Destino
// --------------------------------------------------
If lAtuDir
	U_TIBXMLFB()
EndIf


If xlCkDir .or. xlCkMail // Busca Arquivos XML no diretório informado/

	If xlCkDir
		If !Empty(cGetDir)
			If Len(aFiles) > 0
				o1Progress:SetTotal(Len(aFiles)- (Len(aFiles)/100) )

				TIBXMLD(aFiles,@o1Progress,@cMsg1,@oSayTab1,"1")

				// -----------------------------------------------------------
				// Trecho criado para corrigir o BUG Padrão do TMeter()
				// -----------------------------------------------------------
				o1Progress:SetTotal(100)
				o1Progress:Set(100)
				o1Progress:Refresh()

				cMsg1:= "Arquivos Processados com Sucesso!"
				oSayTab1:Refresh()
				oTBitmap1:Load(NIL, "\xml_totvs\img\TOTVS.PNG" )
				oTBitmap1:Refresh()
			Else
				MsgInfo("Não há arquivos XML no diretório selecionado!","Atenção")
			EndIf
		Else
			MsgInfo("Nenhum diretório foi selecionado!","Atenção")
		EndIf
	EndIf

	If xlCkMail
		If !Empty(cGetMail)
			If TIBXMLMAIL(cMailSrv,cMailAcc, cMailPsw, nPopPort)

				cGetDir := DIRXML + "TEMP_MAIL\"

				aFiles	:= Directory( DIRXML + "TEMP_MAIL\"+"*.XML", "D")

				TIBXMLD(aFiles,@o2Progress,@cMsg2,@oSayTab2,"2")

				// -----------------------------------------------------------
				// Trecho criado para corrigir o BUG Padrão do TMeter()
				// -----------------------------------------------------------
				o2Progress:SetTotal(100)
				o2Progress:Set(100)
				o2Progress:Refresh()

				cMsg2:= "E-Mail Verificado com Sucesso!"
				oSayTab2:Refresh()
				oTBitmap2:Load(NIL, "\xml_totvs\img\TOTVS.PNG" )
				oTBitmap2:Refresh()
			EndIf
		EndIf
	EndIf
Else
	If !(MsgYesNo("Nenhuma origem (DIRETÓRIO / E-MAIL) foi selecionada. Deseja pular esta etapa?","Atenção!"))
		lRet:= .F.
	EndIf
EndIf

// --------------------------
// GRAVAÇÃO DOS DADOS DE LOG
// --------------------------

If Len(aArqLog) > 0
	cLog_SQL := ''
	// -----------------------------------------------------------
	// XTH - Trecho criado para corrigir o BUG Padrão do TMeter()
	// -----------------------------------------------------------
	o3Progress:SetTotal(Len(aArqLog))

	For x := 1 to Len(aArqLog)

		o3Progress:Set(x)
		cMsg3:= "Gravando LOG " + Alltrim(STR(x)) + " de " + Alltrim(STR(Len(aArqLog)))
		oSayTab3:Refresh()

		//Abrindo Tabela
		DbSelectArea('ZA1')

		//Compondo SQL para INSERT
		cLog_SQL := "INSERT INTO ZA1" + aArqLog[x, 20] + "0" + CHR(13) + CHR(10)
		cLog_SQL += "(ZA1_FILIAL" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_COD" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_STATUS" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_ORIGEM" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_NOMORI" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_NEWNOM" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CHAVE" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_DATA" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_HOTA" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_DOC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_SERIE" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_DTDOC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_USER" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_PARTIC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CODPAR" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_LOJPAR" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_TIPO" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_EMIT" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_DEST" + CHR(13) + CHR(10)
		cLog_SQL += ",D_E_L_E_T_" + CHR(13) + CHR(10)
		cLog_SQL += ",R_E_C_N_O_" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCEMI" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCDES" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCTRP" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_TRANCT" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCDTC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_DESTCT" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCREC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_REMCTE" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCEXC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_EXPCTE" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCRCC" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_RECCTE" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_CGCTOM" + CHR(13) + CHR(10)
		cLog_SQL += ",ZA1_TOMCTE)" + CHR(13) + CHR(10)
		cLog_SQL += "VALUES" + CHR(13) + CHR(10)
		cLog_SQL += "(" + CHR(13) + CHR(10)
		cLog_SQL += "'" + aArqLog[x, 21] + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + NextNumero("ZA1",1,"ZA1_COD",.T.,"000001") + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 01], TamSX3('ZA1_STATUS')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 02], TamSX3('ZA1_ORIGEM')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 03], TamSX3('ZA1_NOMORI')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 04], TamSX3('ZA1_NEWNOM')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 05], TamSX3('ZA1_CHAVE')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + DTOS(aArqLog[x, 06]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 08], TamSX3('ZA1_HOTA')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 09], TamSX3('ZA1_DOC')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 10], TamSX3('ZA1_SERIE')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + DTOS(aArqLog[x, 07]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 11], TamSX3('ZA1_USER')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 12], TamSX3('ZA1_PARTIC')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 13], TamSX3('ZA1_CODPAR')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 14], TamSX3('ZA1_LOJPAR')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 15], TamSX3('ZA1_TIPO')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 16], TamSX3('ZA1_EMIT')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 17], TamSX3('ZA1_DEST')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",' '" + CHR(13) + CHR(10) //D_E_L_E_T_
		cLog_SQL += ",(SELECT ISNULL(MAX(R_E_C_N_O_), 0) + 1 FROM ZA1" + aArqLog[x, 20] + "0)" + CHR(13) + CHR(10) //R_E_C_N_O_
		cLog_SQL += ",'" + Left(aArqLog[x, 18], TamSX3('ZA1_CGCEMI')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 19], TamSX3('ZA1_CGCDES')[01]) + "'" + CHR(13) + CHR(10)

		cLog_SQL += ",'" + Left(aArqLog[x, 22], TamSX3('ZA1_CGCTRP')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 23], TamSX3('ZA1_TRANCT')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 24], TamSX3('ZA1_CGCDTC')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 25], TamSX3('ZA1_DESTCT')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 26], TamSX3('ZA1_CGCREC')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 27], TamSX3('ZA1_REMCTE')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 28], TamSX3('ZA1_CGCEXC')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 29], TamSX3('ZA1_EXPCTE')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 30], TamSX3('ZA1_CGCRCC')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 31], TamSX3('ZA1_RECCTE')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 32], TamSX3('ZA1_CGCTOM')[01]) + "'" + CHR(13) + CHR(10)
		cLog_SQL += ",'" + Left(aArqLog[x, 33], TamSX3('ZA1_TOMCTE')[01]) + "'" + CHR(13) + CHR(10)

		cLog_SQL += ")" + CHR(13) + CHR(10)

		nExec := TcSQLExec(cLog_SQL)

		If (nExec < 0)
			Aviso('Erro na Inclusão de Log', TcSQLError(), {'OK'}, 03)
		EndIf

		/*
		Reclock("ZA1", .T.)

		ZA1->ZA1_FILIAL	:= xFilial("ZA1")
		ZA1->ZA1_COD 	:= NextNumero("ZA1",1,"ZA1_COD",.T.,"000001")
		ZA1->ZA1_STATUS := aArqLog[x][01]
		ZA1->ZA1_ORIGEM := aArqLog[x][02]
		ZA1->ZA1_NOMORI := aArqLog[x][03]
		ZA1->ZA1_NEWNOM := aArqLog[x][04]
		ZA1->ZA1_CHAVE  := aArqLog[x][05]
		ZA1->ZA1_DATA 	:= aArqLog[x][06]
		ZA1->ZA1_HOTA 	:= aArqLog[x][08]
		ZA1->ZA1_DOC   	:= aArqLog[x][09]
		ZA1->ZA1_SERIE 	:= aArqLog[x][10]
		ZA1->ZA1_DTDOC 	:= aArqLog[x][07]
		ZA1->ZA1_USER   := aArqLog[x][11]
		ZA1->ZA1_PARTIC := aArqLog[x][12]
		ZA1->ZA1_CODPAR := aArqLog[x][13]
		ZA1->ZA1_LOJPAR := aArqLog[x][14]
		ZA1->ZA1_TIPO 	:= aArqLog[x][15]
		ZA1->ZA1_EMIT 	:= aArqLog[x][16]
		ZA1->ZA1_DEST 	:= aArqLog[x][17]
		ZA1->ZA1_CGCEMI	:= aArqLog[x][18]
		ZA1->ZA1_CGCDES	:= aArqLog[x][19]
		ZA1->(MsUnlock())
		*/

	Next x

	// -----------------------------------------------------------
	// XTH - Trecho criado para corrigir o BUG Padrão do TMeter()
	// -----------------------------------------------------------
	o3Progress:SetTotal(100)
	o3Progress:Set(100)
	o3Progress:Refresh()

	cMsg3:= "Informações de Log salvas com sucesso!"
	oSayTab3:Refresh()
	oTBitmap3:Load(NIL, "\xml_totvs\img\TOTVS.PNG" )
	oTBitmap3:Refresh()
EndIf

Return .T.

/*/
----------------------------------------------------------------------

@author	 Fernando Alves Silva
@since 	 08/09/2016
@version P12 R7

@return Nil
----------------------------------------------------------------------
/*/

User Function TIBXMLFB()

Local aAreaSMO 	:= SM0->( GetArea() )
Local cKeyEmp 	:= ""
Local nRetDir 	:= 0
Local i			:= 0
Local aTP_NF	:= {"NF_SAIDA","NF_ENTRADA","NF_TRANSPORTE","CANCELAMENTOS","INUTILIZACOES","CARTA_CORRECAO"}
DbSelectArea("SM0")
SM0->(DbGoTop())

If !ExistDir(DIRXML)
	nRetDir := MakeDir(DIRXML)
	If nRetDir >= 0
		Conout( "Não foi possível criar o diretório ["+DIRXML+"]. Erro: " + cValToChar( FError() ) )
	EndIf
EndIf

If !ExistDir(DIRXML+"TEMP_MAIL\")
	MakeDir(DIRXML+"TEMP_MAIL\")
EndIf

If !ExistDir(DIRXML+"TEMP_IMP\")
	MakeDir(DIRXML+"TEMP_IMP\")
EndIf

If !ExistDir(DIRXML+"TEMP_ERRO\")
	MakeDir(DIRXML+"TEMP_ERRO\")
EndIf

If !ExistDir(DIRXML+"TEMP\")
	MakeDir(DIRXML+"TEMP\")
EndIf


While SM0->(!Eof())

	aAdd(aCGCEmp, {SM0->M0_CODIGO+SM0->M0_CODFIL, SM0->M0_CGC, SM0->M0_CODIGO, SM0->M0_CODFIL} )

	cKeyEmp:= Alltrim(SM0->M0_CGC)

	If !ExistDir(DIRXML+cKeyEmp)

		nRetDir := MakeDir( DIRXML+cKeyEmp )

		If nRetDir >= 0
			For i := 1 to Len(aTP_NF)
				MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] 				)
				MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] + "\NAO_PROC"	)
				MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] + "\IMPORTADOS"	)
				MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] + "\NAO_IMP"	)
			Next i
		Else
			Conout( "Não foi possível criar o diretório ["+DIRXML+cKeyEmp+"]. Erro: " + cValToChar( FError() ) )
		EndIf
	Else
		For i := 1 to Len(aTP_NF)
			MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] 				)
			MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] + "\NAO_PROC"	)
			MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] + "\IMPORTADOS"	)
			MakeDir( DIRXML+cKeyEmp + "\" + aTP_NF[i] + "\NAO_IMP"	)
		Next i
	EndIf

	SM0->(DbSkip())

EndDo

Return

/*/
----------------------------------------------------------------------

@author	 Fernando Alves Silva
@since 	 08/09/2016
@version P12 R7

@return Nil
----------------------------------------------------------------------
/*/

Static Function fPegaDir(oGetDir,cGetDir)

Local cArqAux := ""

cArqAux := cGetFile( '*.*' , 'Selecione o Diretório', 1, , .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
cArqAux := ALLTRIM( cArqAux )
cGetDir := PadR(cArqAux, 99)
oGetDir:Refresh()
oDlg:Refresh()

Return  .T.


Static Function TIBXMLD(aFiles,oProgX,cMsgX,oSayX,cOri)

Local cNewName	:= ""
Local aDados	:= {}
Local i			:= 0
Local nLog      := 0

Private aLogTria := {} //Log da Triagem

For i := 1 to Len(aFiles)

	oProgX:Set(i)
	cMsgX:= "Processando Arquivo [" + aFiles[i][1] + "]"
	oSayX:Refresh()

	cNewName:= Alltrim(STR(i))+ "_" + DtoS(dDataBase) + "_" + StrTran(Time(),":","") + ".XML"

	// --------------------------------------------------------------------------------------
	// Função para identificar o Tipo de XML e transferir os arquivo para o diretório destino
	// --------------------------------------------------------------------------------------
	If (__CopyFile(cGetDir + aFiles[i][1],cTempDir + cNewName ))
		//Adicionando Linha com referência ao Log de Processamento do XML
		AAdd(aLogTria, {'', ''}) //[01] - Informações do XML [02] - Log de Processamento
		aLogTria[Len(aLogTria), 01] += 'Arquivo XML: ' + AllTrim(aFiles[i][01]) + CHR(13) + CHR(10)
		TIBXMLFC(cTempDir+cNewName,cOri,aFiles[i][1],cNewName)
		aAdd(aDados, {.F. , aFiles[i][1] , aFiles[i][2] , aFiles[i][3] , aFiles[i][4] , aFiles[i][5] } )
		//Caso tenha copiado com sucesso, e seja MAIL ... Apagar
		If ('TEMP_MAIL' $ Upper(cGetDir))
			nHdl := FErase(cGetDir + aFiles[i][1])
			If (nHdl == -1)
				 ConOut('Erro na eliminação do arquivo nº ' + STR(FERROR()))
			EndIf
		EndIf
	Else
		ConOut('Não foi possível copiar o arquivo: ' + aFiles[i][1])
	EndIf
Next i

//Mostrando Log de Processamento
cLogXML := ''
For nLog := 1 To Len(aLogTria)
	If !(Empty(aLogTria[nLog, 02]))
		cLogXML += aLogTria[nLog, 01] + CHR(13) + CHR(10)
		cLogXML += aLogTria[nLog, 02] + CHR(13) + CHR(10)
		cLogXML += Replicate('_', 15) + CHR(13) + CHR(10)
	EndIf
Next nLog
If !(Empty(cLogXML))
	nOpcAv := Aviso('Importação de XML', 'XMLs Não Triados: ' + CHR(13) + CHR(10) + cLogXML, {'OK', 'Salvar'}, 03)
	If (nOpcAv == 2) //Gerando Arquivo Texto
		cArqAux := cGetFile( '*.*' , 'Selecione o Diretório', 1, , .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
		cArqAux := ALLTRIM( cArqAux )
		If !(Empty(cArqAux))
			If !(Right(cArqAux, 01) == '\')
				cArqAux += '\'
			EndIf
			cNomeArq := 'Log_Triagem_XML_' + STrTran(DTOC(dDataBase), '/', '-') + '_' + StrTran(Time(), ':', '-') + '.TXT'
			cArqAux += cNomeArq
			MemoWrite(cArqAux, cLogXML)
		EndIf
	EndIf
EndIf

Return .T.

/*/
----------------------------------------------------------------------

@author	 Fernando Alves Silva
@since 	 08/09/2016
@version P12 R7

@return Nil
----------------------------------------------------------------------
/*/

Static Function TIBXMLFC(cArqXML,cOri,cNomeAnt,cNomeNew)

Local cError    	:= ""
Local cWarning  	:= ""
Local lFound    	:= .F.
Local nX			:= 0
Local cEmpDest		:= ""
Local lRet			:= .F.
Local aEmpDest		:= {}
Local aEmpEmit		:= {}

Private cLog_Status	:= "1"
Private cLog_Origem	:= cOri
Private cLog_ArqOri	:= cNomeAnt
Private cLog_ArqNew	:= cNomeNew
Private cLog_Chave	:= ""
Private cLog_DtPro	:= dDataBase
Private cLog_DtDoc	:= StoD(" ")
Private cLog_HrPro	:= TIME()
Private cLog_NumDoc	:= ""
Private cLog_SerDoc	:= ""
Private cLog_User		:= Alltrim(cUserName)
Private cLog_Part		:= ""
Private cLog_CodPar	:= ""
Private cLog_LojPar	:= ""
Private cLog_Tipo		:= ""
Private cLog_ArqXML   := cArqXML
Private cLog_CGCEm    := "" //CGC Emitente
Private cLog_Emit		:= ""
Private cLog_CGCDe    := "" //CGC Destinatário
Private cLog_Dest		:= ""
Private cLog_Emp      := "" //Empresa
Private cLog_Fil      := "" //Filial
Private cLog_SQL      := "" //SQL de Inclusão de Log
Private cTpCTe        := "0" //Tipo do CTE
Private cToma03       := "0" //Tomador 03
Private cCGCEmit      := "" //CGC do Emitente
Private cCGCDest      := "" //CGC do Destinatário
Private cCGCRem       := "" //CGC do Remetente
Private cCGCExp       := "" //CGC do Expedidor
Private cCGCRec       := "" //CGC do Recebedor
Private cCGCTom       := "" //CGC do Tomador
Private cRemCTe       := "" //Nome Remetente CTe
Private cEmitCTe      := "" //Nome Emitente CTe
Private cDestCTe      := "" //Nome Destinatário CTe
Private cExpCTE       := "" //Nome Expedidor CTe
Private cRecCTe       := "" //Nome Recebedor CTe
Private cTomCTe       := "" //Nome Tomador CTe
Private cTpNF         := "" //Tipo de Nota Fiscal
Private lNF			:= .T.
Private lCanc			:= .F.
Private lCTe			:= .F.
Private lCTeTMS			:= .F.
Private lInut			:= .F.
Private lImp			:= .F.

Private oFullXML	:= XmlParserFile(cArqXML,"_",@cError,@cWarning)
Private cXML 		:= MemoRead(cArqXML)
Private oXML    	:= oFullXML
Private oAuxXML 	:= oXML
Private cDirDest	:= ""
Private oXmlOk		:= Nil

//-- Erro na sintaxe do XML
If Empty(oFullXML) .Or. !Empty(cError)
	aLogTria[Len(aLogTria), 02] += "Erro de sintaxe no arquivo XML: " + cError + CHR(13) + CHR(10)
	Conout("[DIXGetXML] Erro de sintaxe no arquivo XML: "+cError,"Entre em contato com o emissor do documento e comunique a ocorrência.")
Else
	lRet := .T.
EndIf

If lRet

	//-- Resgata o no inicial da NF-e
	Do While !lFound
		If ValType(oAuxXML) <> "O"
			lNF:= .F.
			Exit
		EndIf
		oAuxXML := XmlChildEx(oAuxXML,"_NFE")
		lFound := (oAuxXML <> NIL)
		If !lFound
			For nX := 1 To XmlChildCount(oXML)
				oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
				If ValType(oAuxXML) == "O"
					lFound := oAuxXML:_InfNfe # Nil
					If lFound
						oXML := oAuxXML
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndDo

	If !lFound
		oXmlOk:= oXML
	Else
		oXmlOk:= oAuxXML
	EndIf

	If (XmlChildEx(oXmlOk ,"_PROCINUTNFE") <> NIL)
		oXmlOk := oXmlOk:_PROCINUTNFE
	EndIf

	If lNF
		aEmpDest	:= fPartXML( IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_CNPJ") <> Nil,oXmlOk:_InfNfe:_DEST:_CNPJ:Text ,"EX") , "", oXmlOk:_InfNfe:_IDE:_TpNf:Text)
		aEmpEmit	:= fPartXML( "" , oXmlOk:_InfNfe:_EMIT:_CNPJ:Text, oXmlOk:_InfNfe:_IDE:_TpNf:Text)
		cTpNF       := oXmlOk:_InfNfe:_IDE:_TpNf:Text
		//Gravando Empresa e Filial do XML
		If (Len(aEmpDest) > 0)
			cLog_Emp := aEmpDest[01, 04] //Empresa
			cLog_Fil := aEmpDest[01, 05] //Filial
		EndIf
	Else
		If XmlChildEx(oXmlOk ,"_PROCEVENTONFE") <> Nil
			If oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT == "110111" // ENVENTO DE CANCELAMENTO

				/*
				If XmlChildEx(oXmlOk:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO,"_CNPJDEST") <> Nil
					aEmpDest := fPartXML(oXmlOk:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CNPJDEST:TEXT,oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CNPJ:TEXT,"C")
				Else
					aEmpDest := fPartXML("",oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CNPJ:TEXT,"C")
				EndIf
				*/

				aEmpDest := fPartXML("",oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CNPJ:TEXT,"C")

				If Len(aEmpDest) > 0

					cEmpDest := StrTran(aEmpDest[1][2],"\\","\")

					//Gravando Empresa e Filial do XML
					cLog_Emp := aEmpDest[01, 04] //Empresa
					cLog_Fil := aEmpDest[01, 05] //Filial

					cLog_CGCEm  := oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CNPJ:TEXT
					cLog_Emit	:= 'EMITENTE CANCELAMENTO'

					If XmlChildEx(oXmlOk:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO,"_CNPJDEST") <> Nil
						cLog_CGCDe  := oXmlOk:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CNPJDEST:TEXT
						cLog_Dest	:= 'DESTINATÁRIO CANCELAMENTO'
					EndIf

					cLog_Chave  := oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT
					cLog_DtDoc	:= StoD(StrTran(SubStr(oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DHEVENTO:TEXT,1,10),"-",""))
					cLog_NumDoc	:= SubStr(oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT,26,9)
					cLog_SerDoc	:= SubStr(oXmlOk:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT,23,3)
					cLog_Part	:= aEmpDest[1][1]

					If aEmpDest[1][1] == '1'
						cLog_CodPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_COD")
						cLog_LojPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_LOJA")
					Else
						cLog_CodPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_COD")
						cLog_LojPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_LOJA")
					EndIf
				Else
					// EMPRESA NÃO LOCALIZADA
					// AGUARDANDO DECISÃO DE TRATAMENTO
				EndIf
			EndIf
			lCanc := .T.

		ElseIf XmlChildEx(oXmlOk ,"_CTEPROC") <> Nil

			//Verificar o Tipo do CTe
			If XmlChildEx(oXMLOk:_CTEPROC:_CTE:_INFCTE ,"_IDE") <> Nil
				cTpCTe := AllTrim(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE:_tpCTe:TEXT)
				//Verificar qual o Tipo de Tomador
				If XmlChildEx(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE ,"_TOMA03") <> Nil
					cToma03 := AllTrim(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA03:_toma:TEXT)
				ElseIf XmlChildEx(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE ,"_TOMA4") <> Nil
					cToma03 := AllTrim(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_toma:TEXT)
				Else
					cTpCTe  := 'X' //Casos que não importará
					cToma03 := 'X'
				EndIf
			Else
				cTpCTe  := 'X' //Casos que não importará
				cToma03 := 'X'
			EndIf

			//Verifica se irá importar
			If !(cTpCTe == "0") .OR. (cToma03 == "X") //Não importará
				lCTe := .F.
			Else
				//Gravando CNPJ's

				//Tomador 4
				If (AllTrim(cToma03) == '4')
					If XmlChildEx(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE ,"_TOMA4") <> Nil
						//Alison 04.08.2017 //Tag CNPJ ou CPF
						If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4 ,"_CNPJ") <> Nil)
							cCGCTom := oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT
						ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4 ,"_CPF") <> Nil)
							cCGCTom  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CPF:TEXT
						Else
							cCGCTom := ""
						EndIf
					EndIf
				EndIf

				//Remetente
				If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_REM") <> Nil)
					//Alison 04.08.2017 //Tag CNPJ ou CPF
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM ,"_CNPJ") <> Nil)
						cCGCRem := oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
					ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM ,"_CPF") <> Nil)
						cCGCRem  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_CPF:TEXT
					Else
						cCGCRem := ""
					EndIf
				Else
					cCGCRem := ""
				EndIf
				//Emitente
				If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_EMIT") <> Nil)
					//Alison 04.08.2017 //Tag CNPJ ou CPF
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT ,"_CNPJ") <> Nil)
						cCGCEmit := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
					ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT ,"_CPF") <> Nil)
						cCGCEmit  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_CPF:TEXT
					Else
						cCGCEmit := ""
					EndIf
				Else
					cCGCEmit := ""
				EndIf
				//Destinatário
				If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_DEST") <> Nil)
					//Alison 04.08.2017 //Tag CNPJ ou CPF
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST ,"_CNPJ") <> Nil)
						cCGCDest := oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
					ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST ,"_CPF") <> Nil)
						cCGCDest  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT
					Else
						cCGCDest := ""
					EndIf
				Else
					cCGCDest := ""
				EndIf
				//Expedidor
				If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_EXPED") <> Nil)
					//Alison 04.08.2017 //Tag CNPJ ou CPF
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED ,"_CNPJ") <> Nil)
						cCGCExp := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT
					ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED ,"_CPF") <> Nil)
						cCGCExp  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED:_CPF:TEXT
					Else
						cCGCExp := ""
					EndIf
				Else
					cCGCExp := ""
				EndIf
				//Recebedor
				If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_RECEB") <> Nil)
					//Alison 19.07.2017 //Tag CNPJ ou CPF
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB ,"_CNPJ") <> Nil)
						cCGCRec := oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT
					ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB ,"_CPF") <> Nil)
						cCGCRec  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB:_CPF:TEXT
					Else
						cCGCRec := ""
					EndIf
				Else
					cCGCRec := ""
				EndIf

				//Alison 10/10/2017
				//Verificar se o Emitente do CTe é um cliente (SM0)
				If (Len(aEmpDest := fPartXML(cCGCEmit, cCGCEmit, "T")) > 0)
					lCTeTMS := .T.
					lCTe    := .F.
				Else
					//Verificar o Tomador
					Do Case
						Case cToma03 == '0'
							aEmpDest := fPartXML(cCGCRem, cCGCRem, "T")
						Case cToma03 == '1'
							aEmpDest := fPartXML(cCGCExp, cCGCExp, "T")
						Case cToma03 == '2'
							aEmpDest := fPartXML(cCGCRec, cCGCRec, "T")
						Case cToma03 == '3'
							aEmpDest := fPartXML(cCGCDest , cCGCDest, "T")
						Case cToma03 == '4'
							aEmpDest := fPartXML(cCGCTom , cCGCDest, "T")
					EndCase
				EndIf

				If Len(aEmpDest) > 0
					cEmpDest := StrTran(aEmpDest[1][2],"\\","\")

					//Gravando Empresa e Filial do XML
					cLog_Emp := aEmpDest[01, 04] //Empresa
					cLog_Fil := aEmpDest[01, 05] //Filial

					cLog_CGCEm	:= ""//oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
					cLog_Emit	:= ""//oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_xNome:TEXT
					cLog_CGCDe	:= ""//oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
					cLog_Dest	:= ""//oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_xNome:TEXT

					//Gravando CNPJ's
					//Tomador 4
					If (AllTrim(cToma03) == '4')
						If XmlChildEx(oXMLOk:_CTEPROC:_CTE:_INFCTE:_IDE ,"_TOMA4") <> Nil
							//Alison 04.08.2017 //Tag CNPJ ou CPF
							If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4 ,"_CNPJ") <> Nil)
								cCGCTom := oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT
							ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4 ,"_CPF") <> Nil)
								cCGCTom  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CPF:TEXT
							Else
								cCGCTom := ""
							EndIf
							cTomCTe := oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_xNome:TEXT
						EndIf
					EndIf

					//Remetente
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_REM") <> Nil)
						//Alison 04.08.2017 //Tag CNPJ ou CPF
						If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM ,"_CNPJ") <> Nil)
							cCGCRem := oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
						ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM ,"_CPF") <> Nil)
							cCGCRem  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_CPF:TEXT
						Else
							cCGCRem := ""
						EndIf
					Else
						cCGCRem := ""
					EndIf
					cRemCTe  := IIf(XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_REM") <> Nil, oXmlOk:_CTEPROC:_CTE:_INFCTE:_REM:_xNOME:TEXT, "") //Nome Remetente
					//Emitente
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_EMIT") <> Nil)
						//Alison 04.08.2017 //Tag CNPJ ou CPF
						If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT ,"_CNPJ") <> Nil)
							cCGCEmit := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
						ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT ,"_CPF") <> Nil)
							cCGCEmit  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_CPF:TEXT
						Else
							cCGCEmit := ""
						EndIf
					Else
						cCGCEmit := ""
					EndIf
					cEmitCTe := IIf(XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_EMIT") <> Nil, oXmlOk:_CTEPROC:_CTE:_INFCTE:_EMIT:_xNOME:TEXT, "") //Nome Emitente
					//Destinatário
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_DEST") <> Nil)
						//Alison 04.08.2017 //Tag CNPJ ou CPF
						If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST ,"_CNPJ") <> Nil)
							cCGCDest := oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
						ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST ,"_CPF") <> Nil)
							cCGCDest  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT
						Else
							cCGCDest := ""
						EndIf
					Else
						cCGCDest := ""
					EndIf
					cDestCTe := IIf(XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_DEST") <> Nil, oXmlOk:_CTEPROC:_CTE:_INFCTE:_DEST:_xNOME:TEXT, "") //Nome Destinatário
					//Expedidor
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_EXPED") <> Nil)
						//Alison 04.08.2017 //Tag CNPJ ou CPF
						If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED ,"_CNPJ") <> Nil)
							cCGCExp := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT
						ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED ,"_CPF") <> Nil)
							cCGCExp  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED:_CPF:TEXT
						Else
							cCGCExp := ""
						EndIf
					Else
						cCGCExp := ""
					EndIf
					cExpCTE  := IIf(XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_EXPED") <> Nil, oXmlOk:_CTEPROC:_CTE:_INFCTE:_EXPED:_xNOME:TEXT, "") //Nome Expedidor
					//Recebedor
					If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_RECEB") <> Nil)
						//Alison 19.07.2017 //Tag CNPJ ou CPF
						If (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB ,"_CNPJ") <> Nil)
							cCGCRec := oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT
						ElseIf (XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB ,"_CPF") <> Nil)
							cCGCRec  := oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB:_CPF:TEXT
						Else
							cCGCRec := ""
						EndIf
					Else
						cCGCRec := ""
					EndIf
					cRecCTe  := IIf(XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE ,"_RECEB") <> Nil, oXmlOk:_CTEPROC:_CTE:_INFCTE:_RECEB:_xNOME:TEXT, "") //Nome Recebedor

					cLog_Chave  := StrTran(oXmlOk:_CTEPROC:_CTE:_INFCTE:_ID:TEXT,"CTe","")
					ConOut('Teste')
					cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
					cLog_NumDoc	:= oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT
					cLog_SerDoc	:= oXmlOk:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
					cLog_Part	:= aEmpDest[1][1]

					If aEmpDest[1][1] == '1'
						cLog_CodPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_COD")
						cLog_LojPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_LOJA")
					Else
						cLog_CodPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_COD")
						cLog_LojPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_LOJA")
					EndIf
					lCTe := !lCTeTMS//.T.
				Else
					lCTe := .F.
					lCTeTMS := .F.
					// EMPRESA NÃO LOCALIZADA
					// AGUARDANDO DECISÃO DE TRATAMENTO
				EndIf
			EndIf
		ElseIf (XmlChildEx(oXmlOk ,"_RETINUTNFE") <> Nil) .Or. (XmlChildEx(oXmlOk ,"_INUTNFE") <> Nil)

			If XmlChildEx(oXmlOk ,"_RETINUTNFE") <> Nil
				aEmpDest := fPartXML("", oXmlOk:_RETINUTNFE:_INFINUT:_CNPJ:TEXT ,"I")
			Else
				aEmpDest := fPartXML("", oXmlOk:_INUTNFE:_INFINUT:_CNPJ:TEXT ,"I")
			EndIf

			If Len(aEmpDest) > 0
				cEmpDest := StrTran(aEmpDest[1][2],"\\","\")

				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpDest[01, 04] //Empresa
				cLog_Fil := aEmpDest[01, 05] //Filial

				If XmlChildEx(oXmlOk ,"_RETINUTNFE") <> Nil
					cLog_CGCEm	:= oXmlOk:_RETINUTNFE:_INFINUT:_CNPJ:TEXT
					cLog_Emit   := 'EMITENTE UNITILIZAÇÃO'
					cLog_CGCDe	:= oXmlOk:_RETINUTNFE:_INFINUT:_CNPJ:TEXT
					cLog_Dest   := 'DESTINATÁRIO UNITILIZAÇÃO'
					cLog_NumDoc	:= oXmlOk:_RETINUTNFE:_INFINUT:_NNFINI:TEXT
					cLog_SerDoc	:= oXmlOk:_RETINUTNFE:_INFINUT:_SERIE:TEXT
				Else
					cLog_CGCEm	:= oXmlOk:_INUTNFE:_INFINUT:_CNPJ:TEXT
					cLog_Emit   := 'EMITENTE UNITILIZAÇÃO'
					cLog_CGCDe	:= oXmlOk:_INUTNFE:_INFINUT:_CNPJ:TEXT
					cLog_Dest   := 'DESTINATÁRIO UNITILIZAÇÃO'
					cLog_NumDoc	:= oXmlOk:_INUTNFE:_INFINUT:_NNFINI:TEXT
					cLog_SerDoc	:= oXmlOk:_INUTNFE:_INFINUT:_SERIE:TEXT
				EndIf

				cLog_Chave := ""
				cLog_DtDoc	:= dDataBase

				If aEmpDest[1][1] == '1'
					cLog_CodPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_COD")
					cLog_LojPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_LOJA")
				Else
					cLog_CodPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_COD")
					cLog_LojPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_LOJA")
				EndIf
			Else
				// EMRPESA NÃO LOCALIZADA
				// AGUARDANDO DECISÃO DE TRATAMENTO
			EndIf
			lInut:= .T.
		EndIf

	EndIf

	//Gerando o Arquivo no Diretório Destino
	If Len(aEmpDest) > 0 .OR. Len(aEmpEmit) > 0
		CpyXML(aEmpDest, aEmpEmit)
	EndIf
EndIf

Return lRet

/**
	Rotina responsável pela cópia de arquivo XML
	no diretório correto de acordo com o CNPJ do emitente ou destinatário
**/
Static Function CpyXML(aEmpDest, aEmpEmit)
	Local cCGCEmit := '' //CNPJ Emitente
	Local cCGCDest := '' //CNPJ Destinatário
	Local lValid   := .T. //XML Válido

	//Verifica se o XML é Valido
	//Verifica se existe a Tag "NFEPROC"
	IF(XmlChildEx(oFullXML ,"_NFEPROC") <> Nil)
		oInfProt := Nil
		IF(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE ,"_INFPROT") <> Nil)
			oInfProt := oFullXML:_NFEPROC:_PROTNFE:_INFPROT
		ElseIF(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE ,"_PROTNFE") <> Nil)
			IF(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE:_PROTNFE ,"_INFPROT") <> Nil)
				oInfProt := oFullXML:_NFEPROC:_PROTNFE:_PROTNFE:_INFPROT
			EndIf
		EndIf
		If !(oInfProt == Nil)
			IF (XmlChildEx(oInfProt, "_TPAMB") <> Nil)
				If !(lValid := !(AllTrim(oInfProt:_TPAMB:TEXT) == '2'))
					aLogTria[Len(aLogTria), 02] += "XML Emitido em ambiente Homologação" + CHR(13) + CHR(10)
				EndIf
			EndIf
	   	EndIf
	EndIf


	/**
		TAG <TPNF>
		0 - ENTRADA
		1 - SAÍDA
	**/
	If (lValid)
		If !(Empty(cTpNF))
			//Pegando o CNPJ do Emitente
			cCGCEmit := IIf(Len(aEmpEmit) > 0, aEmpEmit[01, 03], "")
			//Pegando o CNPJ do Destinatário
			cCGCDest := IIf(Len(aEmpDest) > 0, aEmpDest[01, 03], "")
			//Verifica se os dois CNPJ's são iguais
			If (cCGCEmit == cCGCDest)
				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpEmit[01, 04] //Empresa
				cLog_Fil := aEmpEmit[01, 05] //Filial
				cEmpDest:= "\xml_totvs\" + Alltrim(cCGCEmit)
				//Verifica o Tipo da Nota Fiscal
				If (cTpNF == '0') //Entrada no Emitente
					cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
					cLog_Tipo	:= '1'
					cLog_CodPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCEmit, "A2_COD")
					cLog_LojPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCEmit, "A2_LOJA")
				ElseIf (cTpNF == '1') //Saída no Emitente
					cDirDest 	:= cEmpDest + "\nf_saida\nao_proc\"
					cLog_Tipo	:= '2'
					cLog_CodPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCEmit, "A1_COD")
					cLog_LojPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCEmit, "A1_LOJA")
				EndIf
				cLog_Chave 	:= StrTran(oXmlOk:_InfNfe:_ID:Text,"NFe","")
				cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
				cLog_NumDoc	:= oXmlOk:_InfNfe:_IDE:_NNF:TEXT
				cLog_SerDoc	:= oXmlOk:_InfNfe:_IDE:_SERIE:TEXT
				cLog_Part	:= aEmpEmit[1][1]

				cLog_CGCEm  := oXmlOk:_InfNfe:_EMIT:_CNPJ:Text
				cLog_Emit	:= oXmlOk:_InfNfe:_EMIT:_xNome:Text
				cLog_Dest	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_XNOME") <> Nil,oXmlOk:_InfNfe:_DEST:_xNome:Text ,"EX")
				cLog_CGCDe	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_CNPJ") <> Nil,oXmlOk:_InfNfe:_DEST:_CNPJ:Text ,"EX")
			ElseIf !(Empty(cCGCDest)) .AND. !(Empty(cCGCEmit)) .AND. !(cCGCDest == cCGCEmit)
				//Ambos Clientes da Planaudi
				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpEmit[01, 04] //Empresa
				cLog_Fil := aEmpEmit[01, 05] //Filial
				cEmpDest:= "\xml_totvs\" + Alltrim(cCGCEmit)
				//Gerará entrada em um e Saída em Outro
				//Verificar o Tipo
				If (cTpNF == '0') //Entrada no Emitente
					cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
					cLog_Tipo	:= '1'
					cLog_CodPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCEmit, "A2_COD")
					cLog_LojPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCEmit, "A2_LOJA")
				ElseIf (cTpNF == '1') //Saída no Emitente
					cDirDest 	:= cEmpDest + "\nf_saida\nao_proc\"
					cLog_Tipo	:= '2'
					cLog_CodPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCEmit, "A1_COD")
					cLog_LojPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCEmit, "A1_LOJA")
				EndIf
				cLog_Chave 	:= StrTran(oXmlOk:_InfNfe:_ID:Text,"NFe","")
				cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
				cLog_NumDoc	:= oXmlOk:_InfNfe:_IDE:_NNF:TEXT
				cLog_SerDoc	:= oXmlOk:_InfNfe:_IDE:_SERIE:TEXT
				cLog_Part	:= aEmpEmit[1][1]

				cLog_CGCEm  := oXmlOk:_InfNfe:_EMIT:_CNPJ:Text
				cLog_Emit	:= oXmlOk:_InfNfe:_EMIT:_xNome:Text
				cLog_Dest	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_XNOME") <> Nil,oXmlOk:_InfNfe:_DEST:_xNome:Text ,"EX")
				cLog_CGCDe	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_CNPJ") <> Nil,oXmlOk:_InfNfe:_DEST:_CNPJ:Text ,"EX")

				If !Empty(cDirDest)
					If(__CopyFile(cLog_ArqXML, cDirDest + cLog_ArqNew ))
						aAdd(aArqLog, { cLog_Status	,; // [01] - STATUS DO PROCESSAMENTO
							cLog_Origem	,; // [02] - ORIGEM DO ARQUIVO XML
							cLog_ArqOri	,; // [03] - NOME ORIGINAL DO ARQUIVO
							cLog_ArqNew	,; // [04] - NOVA NOMENCLATURA DO ARQUIVO
							cLog_Chave	,; // [05] - CHAVE DE ACESSO DO DOCUMENTO
							cLog_DtPro	,; // [06] - DATA DE PROCESSAMENTO
							cLog_DtDoc	,; // [07] - DATA DO DOCUMENTO
							cLog_HrPro	,; // [08] - HORA DO PROCESSAMENTO
							StrZero(Val(AllTrim(cLog_NumDoc)),TamSx3("F1_DOC")[1])	,; // [09] - NÚMERO DO DOCUMENTO
							StrZero(Val(AllTrim(cLog_SerDoc)),TamSx3("F1_SERIE")[1]),; // [10] - SERIE DO DOCUMENTO
							cLog_User	,; // [11] - USUÁRIO
							cLog_Part	,; // [12] - PARTICIPANTE
							cLog_CodPar	,; // [13] - CÓDIGO DO PARTICIPANETE
							cLog_LojPar ,; // [14] - LOJA DO PARTICIPANTE
							cLog_Tipo	,; // [15] - TIPO DO ARQUIVO XML
							cLog_Emit	,; // [16] - EMITENTE
							cLog_Dest	,; // [17] - DESTINATÁRIO
							cLog_CGCEm	,; // [18] - CNPJ/CPF EMITENTE
							cLog_CGCDe  ,; // [19] - CNPJ/CPF DESTINATÁRIO
							cLog_Emp	,; // [20] - EMPRESA
							cLog_Fil    ,; // [21] - FILIAL
							cCGCEmit    ,; // [22] - EMITENTE CTE
							cEmitCTe    ,; // [23] - NOME EMITENTE CTE
							cCGCDest    ,; // [24] - DESTINATÁRIO CTE
							cDestCTe    ,; // [25] - NOME DESTINATÁRIO CTE
							cCGCRem     ,; // [26] - REMETENTE CTE
							cRemCTe     ,; // [27] - NOME REMETENTE CTE
							cCGCExp     ,; // [28] - EXPEDIDOR CTE
							cExpCTE     ,; // [29] - NOME EXPEDIDOR CTE
							cCGCRec     ,; // [30] - RECEBEDOR CTE
							cRecCTe     ,; // [31] - NOME RECEBEDOR CTE
							cCGCTom     ,; // [32] - TOMADOR CTE
							cTomCTe     }) // [33] - NOME TOMADOR CTE
					Endif
				Else
					__CopyFile(cArqXML, "\xml_totvs\temp_erro\" + cNomeNew )
				EndIf

				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpDest[01, 04] //Empresa
				cLog_Fil := aEmpDest[01, 05] //Filial
				cEmpDest:= "\xml_totvs\" + Alltrim(cCGCDest)
				//Gerará entrada em um e Saída em Outro
				//Verificar o Tipo
				If (cTpNF == '0') //Saída no Destinatário
					cDirDest 	:= cEmpDest + "\nf_saida\nao_proc\"
					cLog_Tipo	:= '2'
					cLog_CodPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCDest, "A1_COD")
					cLog_LojPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCDest, "A1_LOJA")
				ElseIf (cTpNF == '1') //Entrada no Destinatário
					cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
					cLog_Tipo	:= '1'
					cLog_CodPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCDest, "A2_COD")
					cLog_LojPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCDest, "A2_LOJA")
				EndIf
				cLog_Chave 	:= StrTran(oXmlOk:_InfNfe:_ID:Text,"NFe","")
				cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
				cLog_NumDoc	:= oXmlOk:_InfNfe:_IDE:_NNF:TEXT
				cLog_SerDoc	:= oXmlOk:_InfNfe:_IDE:_SERIE:TEXT
				cLog_Part	:= aEmpDest[1][1]

				cLog_CGCEm  := oXmlOk:_InfNfe:_EMIT:_CNPJ:Text
				cLog_Emit	:= oXmlOk:_InfNfe:_EMIT:_xNome:Text
				cLog_Dest	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_XNOME") <> Nil,oXmlOk:_InfNfe:_DEST:_xNome:Text ,"EX")
				cLog_CGCDe	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_CNPJ") <> Nil,oXmlOk:_InfNfe:_DEST:_CNPJ:Text ,"EX")
			ElseIf !(Empty(cCGCEmit)) //Emitente Cliente Planaudi
				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpEmit[01, 04] //Empresa
				cLog_Fil := aEmpEmit[01, 05] //Filial
				cEmpDest:= "\xml_totvs\" + Alltrim(cCGCEmit)
				//Verifica o Tipo da Nota Fiscal
				If (cTpNF == '0') //Entrada no Emitente
					cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
					cLog_Tipo	:= '1'
					cLog_CodPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCEmit, "A2_COD")
					cLog_LojPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCEmit, "A2_LOJA")
				ElseIf (cTpNF == '1') //Saída no Emitente
					cDirDest 	:= cEmpDest + "\nf_saida\nao_proc\"
					cLog_Tipo	:= '2'
					cLog_CodPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCEmit, "A1_COD")
					cLog_LojPar	:= POSICIONE("SA1", 3, xFilial("SA1") + cCGCEmit, "A1_LOJA")
				EndIf
				cLog_Chave 	:= StrTran(oXmlOk:_InfNfe:_ID:Text,"NFe","")
				cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
				cLog_NumDoc	:= oXmlOk:_InfNfe:_IDE:_NNF:TEXT
				cLog_SerDoc	:= oXmlOk:_InfNfe:_IDE:_SERIE:TEXT
				cLog_Part	:= aEmpEmit[1][1]

				cLog_CGCEm  := oXmlOk:_InfNfe:_EMIT:_CNPJ:Text
				cLog_Emit	:= oXmlOk:_InfNfe:_EMIT:_xNome:Text
				cLog_Dest	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_XNOME") <> Nil,oXmlOk:_InfNfe:_DEST:_xNome:Text ,"EX")
				cLog_CGCDe	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_CNPJ") <> Nil,oXmlOk:_InfNfe:_DEST:_CNPJ:Text ,"EX")
			ElseIf !(Empty(cCGCDest)) //Destinatário Cliente Planaudi
				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpDest[01, 04] //Empresa
				cLog_Fil := aEmpDest[01, 05] //Filial
				cEmpDest:= "\xml_totvs\" + Alltrim(cCGCDest)
				//Verifica o Tipo da Nota Fiscal
				If (cTpNF == '0') //Entrada no Destinatário
					cDirDest 	:= ""//cEmpDest + "\nf_entrada\nao_proc\"
					cLog_Tipo	:= '1'
					cLog_CodPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCDest, "A2_COD")
					cLog_LojPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCDest, "A2_LOJA")
				ElseIf (cTpNF == '1') //Entrada no Destinatário
					cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
					cLog_Tipo	:= '1'
					cLog_CodPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCDest, "A2_COD")
					cLog_LojPar	:= POSICIONE("SA2", 3, xFilial("SA2") + cCGCDest, "A2_LOJA")
				EndIf
				cLog_Chave 	:= StrTran(oXmlOk:_InfNfe:_ID:Text,"NFe","")
				cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
				cLog_NumDoc	:= oXmlOk:_InfNfe:_IDE:_NNF:TEXT
				cLog_SerDoc	:= oXmlOk:_InfNfe:_IDE:_SERIE:TEXT
				cLog_Part	:= aEmpDest[1][1]

				cLog_CGCEm  := oXmlOk:_InfNfe:_EMIT:_CNPJ:Text
				cLog_Emit	:= oXmlOk:_InfNfe:_EMIT:_xNome:Text
				cLog_Dest	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_XNOME") <> Nil,oXmlOk:_InfNfe:_DEST:_xNome:Text ,"EX")
				cLog_CGCDe	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST ,"_CNPJ") <> Nil,oXmlOk:_InfNfe:_DEST:_CNPJ:Text ,"EX")
			EndIf
		Else
			If Len(aEmpDest) > 0
				//Pegando o CNPJ do Destinatário
				cCGCDest := IIf(Len(aEmpDest) > 0, aEmpDest[01, 03], "")
				//Gravando Empresa e Filial do XML
				cLog_Emp := aEmpDest[01, 04] //Empresa
				cLog_Fil := aEmpDest[01, 05] //Filial

				If "<TPNF>" $ Upper(cXML)
			   		If oXmlOk:_InfNfe:_VERSAO:Text == "3.10"
			   			cTipoNF		:= fConvTAG("TPNF",oXmlOk:_INFNFE:_IDE:_FINNFE:TEXT)

						lDev := .F.
						If "<DI>" $ Upper(cXML) // NF DE IMPORTAÇÃO
							cEmpDest:= "\xml_totvs\" + Alltrim(oXmlOk:_InfNfe:_EMIT:_CNPJ:Text)
							lImp := .T.
						ElseIf cTipoNF == "D"
							cEmpDest := StrTran(aEmpDest[1][2],"\\","\")
							lDev := .T.
						Else
							cEmpDest := StrTran(aEmpDest[1][2],"\\","\")
						EndIf

						If (aEmpDest[1][1] == '1' .Or. lImp) .AND. !lDev  // NF DE ENTRADA
							cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
							cLog_Tipo	:= '1'
						ElseIf aEmpDest[1][1] == '1' .AND. lDev // DEVOLUÇÃO DE VENDA
							cDirDest 	:= cEmpDest + "\nf_saida\nao_proc\"
							cLog_Tipo	:= '2'
						/*ElseIf aEmpDest[1][1] == '2' .AND. lDev // DEVOLUÇÃO DE COMPRA
							cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
							cLog_Tipo	:= '1'*/
						Else
							cDirDest 	:= cEmpDest + "\nf_saida\nao_proc\"
							cLog_Tipo	:= '2'
						EndIf

						If "<DI>" $ Upper(cXML) // NF DE IMPORTAÇÃO
							cDirDest 	:= cEmpDest + "\nf_entrada\nao_proc\"
							cLog_Tipo	:= '1'
						EndIf

						cLog_Chave 	:= StrTran(oXmlOk:_InfNfe:_ID:Text,"NFe","")
						cLog_DtDoc	:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
						cLog_NumDoc	:= oXmlOk:_InfNfe:_IDE:_NNF:TEXT
						cLog_SerDoc	:= oXmlOk:_InfNfe:_IDE:_SERIE:TEXT
						cLog_Part	:= aEmpDest[1][1]

						If aEmpDest[1][1] == '1'
							cLog_CodPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_COD")
							cLog_LojPar	:= POSICIONE("SA1",3,xFilial("SA1")+aEmpDest[1][3],"A1_LOJA")
						Else
							cLog_CodPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_COD")
							cLog_LojPar	:= POSICIONE("SA2",3,xFilial("SA2")+aEmpDest[1][3],"A2_LOJA")
						EndIf
				    Else
				    // A VERSÃO DO XML É INVÁLIDA
				    // AGUARDANDO DECISÃO DE TRATAMENTO
					EndIf
				Else
					cEmpDest:= "\xml_totvs\" + Alltrim(cCGCDest)
					Do Case

						Case lInut 													// INUTILIZAÇÃO DE NF
							cDirDest	:= cEmpDest + "\inutilizacoes\nao_proc\"
							cLog_Tipo	:= '6'
						Case lCTe 													// CONHECIMENTO DE TRANSPORTE
							cDirDest	:= cEmpDest + "\nf_transporte\nao_proc\"
							cLog_Tipo	:= '3'
						Case "<XCORRECAO>"	$ Upper(cXML) 							// CARTA DE CORREÇÃO

							cDirDest:= cEmpDest + "\carta_correcao\nao_proc\"

							cLog_Chave := ""
							cLog_DtDoc	:= StoD(" ")
							cLog_NumDoc	:= ""
							cLog_SerDoc	:= ""
							cLog_Part	:= ""
							cLog_CodPar	:= ""
							cLog_LojPar	:= ""

						Case lCanc	// CANCELAMENTO

							cDirDest	:= cEmpDest + "\cancelamentos\nao_proc\"
							cLog_Tipo	:= '5'

						OtherWise // XML DESCONHECIDO
							cDirDest	:= ""
							cLog_Status	:= "2"
					EndCase
				EndIf
			EndIf
		EndIf

		If !Empty(cDirDest)
			If(__CopyFile(cLog_ArqXML, cDirDest + cLog_ArqNew ))
				aAdd(aArqLog, { cLog_Status	,; // [01] - STATUS DO PROCESSAMENTO
					cLog_Origem	,; // [02] - ORIGEM DO ARQUIVO XML
					cLog_ArqOri	,; // [03] - NOME ORIGINAL DO ARQUIVO
					cLog_ArqNew	,; // [04] - NOVA NOMENCLATURA DO ARQUIVO
					cLog_Chave	,; // [05] - CHAVE DE ACESSO DO DOCUMENTO
					cLog_DtPro	,; // [06] - DATA DE PROCESSAMENTO
					cLog_DtDoc	,; // [07] - DATA DO DOCUMENTO
					cLog_HrPro	,; // [08] - HORA DO PROCESSAMENTO
					StrZero(Val(AllTrim(cLog_NumDoc)),TamSx3("F1_DOC")[1])	,; // [09] - NÚMERO DO DOCUMENTO
					StrZero(Val(AllTrim(cLog_SerDoc)),TamSx3("F1_SERIE")[1]),; // [10] - SERIE DO DOCUMENTO
					cLog_User	,; // [11] - USUÁRIO
					cLog_Part	,; // [12] - PARTICIPANTE
					cLog_CodPar	,; // [13] - CÓDIGO DO PARTICIPANETE
					cLog_LojPar ,; // [14] - LOJA DO PARTICIPANTE
					cLog_Tipo	,; // [15] - TIPO DO ARQUIVO XML
					cLog_Emit	,; // [16] - EMITENTE
					cLog_Dest	,; // [17] - DESTINATÁRIO
					cLog_CGCEm	,; // [18] - CNPJ/CPF EMITENTE
					cLog_CGCDe  ,; // [19] - CNPJ/CPF DESTINATÁRIO
					cLog_Emp	,; // [20] - EMPRESA
					cLog_Fil    ,; // [21] - FILIAL
					cCGCEmit    ,; // [22] - EMITENTE CTE
					cEmitCTe    ,; // [23] - NOME EMITENTE CTE
					cCGCDest    ,; // [24] - DESTINATÁRIO CTE
					cDestCTe    ,; // [25] - NOME DESTINATÁRIO CTE
					cCGCRem     ,; // [26] - REMETENTE CTE
					cRemCTe     ,; // [27] - NOME REMETENTE CTE
					cCGCExp     ,; // [28] - EXPEDIDOR CTE
					cExpCTE     ,; // [29] - NOME EXPEDIDOR CTE
					cCGCRec     ,; // [30] - RECEBEDOR CTE
					cRecCTe     ,; // [31] - NOME RECEBEDOR CTE
					cCGCTom     ,; // [32] - TOMADOR CTE
					cTomCTe     }) // [33] - NOME TOMADOR CTE
			Endif
		Else
			__CopyFile(cLog_ArqXML, "\xml_totvs\temp_erro\" + cLog_ArqNew )
		EndIf
	EndIf

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TIBXMLMAIL


@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------

Static Function TIBXMLMAIL(cMailServer,cUserMail,cPassMail,nPortPop)

Local oPOPManager := Nil
Local oMessage    := NIl
Local nNumMsg     := 0
Local nNumAttach  := 0
Local nCntFor1    := 0
Local nCntFor2    := 0
Local aInfAttach  := {}
Local cRootPath   := AllTrim( GetSrvProfString( "RootPath","" ) )
Local lUsaSSl     := GetMv("MV_RELSSL")
Local nRet        := 0
Local cProtocol   := AllTrim(Upper(GetPvProfString("MAIL", "PROTOCOL", "AKL", GetAdv97())))
Local cSSLVersion := AllTrim(Upper(GetPvProfString("MAIL", "SSLVERSION", "AKL", GetAdv97())))
Local cPathXML    := AllTrim(GetSrvProfString( "RootPath", "" )) + DIRXML
Local cArqINI     := '' //Arquivo APPSERVER.INI
Local cSSL        := ''

DEFAULT nPortPop  := 110

//---------------------------------------------------//
//***********Criação da Seção PROTOCOL***************//
//---------------------------------------------------//
cArqINI := GetSrvIniName()
WritePProString('MAIL', 'PROTOCOL', 'IMAP', cArqINI) //Protocolo
WritePProString('MAIL', 'SSLVersion', '2', cArqINI) //SSL
cProtocol := AllTrim(Upper(GetPvProfString("MAIL", "PROTOCOL", "AKL", GetAdv97())))
cSSL := AllTrim(Upper(GetPvProfString("MAIL", "SSLVersion", "AKL", GetAdv97())))

// CONEXAO POP ---------------------------------------
oPOPManager:= tMailManager():New()
oPOPManager:SetUseSSL(.T.)
oPOPManager:SetUseTLS(.T.)
oPOPManager:Init(cMailServer, "smtp.office365.com", cUserMail, cPassMail, nPortPop, 587)

If oPOPManager:SetPopTimeOut( 60 ) != 0
	Conout( "[POPCONNECT] Falha ao setar o time out" )
	Return .F.
EndIf

cMsg2:= "Conectanto no Servidor de E-mail..."
oSayTab2:Refresh()

If cProtocol == "POP3"
	nRet := oPOPManager:POPConnect()
ElseIf cProtocol == "IMAP"
	nRet := oPOPManager:IMAPConnect()
EndIf

If nRet != 0
	Conout("[POPCONNECT] Falha ao conectar" )
	Conout("[POPCONNECT][ERROR] " + str(nRet,6) , oPOPManager:GetErrorString(nRet))
	Return .F.
Else
	Conout( "[POPCONNECT] Sucesso ao conectar" )
	cMsg2:= "Conexão realizada com Sucesso! Verificando Caixa de Entrada..."
	oSayTab2:Refresh()
EndIf

//Quantidade de mensagens
oPOPManager:GetNumMsgs( @nNumMsg )

If nNumMsg > 0

	o2Progress:SetTotal(nNumMsg)

	For nCntFor1 := 1 To nNumMsg

		o2Progress:Set(nCntFor1)

		//inicia Objeto
		oMessage := tMailMessage():new()
		//Limpa o objeto da mensagem
		oMessage:Clear()
		//Recebe a mensagem do servidor
		oMessage:Receive( oPOPManager, nCntFor1 )

		//Quantidade de anexos na mensagem
		nNumAttach := oMessage:GetAttachCount()

		//Escreve no server os dados do e-mail recebido
		Conout( CRLF )
		Conout( "[POPCONNECT] Email Numero: " + AllTrim(Str(nCntFor1)) )
		Conout( "[POPCONNECT] De:      " + oMessage:cFrom )
		Conout( "[POPCONNECT] Para:    " + oMessage:cTo )
		Conout( "[POPCONNECT] Copia:   " + oMessage:cCc )
		Conout( "[POPCONNECT] Assunto: " + oMessage:cSubject )

		cMsg2:= "Verificando E-mail. Baixando arquivo XML " + Alltrim(STR(nCntFor1)) + " de " + Alltrim(STR(nNumMsg)) + " ..."
		oSayTab2:Refresh()

		lValidAtt := .F. //Anexo Válido

		// recebe o anexo da mensagem em string
		For nCntFor2 := 1 To nNumAttach

			aInfAttach := oMessage:GetAttachInfo(nCntFor2)

			If !Empty(aInfAttach[1]) .And. Upper(Right(AllTrim(aInfAttach[1]),4)) == '.XML'
				lValidAtt := .T.
				//Salva Anexo na pasta
				If oMessage:SaveAttach(nCntFor2, cPathXML + "TEMP_MAIL\" + aInfAttach[1])
					Conout( "[POPCONNECT] Anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				Else
					Conout( "[POPCONNECT] Erro ao salvar anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				EndIf
			ElseIf !Empty(aInfAttach[1]) .And. Upper(Right(AllTrim(aInfAttach[1]),4)) == '.PDF'
				lValidAtt := .T.
				//Salva Anexo na pasta
				If oMessage:SaveAttach(nCntFor2, cPathXML + "TEMP_MAIL\" + aInfAttach[1])
					Conout( "[POPCONNECT] Anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				Else
					Conout( "[POPCONNECT] Erro ao salvar anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				EndIf
			ElseIf !Empty(aInfAttach[1]) .And. Upper(Right(AllTrim(aInfAttach[1]),4)) == '.ZIP'
				lValidAtt := .T.
				cNameAtt := STrTran(AllTrim(aInfAttach[1]), ' ', '_')
				//Salva Anexo na pasta
				If oMessage:SaveAttach(nCntFor2, cPathXML + "TEMP_MAIL\" + cNameAtt)
					If (u_TIBUnZip(cNameAtt, DIRXML + "TEMP_MAIL\", DIRXML + "TEMP_MAIL\", .F., 10))
						Conout( "[POPCONNECT] Anexo " + AllTrim(Str(nCntFor2)) + ": " + cNameAtt )
					Else
						Conout( "[POPCONNECT] Erro ao salvar anexo " + AllTrim(Str(nCntFor2)) + ": " + cNameAtt )
					EndIf
				Else
					Conout( "[POPCONNECT] Erro ao salvar anexo " + AllTrim(Str(nCntFor2)) + ": " + aInfAttach[1] )
				EndIf
			EndIf

		Next nCntFor2

		//Movendo a mensagem para a pasta "Processados", somente se tiver anexos válidos
		If (lValidAtt)
			If !(oPOPManager:MoveMsg(nCntFor1, "Processados"))
				ConOut("Mensagem " + cValToChar(nCntFor1) + " não movida...")
			EndIf
		EndIf

		//Deleta a mensagens do servidor
		//oPOPManager:DeleteMsg( nCntFor1 )

		Conout( CRLF )
	Next nCntFor1
Else
	ConOut("[POPCONNECT] Nao ha mensagens pendentes para processamento. Desconectando...")
EndIf

//Desconecta do servidor POP
oPOPManager:POPDisconnect()

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} fPartXML


@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------

Static Function fPartXML(cDest,cEmit,cTipo)

Local aRet 		:= {}
Local nPosDest 	:= {}
Local nPosEmit	:= {}
Local cCNPJPart	:= ""
Local cPart		:= ""
Local cEmpPart  := ""
Local cFilPart  := ""

nPosDest := ASCAN(aCGCEmp, { |x| x[2] == cDest }) // NF DE ENTRADA
nPosEmit := ASCAN(aCGCEmp, { |x| x[2] == cEmit }) // NF DE SAIDA

If nPosDest > 0
	cPart		:= "1"
	cEmpDest	:= "\xml_totvs\" + Alltrim(aCGCEmp[nPosDest][2])
	cCNPJPart	:= Alltrim(aCGCEmp[nPosDest][2])
	cEmpPart    := aCGCEmp[nPosDest, 03] //Empresa
	cFilPart    := aCGCEmp[nPosDest, 04] //Filial
ElseIf nPosEmit > 0
	cPart		:= "2"
	cEmpDest	:= "\xml_totvs\" + Alltrim(aCGCEmp[nPosEmit][2])
	cCNPJPart	:= Alltrim(aCGCEmp[nPosEmit][2])
	cEmpPart    := aCGCEmp[nPosEmit, 03] //Empresa
	cFilPart    := aCGCEmp[nPosEmit, 04] //Filial
Else
	cPart		:= ""
	cEmpDest	:= ""
EndIf

If !Empty(cEmpDest)
	aAdd(aRet, {cPart,cEmpDest, cCNPJPart, AllTrim(cEmpPart), AllTrim(cFilPart)} )
EndIf

Return aRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TIBXMLFD


@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------

Static Function TIBXMLFD()

Local aTags	:= {}
Local aField := {}
Local aGrid := {}

// ----------------------------------------------
// Nota Fiscal de Saída
// ----------------------------------------------
If lCheckNFS
	TIBXMLIMP('NFS')
EndIf

// ----------------------------------------------
// Nota Fiscal de Entrada
// ----------------------------------------------
If lCheckNFE
	TIBXMLIMP('NFE')
EndIf

// ----------------------------------------------
// Evento de Cancelamento
// ----------------------------------------------
If lCheckCAN
	TIBXMLIMP('CAN')
EndIf

// ----------------------------------------------
// Eventos de Inutilização de NF
// ----------------------------------------------
If lCheckINU
	aTags := TIBXMLIMP('INU')
EndIf

// ----------------------------------------------
// Nota Fiscal Complementar
// ----------------------------------------------
If lCheckNFC
	aTags := TIBXMLIMP('NFC')
EndIf

// ----------------------------------------------
// Conhecimento de Transporte
// ----------------------------------------------
If lCheckCTE
	TIBXMLIMP('CTE')
EndIf

Return

Static Function TIBXMLIMP(IdXML)

Local cDirArq	:= ""
Local nPosEmp	:= ASCAN(aCGCEmp, { |x| Alltrim(x[1]) == cEmpAnt+cFilAnt })
Local aRet		:= {}
Local bLetsGo
Local i := 0

If nPosEmp > 0
	Do Case
		Case IdXML == 'NFS'
			bLetsGo:= {|cDirArq,aFiles,aRet| cDirArq	:= "\XML_TOTVS\" + aCGCEmp[nPosEmp][2] + "\NF_SAIDA\NAO_PROC\"		 , aFiles := Directory(cDirArq+"*.XML", "D") , aRet:= TIB1XMLIMP(IdXML,cDirArq,aFiles,aCGCEmp[nPosEmp][2]) }
		Case IdXML == 'NFE'
			bLetsGo:= {|cDirArq,aFiles,aRet| cDirArq	:= "\XML_TOTVS\" + aCGCEmp[nPosEmp][2] + "\NF_ENTRADA\NAO_PROC\"	 , aFiles := Directory(cDirArq+"*.XML", "D") , aRet:= TIB1XMLIMP(IdXML,cDirArq,aFiles,aCGCEmp[nPosEmp][2]) }
		Case IdXML == 'CAN'
			bLetsGo:= {|cDirArq,aFiles,aRet| cDirArq	:= "\XML_TOTVS\" + aCGCEmp[nPosEmp][2] + "\CANCELAMENTOS\NAO_PROC\"  , aFiles := Directory(cDirArq+"*.XML", "D") , aRet:= TIB1XMLIMP(IdXML,cDirArq,aFiles,aCGCEmp[nPosEmp][2]) }
		Case IdXML == 'INU'
			bLetsGo:= {|cDirArq,aFiles,aRet| cDirArq	:= "\XML_TOTVS\" + aCGCEmp[nPosEmp][2] + "\INUTILIZACOES\NAO_PROC\"	 , aFiles := Directory(cDirArq+"*.XML", "D") , aRet:= TIB1XMLIMP(IdXML,cDirArq,aFiles,aCGCEmp[nPosEmp][2]) }
		Case IdXML == 'NFC'
			bLetsGo:= {|cDirArq,aFiles,aRet| cDirArq	:= "\XML_TOTVS\" + aCGCEmp[nPosEmp][2] + "\CARTA_CORRECAO\NAO_PROC\" , aFiles := Directory(cDirArq+"*.XML", "D") , aRet:= TIB1XMLIMP(IdXML,cDirArq,aFiles,aCGCEmp[nPosEmp][2]) }
		Case IdXML == 'CTE'
			bLetsGo:= {|cDirArq,aFiles,aRet| cDirArq	:= "\XML_TOTVS\" + aCGCEmp[nPosEmp][2] + "\NF_TRANSPORTE\NAO_PROC\"	 , aFiles := Directory(cDirArq+"*.XML", "D") , aRet:= TIB1XMLIMP(IdXML,cDirArq,aFiles,aCGCEmp[nPosEmp][2]) }
	EndCase

	Eval(bLetsGo)

Else
	// EMPRESA NÃO LOCALIZADA
	// AGUARDANDO DECISÃO DE TRATAMENTO
EndIf

If Len(aCGCCli) > 0
	For i := 1 to Len(aCGCCli)
		DbSelectArea("SA1")
		SA1->(dbSetOrder(3)) //-- A1_FILIAL + A1_CGC
		If SA1->(dbSeek(xFilial('SA1') + aCGCCli[i]))
			If (RecLock("SA1",.F.))
				SA1->A1_MSBLQL	:= "1"
				MsUnLock()
			EndIf
	   	EndIf
	Next i
EndIf

If Len(aCGCFor) > 0
	For i := 1 to Len(aCGCFor)
		DbSelectArea("SA2")
		SA2->(dbSetOrder(3)) //-- A2_FILIAL + A2_CGC
		If SA2->(dbSeek(xFilial('SA2') + aCGCFor[i]))
			If (RecLock("SA2",.F.))
				SA2->A2_MSBLQL	:= "1"
				MsUnLock()
			EndIf
	   	EndIf
	Next i
EndIf


Return aRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TIB1XMLIMP


@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------

Static Function TIB1XMLIMP(IdXML,cDirArq,aFiles,cCGCX)

Local nPosEmp	:= ASCAN(aCGCEmp, { |x| Alltrim(x[1]) == cEmpAnt+cFilAnt })
Local cEmpAtu   := IIf(nPosEmp > 0, aCGCEmp[nPosEmp, 03], cEmpAnt)
Local cFilAtu   := IIf(nPosEmp > 0, AllTrim(aCGCEmp[nPosEmp, 04]), cFilAnt)
Local cCondPag	:= SuperGetMV('TI_XMLCOND',.F.,'XML')
Local F_Tipo	:= ""
Local F_Formul	:= ""
Local F_Doc		:= ""
Local F_Serie	:= ""
Local F_Fornec	:= ""
Local F_Loja	:= ""
Local F_Espec	:= ""
Local F_Chave	:= ""
Local F_HrTran	:= ""
Local F_Stat    := "" //Status
Local F_CGCEmi  := "" //CGC do Emitente
Local F_Emit	:= ""
Local F_CGCDes  := "" //CGC do Destinatário
Local F_Dest	:= ""
Local F_CadEnt	:= ""
Local L_CadPro	:= .F.
Local L_CadoPro2:= .F.
Local F_DtEmi	:= StoD(" ")
Local F_DtTran	:= StoD(" ")
Local F_VALMERC := ""
Local F_TipoEnt := ""
Local F_DESCONT := ""
Local F_FRETE	:= ""
Local F_SEGURO	:= ""
Local F_DESPESA	:= 0
Local F_VALBRUT	:= ""
Local F_VICMSUFD  := 0
Local F_VBCUFDEST := 0
Local F_EST		:= ""
Local F_REFNFE  := "" //Chave de Referência da Nota Fiscal
Local F_BASEICM := 0
Local F_VALICM  := 0
Local F_BASEIPI := 0
Local F_VALIPI  := 0
Local F_BASIMP6 := 0
Local F_VALIMP6 := 0
Local F_BASIMP5 := 0
Local F_VALIMP5 := 0
Local F_BRICMS  := 0
Local F_ICMSRET := 0
Local G_Item	:= ""
Local G_ItemOri	:= "" //Número do Item de Origem
Local G_PrdOri  := "" //Origem do Produto
Local G_AliIPI  := 0 //Aliquota do IPI
Local G_CEst    := "" //Código Especificador da Substituição Tributária
Local G_BasICST    := 0 //Valor da BC do ICMS ST
Local G_AlICST     := 0 //Alíquota do imposto do ICMS ST
Local G_ValICST    := 0 //Valor do ICMS ST
Local vBCUFDest    := 0 // -- Variáveis de ICMS UF RET -- //
Local pFCPUFDest   := 0
Local pICMSUFDest  := 0
Local pICMSInter   := 0
Local pICMSIntPart := 0
Local vFCPUFDest   := 0
Local vICMSUFDest  := 0
Local vICMSUFRemet := 0 // -- Variáveis de ICMS UF RET -- //
Local G_Cod		:= ""
Local G_Local	:= ""
Local G_CodEnt	:= ""
Local G_Desc	:= ""
Local G_Quant	:= ""
Local G_VlrUni	:= ""
Local G_Total	:= ""
Local G_ClasF	:= ""
Local G_BaseIcn	:= ""
Local G_AliqIcm	:= ""
Local G_ValIcms	:= ""
Local G_BaseIPI	:= ""
Local G_AliqIPI	:= ""
Local G_ValIPI	:= ""
Local G_BasePIS	:= ""
Local G_AliqPIS := ""
Local G_ValPIS 	:= ""
Local G_BaseCOF	:= ""
Local G_AliqCOF	:= ""
Local G_BaseII  := 0
Local G_ValCOF	:= ""
Local G_VlrII	:= ""
Local G_CFOP	:= ""
Local cArqXML	:= ""
Local cXML		:= ""
Local cError    := ""
Local cWarning  := ""
Local oXML		:= Nil
Local oAuxXML	:= Nil
Local oAuxXML1	:= Nil
Local oEvento	:= Nil
Local oInfEvento:= Nil
Local oCHNFE	:= Nil
Local cChaveNFE	:= Nil
Local oXMLAux	:= Nil
Local oFullXML	:= Nil
Local oXmlOk	:= Nil
Local lFound    := .F.
Local i			:= 0
Local j			:= 0
Local nX		:= 0
Local cTabEmit	:= ""
Local aItens	:= {}
Local nQuant	:= 0
Local aDadosEnt	:= {}
Local lGrava	:= .T.
Local oICM		:= Nil
Local oImpAux	:= Nil
Local l_ICMS	:= .F.
Local l_IPI 	:= .F.
Local l_PIS	 	:= .F.
Local l_COFINS 	:= .F.
Local l_II	 	:= .F.
Local l_ICMUFDes:= .F. //Tag <ICMSUFDEST>
Local oArqAux	:= Nil
Local cXMLAux 	:= ""
Local cArqAux	:= ""
Local cTipoCli	:= ""
Local lContinua	:= .T.
Local nProd := 0
Local nCount	:= 0
Local nValCte	:= 0 //-- Valor CT-e
Local nBaseICM60:= 0 //-- Base ICMS Substituição Tributária
Local nAliICM60 := 0 //-- Aliquota ICMS Substituição Tributária
Local nValICM60	:= 0 //-- Valor ICMS Substituição Tributária
Local cBuffer	:= ""
Local cCodigo	:= ""
Local cLoja		:= ""
Local cCodProd	:= ""
Local cXMLRet	:= ""
Local cNumCTe	:= "" //-- Numeração CT-e
Local cSerieCTe	:= "" //-- Serie CT-e
Local cChvCTe   := "" //-- Chave CT-e
Local cCGCForn	:= "" //-- CNPJ Fornecedor
Local lRet		:= .T.
Local aNotas	:= {}
Local dDtEmisCTe:= Nil
Local cFornCTe	:= ""
Local cLojaCTe	:= ""
Local cCST_ICM	:= ""
Local cCST_IPI	:= ""
Local cCST_PIS	:= ""
Local cCST_COF	:= ""
Local cENQ_IPI	:= ""
Local nMargem   := 0
Local lTemIPI	:= .F.
Local lTemICMS  := .F.
Local k			:= 0
Local lClassOk	:= .T.
Local lProdOk	:= .T.
Local cTexto	:= ""
Local lJob		:= .F.
Local aForImp	:= {}
Local aNFOrigem := {}
Local lNFImp	:= .F.
Local lGoImp	:= .F.
Local aProd		:= {}
Local nValUnit	:= 0
Local nValProd	:= 0
Local nValFre	:= 0
Local G_ValDesp	:= 0
Local lMajorada	:= .F.
Local nSomaII 	:= SuperGetMV("TI_SOMAII",.F.,1)
Local cCliInut	:= PadR(AllTrim(SuperGetMV('MV_INUTCLI',.F.,'000001'	)), TamSX3('A1_COD')[01])
Local cLojInut	:= PadR('01', TamSX3('A1_LOJA')[01])
Local cProInut	:= SuperGetMV('MV_INUTPRO',.F.,'000000000000001')
Local cTesInut	:= SuperGetMV('MV_INUTTES',.F.,'501')
Local cAliqMajo := SuperGetMV('TI_ALIQMAJ',.F.,'10.65|15.37|17.48')
Local cCodDeneg := SuperGetMV('TI_CODDENE',.F.,'301|302|205') //Códigos para NF Denegada
Local nItCTe    := 0
Local lOK       := .F.

Local cCGCEmit      := "" //CGC do Emitente
Local cCGCDest      := "" //CGC do Destinatário
Local cCGCRem       := "" //CGC do Remetente
Local cCGCExp       := "" //CGC do Expedidor
Local cCGCRec       := "" //CGC do Recebedor
Local cCGCTom       := "" //CGC do Tomador
Local cRemCTe       := "" //Nome Remetente CTe
Local cEmitCTe      := "" //Nome Emitente CTe
Local cDestCTe      := "" //Nome Destinatário CTe
Local cExpCTE       := "" //Nome Expedidor CTe
Local cRecCTe       := "" //Nome Recebedor CTe
Local cTomCTe       := "" //Nome Tomador CTe
Local cTpNF         := "" //Tipo da Nota Fiscal

Local cAdic    := "" //Adição
Local cSeqAdic := "" //Sequencial da Adição
Local aCFInv   := {'949'} //CFOP's que não permitem inclusão do Documento

Local lBenef   := .F. //Verifica se a Nota Fiscal é Beneficiamento
Local lExp     := .F. //Exportação
Local lDI      := .F. //Importação
Local lDevP3   := .F. //Verifica se a TES é de Devolução em Poder de Terceiro
Local lCupFis  := .F. //Operação decorrente a emissão do Cupom Fiscal ECF
Local lSemOrig := .F. //Aceita Nota Fiscal sem Origem ?
Local lCFOk    := .T. //Verifica se possui CFOP que permita a Inclusão do Documento
Local lCIAP    := .F. //Verifica se é Nota Fiscal de CIAP
Local lIPIObs  := .F. //Verifica  se é IPI Obs

Local cArqSmf  := '' //Arquivo de Semáforo

Local aBkpFile := AClone(aFiles) //Backup do Array de Arquivos
Local nLog     := 0

Local nD := nF1 := 0
Local nDocIni	:= 0
Local nDocFim	:= 0
Local n			:= 0

Private aLogXML  := {} //Array com Log do Arquivo XML

//Zerando array de Arquivos
aFiles := {}

//Percorrendo os arquivos e gerando LOCK
For i := 1 to Len(aBkpFile)
	//Gerando Arquivo de Semáforo
	cArqSmf := cDirArq + Left(AllTrim(aBkpFile[i, 01]), Len(AllTrim(aBkpFile[i, 01])) - 04) + ".LCK"
	//Verifica se o arquivo já existe
	If !(File(cArqSmf))
		//Gerando o Arquivo
		nHdl := fCreate(cArqSmf)
		FClose(nHdl)
		//Se o arquivo foi gerado, gravar no array
		If (File(cArqSmf))
			AAdd(aFiles, {AllTrim(aBkpFile[i, 01]), cArqSmf, .T.})
		EndIf
	EndIf
Next i

If Len(aFiles) == 0
	Aviso('TOTVS', 'Nenhum arquivo encontrado no diretório: "' + cDirArq + '"', {'OK'}, 03)
EndIf

//Posicionando na SM0
DbSelectArea('SM0')
SM0->(DbGoTop())
While !(SM0->(EOF()))
	If (AllTrim(cEmpAnt) == AllTrim(SM0->M0_CODIGO)) .AND. (AllTrim(cFilAnt) == AllTrim(SM0->M0_CODFIL))
		Exit
	EndIf
	//Pulando registro
	SM0->(DbSkip())
EndDo

For i := 1 to Len(aFiles)

	//Adicionando Linha com referência ao Log de Processamento do XML
	AAdd(aLogXML, {'', '', ''}) //[01] - Informações do XML [02] - Log de Processamento [03] - Informativos

	//Verifica se mudou a empresa
	If (!(cEmpAnt == cEmpAtu) .OR. !(cFilAnt == cFilAtu));
		.OR. (!(AllTrim(SM0->M0_CODIGO) == cEmpAtu) .OR. !(AllTrim(SM0->M0_CODFIL) == cFilAtu))
		u_WSConecta(cEmpAtu, cFilAtu)
	EndIf

	lClassOk	:= .T.
	lProdOk		:= .T.
	L_CadPro	:= .F.
	lMajorada	:= .F.

	lBenef      := .F. //Verifica se a Nota Fiscal é Beneficiamento
	lExp        := .F. //Exportação
	lDI         := .F. //Importação
	lCupFis     := .F. //Cupom Fiscal
	aNFOrigem   := {} //Zerando Array de Nota Fiscal
	lSemOrig    := .F. //Aceita Nota Fiscal sem Origem ?
	lCFOk       := .T. //Verifica se possui CFOP que permita a Inclusão do Documento
	lCIAP       := .F. //Verifica se é Nota Fiscal de CIAP
	lIPIObs     := .F. //Verifica  se é IPI Obs

	o4Progress:SetTotal(Len(aFiles))
	o4Progress:Set(i)

	cArqXML 	:= cDirArq+aFiles[i][1]

	oFullXML	:= XmlParserFile(cArqXML,"_",@cError,@cWarning)
	cXML 		:= MemoRead(cArqXML)
	oXML    	:= oFullXML
	oAuxXML 	:= oXML
	oXmlOk		:= Nil

	//-- Erro na sintaxe do XML
	If Empty(oFullXML) .Or. !Empty(cError)
		Conout("[DIXGetXML] Erro de sintaxe no arquivo XML: "+cError,"Entre em contato com o emissor do documento e comunique a ocorrência.")
	Else
		lRet := .T.
	EndIf

	If lRet

		If IdXML == "NFE" .or. IdXML == "NFS"
			//-- Resgata o no inicial da NF-e
			lFound  := .F.
			lGrava	:= .F.

			Do While !lFound
				If ValType(oAuxXML) <> "O"
					lNF:= .F.
					Exit
				EndIf
				oAuxXML := XmlChildEx(oAuxXML,"_NFE")
				lFound := (oAuxXML <> NIL)
				If !lFound
					For nX := 1 To XmlChildCount(oXML)
						oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
						If ValType(oAuxXML) == "O"
							lFound := oAuxXML:_InfNfe # Nil
							If lFound
								oXML := oAuxXML
								Exit
							EndIf
						EndIf
					Next nX
				EndIf
			EndDo

			If !lFound
				oXmlOk:= oXML
			Else
				oXmlOk:= oAuxXML
			EndIf

			If ValType(oXmlOk:_InfNfe:_Det) == "O"
				aItens := {oXmlOk:_InfNfe:_Det}
			Else
				aItens := oXmlOk:_InfNfe:_Det
			EndIf

			cTipoNF		:= fConvTAG("TPNF",oXmlOk:_INFNFE:_IDE:_FINNFE:TEXT)
			cTpNF       := oXmlOk:_InfNfe:_IDE:_TpNf:Text
			cTipoCli	:= oXmlOk:_INFNFE:_IDE:_INDFINAL:TEXT

			If (XmlChildEx(oXmlOk:_INFNFE,"_DEST") <> Nil)
				oInfDEST := Nil
				If IdXML == "NFE"
					IF ValType(oXmlOk) == "O"
						oInfDEST := oXmlOk:_INFNFE:_DEST
					EndIf
				Else
					IF ValType(oXmlOk) == "O"
						oInfDEST := oXmlOk:_INFNFE:_DEST
					EndIf
				EndIf
				If (ValType(oInfDEST) == 'O')
					F_EST := AllTrim(oInfDEST:_ENDERDEST:_UF:TEXT)
				EndIf
			EndIf

			//Percorrendo os Itens para Verificar se é Beneficiamento
			For j := 1 To Len(aItens)
				G_CFOP	 := aItens[j]:_Prod:_CFOP:Text
				//Verifica se é CFOP de Importação
				If !(lDI) .AND. Left(G_CFOP, 01) == '3'
					lDI := .T.
				EndIf
				//Verifica se pode gerar o Documento
				If (lCFOk .AND. AScan(aCFInv, {|x| AllTrim(x) == SubStr(G_CFOP, 02, 03)}) > 0) .AND. !(cTipoNF == "C")
					lCFOk := .F.
				EndIf
				//Verifica se é CIAP
				If (AllTrim(G_CFOP) == '1604')
					lCIAP    := .T.
					lSemOrig := .T.
				EndIf
				//Verifica se é Exportação
				If !(lExp)
					lExp := ((F_EST == "EX") .AND. (Left(G_CFOP, 01) == "7"))
				EndIf
				//Verifica se é Cupom Fiscal
				If (SubStr(G_CFOP, 2, 03) == '929')
					lCupFis := .T.
				EndIf
				//Verifica se é Beneficiamento
				lBenef := fIsBenef(G_CFOP, IdXML)
				If (lBenef) .AND. !(cTipoNF == "C")
					cTipoNF := "B"
					Exit
				EndIf
				//Verifica se é IPI Obs
				If (IdXML == "NFS" .AND. !lIPIObs)
					lIPIObs := fIsIPIObs(G_CFOP)
				EndIf
			Next j

			If (lDI)
				lDI := ("<DI>" $ Upper(cXML))
			EndIf

			F_Emit		:= oXmlOk:_INFNFE:_EMIT:_xNome:Text
			F_CGCEmi    := IIF(XmlChildEx(oXmlOk:_InfNfe:_EMIT,"_CNPJ") <> Nil, oXmlOk:_INFNFE:_EMIT:_CNPJ:Text, "")
			F_Dest		:= oXmlOk:_INFNFE:_DEST:_xNome:Text
			F_CGCDes    := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST,"_CNPJ") <> Nil, oXmlOk:_INFNFE:_DEST:_CNPJ:Text, "")
			//Verifica se é Pessoa Fisica
			F_CGCEmi    := IIF(XmlChildEx(oXmlOk:_InfNfe:_EMIT,"_CPF") <> Nil, oXmlOk:_INFNFE:_EMIT:_CPF:Text, F_CGCEmi)
			F_CGCDes    := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST,"_CPF") <> Nil, oXmlOk:_INFNFE:_DEST:_CPF:Text, F_CGCDes)

			If (AllTrim(F_CGCEmi) == AllTrim(SM0->M0_CGC)) .AND. IdXML == 'NFE'
				F_Formul := 'S' //Formulário Próprio
			Else
				F_Formul := 'N' //Terceiros
			EndIf

			//-- CNPJ do Emitente
			If IdXML == "NFE"
				//Formulário Próprio pega do Destinatário
				If (F_Formul == 'S')
					cCGC := F_CGCDes
				Else //Pega do Emitente
					cCGC := F_CGCEmi
				EndIf
			Else
				If XmlChildEx(oXmlOk:_INFNFE:_DEST,"_CNPJ") <> Nil
					cCGC := oXmlOk:_INFNFE:_DEST:_CNPJ:Text
				ElseIf XmlChildEx(oXmlOk:_INFNFE:_DEST,"_CPF") <> Nil
					cCGC := oXmlOk:_INFNFE:_DEST:_CPF:Text
				Else
					cCGC := ""
				EndIf
			EndIf

			//Verifica se é Nota Fiscal de Ajuste
			If (cTipoNF == 'A')
				If (lCIAP)//Verifica se é CIAP
					cTipoNF := 'C'
				EndIf
			EndIf

			If IdXML == "NFE"
				If cTipoNF == "N" .or. cTipoNF == "C"
					cTabEmit := "SA2"
				Else
					cTabEmit := "SA1"
				Endif
			Else
				If cTipoNF == "N" .or. cTipoNF == "C"
					cTabEmit := "SA1"
				Else
					cTabEmit := "SA2"
				Endif
			EndIf

			//Verifica se é Importação ou Exportação
			//If !("<DI>" $ Upper(cXML)) .AND. !lExp
			lCadCliFor := .T.
			If !(lDI) .AND. !lExp
				(cTabEmit)->(dbSetOrder(3))
				If (cTabEmit)->(dbSeek(xFilial(cTabEmit)+cCGC))
					cCodigo  := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
					cLoja    := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
					If (cTabEmit)->&(Substr(cTabEmit,2,2)+"_MSBLQL") == '1'
						F_CadEnt := '2'
					Else
						F_CadEnt := '1'
					EndIf
				Else
					If IdXML == "NFE"
						If cTipoNF == "N" .or. cTipoNF == "C"
							aDadosEnt	:= XMLCADFOR(cCGC,oXmlOk,cArqXML,cTipoNF,IdXML)
							aAdd(aCGCFor, cCGC )
						Else
							aDadosEnt	:= XMLCADCLI(cCGC,oXmlOk,cArqXML,cTipoNF,IdXML)
							aAdd(aCGCCli, cCGC )
						EndIf
					Else
						If cTipoNF == "N" .or. cTipoNF == "C"
							aDadosEnt	:= XMLCADCLI(cCGC,oXmlOk,cArqXML,cTipoNF,IdXML)
							aAdd(aCGCCli, cCGC )
						Else
							aDadosEnt	:= XMLCADFOR(cCGC,oXmlOk,cArqXML,cTipoNF,IdXML)
							aAdd(aCGCFor, cCGC )
						EndIf
					EndIf

					If Len(aDadosEnt) > 0
						cCodigo 	:= aDadosEnt[1]
						cLoja   	:= aDadosEnt[2]
						F_CadEnt 	:= '2'
					Else
						aLogXML[Len(aLogXML), 02] += 'Cliente/Fornecedor CGC: ' + cCGC + ' não cadastrado (Error ExecAuto)' + CHR(13) + CHR(10)
						lCadCliFor := .F.
						cCodigo 	:= ""
						cLoja   	:= ""
					EndIf
				EndIf
			EndIf

			F_Tipo		:= cTipoNF
			F_Formul	:= "N"
			F_Doc		:= StrZero(Val(AllTrim(oXmlOk:_InfNfe:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
			F_Serie		:= PadR(oXmlOk:_InfNfe:_Ide:_Serie:Text,TamSX3("F1_SERIE")[1])
			F_Serie     := StrZero(Val(AllTrim(F_Serie)),TamSx3("F1_SERIE")[1])
			F_Fornec	:= cCodigo
			F_Loja		:= cLoja
			F_Espec		:= "SPED"
			F_Chave		:= Right(AllTrim(oXmlOk:_InfNfe:_Id:Text),44)
			F_DtEmi		:= IIF(XmlChildEx(oXmlOk:_InfNfe:_IDE ,"_DHEMI") <> Nil, StoD(StrTran(SubStr(oXmlOk:_InfNfe:_IDE:_DHEMI:TEXT,1,10),"-","")), dDataBase)
			//--------------------
			//Log de Processamento
			//--------------------
			aLogXML[Len(aLogXML), 01] += 'Arquivo XML: ' + cArqXML + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Documento: ' + AllTrim(F_Doc) + ' Série: ' + AllTrim(F_Serie) + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Chave: ' + AllTrim(F_Chave) + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Emissão: ' + DTOC(F_DtEmi) + CHR(13) + CHR(10)
			If cTipoNF == "N" .OR. cTipoNF == "B"
				//Verifica se existe a Tag "NFEPROC"
				IF(XmlChildEx(oFullXML ,"_NFEPROC") <> Nil)
					oInfProt := Nil
					IF(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE ,"_INFPROT") <> Nil)
						oInfProt := oFullXML:_NFEPROC:_PROTNFE:_INFPROT
					ElseIF(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE ,"_PROTNFE") <> Nil)
						IF(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE:_PROTNFE ,"_INFPROT") <> Nil)
							oInfProt := oFullXML:_NFEPROC:_PROTNFE:_PROTNFE:_INFPROT
						EndIf
					EndIf
					If !(oInfProt == Nil)
						cHrXML      := Upper(oInfProt:_DHRECBTO:TEXT)
						nPosHr := At('T', cHrXML)
						If (nPosHr > 0)
							F_HrTran := Left(SubStr(cHrXML, nPosHr + 1), 08)
						Else
							F_HrTran	:= StrTran(Right(oInfProt:_DHRECBTO:TEXT,8),"-",":")
						EndIf
				   		F_DtTran	:= StoD(StrTran(Left(oInfProt:_DHRECBTO:TEXT,10),"-",""))
				   		F_Stat := IIF(XmlChildEx(oInfProt ,"_CSTAT") <> Nil, oInfProt:_CSTAT:TEXT, '')
				   	Else
				   		F_HrTran := ''
				   		F_DtTran := CTOD('//')
				   	EndIf
				Else
					F_HrTran := ''
				   	F_DtTran := CTOD('//')
				EndIf
			EndIf
			F_EST		:= RetUF(oXmlOk:_InfNfe:_Ide:_cUF:Text)
			If (XmlChildEx(oXmlOk:_INFNFE,"_DEST") <> Nil)
				oInfDEST := Nil
				If IdXML == "NFE"
					IF ValType(oXmlOk) == "O"
						oInfDEST := oXmlOk:_INFNFE:_DEST
					EndIf
				Else
					IF ValType(oXmlOk) == "O"
						oInfDEST := oXmlOk:_INFNFE:_DEST
					EndIf
				EndIf
				If (ValType(oInfDEST) == 'O')
					F_EST := oInfDEST:_ENDERDEST:_UF:TEXT
				EndIf
			EndIf
			F_VALMERC	:= Val(oXmlOk:_InfNfe:_Total:_ICMSTot:_vProd:Text)
			F_DESCONT	:= Val(oXmlOk:_InfNfe:_Total:_ICMSTot:_vDesc:Text)
			F_FRETE		:= Val(oXmlOk:_InfNfe:_Total:_ICMSTot:_vFrete:Text)
			F_SEGURO	:= Val(oXmlOk:_InfNfe:_Total:_ICMSTot:_vSeg:Text)
			F_VALBRUT	:= Val(oXmlOk:_InfNfe:_Total:_ICMSTot:_vNF:Text)
			F_DESPESA   := Val(IIf(XmlChildEx(oXmlOk:_InfNfe:_Total:_ICMSTot,"_VOUTRO") <> Nil, oXmlOk:_InfNfe:_Total:_ICMSTot:_vOutro:Text, "0"))
			F_DESPESA   := IIf(lIPIObs, 0, F_DESPESA)

			oTotal := oXmlOk:_InfNfe:_Total
			/*Impostos*/
			F_BASEICM := 0
			F_VALICM  := 0
			F_BASEIPI := 0
			F_VALIPI  := 0
			F_BASIMP6 := 0
			F_VALIMP6 := 0
			F_BASIMP5 := 0
			F_VALIMP5 := 0
			F_BRICMS  := 0
			F_ICMSRET := 0

			F_VICMSUFD  := IIF(XmlChildEx(oXmlOk:_InfNfe:_Total:_ICMSTot,"_VICMSUFDEST") <> Nil, Val(oXmlOk:_InfNfe:_Total:_ICMSTot:_vICMSUFDest:TEXT) , 0 )

			If IdXML == "NFE"
				If cTipoNF == "N"
					F_TpXML		:= '1'
				ElseIf cTipoNF == "C"
					F_TpXML		:= '4'
				Else
					F_TpXML		:= '1'
				EndIf
			Else
				If cTipoNF == "N" .OR. cTipoNF == "B" .OR. cTipoNF == "D"
					F_TpXML		:= '2'
				ElseIf cTipoNF == "C"
					F_TpXML		:= '4'
				Else
					F_TpXML		:= '1'
				EndIf
			EndIf

			lNFImp := .F.

			//If "<DI>" $ Upper(cXML)
			If lDI
	        	DbSelectArea("SA2")
	        	SA2->(DbSetOrder(2))
	        	cEndere := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST:_ENDERDEST,"_XLGR") <> Nil, oXmlOk:_INFNFE:_DEST:_ENDERDEST:_xLgr:Text, ' ')
	     		cNroEnd := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST:_ENDERDEST,"_NRO") <> Nil, oXmlOk:_INFNFE:_DEST:_ENDERDEST:_Nro:Text, ' ')
	        	aForImp := fBuscaForn(AllTrim(UPPER(oXmlOk:_INFNFE:_DEST:_xNome:Text)), u_fNoAcento(AllTrim(Upper(cEndere + ', ' + cNroEnd)), {"'"}))
	        	If (aForImp[01])
	        		F_Fornec := aForImp[02]
					F_Loja 	 := aForImp[03]
					F_CadEnt := '1'
					lGoImp	 := .T.
				Else
					aForImp := fSelFornec(oXmlOk:_INFNFE:_DEST:_xNome:Text,F_Doc,F_Serie,F_Chave,cArqXML)
					If Len(aForImp) > 0
						F_Fornec := aForImp[1]
						F_Loja 	 := aForImp[2]
						F_CadEnt := '1'
						lGoImp:= .T.
					Else
						F_Fornec := ""
						F_Loja 	 := ""
						F_CadEnt := '3'
						lGoImp	 := .F.
					EndIf
	        	EndIf
	        	If (Empty(F_Fornec) .OR. Empty(F_Loja))
	        		aLogXML[Len(aLogXML), 02] += 'Fornecedor de Importação: "' + AllTrim(UPPER(oXmlOk:_INFNFE:_DEST:_xNome:Text)) + '" não encontrado.' + CHR(13) + CHR(10)
	        	EndIf
	        	F_Emit  := oXmlOk:_INFNFE:_DEST:_xNome:Text
	        	F_CGCEmi:= IIF(XmlChildEx(oXmlOk:_InfNfe:_EMIT,"_CNPJ") <> Nil, oXmlOk:_INFNFE:_EMIT:_CNPJ:Text, "")
			  	F_Dest  := oXmlOk:_INFNFE:_DEST:_xNome:Text
			  	F_CGCDes:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST,"_CNPJ") <> Nil, oXmlOk:_INFNFE:_DEST:_CNPJ:Text, "")
			  	F_EST   := "EX"
			  	F_Formul:= "S"
			  	F_DESPESA := IIF(XmlChildEx(oXmlOk:_InfNfe:_TOTAL:_ICMSTOT,"_VOUTRO") <> Nil, Val(oXmlOk:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:Text), 0)
			  	If (nSomaII == 5)
			  		F_DESPESA -= IIF(XmlChildEx(oXmlOk:_InfNfe:_TOTAL:_ICMSTOT,"_VPIS") <> Nil, Val(oXmlOk:_INFNFE:_TOTAL:_ICMSTOT:_VPIS:Text), 0)
			  		F_DESPESA -= IIF(XmlChildEx(oXmlOk:_InfNfe:_TOTAL:_ICMSTOT,"_VCOFINS") <> Nil, Val(oXmlOk:_INFNFE:_TOTAL:_ICMSTOT:_VCOFINS:Text), 0)
			  	ElseIf (nSomaII == 6)
			  		F_DESPESA := 0
			  	EndIf
	        	lNFImp := .T.
	        ElseIf (lExp)
	        	cEndere := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST:_ENDERDEST,"_XLGR") <> Nil, oXmlOk:_INFNFE:_DEST:_ENDERDEST:_xLgr:Text, ' ')
	     		cNroEnd := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST:_ENDERDEST,"_NRO") <> Nil, oXmlOk:_INFNFE:_DEST:_ENDERDEST:_Nro:Text, ' ')
				DbSelectArea("SA1") //Buscar pelo Nome completo
	        	SA1->(DbSetOrder(2)) //A1_FILIAL+A1_NOME+A1_LOJA
	        	aForImp := fBuscaCli(AllTrim(Upper(oXmlOk:_INFNFE:_DEST:_xNome:Text)), u_fNoAcento(AllTrim(Upper(cEndere + ', ' + cNroEnd)), {"'"}))
	        	If aForImp[01]
	        		F_Fornec := aForImp[02]
					F_Loja 	 := aForImp[03]
					F_CadEnt := '1'
	        	Else
	        		aForImp := fSelCli(oXmlOk:_INFNFE:_DEST:_xNome:Text,F_Doc,F_Serie,F_Chave,cArqXML)
					If Len(aForImp) > 0
						F_Fornec := aForImp[1]
						F_Loja 	 := aForImp[2]
						F_CadEnt := '1'
					Else
						F_Fornec := ""
						F_Loja 	 := ""
						F_CadEnt := '3'
					EndIf
	        	EndIf
	        	If (Empty(F_Fornec) .OR. Empty(F_Loja))
	        		aLogXML[Len(aLogXML), 02] += 'Cliente de Exportação: "' + AllTrim(Upper(oXmlOk:_INFNFE:_DEST:_xNome:Text)) + '" não encontrado.' + CHR(13) + CHR(10)
	        	EndIf
	        	F_Emit  := oXmlOk:_INFNFE:_EMIT:_xNome:Text
	        	F_CGCEmi:= IIF(XmlChildEx(oXmlOk:_InfNfe:_EMIT,"_CNPJ") <> Nil, oXmlOk:_INFNFE:_EMIT:_CNPJ:Text, "")
			  	F_Dest  := IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST,"_XNOME") <> Nil, oXmlOk:_INFNFE:_DEST:_xNome:Text, "")
			  	F_CGCDes:= IIF(XmlChildEx(oXmlOk:_InfNfe:_DEST,"_CNPJ") <> Nil, oXmlOk:_INFNFE:_DEST:_CNPJ:Text, "")
			  	F_EST   := "EX"
			  	F_Formul:= "S"
			  	F_DESPESA := IIF(XmlChildEx(oXmlOk:_InfNfe:_TOTAL:_ICMSTOT,"_VOUTRO") <> Nil, Val(oXmlOk:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:Text), 0)
	        EndIf

	        cTpComp := '' //Tipo de Complemento
	        lOKXML  := .T. //Controle de Processamento
	        //Somente irá checar a Chave de Referencia se não for Cupom Fiscal
        	If !(lCupFis)
        		//Verifica se existe a tag "<REFNFE>"
        		If ("<REFNFE>" $ Upper(cXML))
        			//Verifica se existe mais de uma chave de referência
        			If ValType(oXmlOk:_InfNfe:_Ide:_NFref) == "O"
		        		F_REFNFE  := oXmlOk:_InfNfe:_Ide:_NFref:_refNFe:Text
		        		If !(Empty(F_REFNFE)) .AND. cTipoNF == "N"
				        	cTipoNF := "D"
				        EndIf
				        //Verifica se aceita a Inclusão da Nota Fiscal sem Origem
				        If (IdXML == "NFE" .AND. (cTipoNF == "D" .OR. cTipoNF == "B" .OR. cTipoNF == "C"))
				        	lSemOrig := .T.
				        EndIf
		        		aNFOrigem := fBuscaOrig(oXmlOk:_InfNfe:_Ide:_NFref:_refNFe:Text,cTipoNF,IDXML)
		        		If Len(aNFOrigem) == 0 .AND. !lSemOrig
		        			aLogXML[Len(aLogXML), 02] += 'Nota Fiscal de Origem não encontrada.' + CHR(13) + CHR(10)
		        		EndIf
		        	Else
		        		F_REFNFE  := ''
		        		aNFOrigem := {}
		        		//aLogXML[Len(aLogXML), 02] += 'Possui mais de uma Chave de Referência.' + CHR(13) + CHR(10)
		        		lSemOrig := .T.
		        	EndIf
	        	Else
	        		F_REFNFE  := ''
	        		aNFOrigem := {}
	        	EndIf
        	Else
        		F_REFNFE  := ''
        		aNFOrigem := {}
        	EndIf
	        If (cTipoNF == 'C') .OR. (cTipoNF == 'D') /*.OR. (cTipoNF == 'B')*/ //Complemento ou Devolução ou Beneficiamento
	        	cTipoComp := GetTipoCom(F_Doc, F_Serie, F_Fornec, F_Loja)
	        	//Se for CIAP, a Origem será "CIAP"
	        	If (lCIAP)
	        		aNFOrigem := {}
	        		AAdd(aNFOrigem, "CIAP")
	        		AAdd(aNFOrigem, "")
	        	EndIf
				//Verifica se encontrou a Nota Fiscal de Origem
				If (Len(aNFOrigem) > 0)
					lOKXML := .T. //Controle de Processamento
				ElseIf !lSemOrig
					lOKXML := .F. //Controle de Processamento
					aLogXML[Len(aLogXML), 02] += 'Nota Fiscal de Origem não encontrada.' + CHR(13) + CHR(10)
				Else
					lOKXML := .T. //Controle de Processamento
				EndIf
			Else
				lOKXML := .T. //Controle de Processamento
	        EndIf

	        If (Empty(F_Fornec) .OR. Empty(F_Loja))
	        	lOKXML := .F. //Controle de Processamento
	        	lGrava := .F.
	        	//Se não for Exportação, compor o Log de Processamento
	        	If !(F_EST == 'EX')
					If (IdXML == 'NFS')
						aLogXML[Len(aLogXML), 02] += 'Cliente : "' + AllTrim(Upper(oXmlOk:_INFNFE:_DEST:_xNome:Text)) + '" não encontrado.' + CHR(13) + CHR(10)
					ElseIf (IdXML == 'NFE')
						aLogXML[Len(aLogXML), 02] += 'Fornecedor: "' + AllTrim(UPPER(oXmlOk:_INFNFE:_DEST:_xNome:Text)) + '" não encontrado.' + CHR(13) + CHR(10)
					EndIf
	        	EndIf
	        EndIf

	        //cTipoNF := F_Tipo
	        F_Tipo := cTipoNF

	        //Caso o CNPJ do Emitente seja o CNPJ da Empresa Corrente e for Entrada
	        //Será Formulário Próprio
	        If (AllTrim(F_CGCEmi) == AllTrim(SM0->M0_CGC)) .AND. IdXML == 'NFE'
	        	F_Formul := 'S'
	        ElseIf IdXML == 'NFS'
	        	F_Formul := 'S'
	        EndIf

	        //--------------------
			//Log de Processamento
			//--------------------
			aLogXML[Len(aLogXML), 01] += 'Tipo: ' + cTipoNF + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Emitente: ' + F_Emit + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Destinatário: ' + F_Dest + CHR(13) + CHR(10)

			//Verificar se as Duplicatas estão OK
			If (lOKXML)
				aDupl := {} //Array de Duplicatas
				If (XmlChildEx(oXmlOk:_InfNfe,"_COBR") <> Nil)
					If (XmlChildEx(oXmlOk:_InfNfe:_Cobr,"_DUP") <> Nil)
						If ValType(oXmlOk:_InfNfe:_Cobr:_Dup) == 'O'
							aDupl := {oXmlOk:_InfNfe:_Cobr:_Dup}
						Else
							aDupl := oXmlOk:_InfNfe:_Cobr:_Dup
						EndIf
					Else
						aDupl := {} //Array de Duplicatas
					EndIf
				Else
					aDupl := {} //Array de Duplicatas
				EndIf
				//Percorrendo o array de Duplicatas
				For nD := 1 To Len(aDupl)
					//Verifica se possui a Tag dVenc
					dVencDupl := IIf(XmlChildEx(aDupl[nD],"_DVENC") <> Nil, StoD( StrTran( AllTrim(aDupl[nD]:_dVenc:Text), "-", "" )), F_DtEmi)
					nValDupl  := Val(AllTrim(aDupl[nD]:_vDup:Text))
					//Verifica se a Emissão é maior que o Vencimento
					If (F_DtEmi > dVencDupl)
						aLogXML[Len(aLogXML), 02] += 'Parcela ' + StrZero(nD, TamSX3('E1_PARCELA')[01]) + ' possui Emissão (' + DTOC(F_DtEmi) + ') maior que o Vencimento (' + DTOC(dVencDupl) + ').' + CHR(13) + CHR(10)
						lOKXML := .F.
					EndIf
				Next nD
			EndIf

			//Verifica se o Cadastro de Cliente/Fornecedor está OK
			If (lOKXML)
				lOKXML := lCadCliFor
			EndIf

			If (lOKXML)
				DbSelectArea("SZ1")
				SZ1->(DbSetOrder(8)) // Z1_FILIAL + Z1_CHVNFE

				If !(SZ1->(DbSeek(FWxFilial("SZ1") + PadR(AllTrim(F_Chave), TamSX3('Z1_CHVNFE')[01]))))

					cChaveZ1:= xFilial("SZ1")+F_Doc+F_Serie+F_Fornec+F_Loja+F_Tipo

					If IdXML == "NFE"
						If cTipoNF == "N" .or. cTipoNF == "C"
							cTabEmit := 'SA2'
							F_TipoEnt := '2'
						Else
							cTabEmit := 'SA1'
							F_TipoEnt := '1'
						EndIf
					Else
						If cTipoNF == "N" .or. cTipoNF == "C"
							cTabEmit := 'SA1'
							F_TipoEnt := '1'
						Else
							cTabEmit := 'SA2'
							F_TipoEnt := '2'
						EndIf
					EndIf

					Reclock("SZ1",.T.)
					SZ1->Z1_FILIAL 	:= xFilial("SZ1")
					SZ1->Z1_DOC 	:= F_Doc
					SZ1->Z1_SERIE	:= F_Serie
					SZ1->Z1_FORNECE	:= F_Fornec
					SZ1->Z1_LOJA	:= F_Loja
					SZ1->Z1_ESPECIE	:= F_Espec
					SZ1->Z1_FORMUL	:= F_Formul
					SZ1->Z1_CHVNFE	:= F_Chave
					SZ1->Z1_CODNFE	:= F_Chave
					SZ1->Z1_TIPO	:= F_Tipo
					SZ1->Z1_EMISSAO	:= F_DtEmi
					SZ1->Z1_DTDIGIT	:= F_DtEmi
					SZ1->Z1_EMINFE	:= F_DtTran
					SZ1->Z1_HORNFE	:= F_HrTran
					SZ1->Z1_CGCEMI  := F_CGCEmi
					SZ1->Z1_EMIT	:= F_Emit
					SZ1->Z1_CGCDES  := F_CGCDes
					SZ1->Z1_DEST	:= F_Dest
					SZ1->Z1_TPXML	:= F_TpXML
					SZ1->Z1_COND	:= cCondPag //Condição XML
					SZ1->Z1_TIPOENT	:= F_TipoEnt
					SZ1->Z1_STATUS	:= '2'
					SZ1->Z1_CADENT	:= F_CadEnt
					SZ1->Z1_VALMERC	:= F_VALMERC
					SZ1->Z1_DESCONT := F_DESCONT
					SZ1->Z1_FRETE  	:= IIf(lNFImp, 0, F_FRETE) //Considerar o Frete Somente se não for importação
					SZ1->Z1_SEGURO	:= IIf(lNFImp, 0, F_SEGURO) //Considerar o Seguro Somente se não for importação
					SZ1->Z1_DESPESA	:= F_DESPESA
					SZ1->Z1_VALBRUT	:= F_VALBRUT
					SZ1->Z1_EST		:= F_EST
					SZ1->Z1_ARQXML	:= cArqXML
					SZ1->Z1_CODRSEF := F_Stat //Código de Retorno do SEFAZ
					If cTipoNF == 'C'
						If Len(aNFOrigem) > 0
							SZ1->Z1_NFORIG	:= aNFOrigem[1]
							SZ1->Z1_SERORIG	:= aNFOrigem[2]
						EndIf
					EndIf
					SZ1->Z1_VICMUFD := F_VICMSUFD
					/*Impostos*/
					SZ1->Z1_BASEICM := F_BASEICM
					SZ1->Z1_VALICM  := F_VALICM
					SZ1->Z1_BASEIPI := F_BASEIPI
					SZ1->Z1_VALIPI  := F_VALIPI
					SZ1->Z1_BASIMP6 := F_BASIMP6
					SZ1->Z1_VALIMP6 := F_VALIMP6
					SZ1->Z1_BASIMP5 := F_BASIMP5
					SZ1->Z1_VALIMP5 := F_VALIMP5
					SZ1->Z1_BRICMS  := F_BRICMS
					SZ1->Z1_ICMSRET := F_ICMSRET
					SZ1->(MsUnlock())

					lGrava:= .T.
				Else
					aLogXML[Len(aLogXML), 02] += 'Já existe Pré-Nota para a chave "' + AllTrim(F_Chave) + '"' + CHR(13) + CHR(10)
					aLogXML[Len(aLogXML), 02] += 'Favor checar a Pré-Nota/Série: ' + AllTrim(SZ1->Z1_DOC) + '/' + AllTrim(SZ1->Z1_SERIE) + CHR(13) + CHR(10)
					// Registro Duplicado
					lGrava	:= .F.
					//Forçar a abertura de um arquivo qualquer
					oFullXML := XmlParserFile("C:\TOTVS\TESTE.XML","_",@cError,@cWarning)
					//Copiar para a Pasta \IMPORTADOS
					nPosArq := RAt("\NAO_PROC", Upper(cDirArq))
					If (nPosArq > 0)
						cNewArq := SubStr(cDirArq, 1, nPosArq - 1) + '\IMPORTADOS\' + aFiles[i, 01]
						If (__CopyFile(cArqXML, cNewArq))
							nHdl := FErase(cArqXML)
							If (nHdl == -1)
								 MsgAlert('Erro na eliminação do arquivo nº ' + STR(FERROR()))
							Else
								//Apagar arquivo de LOCK
								nHdl := FErase(aFiles[i, 02])
								If (nHdl == -1)
									MsgAlert('Erro na eliminação do arquivo de LOCK nº ' + STR(FERROR()))
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If lGrava
				For j := 1 to Len(aItens)

					cAdic    := ""
					cSeqAdic := ""

					//Caso seja Nota de Importação, gravar o Adição e Seq Adição
					If (lNFImp) .AND. !(XmlChildEx(aItens[j]:_PROD,"_DI") == Nil)
						If !(XmlChildEx(aItens[j]:_PROD:_DI,"_ADI") == Nil)
							//Verifica o Tipo da Tag
							If (ValType(aItens[j]:_PROD:_DI:_ADI) == "O")
								If !(XmlChildEx(aItens[j]:_PROD:_DI:_ADI,"_NADICAO") == Nil) .AND.;
									!(XmlChildEx(aItens[j]:_PROD:_DI:_ADI,"_NSEQADIC") == Nil)
									cAdic    := StrZero(Val(aItens[j]:_PROD:_DI:_ADI:_NADICAO:TEXT), TamSX3('Z2_NADIC')[01])
									cSeqAdic := StrZero(Val(aItens[j]:_PROD:_DI:_ADI:_NSEQADIC:TEXT), TamSX3('Z2_SQADIC')[01])
								EndIf
							ElseIf (ValType(aItens[j]:_PROD:_DI:_ADI) == "A")
								If !('Nota Fiscal possui mais de uma adição!' $ aLogXML[Len(aLogXML), 03])
									aLogXML[Len(aLogXML), 03] += 'Nota Fiscal possui mais de uma adição!' + CHR(13) + CHR(10)
								EndIf
								If (Len(aItens[j]:_PROD:_DI:_ADI) > 0)
									If !(XmlChildEx(aItens[j]:_PROD:_DI:_ADI[01],"_NADICAO") == Nil) .AND.;
										!(XmlChildEx(aItens[j]:_PROD:_DI:_ADI[01],"_NSEQADIC") == Nil)
										cAdic    := StrZero(Val(aItens[j]:_PROD:_DI:_ADI[01]:_NADICAO:TEXT), TamSX3('Z2_NADIC')[01])
										cSeqAdic := StrZero(Val(aItens[j]:_PROD:_DI:_ADI[01]:_NSEQADIC:TEXT), TamSX3('Z2_SQADIC')[01])
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

    				lMajorada	:= .F.
					oImpAux 	:= aItens[j]

					l_ICMS	   := IIF(XmlChildEx(oImpAux:_Imposto,"_ICMS") 	<> Nil, .T. , .F. )
					l_IPI 	   := IIF(XmlChildEx(oImpAux:_Imposto,"_IPI") 	<> Nil, .T. , .F. )
					l_PIS	   := IIF(XmlChildEx(oImpAux:_Imposto,"_PIS") 	<> Nil, .T. , .F. )
					l_COFINS   := IIF(XmlChildEx(oImpAux:_Imposto,"_COFINS") 	<> Nil, .T. , .F. )
					l_II	   := IIF(XmlChildEx(oImpAux:_Imposto,"_II") 		<> Nil, .T. , .F. )
					l_ICMUFDes := IIF(XmlChildEx(oImpAux:_Imposto,"_ICMSUFDEST") <> Nil, .T. , .F. )

					nQuant  := Val(aItens[j]:_Prod:_qCom:Text)

					If j == 1 .And. lNFImp
						If lNFImp
							Reclock("SZ1",.F.)
								SZ1->Z1_NDI		:= StrTran(StrTran(aItens[j]:_PROD:_DI:_nDI:Text,"/",""),"-","")
								SZ1->Z1_DTDI	:= StoD(StrTran(aItens[j]:_PROD:_DI:_dDI:Text,"-",""))
								SZ1->Z1_LOCDES	:= aItens[j]:_PROD:_DI:_xLocDesemb:Text
								SZ1->Z1_UFDES	:= aItens[j]:_PROD:_DI:_UFDesemb:Text
								SZ1->Z1_DTDES	:= StoD(StrTran(aItens[j]:_PROD:_DI:_dDesemb:Text,"-",""))
								SZ1->Z1_CODEXP	:= aItens[j]:_PROD:_DI:_cExportador:Text
							SZ1->(MsUnlock())
						EndIf
					EndIf

					G_Item	 := PadL(aItens[j]:_nItem:Text,TamSX3("D1_ITEM")[1],"0")
					G_CFOP	 := aItens[j]:_Prod:_CFOP:Text
					G_CodEnt := PadR(AllTrim(aItens[j]:_Prod:_cProd:Text),TamSX3("B1_COD")[1])
					G_Desc    := u_fNoAcento(PadR(AllTrim(aItens[j]:_Prod:_xProd:Text),TamSX3("B1_DESC")[1]), {"'"})
					G_CEst   := IIF(XmlChildEx(aItens[j]:_Prod,"_CEST") <> Nil, PadR(AllTrim(aItens[j]:_Prod:_CEST:Text),TamSX3("B1_CEST")[1]), "")
					G_Quant	 := nQuant
					G_VlrUni := Val(aItens[j]:_Prod:_vUnCom:Text)
					G_Total	 := Val(aItens[j]:_Prod:_vProd:Text)

					nMargem := 0

					// ----------------------------------------------------------
					// TRATAMENTO DE IMPOSTOS: ICMS | IPI | PIS | COFINS | II
					// ----------------------------------------------------------

					// -------
					// ICMS
					// -------
					If l_ICMS

						Do Case
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS00") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS00
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS10") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS10
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS20") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS20
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS30") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS30
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS40") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS40
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS51") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS51
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS60") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS60
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS70") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS70
							Case XmlChildEx(oImpAux:_Imposto:_ICMS,"_ICMS90") <> Nil
								oICM:=oImpAux:_Imposto:_ICMS:_ICMS90
						EndCase

						If Valtype(oICM) == 'O'
							If (XmlChildEx(oICM:_ORIG,"TEXT") <> Nil) .And. ( XmlChildEx(oICM:_CST,"TEXT") <> Nil)
								G_ClasF := Alltrim(oICM:_ORIG:TEXT)+Alltrim(oICM:_CST:TEXT)
								G_PrdOri := Alltrim(oICM:_ORIG:TEXT) //Origem
								cCST_ICM:= Alltrim(oICM:_CST:TEXT)
							Endif

							//Margem
							nMargem := IIf(XmlChildEx(oICM,"_PMVAST")   <> Nil, Val(oICM:_pMVAST:TEXT)  , 0)

							G_BasICST := IIf(XmlChildEx(oICM,"_")   <> Nil, Val(oICM:_:TEXT)  , 0)
							G_AlICST  := IIf(XmlChildEx(oICM,"_PICMSST") <> Nil, Val(oICM:_pICMSST:TEXT), 0)
							G_ValICST := IIf(XmlChildEx(oICM,"_VICMSST") <> Nil, Val(oICM:_vICMSST:TEXT), 0)

							If XmlChildEx(oICM,"_PICMS") <> Nil
								G_BaseIcn	:=	Val(oICM:_vBC:TEXT)
								G_AliqIcm	:=	Val(oICM:_pICMS:TEXT)
								G_ValIcms	:=	Val(oICM:_vICMS:TEXT)
							Else
								G_BaseIcn	:=	0
								G_AliqIcm	:=	0
								G_ValIcms	:=	0
							EndIf
						Else
							G_BaseIcn	:=	0
							G_AliqIcm	:=	0
							G_ValIcms	:=	0
						EndIf
					Else
						G_BaseIcn	:=	0
						G_AliqIcm	:=	0
						G_ValIcms	:=	0
					EndIf

					//Alison 25.08.2017
					//Caso seja Importação e a Aliquota esiver zerada,
					//atribuir aliquota 18
					If (lDI .AND. G_AliqIcm == 0)
						G_AliqIcm := 18
					EndIf

					lTemICMS := (G_ValIcms > 0)

					G_AliIPI := 0

					// -------
					// ICMS UF DEST
					// -------
					If (l_ICMUFDes .AND. IdXML == "NFS")
						oICMUFD := oImpAux:_Imposto:_ICMSUFDest //Objeto
						//Alimentando registros
						vBCUFDest    := IIf(XmlChildEx(oICMUFD,"_VBCUFDEST")      <> Nil, Val(oICMUFD:_vBCUFDest:TEXT)     , 0) // -- Variáveis de ICMS UF RET -- //
						pFCPUFDest   := IIf(XmlChildEx(oICMUFD,"_PFCPUFDEST")     <> Nil, Val(oICMUFD:_pFCPUFDest:TEXT)    , 0)
						pICMSUFDest  := IIf(XmlChildEx(oICMUFD,"_PICMSUFDEST")    <> Nil, Val(oICMUFD:_pICMSUFDest:TEXT)   , 0)
						pICMSInter   := IIf(XmlChildEx(oICMUFD,"_PICMSINTER")     <> Nil, Val(oICMUFD:_pICMSInter:TEXT)    , 0)
						pICMSIntPart := IIf(XmlChildEx(oICMUFD,"_PICMSINTERPART") <> Nil, Val(oICMUFD:_pICMSInterPart:TEXT), 0)
						vFCPUFDest   := IIf(XmlChildEx(oICMUFD,"_VFCPUFDEST")     <> Nil, Val(oICMUFD:_vFCPUFDest:TEXT)    , 0)
						vICMSUFDest  := IIf(XmlChildEx(oICMUFD,"_VICMSUFDEST")    <> Nil, Val(oICMUFD:_vICMSUFDest:TEXT)   , 0)
						vICMSUFRemet := IIf(XmlChildEx(oICMUFD,"_VICMSUFREMET")   <> Nil, Val(oICMUFD:_vICMSUFRemet:TEXT)  , 0) // -- Variáveis de ICMS UF RET -- //
					Else
						//Zerando Variáveis
						vBCUFDest    := 0 // -- Variáveis de ICMS UF RET -- //
						pFCPUFDest   := 0
						pICMSUFDest  := 0
						pICMSInter   := 0
						pICMSIntPart := 0
						vFCPUFDest   := 0
						vICMSUFDest  := 0
						vICMSUFRemet := 0 // -- Variáveis de ICMS UF RET -- //
					EndIf

					// -------
					// IPI
					// -------
					If l_IPI

						cENQ_IPI := oImpAux:_Imposto:_IPI:_CENQ:TEXT

						If XmlChildEx(oImpAux:_Imposto:_IPI,"_IPITRIB") <> Nil

							If XmlChildEx(oImpAux:_Imposto:_IPI:_IPITRIB,"_PIPI") <> Nil
								G_AliIPI := NoRound(Val(oImpAux:_Imposto:_IPI:_IPITrib:_pIPI:TEXT), TamSX3('B1_IPI')[02])
							Else
								G_AliIPI := 0
							EndIf

							cCST_IPI	:= oImpAux:_Imposto:_IPI:_IPITrib:_CST:TEXT

							If Val(oImpAux:_Imposto:_IPI:_IPITrib:_vIPI:TEXT) > 0

								lTemIPI		:= .T.

								// -----------------------------------------------------------------------------------------------------------
								// Método alternativo para verificar existencia de TAG devido ao mal funcionamento do XmlChildEx() após 3° nó
								// -----------------------------------------------------------------------------------------------------------
								oArqAux:= oImpAux:_Imposto:_IPI:_IPITrib
								VarInfo("Array", oArqAux)
								cArqAux:= "\xml_totvs\temp_imp\" + "IPITRIB" + StrTran(TIME(),":","") + aFiles[i][1]
								SAVE oArqAux XMLFILE cArqAux
								cXMLAux := MemoRead(cArqAux)

								If "<VBC>" $ Upper(cXMLAux)
									G_BaseIPI	:=	Val(oImpAux:_Imposto:_IPI:_IPITrib:_vBC:TEXT)
									G_AliqIPI	:=	Val(oImpAux:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
								EndIf
								G_ValIPI	:=	Val(oImpAux:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
							Else
								G_BaseIPI	:=	0
								G_AliqIPI	:=	0
								G_ValIPI	:=	0
								lTemIPI		:= .F.
							EndIf

						ElseIf XmlChildEx(oImpAux:_Imposto:_IPI,"_IPINT") <> Nil
							cCST_IPI	:= oImpAux:_Imposto:_IPI:_IPINT:_CST:TEXT
							G_BaseIPI	:=	0
							G_AliqIPI	:=	0
							G_ValIPI	:=	0
							lTemIPI		:= .F.
						Else
							G_BaseIPI	:=	0
							G_AliqIPI	:=	0
							G_ValIPI	:=	0
							lTemIPI		:= .F.
						EndIf
					Else
						G_BaseIPI	:=	0
						G_AliqIPI	:=	0
						G_ValIPI	:=	0
						lTemIPI		:= .F.
					EndIf

					L_CadoPro2 := .F.

					//If IdXML == "NFE" .And. !("<DI>" $ Upper(cXML))
					If IdXML == "NFE" .And. !(lDI)

						If cTipoNF == "D" .OR. cTipoNF == "B"
							/*
							DbSelectArea("SA7")
							SA7->(DbSetOrder(3)) // A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI
							If DbSeek( xFilial("SA7") + F_Fornec +  F_Loja + G_CodEnt  )
								G_Cod	 := SA7->A7_PRODUTO
								G_Local	 := POSICIONE("SB1",1,xFilial("SB1")+G_Cod,"B1_LOCPAD")
							Else
								G_Cod	 := IIf(cTipoNF == "D", G_CodEnt, cProdPad)
								G_Local	 := POSICIONE("SB1",1,xFilial("SB1")+IIf(cTipoNF == "D", G_CodEnt, cProdPad),"B1_LOCPAD")
								L_CadPro := .T.
								lProdOk	 := .F.
							EndIf
							*/
							If (cTpNF == '0' .AND. cTipoNF == 'D')
								G_Cod	 := G_CodEnt
								G_Local	 := POSICIONE("SB1",1,xFilial("SB1")+ G_CodEnt ,"B1_LOCPAD")
								L_CadPro := .T.
								lProdOk	 := .F.
							ElseIf (cTpNF == '1' .AND. cTipoNF == 'D')
								G_Cod	 := cProdPad
								G_Local	 := POSICIONE("SB1",1,xFilial("SB1") + cProdPad,"B1_LOCPAD")
								L_CadPro := .T.
								lProdOk	 := .F.
								aNFOrigem := {}
							ElseIf cTipoNF == 'B'
								DbSelectArea("SA7")
								SA7->(DbSetOrder(03)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI
								If DbSeek( FWxFilial("SA5") + F_Fornec +  F_Loja + G_CodEnt  )
									G_Cod	 := SA7->A7_PRODUTO
									G_Local	 := POSICIONE("SB1",1,xFilial("SB1") + G_Cod,"B1_LOCPAD")
								Else
									G_Cod	 := cProdPad
									G_Local	 := POSICIONE("SB1",1,xFilial("SB1")+cProdPad,"B1_LOCPAD")
									L_CadPro := .T.
									lProdOk	 := .F.
								EndIf
							EndIf
						Else
							DbSelectArea("SA5")
							SA5->(DbSetOrder(14)) // A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
							If DbSeek( xFilial("SA5") + F_Fornec +  F_Loja + G_CodEnt  )
								G_Cod	 := SA5->A5_PRODUTO
								G_Local	 := POSICIONE("SB1",1,xFilial("SB1")+G_Cod,"B1_LOCPAD")
							Else
								
							
							//Retornando o Tipo de Produto
							G_TipoPrd := u_GetTipoPrd(IdXML, G_CFOP)
							G_Cod     := GetSxeNum("SB1","B1_COD")
							G_Local   := AllTrim(SuperGetMV("ES_LOCPRD", .F., ""))
							G_UM      := fGetUM(Upper(AllTrim(aItens[j]:_Prod:_uCom:Text)))
							G_Desc    := u_fNoAcento(PadR(AllTrim(aItens[j]:_Prod:_xProd:Text),TamSX3("B1_DESC")[1]), {"'"})

							//Array com o produto a ser incluido
							aProd := {}
							AAdd(aProd, {"B1_FILIAL"  , FWxFilial('SB1')           , NIL})
							AAdd(aProd, {"B1_COD"	  , G_Cod          , NIL})
							AAdd(aProd, {"B1_DESC"	  , G_Desc          , NIL})
							AAdd(aProd, {"B1_TIPO"	  , G_TipoPrd                                                                      , NIL})
							AAdd(aProd, {"B1_UM"      , Left(G_UM,2)            , NIL})
							AAdd(aProd, {"B1_LOCPAD"  , AllTrim(SuperGetMV("ES_LOCPRD", .F., ""))						  , NIL})
							AAdd(aProd, {"B1_CONTRAT" , "N"                                                                       , NIL})
							AAdd(aProd, {"B1_LOCALIZ" , "N"                                                                       , NIL})
							AAdd(aProd, {"B1_POSIPI"  , PadR(AllTrim(aItens[j]:_Prod:_NCM:Text) ,TamSX3("B1_POSIPI")[1])         , NIL})
							AAdd(aProd, {"B1_IPI"     , G_AliIPI         																, NIL})
							AAdd(aProd, {"B1_ORIGEM"  , '0'/*G_PrdOri*/         																, NIL})
							AAdd(aProd, {"B1_CEST"    , G_CEst         																, NIL})
							AAdd(aProd, {"B1_XIMPXML" , '1'         																, NIL})
							AAdd(aProd, {"B1_GARANT"  , '2'         																, NIL})
							AAdd(aProd, {"B1_UCALSTD" , dDataBase         													, NIL})
							AAdd(aProd, {"B1_CONINI"  , dDataBase         													, NIL})
							
							lMsErroAuto := .F.
							
							MATA010(aProd, 03)

							If lMsErroAuto
								MostraErro()
								L_CadoPro2 := .T.
								lProdOk	 	:= .F.
								RollBackSx8()
							Else
								
								ConfirmSx8()
								
								lProdOk	 	:= .T.
								L_CadoPro2  := .T.
								
								
								//CRIA AMARRACAO COM FORNECEDOR
								Reclock("SA5",.T.)
								A5_FILIAL := FWxFilial("SA5")
								A5_FORNECE  := F_Fornec   
								A5_LOJA := F_Loja
								A5_NOMEFOR := POSICIONE("SA2",1,FWxFilial("SA2")+F_Fornec+F_Loja,"A2_NOME")
								A5_PRODUTO := G_Cod
								A5_NOMPROD := G_Desc 
								A5_CODPRF := G_CodEnt
								
								SA5->(MsUnLock())
							
							EndIf
								
							
							EndIf
						EndIf
					Else

						DbSelectArea("SB1")
						SB1->(DbSetOrder(1))
						If SB1->(dbSeek(xFilial('SB1') + PadR(AllTrim(aItens[j]:_Prod:_cProd:Text),Len(SB1->B1_COD)) ) )
 							G_Cod	 := SB1->B1_COD
							G_Local	 := SB1->B1_LOCPAD
							lProdOk	 := .T.
						Else

							//Retornando o Tipo de Produto
							G_TipoPrd := u_GetTipoPrd(IdXML, G_CFOP)
							G_Cod     := PadR(AllTrim(aItens[j]:_Prod:_cProd:Text),TamSX3("B1_COD")[1])
							G_Local   := AllTrim(SuperGetMV("ES_LOCPRD", .F., ""))
							G_UM      := fGetUM(Upper(AllTrim(aItens[j]:_Prod:_uCom:Text)))
							G_Desc    := u_fNoAcento(PadR(AllTrim(aItens[j]:_Prod:_xProd:Text),TamSX3("B1_DESC")[1]), {"'"})

							//Array com o produto a ser incluido
							aProd := {}
							AAdd(aProd, {"B1_FILIAL"  , FWxFilial('SB1')           , NIL})
							AAdd(aProd, {"B1_COD"	  , PadR(AllTrim(aItens[j]:_Prod:_cProd:Text),TamSX3("B1_COD")[1])           , NIL})
							AAdd(aProd, {"B1_DESC"	  , G_Desc          , NIL})
							AAdd(aProd, {"B1_TIPO"	  , G_TipoPrd                                                                      , NIL})
							AAdd(aProd, {"B1_UM"      , Left(G_UM,2)            , NIL})
							AAdd(aProd, {"B1_LOCPAD"  , AllTrim(SuperGetMV("ES_LOCPRD", .F., ""))						  , NIL})
							AAdd(aProd, {"B1_CONTRAT" , "N"                                                                       , NIL})
							AAdd(aProd, {"B1_LOCALIZ" , "N"                                                                       , NIL})
							AAdd(aProd, {"B1_POSIPI"  , PadR(AllTrim(aItens[j]:_Prod:_NCM:Text) ,TamSX3("B1_POSIPI")[1])         , NIL})
							AAdd(aProd, {"B1_IPI"     , G_AliIPI         																, NIL})
							AAdd(aProd, {"B1_ORIGEM"  , G_PrdOri         																, NIL})
							AAdd(aProd, {"B1_CEST"    , G_CEst         																, NIL})
							AAdd(aProd, {"B1_XIMPXML" , '1'         																, NIL})
							AAdd(aProd, {"B1_GARANT"  , '2'         																, NIL})
							AAdd(aProd, {"B1_UCALSTD" , dDataBase         													, NIL})
							AAdd(aProd, {"B1_CONINI"  , dDataBase         													, NIL})

							cProdTXT := ''
							For nProd := 1 To Len(aProd)
								cProdTXT += aProd[nProd, 01] + ' ' + '|' + IIf(ValType(aProd[nProd, 02]) == "N", cValToChar(aProd[nProd, 02]), IIf(ValType(aProd[nProd, 02]) == "D", DTOC(aProd[nProd, 02]), aProd[nProd, 02])) + '|' + CHR(13) + CHR(10)
							Next nProd

							MemoWrite('C:\TOTVS\PRODUTO_' + aItens[j]:_Prod:_cProd:Text + '.txt', cProdTXT)

							lMsErroAuto := .F.
							//Inicializando Variáveis de memória
							//RegToMemory("SB1", .T.)
							//MSExecAuto({|x,y| MATA010(x,y)},aProd,3)
							MATA010(aProd, 03)

							If lMsErroAuto
								MostraErro()
								L_CadoPro2 := .T.
							Else
								/*G_Cod	 	:= SB1->B1_COD
								G_Local	 	:= SB1->B1_LOCPAD*/
								G_Cod     := PadR(AllTrim(aItens[j]:_Prod:_cProd:Text),TamSX3("B1_COD")[1])
								G_Local   := AllTrim(SuperGetMV("ES_LOCPRD", .F., ""))
								lProdOk	 	:= .T.
								L_CadoPro2  := .T.
							EndIf
						EndIf
						DbSelectArea("SA7")
						SA7->(DbSetOrder(2)) // A7_FILIAL, A7_PRODUTO, A7_CLIENTE, A7_LOJA
						If !(DbSeek(xFilial("SA7") + G_Cod + F_Fornec + F_Loja ))
							CriaSA7(F_Fornec , F_Loja , G_Cod , G_CodEnt)
						EndIf
					EndIf

					// -------
					// PIS
					// -------
					If l_PIS
						If XmlChildEx(oImpAux:_Imposto:_PIS,"_PISALIQ") <> Nil
							G_BasePIS	:= Val(oImpAux:_Imposto:_PIS:_PISALIQ:_vBC:TEXT)
							G_AliqPIS	:= Val(oImpAux:_Imposto:_PIS:_PISALIQ:_pPIS:TEXT)
							G_ValPIS	:= Val(oImpAux:_Imposto:_PIS:_PISALIQ:_vPIS:TEXT)
							cCST_PIS	:= oImpAux:_Imposto:_PIS:_PISALIQ:_CST:TEXT
						ElseIf XmlChildEx(oImpAux:_Imposto:_PIS,"_PISNT") <> Nil
							cCST_PIS	:= oImpAux:_Imposto:_PIS:_PISNT:_CST:TEXT
							G_BasePIS	:=	0
							G_AliqPIS	:=	0
							G_ValPIS	:=	0
						ElseIf XmlChildEx(oImpAux:_Imposto:_PIS,"_PISQTDE") <> Nil
							cCST_PIS	:= oImpAux:_Imposto:_PIS:_PISQTDE:_CST:TEXT
							G_BasePIS	:=	0
							G_AliqPIS	:=	0
							G_ValPIS	:=	0
						ElseIf XmlChildEx(oImpAux:_Imposto:_PIS,"_PISOUTR") <> Nil
							cCST_PIS	:= oImpAux:_Imposto:_PIS:_PISOUTR:_CST:TEXT
							If Val(oImpAux:_Imposto:_PIS:_PISOUTR:_vPIS:TEXT) > 0
								G_BasePIS	:= Val(oImpAux:_Imposto:_PIS:_PISOUTR:_vBC:TEXT)
								G_AliqPIS	:= Val(oImpAux:_Imposto:_PIS:_PISOUTR:_pPIS:TEXT)
								G_ValPIS	:= Val(oImpAux:_Imposto:_PIS:_PISOUTR:_vPIS:TEXT)
								cCST_PIS	:= oImpAux:_Imposto:_PIS:_PISOUTR:_CST:TEXT
							Else
								G_BasePIS	:=	0
								G_AliqPIS	:=	0
								G_ValPIS	:=	0
							EndIf
						Else
							G_BasePIS	:=	0
							G_AliqPIS	:=	0
							G_ValPIS	:=	0
						EndIf
					Else
						G_BasePIS	:=	0
						G_AliqPIS	:=	0
						G_ValPIS	:=	0
					EndIf

					If l_COFINS

						If XmlChildEx(oImpAux:_Imposto:_COFINS,"_COFINSALIQ") <> Nil
							G_BaseCOF	:=	Val(oImpAux:_Imposto:_COFINS:_COFINSALIQ:_vBC:TEXT)
							G_AliqCOF	:=	Val(oImpAux:_Imposto:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
							G_ValCOF	:=	Val(oImpAux:_Imposto:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
							cCST_COF	:= oImpAux:_Imposto:_COFINS:_COFINSALIQ:_CST:TEXT
						ElseIf XmlChildEx(oImpAux:_Imposto:_COFINS,"_COFINSNT") <> Nil
							cCST_COF	:= oImpAux:_Imposto:_COFINS:_COFINSNT:_CST:TEXT
							G_BaseCOF	:=	0
							G_AliqCOF	:=	0
							G_ValCOF	:=	0
						ElseIf XmlChildEx(oImpAux:_Imposto:_COFINS,"_COFINSQTDE") <> Nil
							cCST_COF	:= oImpAux:_Imposto:_COFINS:_COFINSQTDE:_CST:TEXT
							G_BaseCOF	:=	0
							G_AliqCOF	:=	0
							G_ValCOF	:=	0
						ElseIf XmlChildEx(oImpAux:_Imposto:_COFINS,"_COFINSOUTR") <> Nil
							cCST_COF	:= oImpAux:_Imposto:_COFINS:_COFINSOUTR:_CST:TEXT
							If Val(oImpAux:_Imposto:_COFINS:_COFINSOUTR:_vCOFINS:TEXT) > 0
								G_BaseCOF	:=	Val(oImpAux:_Imposto:_COFINS:_COFINSOUTR:_vBC:TEXT)
								G_AliqCOF	:=	Val(oImpAux:_Imposto:_COFINS:_COFINSOUTR:_pCOFINS:TEXT)
								G_ValCOF	:=	Val(oImpAux:_Imposto:_COFINS:_COFINSOUTR:_vCOFINS:TEXT)
								cCST_COF	:= oImpAux:_Imposto:_COFINS:_COFINSOUTR:_CST:TEXT

								//If oImpAux:_Imposto:_COFINS:_COFINSOUTR:_pCOFINS:TEXT $ cAliqMajo
								If cValToChar(Round(Val(oImpAux:_Imposto:_COFINS:_COFINSOUTR:_pCOFINS:TEXT), 02)) $ cAliqMajo
									lMajorada:= .T.
								Else
									lMajorada:= .F.
								EndIf

							Else
								G_BaseCOF	:=	0
								G_AliqCOF	:=	0
								G_ValCOF	:=	0
							EndIf
						Else
							G_BaseCOF	:=	0
							G_AliqCOF	:=	0
							G_ValCOF	:=	0
						EndIf
					Else
						G_BaseCOF	:=	0
						G_AliqCOF	:=	0
						G_ValCOF	:=	0
					EndIf

					If l_II
						If XmlChildEx(oImpAux:_Imposto:_II,"_VII") <> Nil
							G_VlrII := Val(oImpAux:_Imposto:_II:_vII:TEXT)
						Else
							G_VlrII := 0
						EndIf
						If XmlChildEx(oImpAux:_Imposto:_II,"_VBC") <> Nil
							G_BaseII := Val(oImpAux:_Imposto:_II:_vBC:TEXT)
						Else
							G_BaseII := 0
						EndIf
					Else
						G_VlrII := 0
					EndIf

					nValFre := 0

					If XmlChildEx(aItens[j]:_Prod,"_VFRETE") <> Nil
						nValFre += Val(aItens[j]:_Prod:_vFrete:Text)
					Endif

					G_ValDesc := 0

					If XmlChildEx(aItens[j]:_Prod,"_VDESC") <> Nil
						G_ValDesc := Val(aItens[j]:_Prod:_vDesc:Text)
					Endif

					G_ValDesp := 0

					If XmlChildEx(aItens[j]:_Prod,"_VOUTRO") <> Nil
						G_ValDesp := Val( aItens[j]:_Prod:_vOutro:Text )
					EndIf

					G_ValSeg := 0

					If XmlChildEx(aItens[j]:_Prod,"_VSEG") <> Nil
						G_ValSeg := Val( aItens[j]:_Prod:_vSeg:Text )
					EndIf

					//If "<DI>" $ Upper(cXML)
					If lDI

						nValFre := 0
						G_ValDesc := 0
						G_ValDesp := 0
						G_ValSeg := 0

						If nSomaII == 1
							G_VlrUni	:= Val( aItens[j]:_Prod:_vUnCom:Text)
							G_Total		:= Val( aItens[j]:_Prod:_vProd:Text)

							//If Type("aItens[j]:_Prod:_vOutro") <> "U"
							If XmlChildEx(aItens[j]:_Prod,"_VOUTRO") <> Nil
								G_ValDesp :=	Val( aItens[j]:_Prod:_vOutro:Text )
							EndIf
						ElseIf nSomaII == 2
							//If Type("aItens[" + cValToChar(j) + "]:_Imposto:_II:_vII") <> "U"
							If XmlChildEx(aItens[j]:_Imposto,"_II") <> Nil
								If XmlChildEx(aItens[j]:_Imposto:_II,"_VII") <> Nil
									nValUnit :=  Val( aItens[j]:_Prod:_vProd:Text ) + Val(aItens[j]:_Imposto:_II:_vII:Text)
									nValProd := nValUnit
									nValUnit := nValUnit / Val( aItens[j]:_Prod:_qCom:Text )
									G_VlrUni := nValUnit
									G_Total  := nValProd
								EndIf
							EndIf

							//If Type("aItens[j]:_Prod:_vOutro") <> "U"
							If XmlChildEx(aItens[j]:_Prod,"_VOUTRO") <> Nil
								G_ValDesp := Val( aItens[j]:_Prod:_vOutro:Text )
							EndIf

						ElseIf nSomaII == 3

							nValUnit := Val( aItens[j]:_Prod:_vProd:Text )

							If XmlChildEx(aItens[j]:_Imposto,"_II") <> Nil
								If XmlChildEx(aItens[j]:_Imposto:_II,"_VII") <> Nil
									nValUnit += Val(aItens[j]:_Imposto:_II:_vII:Text)
								EndIf
							EndIf

							If XmlChildEx(aItens[j]:_Prod,"_VFRETE") <> Nil
								nValUnit += Val(aItens[j]:_Prod:_vFrete:Text)
							Endif

							If XmlChildEx(aItens[j]:_Prod,"_VSEG") <> Nil
								nValUnit += Val(aItens[j]:_Prod:_vSeg:Text)
							Endif

							nValProd := nValUnit
							nValUnit := nValUnit / Val( aItens[j]:_Prod:_qCom:Text )

							G_VlrUni := nValUnit
							G_Total  := nValProd

							If Type("aItens[j]:_Imposto:_II:_vDespadu") <> "U"
								G_ValDesp:= Val( aItens[j]:_Imposto:_II:_vDespadu:Text )
							EndIf


						ElseIf nSomaII == 4

							nValUnit := Val( aItens[j]:_Prod:_vProd:Text )

							//If Type("aItens[j]:_Imposto:_II:_vII") <> "U"
							If XmlChildEx(aItens[j]:_Imposto,"_II") <> Nil
								If XmlChildEx(aItens[j]:_Imposto:_II,"_VII") <> Nil
									nValUnit += Val(aItens[j]:_Imposto:_II:_vII:Text)
								EndIf
							EndIf

							nValProd := nValUnit

							nValUnit := nValUnit / Val( aItens[j]:_Prod:_qCom:Text )

							G_VlrUni := nValUnit
							G_Total  := nValProd

							G_ValDesp := 0

							//If Type("aItens[j]:_Imposto:_II:_vDespadu") <> "U"
							If XmlChildEx(aItens[j]:_Imposto,"_II") <> Nil
								If XmlChildEx(aItens[j]:_Imposto:_II,"_VDESPADU") <> Nil
									G_ValDesp += Val( aItens[j]:_Imposto:_II:_vDespadu:Text )
								EndIf
							EndIf

							//If Type("aItens[j]:_Prod:_DI:_vAFRMM") <> "U"
							If XmlChildEx(aItens[j]:_Prod,"_DI") <> Nil
								If XmlChildEx(aItens[j]:_Prod:_DI,"_VAFRMM") <> Nil
									G_ValDesp += Val(aItens[j]:_Prod:_DI:_vAFRMM:Text)
								EndIf
							EndIf

						ElseIf nSomaII == 5
							G_VlrUni	:= Val( aItens[j]:_Prod:_vUnCom:Text)
							G_Total		:= Val( aItens[j]:_Prod:_vProd:Text)

							If XmlChildEx(aItens[j]:_Prod,"_VOUTRO") <> Nil
								G_ValDesp :=	Val( aItens[j]:_Prod:_vOutro:Text ) - (G_ValPIS + G_ValCOF)
							EndIf
						ElseIf nSomaII == 6
							nValUnit := 0//Val( aItens[j]:_Prod:_vProd:Text )

							nValUnit += (G_BaseII + G_VlrII)

							nValProd := nValUnit

							nValUnit := nValUnit / Val( aItens[j]:_Prod:_qCom:Text )

							G_VlrUni := nValUnit
							G_Total  := nValProd

							G_ValDesp := G_BaseIcn - (G_BaseII + G_VlrII + G_ValIPI + G_ValPIS + G_ValCOF + G_ValIcms)

						Else
							G_VlrUni := Val( aItens[j]:_Prod:_vUnCom:Text )
							G_Total  := Val( aItens[j]:_Prod:_vProd:Text )
						EndIf

					EndIf

					//Alison 25.08.2017
					//Caso o CST de PIS e COFINS seja "06", considerar a Base de Cálculo
					//como o Valor da Mercadoria
					If (AllTrim(cCST_PIS) == "06" .AND. AllTrim(cCST_COF) == "06")
						G_BasePIS := (G_Total + IIf(lIPIObs, 0, G_ValDesp) + G_ValSeg + nValFre) - G_ValDesc
						G_BaseCOF := (G_Total + IIf(lIPIObs, 0, G_ValDesp) + G_ValSeg + nValFre) - G_ValDesc
					EndIf

					Reclock("SZ2",.T.)
						SZ2->Z2_FILIAL  := FWxFilial('SZ2')
						SZ2->Z2_ITEM	:= G_Item
						SZ2->Z2_COD		:= G_Cod
						SZ2->Z2_QUANT	:= G_Quant
						SZ2->Z2_LOCAL	:= G_Local
						SZ2->Z2_UM		:= POSICIONE("SB1",1,xFilial("SB1")+G_Cod,"B1_UM")
						SZ2->Z2_VUNIT	:= G_VlrUni
						SZ2->Z2_CODENT	:= G_CodEnt
						SZ2->Z2_XDESC	:= G_Desc
						SZ2->Z2_TOTAL	:= G_Total
						SZ2->Z2_CF		:= G_CFOP
						SZ2->Z2_DOC		:= F_Doc
						SZ2->Z2_SERIE	:= F_Serie//StrZero(Val(AllTrim(F_Serie)),TamSx3("F1_SERIE")[1])
						SZ2->Z2_FORNECE	:= F_Fornec
						SZ2->Z2_LOJA	:= F_Loja
						SZ2->Z2_TIPO	:= F_Tipo
						SZ2->Z2_EMISSAO	:= F_DtEmi
						SZ2->Z2_DTDIGIT	:= F_DtEmi
						SZ2->Z2_BASEICM	:= G_BaseIcn
						SZ2->Z2_PICM	:= G_AliqIcm
						SZ2->Z2_VALICM	:= G_ValIcms
						SZ2->Z2_CLASFIS	:= G_ClasF
						SZ2->Z2_BASEIPI	:= G_BaseIPI
						SZ2->Z2_IPI		:= G_AliqIPI
						SZ2->Z2_VALIPI	:= G_ValIPI
						SZ2->Z2_BASEPIS	:= G_BasePIS
						SZ2->Z2_ALQPIS	:= G_AliqPIS
						SZ2->Z2_VALPIS	:= G_ValPIS
						SZ2->Z2_BASECOF	:= G_BaseCOF
						SZ2->Z2_ALQCOF	:= G_AliqCOF
						SZ2->Z2_VALCOF	:= G_ValCOF
						SZ2->Z2_II		:= G_VlrII
						SZ2->Z2_DESPESA	:= IIf(lIPIObs, 0, G_ValDesp)
						SZ2->Z2_IPIOBS  := IIf(lIPIObs, G_ValDesp, 0)
						SZ2->Z2_VALFRE  := nValFre
						SZ2->Z2_VALDESC := G_ValDesc
						SZ2->Z2_SEGURO  := G_ValSeg
						If Len(aNFOrigem) > 0
							SZ2->Z2_NFORI	:= aNFOrigem[1]
							SZ2->Z2_SERIORI	:= aNFOrigem[2]
							G_ItemOri := GetItemOri(aNFOrigem[1], aNFOrigem[2], F_REFNFE, IIf(cTipoNF == "D" .AND. IdXML == "NFE", G_CodEnt, G_Cod), IIf(cTipoNF == "D", IIf(IdXML == "NFS", "NFE", "NFS") , IdXML))
							SZ2->Z2_ITEMORI := G_ItemOri
						EndIf
						//If IdXML == "NFS" .OR. "<DI>" $ Upper(cXML)
						If IdXML == "NFS" .OR. lDI
							//cTES := fBuscaTES(G_CFOP, cCST_ICM, cCST_IPI, cCST_PIS, cCST_COF, cENQ_IPI,cTipoCli,lTemIPI,lMajorada,IIF("<DI>" $ Upper(cXML),"IMP","NFS"), cTipoNF, @lDevP3, lTemICMS )
							cTES := fBuscaTES(G_CFOP, cCST_ICM, cCST_IPI, cCST_PIS, cCST_COF, cENQ_IPI,cTipoCli,lTemIPI,lMajorada,IIF(lDI,"IMP","NFS"), cTipoNF, @lDevP3, lTemICMS, F_EST )
							If !Empty(cTES)
								SZ2->Z2_TES := cTES
							Else
								lClassOk	:= .F.
							EndIf
						EndIf
						//Verifica se é TES em Poder de Terceiros para Devolução
						If (lDevP3)
							aDevP3 := u_fSelSB6(F_Doc, F_Serie, G_Item, F_Fornec, F_Loja, G_Cod)
							If Len(aDevP3) == 04
								SZ2->Z2_NFORI	:= aDevP3[1]
								SZ2->Z2_SERIORI	:= aDevP3[2]
								SZ2->Z2_ITEMORI := aDevP3[3]
								SZ2->Z2_IDENTB6 := aDevP3[4]
							EndIf
						EndIf
						SZ2->Z2_VBCUFDE := vBCUFDest
						SZ2->Z2_PFCPUFD := pFCPUFDest
						SZ2->Z2_PICMSUF := pICMSUFDest
						SZ2->Z2_PICMSIN := pICMSInter
						SZ2->Z2_PICMSIP := pICMSIntPart
						SZ2->Z2_VFCPUFD := vFCPUFDest
						SZ2->Z2_VICMSUF := vICMSUFDest
						SZ2->Z2_VICMSRE := vICMSUFRemet
						SZ2->Z2_NADIC   := cAdic
						SZ2->Z2_SQADIC  := cSeqAdic
						/*Impostos*/
						SZ2->Z2_BASIMP6 := G_BasePIS
						SZ2->Z2_ALQIMP6 := G_AliqPIS
						SZ2->Z2_VALIMP6 := G_ValPIS
						SZ2->Z2_BASIMP5 := G_BaseCOF
						SZ2->Z2_ALQIMP5 := G_AliqCOF
						SZ2->Z2_VALIMP5 := G_ValCOF
						SZ2->Z2_BRICMS  := G_BasICST
						SZ2->Z2_ICMSRET := G_ValICST
						SZ2->Z2_ALIQSOL := G_AlICST
						/*Campos DIFAL*/
						/*
						SZ2->Z2_PDDES   := pICMSIntPart
						SZ2->Z2_VDDES   := vICMSUFDest
						SZ2->Z2_PDORI   := 100 - pICMSIntPart
						SZ2->Z2_ADIF    := pICMSUFDest
						SZ2->Z2_BASEDES := vBCUFDest
						SZ2->Z2_ICMSCOM := vICMSUFRemet
						*/
						/*Campos de CST*/
						SZ2->Z2_CSTPIS := cCST_PIS
						SZ2->Z2_CSTIPI := cCST_IPI
						SZ2->Z2_CSTCOF := cCST_COF
						SZ2->Z2_MARGEM := nMargem
					SZ2->(MsUnlock())

					F_BASEICM += G_BaseIcn
					F_VALICM  += G_ValIcms
					F_BASEIPI += G_BaseIPI
					F_VALIPI  += G_ValIPI
					F_BASIMP6 += G_BasePIS
					F_VALIMP6 += G_ValPIS
					F_BASIMP5 += G_BaseCOF
					F_VALIMP5 += G_ValCOF
					F_BRICMS  += G_BasICST
					F_ICMSRET += G_ValICST
					F_VBCUFDEST += vBCUFDest
					//If (nSomaII == 6 .AND. "<DI>" $ Upper(cXML)) //Compondo a despesa de Acordo com a regra
					If (nSomaII == 6 .AND. lDI) //Compondo a despesa de Acordo com a regra
						F_DESPESA += G_BaseIcn - (G_BaseII + G_VlrII + G_ValIPI + G_ValPIS + G_ValCOF + G_ValIcms)
					EndIf
				Next j

				If (RecLock('SZ1', .F.))
					/*Impostos*/
					SZ1->Z1_BASEICM := F_BASEICM
					SZ1->Z1_VALICM  := F_VALICM
					SZ1->Z1_BASEIPI := F_BASEIPI
					SZ1->Z1_VALIPI  := F_VALIPI
					SZ1->Z1_BASIMP6 := F_BASIMP6
					SZ1->Z1_VALIMP6 := F_VALIMP6
					SZ1->Z1_BASIMP5 := F_BASIMP5
					SZ1->Z1_VALIMP5 := F_VALIMP5
					SZ1->Z1_BRICMS  := F_BRICMS
					SZ1->Z1_ICMSRET := F_ICMSRET
					//If (nSomaII == 6 .AND. "<DI>" $ Upper(cXML)) //Compondo a despesa de Acordo com a regra
					If (nSomaII == 6 .AND. lDI) //Compondo a despesa de Acordo com a regra
						SZ1->Z1_DESPESA := F_DESPESA
					EndIf
					/*Difal*/
					/*
					SZ1->Z1_DIFAL   := F_VICMSUFD
					SZ1->Z1_BASEDES := F_VBCUFDEST
					*/
					SZ1->(MsUnlock())
				EndIf

				// -------------------------------
				// Verifico o Tipo de Complemento
				// -------------------------------
				If cTipoNF == 'C'

					If G_Total > 0			// COMPLEMENTO DE PREÇO
						cTpComp	:= "C"
					ElseIf G_ValIcms > 0	// COMPLEMENTO DE ICMS
						cTpComp	:= "I"
					ElseIf G_ValIPI > 0 	// COMPLEMENTO DE IPI
						cTpComp	:= "P"
					ElseIf G_ValICST > 0
						cTpComp	:= "I"
					Else					// NÃO IDENTIFICADO | INCONSISTÊNCIA NO ARQUIVO XML
				    	cTpComp	:= ""
					EndIf

					Reclock("SZ1",.F.)
						SZ1->Z1_TIPO := cTpComp
					SZ1->(MsUnlock())

				EndIf

				If IdXML == "NFE"
					IF F_Tipo == "D"
						SA1->( DbSetOrder(1) )
						IF SA1->( DbSeek( xFilial("SA1") + SZ1->Z1_FORNECE + SZ1->Z1_LOJA ) ) .And. SA1->A1_MSBLQL == "1"
							RecLock("SA1",.F.)
							SA1->A1_MSBLQL	:= "2"
							MsUnLock()
							aAdd(aCGCCli, cCGC )
						Endif
					Else
						SA2->( DbSetOrder(1) )
						IF SA2->( DbSeek( xFilial("SA2") + SZ1->Z1_FORNECE + SZ1->Z1_LOJA ) ) .And. SA2->A2_MSBLQL == "1"
							RecLock("SA2",.F.)
							SA2->A2_MSBLQL	:= "2"
							MsUnLock()
							aAdd(aCGCFor, cCGC )
						Endif
					Endif

					//Verifica se pode gerar o Documento
					If (lCFOk)
						cZ1Stat := '' //Status da SZ1
						If lNFImp
							If lGoImp .AND. lClassOk
								lOk:= U_TIBNFEXML("IMP")
								//Customizado B. Vinicius, quando for entrada e importacao bloqueio de movimento status
								cZ1Stat := Iif( SZ1->Z1_STATUS == '1' .And. SZ1->Z1_EST = 'EX' , '7' , '1')
							ElseIf !(lClassOk)
								lOK     := .T.
								cZ1Stat := '2'
							EndIf
						Else
							lOk:= U_TIBNFEXML("PRE")
							cZ1Stat := '2'
						EndIf

						If lOk
							Reclock("SZ1",.F.)
								SZ1->Z1_STATUS := cZ1Stat
							SZ1->(MsUnlock())
						Else
							Reclock("SZ1",.F.)
								SZ1->Z1_STATUS := '4'
							SZ1->(MsUnlock())
						EndIf
					Else
						Reclock("SZ1",.F.)
						SZ1->Z1_STATUS := '4'
						SZ1->(MsUnlock())
					EndIf
				EndIf

				If IdXML == "NFS" .And. lClassOk .And. lProdOk .AND. lCFOk
					lOk:= U_TIBNFSXML()
					If lOk
						//Verifica se é denegada
						If (SZ1->Z1_CODRSEF $ cCodDeneg)
							//Excluindo a Nota Fiscal
							If (u_TIBCANXML())
								Reclock("SZ1",.F.)
								SZ1->Z1_STATUS := '6' //NF Denegada
								SZ1->(MsUnlock())
							Else
								Reclock("SZ1",.F.)
								SZ1->Z1_STATUS := '4'
								SZ1->(MsUnlock())
							Endif
						Else
							Reclock("SZ1",.F.)
								SZ1->Z1_STATUS := '1'
							SZ1->(MsUnlock())
						EndIf
					Else
						Reclock("SZ1",.F.)
							SZ1->Z1_STATUS := '4'
						SZ1->(MsUnlock())
					EndIf
				EndIf

				If L_CadoPro2
					Reclock("SZ1",.F.)
						SZ1->Z1_CADPRO 	:= '3'
					SZ1->(MsUnlock())
				Else
					If L_CadPro
						Reclock("SZ1",.F.)
							SZ1->Z1_CADPRO 	:= '2'
						SZ1->(MsUnlock())
					Else
						Reclock("SZ1",.F.)
							SZ1->Z1_CADPRO 	:= '1'
						SZ1->(MsUnlock())
					EndIf
				EndIf
			Else
				// ARQUIVO JÁ IMPORTADO
				// AGUARDANDO DECISÃO DE TRATAMENTO
			EndIf

		ElseIf IdXML == "CTE"

			lGrava := .T.
			cChvCTe := ''

			aNotas := {}

			If ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
				If XmlChildEx( oXML, '_CTEPROC' ) != Nil
					oXML	:= oXML:_cteProc

					If XmlChildEx( oXML, '_CTE' ) != Nil
						oXML	:= oXML:_Cte

						If XmlChildEx( oXML , '_INFCTE') != Nil
							oXML	:= oXML:_infCte

							If XmlChildEx( oXML , '_EMIT') != Nil
								F_CGCEmi := ""//oXML:_EMIT:_CNPJ:TEXT
								F_Emit   := ""//oXML:_EMIT:_xNome:TEXT
								F_CGCDes := ""//SM0->M0_CGC
								F_Dest   := ""//SM0->M0_NOMECOM
							EndIf

							//Gravando CNPJ's

							//Tomador
							If XmlChildEx( oXML , '_IDE') != Nil
								If XmlChildEx( oXML:_IDE , '_TOMA4') != Nil
									//Alison 04.08.2017 //Tag CNPJ ou CPF
									If (XmlChildEx(oXML:_IDE:_TOMA4 ,"_CNPJ") <> Nil)
										cCGCTom := oXML:_IDE:_TOMA4:_CNPJ:TEXT
									ElseIf (XmlChildEx(oXML:_REM ,"_CPF") <> Nil)
										cCGCTom  := oXML:_IDE:_TOMA4:_CPF:TEXT
									Else
										cCGCTom := ""
									EndIf
									cTomCTe := oXML:_IDE:_TOMA4:_xNome:TEXT
								EndIf
							EndIf

							//Remetente
							If (XmlChildEx(oXML ,"_REM") <> Nil)
								//Alison 04.08.2017 //Tag CNPJ ou CPF
								If (XmlChildEx(oXML:_REM ,"_CNPJ") <> Nil)
									cCGCRem := oXML:_REM:_CNPJ:TEXT
								ElseIf (XmlChildEx(oXML:_REM ,"_CPF") <> Nil)
									cCGCRem  := oXML:_REM:_CPF:TEXT
								Else
									cCGCRem := ""
								EndIf
							Else
								cCGCRem := ""
							EndIf
							cRemCTe  := IIf(XmlChildEx(oXML ,"_REM") <> Nil, oXML:_REM:_xNOME:TEXT, "") //Nome Remetente
							//Emitente
							If (XmlChildEx(oXML ,"_EMIT") <> Nil)
								//Alison 04.08.2017 //Tag CNPJ ou CPF
								If (XmlChildEx(oXML:_EMIT ,"_CNPJ") <> Nil)
									cCGCEmit := oXML:_EMIT:_CNPJ:TEXT
								ElseIf (XmlChildEx(oXML:_EMIT ,"_CPF") <> Nil)
									cCGCEmit  := oXML:_EMIT:_CPF:TEXT
								Else
									cCGCEmit := ""
								EndIf
							Else
								cCGCEmit := ""
							EndIf
							cEmitCTe := IIf(XmlChildEx(oXML ,"_EMIT") <> Nil, oXML:_EMIT:_xNOME:TEXT, "") //Nome Emitente
							//Destinatário
							If (XmlChildEx(oXML ,"_DEST") <> Nil)
								//Alison 04.08.2017 //Tag CNPJ ou CPF
								If (XmlChildEx(oXML:_DEST ,"_CNPJ") <> Nil)
									cCGCDest := oXML:_DEST:_CNPJ:TEXT
								ElseIf (XmlChildEx(oXML:_DEST ,"_CPF") <> Nil)
									cCGCDest  := oXML:_DEST:_CPF:TEXT
								Else
									cCGCDest := ""
								EndIf
							Else
								cCGCDest := ""
							EndIf
							cDestCTe := IIf(XmlChildEx(oXML ,"_DEST") <> Nil, oXML:_DEST:_xNOME:TEXT, "") //Nome Destinatário
							//Expedidor
							If (XmlChildEx(oXML ,"_EXPED") <> Nil)
								//Alison 04.08.2017 //Tag CNPJ ou CPF
								If (XmlChildEx(oXML:_EXPED ,"_CNPJ") <> Nil)
									cCGCExp := oXML:_EXPED:_CNPJ:TEXT
								ElseIf (XmlChildEx(oXML:_EXPED ,"_CPF") <> Nil)
									cCGCExp  := oXML:_EXPED:_CPF:TEXT
								Else
									cCGCExp := ""
								EndIf
							Else
								cCGCExp := ""
							EndIf
							cExpCTE  := IIf(XmlChildEx(oXML ,"_EXPED") <> Nil, oXML:_EXPED:_xNOME:TEXT, "") //Nome Expedidor
							//Recebedor
							If (XmlChildEx(oXML ,"_RECEB") <> Nil)
								//Alison 19.07.2017 //Tag CNPJ ou CPF
								If (XmlChildEx(oXML:_RECEB ,"_CNPJ") <> Nil)
									cCGCRec := oXML:_RECEB:_CNPJ:TEXT
								ElseIf (XmlChildEx(oXML:_RECEB ,"_CPF") <> Nil)
									cCGCRec  := oXML:_RECEB:_CPF:TEXT
								Else
									cCGCRec := ""
								EndIf
							Else
								cCGCRec := ""
							EndIf
							cRecCTe  := IIf(XmlChildEx(oXML ,"_RECEB") <> Nil, oXML:_RECEB:_xNOME:TEXT, "") //Nome Recebedor

							//--------------------------------------------------------------------
							//-- Busca numeração CT-e
							//--------------------------------------------------------------------
							If XmlChildEx( oXML , '_IDE') != Nil
								oXMLAux	:= oXML:_ide

								If XmlChildEx(oXMLAux,'_NCT') != Nil
									cNumCte		:= oXMLAux:_nCT:text
								EndIf

								If XmlChildEx(oXMLAux,'_REFCTE') != Nil
									cChvCTe		:= oXMLAux:_refCTE:Text
								EndIf

								If (Empty(cChvCTe) .AND. XmlChildEx(oXML ,"_ID") <> Nil)
									cChvCTe := Right(AllTrim(oXML:_Id:Text),44)
								EndIf

								If XMLChildEx(oXMLAux,'_SERIE') != Nil
									cSerieCTe	:= oXMLAux:_serie:text
								EndIf

								If XMLChildEx(oXMLAux,'_DHEMI') != Nil
									dDtEmisCTe := Ctod( SubStr( oXMLAux:_dhEmi:Text , 9, 2 ) + '/' + ;
													SubStr( oXMLAux:_dhEmi:Text, 6, 2 ) + '/' + ;
													SubStr( oXMLAux:_dhEmi:Text, 1, 4 ) )

								EndIf
							EndIf

							//--------------------------------------------------------------------
							//-- Busca dados da transportadora
							//--------------------------------------------------------------------
							If XmlChildEx( oXML , '_EMIT') != Nil
								oXMLAux	:= oXML:_emit

								If XMLChildEx(oXMLAux , '_CNPJ') != Nil
									cCGCForn	:= oXMLAux:_CNPJ:text
								EndIf
							EndIf

							//--------------------------------------------------------------------
							//-- Busca Valores CT-e
							//--------------------------------------------------------------------

							//-- Valor prestação de serviço
							If XmlChildEx( oXML , '_VPREST') != Nil
								oXMLAux	:= oXML:_vPrest

								//-- Valor Prestação de Serviço
								If XmlChildEx(oXMLAux , '_VTPREST') != Nil
									nValCte		:= Val(oXMLAux:_vTPrest:Text)
								EndIf
							EndIf

							//-- Valores ICMS
							If XmlChildEx( oXml , '_IMP') != Nil
								oXMLAux	:= oXml:_imp

								If XmlChildEx(oXmlAux , '_ICMS') != Nil
									oXMLAux		:= oXMLAux:_ICMS
									oICM        := Nil

									//-- Substituição Tributária
									If XmlChildEx(oXMLAux, '_ICMS60') != Nil
										oXMLAux	:= oXMLAux:_ICMS60

										//-- Base ICMS
										If XmlChildEx(oXMLAux,'_VBC') != Nil
											nBaseICM60	:= Val(oXMLAux:_vBC:Text)
										EndIf

										//-- Aliquota ICMS
										If XmlChildEx(oXMLAux,'_PICMS') != Nil
											nAliICM60	:= Val(oXMLAux:_PICMS:Text)
										EndIf

										//-- Valor ICMS
										If XmlChildEx(oXMLAux,'_VICMS') != Nil
											nValICM60	:= Val(oXMLAux:_vICMS:Text)
										EndIf
									ElseIf XmlChildEx(oXMLAux, '_ICMS00') != Nil
										oICM := oXMLAux:_ICMS00
									ElseIf XmlChildEx(oXMLAux, '_ICMS10') != Nil
										oICM := oXMLAux:_ICMS10
									ElseIf XmlChildEx(oXMLAux, '_ICMS20') != Nil
										oICM := oXMLAux:_ICMS20
									ElseIf XmlChildEx(oXMLAux, '_ICMS30') != Nil
										oICM := oXMLAux:_ICMS30
									ElseIf XmlChildEx(oXMLAux, '_ICMS40') != Nil
										oICM := oXMLAux:_ICMS30
									ElseIf XmlChildEx(oXMLAux, '_ICMS51') != Nil
										oICM := oXMLAux:_ICMS30
									ElseIf XmlChildEx(oXMLAux, '_ICMS60') != Nil
										oICM := oXMLAux:_ICMS60
									ElseIf XmlChildEx(oXMLAux, '_ICMS70') != Nil
										oICM := oXMLAux:_ICMS70
									ElseIf XmlChildEx(oXMLAux, '_ICMS90') != Nil
										oICM := oXMLAux:_ICMS90
									ElseIf XmlChildEx(oXMLAux, '_ICMSSN') != Nil
										oICM := oXMLAux:_ICMSSN
									EndIf

									If (ValType(oICM) == 'O')
										G_BaseIcn	:=	IIf(XmlChildEx(oICM, '_VBC')  <> Nil, Val(oICM:_vBC:TEXT)  , 0)
										G_AliqIcm	:=	IIf(XmlChildEx(oICM, '_PICMS') <> Nil, Val(oICM:_pICMS:TEXT), 0)
										G_ValIcms	:=	IIf(XmlChildEx(oICM, '_VICMS') <> Nil, Val(oICM:_vICMS:TEXT), 0)
									Else
										G_BaseIcn	:=	0
										G_AliqIcm	:=	0
										G_ValIcms	:=	0
									EndIf
								EndIf
							EndIf

							//--------------------------------------------------------------------
							//-- Verifica notas fiscais existentes
							//--------------------------------------------------------------------
							If XmlChildEx( oXML , '_INFCTENORM') != Nil
								oXMLAux		:= oXML:_InfCteNorm

								If XmlChildEx( oXMLAux , '_INFDOC') != Nil
									oXMLAux		:= oXMLAux:_infDoc

									If XmlChildEx(oXMLAux,'_INFNFE') != Nil
										oXMLAux		:= oXMLAux:_infNfe

										If ValType(oXMLAux) == 'A'
											For k := 1 to Len(oXMLAux)
												If ValType(oXMLAux[k]:_chave) <> "A"
													XmlNode2Arr(oXMLAux[k]:_chave, "_CHAVE")
												EndIf

												//-- Chaves da nota fiscal eletrônica
												For nCount := 1 To Len(oXMLAux[k]:_chave)
													Aadd( aNotas , oXMLAux[k]:_chave[nCount]:Text )
												Next nCount
											Next k
										Else
											If XmlChildEx(oXMLAux , '_CHAVE') != Nil
												aNotas := fObjArray(oXMLAux)
											EndIf
										Endif

									EndIf
								EndIf
							EndIf

						EndIf
					EndIf

				EndIf
			Else
				//Tratamento no erro do parse Xml
				lRet 	:= .F.
				cXMLRet := 'Erro na manipulação do Xml recebido'
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )
				cXMLRet := EncodeUTF8( cXMLRet )
			EndIf

			cNumCte   := StrZero(Val(AllTrim(cNumCte)),TamSx3("F1_DOC")[1])
			cSerieCte := StrZero(Val(AllTrim(cSerieCte)),TamSx3("F1_SERIE")[1])


			//--------------------
			//Log de Processamento
			//--------------------
			aLogXML[Len(aLogXML), 01] += 'Arquivo XML: ' + cArqXML + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Documento: ' + AllTrim(cNumCte) + ' Série: ' + AllTrim(cSerieCte) + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Chave: ' + AllTrim(cChvCTe) + CHR(13) + CHR(10)
			aLogXML[Len(aLogXML), 01] += 'Emissão: ' + DTOC(dDtEmisCTe) + CHR(13) + CHR(10)

			If lRet .And. Len(aNotas) > 0

				SA2->(dbSetOrder(3))
				If SA2->(dbSeek(xFilial("SA2")+cCGCForn))
					cFornCTe  := SA2->A2_COD
					cLojaCTe  := SA2->A2_LOJA
					F_EST     := SA2->A2_EST
					F_CadEnt := '1'
					If SA2->A2_MSBLQL == '1'
						F_CadEnt := '2'
					Else
						F_CadEnt := '1'
					EndIf
					F_TipoEnt := '2'
				Else
					//Cadastrar o Fornecedor
					If Len(aDadosEnt := XMLCADFOR(cCGCForn, oXML, cArqXML, "CTE")) > 0
						cFornCTe := aDadosEnt[01]
						cLojaCTe := aDadosEnt[02]
						F_CadEnt := '2'
					EndIf
				EndIf

				If lRet

					If Empty(cFornCTe) .OR. Empty(cLojaCTe)
						aLogXML[Len(aLogXML), 02] += 'Fornecedor: "' + AllTrim(UPPER(F_Emit)) + '" não encontrado.' + CHR(13) + CHR(10)
						lRet := .F.
					EndIf

					If (lRet)
						DbSelectArea("SZ1")
						DbSetOrder(1) // Z1_FILIAL, Z1_DOC, Z1_SERIE, Z1_FORNECE, Z1_LOJA, Z1_TIPO

						If !DbSeek(xFilial("SZ1") + cNumCTe + cSerieCTe + cFornCTe + cLojaCTe)

							Reclock("SZ1",.T.)
								SZ1->Z1_FILIAL 	:= xFilial("SZ1")
								SZ1->Z1_DOC 	:= PadR(cNumCTE,TamSx3("F1_DOC")[1])
								SZ1->Z1_SERIE	:= PadR(cSerieCTE,TamSx3("F1_SERIE")[1])
								SZ1->Z1_TIPO    := "N"
								SZ1->Z1_FORNECE	:= cFornCTe
								SZ1->Z1_CHVNFE  := cChvCTe
								SZ1->Z1_LOJA	:= cLojaCTe
								SZ1->Z1_ESPECIE	:= "CTE"
								SZ1->Z1_TIPOENT := F_TipoEnt
								SZ1->Z1_EST     := F_EST
								SZ1->Z1_EMISSAO	:= dDtEmisCTe
								SZ1->Z1_CGCEMI  := F_CGCEmi
								SZ1->Z1_VALMERC := nValICM60
								SZ1->Z1_VALIMP1 := nAliICM60
								SZ1->Z1_VALPEDG := nBaseICM60
								SZ1->Z1_VALBRUT := nValCte
								SZ1->Z1_DTDIGIT := F_DtEmi
								SZ1->Z1_CODNFE  := cChvCTe
								SZ1->Z1_EMIT	:= F_Emit
								SZ1->Z1_CGCDES  := F_CGCDes
								SZ1->Z1_DEST	:= F_Dest
								SZ1->Z1_TPXML	:= '3'
								SZ1->Z1_COND	:= cCondPag //Condição XML
								SZ1->Z1_STATUS	:= '2'
								SZ1->Z1_CADPRO	:= '1'
								SZ1->Z1_TIPOENT := F_TipoEnt
								SZ1->Z1_CADENT	:= F_CadEnt
								SZ1->Z1_CGCTRP  := cCGCEmit
								SZ1->Z1_TRANCTE := cEmitCTe
								SZ1->Z1_CGCDTC  := cCGCDest
								SZ1->Z1_DESTCT  := cDestCTe
								SZ1->Z1_CGCREC  := cCGCRem
								SZ1->Z1_REMCTE  := cRemCTe
								SZ1->Z1_CGCEXC  := cCGCExp
								SZ1->Z1_EXPCTE  := cExpCTE
								SZ1->Z1_CGCRCC  := cCGCRec
								SZ1->Z1_RECCTE  := cRecCTe
								SZ1->Z1_CGCTOM  := cCGCTom
								SZ1->Z1_TOMCTE  := cTomCTe
								SZ1->Z1_ARQXML  := cArqXML
							SZ1->(MsUnlock())

							//Gravar os Itens do CTe
							For nItCTe := 1 To Len(aNotas)
								If (RecLock('SZ2', .T.))
									SZ2->Z2_FILIAL  := FWxFilial('SZ2') //TODO idXML
									If IdXML == 'NFS'
										SZ2->Z2_ITEM	:= U_AjuItem(nItCTe)
									Else
										SZ2->Z2_ITEM	:= StrZero(nItCTe, TamSX3('Z2_ITEM')[01])
									EndIf
									SZ2->Z2_DOC		:= cNumCTe
									SZ2->Z2_SERIE	:= cSerieCTe
									SZ2->Z2_FORNECE	:= cFornCTe
									SZ2->Z2_LOJA	:= cLojaCTe
									SZ2->Z2_TIPO	:= "N"
									SZ2->Z2_EMISSAO	:= dDtEmisCTe
									SZ2->Z2_DTDIGIT	:= F_DtEmi
									SZ2->Z2_CHVORIG := aNotas[nItCTe]
									SZ2->Z2_BASEICM	:= G_BaseIcn
									SZ2->Z2_PICM	:= G_AliqIcm
									SZ2->Z2_VALICM	:= G_ValIcms
									SZ2->(MsUnlock())
								EndIf
							Next nItCTe

							nRecSZ1 := SZ1->(Recno())

							//Definindo a DataBase conforme a emissão do CTE
							dBkDtBas := dDataBase
							dDataBase := dDtEmisCTe

							lRet	:= u_GeraDoc(aNotas , cNumCte , cSerieCte , cChvCTe, dDtEmisCTe , cFornCTe, cLojaCTe , nValCte , G_BaseIcn , G_AliqIcm, G_ValIcms , nBaseICM60, nAliICM60 , nValICM60, lJob, cArqXML )

							//Restaurando a DataBase
							dDataBase := dBkDtBas

							DbSelectArea('SZ1')
							SZ1->(DbGoTop())
							SZ1->(DbGoTo(nRecSZ1))
							//Caso nao consiga gerar a Nota CTe, reclassificar
							If !(lRet)
								If (RecLock('SZ1', .F.))
									SZ1->Z1_STATUS := '4' // NF Não Importada
								EndIf
							Else
								If (RecLock('SZ1', .F.))
									SZ1->Z1_STATUS := '1' // NF Importada
								EndIf
							EndIf

						EndIf
					EndIf
				EndIf
			ElseIf (Len(aNotas) == 0)
				aLogXML[Len(aLogXML), 02] += 'Não há Chave de Nota Fiscal de Origem referenciada.' + CHR(13) + CHR(10)
				lRet	:= .F.
			Else
				lRet	:= .F.
			EndIf

		ElseIf IdXML == "CAN"

			lGrava := .T.

			oAuxXML1 	:= XmlChildEx(oXML,"_PROCEVENTONFE")
			IF oAuxXML1 <> NIL

				If !((oRetEvento := XmlChildEx(oAuxXML1,"_RETEVENTO" )) == Nil)
					If !((oInfEvento	:= XmlChildEx(oRetEvento,"_INFEVENTO" )) == Nil)
						F_Stat := IIF(XmlChildEx(oInfEvento ,"_CSTAT") <> Nil, oInfEvento:_CSTAT:TEXT, '')
					EndIf
				EndIf

				oEvento :=  XmlChildEx(oAuxXML1,"_EVENTO" )
				IF oEvento <> NIL

					oInfEvento	:= XmlChildEx(oEvento,"_INFEVENTO" )
					If oInfEvento <> NIl

						oCHNFE	:= XmlChildEx(oInfEvento,"_CHNFE" )
						IF oCHNFE <> Nil
							cChaveNFE := AllTrim(oInfEvento:_CHNFE:TEXT)
						Else
							lContinua	:= .F.
							cTexto		:= "Chave CHFNE nao localizada no arquivo XML. Arquivo Invalido"
						Endif

						IF lContinua
							oCNPJ	:= XmlChildEx(oInfEvento,"_CNPJ" )
							IF oCNPJ <> Nil
								cCGC := AllTrim(oInfEvento:_CNPJ:TEXT)
							Else
								lContinua	:= .F.
							Endif
						Endif
					Endif
				Endif

			EndIf

			// Valida CGC da empresa corrente
			/*
			If AllTrim(SM0->M0_CGC) <> AllTrim(cCGC)
				cTexto		:= "CNPJ do arquivo diferente da empresa corrente"
				lContinua	:= .F.
			Endif
			*/
			// Localiza registro nos livros fiscais
			IF lContinua
				lMsErroAuto	:= .F.

				IF PesqChaveNFE( cChaveNFE )

					dBkDtBas := dDataBase //Backup da DataBase

					dDataBase := SF3->F3_ENTRADA

					//--------------------
					//Log de Processamento
					//--------------------
					aLogXML[Len(aLogXML), 01] += 'Arquivo XML: ' + cArqXML + CHR(13) + CHR(10)
					aLogXML[Len(aLogXML), 01] += 'Documento: ' + AllTrim(SF3->F3_NFISCAL) + ' Série: ' + AllTrim(SF3->F3_SERIE) + CHR(13) + CHR(10)
					aLogXML[Len(aLogXML), 01] += 'Chave: ' + AllTrim(cChaveNFE) + CHR(13) + CHR(10)
					aLogXML[Len(aLogXML), 01] += 'Emissão: ' + DTOC(SF3->F3_ENTRADA) + CHR(13) + CHR(10)

					//Verifica se está cancelada
					If !(Empty(SF3->F3_DTCANC))
						aLogXML[Len(aLogXML), 02] += 'Nota Fiscal Cancelada em: ' + DTOC(SF3->F3_DTCANC) + CHR(13) + CHR(10)
					Else
						// Busca registro na tabela de notas fiscais
						BEGIN TRANSACTION

						IF SF3->F3_CFO >= "500"

							SF2->( dbSetOrder(1) )
							SD2->( dbSetOrder(3) )
							IF SF2->( dbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA) )

								cNumeroNF	:= SF3->F3_NFISCAL
								cSerieNF	:= SF3->F3_SERIE

								SA1->( dbSetOrder(1) )
								SA1->( dbSeek( xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA) )

							 	aCabec := {}
							 	aItens := {}

								AADD(aCabec, {"F2_TIPO"		, SF2->F2_TIPO 				, Nil})
								AADD(aCabec, {"F2_FORMUL"	, SF2->F2_FORMUL		 	, Nil})
								AADD(aCabec, {"F2_DOC"		, PADR(SF2->F2_DOC,TAMSX3('F2_DOC')[1]), Nil})
								AADD(aCabec, {"F2_SERIE"	, SF2->F2_SERIE			, Nil})
								AADD(aCabec, {"F2_EMISSAO"	, SF2->F2_EMISSAO 		, Nil})
								AADD(aCabec, {"F2_CLIENTE"	, SF2->F2_CLIENTE		, Nil})
								AADD(aCabec, {"F2_LOJA"		, SA1->A1_LOJA			, Nil})
								AADD(aCabec, {"F2_ESPECIE"	, SF2->F2_ESPECIE		, Nil})
								AADD(aCabec, {"F2_COND"		, SF2->F2_COND			, Nil})

								AADD(aCabec, {"F2_DESCONT"	, 0, Nil })
								AADD(aCabec, {"F2_FRETE"	, 0, Nil })
								AADD(aCabec, {"F2_SEGURO"	, 0, Nil })
								AADD(aCabec, {"F2_DESPESA"	, 0, Nil })

								If SD2->(MsSeek( cChave := xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ))
									cOrigLan	:= SD2->D2_ORIGLAN
									While SD2->(!Eof()) .And. cChave == SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )
										aLinha := {}
										AADD(aLinha, {"D2_COD"		, SD2->D2_COD			, Nil })
										AADD(aLinha, {"D2_QUANT"	, SD2->D2_QUANT			, Nil })
										AADD(aLinha, {"D2_PRCVEN"	, SD2->D2_PRCVEN		, Nil })
										AADD(aLinha, {"D2_TOTAL"	, SD2->D2_TOTAL 		, Nil })
										AADD(aLinha, {"D2_TES"		, SD2->D2_TES 			, Nil })
										AADD(aItens, aLinha)
										SD2->(dbSkip())
									EndDo
								EndIf
								lMsErroAuto		:= .F.

								IF cOrigLan == "LF"
									// Exclui a nota na base pela rotina automática MATA920
									MSExecAuto({|x,y,Z| MATA920(x,y,Z)},aCabec,aItens,5)
								Else


									lMostraCTB	:= .F.
									lAlgCtb		:= .F.
									lContab		:= .F.
									lCarteira	:= .F.

									aRegSD2 := {}
									aRegSE1 := {}
									aRegSE2 := {}

									If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) .And. MA521VerSC6(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
										lRec := .T.

										DbSelectArea("SZ1")
										SZ1->(DbSetOrder(8)) // Z1_FILIAL + Z1_CHVNFE

										If !DbSeek(xFilial("SZ1") + SF2->(F2_CHVNFE))
											lRec := .T.
										Else
											lRec := .F.
										EndIf

										If (Reclock("SZ1", lRec))
											SZ1->Z1_FILIAL 	:= FWxFilial("SZ1")
											SZ1->Z1_DOC 	:= SF2->F2_DOC
											SZ1->Z1_SERIE	:= SF2->F2_SERIE
											SZ1->Z1_FORNECE	:= SF2->F2_CLIENTE
											SZ1->Z1_LOJA	:= SF2->F2_LOJA
											SZ1->Z1_ESPECIE	:= SF2->F2_ESPECIE
											SZ1->Z1_CHVNFE	:= SF2->F2_CHVNFE
											SZ1->Z1_CODNFE	:= SF2->F2_CHVNFE
											SZ1->Z1_TIPO	:= SF2->F2_TIPO
											SZ1->Z1_EMISSAO	:= SF2->F2_EMISSAO
											SZ1->Z1_EMINFE	:= SF2->F2_EMINFE
											SZ1->Z1_HORNFE	:= SF2->F2_HORNFE
											SZ1->Z1_EMIT	:= IIf(lRec, "EMITENTE CANCELAMENTO", SZ1->Z1_EMIT)
											SZ1->Z1_DEST	:= IIf(lRec, "DESTINATÁRIO CANCELAMENTO", SZ1->Z1_DEST)
											SZ1->Z1_TPXML	:= '5'
											SZ1->Z1_COND	:= cCondPag //Condição XML
											SZ1->Z1_TIPOENT	:= '2'
											SZ1->Z1_CADPRO	:= '1'
											SZ1->Z1_STATUS	:= '1'
											SZ1->Z1_CADENT	:= '1'
											SZ1->Z1_VALMERC	:= SF2->F2_VALMERC
											SZ1->Z1_DESCONT := SF2->F2_DESCONT
											SZ1->Z1_FRETE  	:= SF2->F2_FRETE
											SZ1->Z1_SEGURO	:= SF2->F2_SEGURO
											SZ1->Z1_DESPESA	:= SF2->F2_DESPESA
											SZ1->Z1_VALBRUT	:= SF2->F2_VALBRUT
											SZ1->Z1_ARQXML  := IIf(lRec, cArqXML, SZ1->Z1_ARQXML)
											SZ1->Z1_XMLCANC := cArqXML
											SZ1->Z1_CODRSEF := IIf(lRec, F_Stat, IIf(Empty(F_Stat), SF1->F1_CODRSEF, F_Stat))
											SZ1->(MsUnlock())
										EndIf

										//Pegando os Pedidos de Venda vinculados a Nota Fiscal
										aPedidos := D2Pedido(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)
										SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lMostraCtb,lAlgCtb,lContab,lCarteira))

										//Excluir o Pedido de Venda
										For nF1 := 1 To Len(aPedidos)
											aSC5 := {}
											aSC6 := {}
											//Posicionar no Pedido de Venda
											DbSelectArea('SC5')
											SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
											If (SC5->(DbSeek(FWxFilial('SC5') + aPedidos[nF1])))
												AAdd(aSC5,{"C5_FILIAL" , SC5->C5_FILIAL , Nil})
												AAdd(aSC5,{"C5_NUM"    , SC5->C5_NUM    , Nil})
												AAdd(aSC5,{"C5_TIPO"   , SC5->C5_TIPO   , Nil})
												AAdd(aSC5,{"C5_CLIENTE", SC5->C5_CLIENTE, Nil})
												AAdd(aSC5,{"C5_LOJACLI", SC5->C5_LOJACLI, Nil})
												AAdd(aSC5,{"C5_LOJAENT", SC5->C5_LOJAENT, Nil})
												AAdd(aSC5,{"C5_CONDPAG", SC5->C5_CONDPAG, Nil})
												AAdd(aSC5,{"C5_NATUREZ", SC5->C5_NATUREZ, Nil})
											EndIf
											//Posicionar nos Itens do Pedido de Venda
											DbSelectArea('SC6')
											SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
											If (SC6->(DbSeek(FWxFilial('SC6') + aPedidos[nF1])))
												//Percorrendo Itens
												While (!SC6->(EOF()) .AND. SC6->(C6_FILIAL + C6_NUM) == (FWxFilial('SC6') + aPedidos[nF1]))
													aItem := {}

													AAdd(aItem,{"LINPOS"    , "C6_ITEM"      , SC6->C6_ITEM})
											        AAdd(aItem,{"AUTDELETA" , "N"            , Nil})
											        AAdd(aItem,{"C6_PRODUTO", SC6->C6_PRODUTO, Nil})
											        AAdd(aItem,{"C6_QTDVEN" , SC6->C6_QTDVEN , Nil})
											        AAdd(aItem,{"C6_PRCVEN" , SC6->C6_PRCVEN , Nil})
											        AAdd(aItem,{"C6_PRUNIT" , SC6->C6_PRUNIT , Nil})
											        AAdd(aItem,{"C6_VALOR"  , SC6->C6_VALOR  , Nil})
											        AAdd(aItem,{"C6_TES"    , C6_TES         , Nil})

											        AAdd(aSC6, AClone(aItem))

													//Pulando registro
													SC6->(DbSkip())
												EndDo
												//ExecAuto
												If (Len(aSC5) > 0 .AND. Len(aSC6) > 0)
													lMsErroAuto := .F.

													DbSelectArea("SC9")
													SC9->(dbSetOrder(1))
													If SC9->(dbSeek(FWxFilial("SC9") + aPedidos[nF1]))
														While (!SC9->(EOF())) .and. SC9->C9_PEDIDO == aPedidos[nF1] .and. SC9->C9_FILIAL == FWxFilial("SC9")
															a460Estorna(.T.)
															SC9->(DbSkip())
														EndDo
													EndIf

													If .T.
														lOKExc := .T.
														//Chamando rotina padrão de exclusão
														MSExecAuto({|x,y,z| MATA410(x,y,z)},aSC5, aSC6, 05)
														If (lMsErroAuto)
															lOKExc := .F.
															MostraErro()
														EndIf
													EndIf
												EndIf
											EndIf
										Next nF1
									Else

										lRet	:=  .F.
										Alert("Nota Fiscal de saida nao podera ser excluida")

									Endif

								Endif
							Else
								aLogXML[Len(aLogXML), 02] += 'Nota Fiscal não encontrada.' + CHR(13) + CHR(10)
							Endif

						Else

							SF1->( dbSetOrder(1) )
							SD1->( dbSetOrder(1) )
							IF SF1->( dbSeek(FWxFilial("SF1") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA) )

								cNumeroNF	:= SF3->F3_NFISCAL
								cSerieNF	:= SF3->F3_SERIE
								cOrigLan	:= SF1->F1_ORIGLAN
								SA2->( dbSetOrder(1) )
								SA2->( dbSeek( xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA) )

							 	aCabec := {}
							 	aItens := {}

								AADD(aCabec, {"F1_TIPO"		, SF1->F1_TIPO 				, Nil})
								AADD(aCabec, {"F1_FORMUL"	, SF1->F1_FORMUL		 	, Nil})
								AADD(aCabec, {"F1_DOC"		, PADR(SF1->F1_DOC,TAMSX3('F1_DOC')[1]), Nil})
								AADD(aCabec, {"F1_SERIE"	, SF1->F1_SERIE			, Nil})
								AADD(aCabec, {"F1_EMISSAO"	, SF1->F1_EMISSAO 		, Nil})
								AADD(aCabec, {"F1_FORNECE"	, SF1->F1_FORNECE		, Nil})
								AADD(aCabec, {"F1_LOJA"		, SF1->F1_LOJA			, Nil})
								AADD(aCabec, {"F1_FORNECE"	, SF1->F1_ESPECIE		, Nil})
								AADD(aCabec, {"F1_COND"		, SF1->F1_COND			, Nil})

								lMsErroAuto		:= .F.

								If SD1->(MsSeek( cChave := xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))

									While SD1->(!Eof()) .And. cChave == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)
										aLinha := {}
										AADD(aLinha, {"D1_COD"		, SD1->D1_COD			, Nil })
										AADD(aLinha, {"D1_QUANT"	, SD1->D1_QUANT			, Nil })
										AADD(aLinha, {"D1_PRCVEN"	, SD1->D1_VUNIT			, Nil })
										AADD(aLinha, {"D1_TOTAL"	, SD1->D1_TOTAL 		, Nil })
										AADD(aLinha, {"D1_TES"		, SD1->D1_TES 			, Nil })
										AADD(aItens, aLinha)
										SD1->(dbSkip())
									EndDo
								EndIf

								If cOrigLan <> "LF"
									// Exclui a nota na base pela rotina automática MATA920
									MSExecAuto({|x,y,Z| MATA103(x,y,Z)},aCabec,aItens,5)
								Else
									lRet	:=  .F.
									cTexto	:= "Nota Fiscal de entrada não poderá ser excluída. Nota Fiscal teve entrada a partir do módulo Livro Fiscal."
									MemoWrite( cDirErro + cArquiLog, cTexto )
								EndIf
							Else
								aLogXML[Len(aLogXML), 02] += 'Nota Fiscal não encontrada.' + CHR(13) + CHR(10)
							Endif

						Endif


			   			If lMsErroAuto
			   			 	DisarmTransaction()
		                    MostraErro()
		            		lRet	:= .F.
						Else
							If (cOrigLan <> 'LF')
								lRec := .T.

								DbSelectArea("SZ1")
								SZ1->(DbSetOrder(8)) // Z1_FILIAL + Z1_CHVNFE

								If !DbSeek(xFilial("SZ1") + SF1->(F1_CHVNFE))
									lRec := .T.
								Else
									lRec := .F.
								EndIf

								If (Reclock("SZ1", lRec))
									SZ1->Z1_FILIAL 	:= FWxFilial("SZ1")
									SZ1->Z1_DOC 	:= SF1->F1_DOC
									SZ1->Z1_SERIE	:= SF1->F1_SERIE
									SZ1->Z1_FORNECE	:= SF1->F1_FORNECE
									SZ1->Z1_LOJA	:= SF1->F1_LOJA
									SZ1->Z1_ESPECIE	:= SF1->F1_ESPECIE
									SZ1->Z1_CHVNFE	:= SF1->F1_CHVNFE
									SZ1->Z1_CODNFE	:= SF1->F1_CHVNFE
									SZ1->Z1_TIPO	:= SF1->F1_TIPO
									SZ1->Z1_EMISSAO	:= SF1->F1_EMISSAO
									SZ1->Z1_EMINFE	:= SF1->F1_EMINFE
									SZ1->Z1_HORNFE	:= SF1->F1_HORNFE
									SZ1->Z1_EMIT	:= IIf(lRec, "EMITENTE CANCELAMENTO", SZ1->Z1_EMIT)
									SZ1->Z1_DEST	:= IIf(lRec, "DESTINATÁRIO CANCELAMENTO", SZ1->Z1_DEST)
									SZ1->Z1_TPXML	:= '5'
									SZ1->Z1_COND	:= cCondPag //Condição XML
									SZ1->Z1_TIPOENT	:= '2'
									SZ1->Z1_CADPRO	:= '1'
									SZ1->Z1_STATUS	:= '1'
									SZ1->Z1_CADENT	:= '1'
									SZ1->Z1_VALMERC	:= SF1->F1_VALMERC
									SZ1->Z1_DESCONT := SF1->F1_DESCONT
									SZ1->Z1_FRETE  	:= SF1->F1_FRETE
									SZ1->Z1_SEGURO	:= SF1->F1_SEGURO
									SZ1->Z1_DESPESA	:= SF1->F1_DESPESA
									SZ1->Z1_VALBRUT	:= SF1->F1_VALBRUT
									SZ1->Z1_ARQXML  := IIf(lRec, cArqXML, SZ1->Z1_ARQXML)
									SZ1->Z1_XMLCANC := cArqXML
									SZ1->(MsUnlock())
								EndIf
							Endif
						/*
		                    If lRet
			                    IF Copia2Lidos( cDirLer + cArquivo , cDirLidos + cArquivo )
									// Deleta arquivo original
									DeletaLido( cDirLer + cArquivo )
								Endif
							Else
			                    IF Copia2Lidos( cDirLer + cArquivo , cDirErro + cArquivo )
									// Deleta arquivo original
									DeletaLido( cDirLer + cArquivo )
								Endif
							Endif
						*/
						Endif

						END TRANSACTION
					EndIf

					dDataBase := dBkDtBas //Voltando DataBase

				Else
						//--------------------
						//Log de Processamento
						//--------------------
						aLogXML[Len(aLogXML), 01] += 'Arquivo XML: ' + cArqXML + CHR(13) + CHR(10)
						aLogXML[Len(aLogXML), 01] += 'Chave: ' + AllTrim(cChaveNFE) + CHR(13) + CHR(10)
						aLogXML[Len(aLogXML), 02] += 'Não encontrada Nota Fiscal para a chave.' + CHR(13) + CHR(10)
				Endif

			Else
				/*
	           	IF Copia2Lidos( cDirLer + cArquivo , cDirErro + cArquivo )
					// Deleta arquivo original
					DeletaLido( cDirLer + cArquivo )
	               	// Exibe Informação
	               	MemoWrite( cDirErro + cArquiLog, cTexto )
					lRet	:= .F.
				Endif
				*/
				lRet	:= .F.
			Endif

		ElseIf IdXML == "INU"

			lGrava := .T.

			oXmlOk:= oXML
			If XmlChildEx(oXmlOk ,"_PROCINUTNFE") <> Nil
				oXmlOk := oXmlOk:_PROCINUTNFE
			EndIf

			If XmlChildEx(oXmlOk ,"_RETINUTNFE") <> Nil
				cEmit	:= oXmlOk:_RETINUTNFE:_INFINUT:_CNPJ:TEXT
				cDest	:= oXmlOk:_RETINUTNFE:_INFINUT:_CNPJ:TEXT
				cNumDoc	:= oXmlOk:_RETINUTNFE:_INFINUT:_NNFINI:TEXT
				cSerDoc	:= oXmlOk:_RETINUTNFE:_INFINUT:_SERIE:TEXT
				dDtEmi  := StoD(StrTran(Left(oXmlOk:_RETINUTNFE:_INFINUT:_DHRECBTO:TEXT,10),"-",""))
				nDocIni	:= Val(oXmlOk:_RETINUTNFE:_INFINUT:_NNFINI:TEXT)
				nDocFim	:= Val(oXmlOk:_RETINUTNFE:_INFINUT:_NNFFIN:TEXT)
			Else
				cEmit	:= oXmlOk:_INUTNFE:_INFINUT:_CNPJ:TEXT
				cDest	:= oXmlOk:_INUTNFE:_INFINUT:_CNPJ:TEXT
				cNumDoc	:= oXmlOk:_INUTNFE:_INFINUT:_NNFINI:TEXT
				cSerDoc	:= oXmlOk:_INUTNFE:_INFINUT:_SERIE:TEXT
				//dDtEmi  := StoD(StrTran(Left(oXmlOk:_INUTNFE:_INFINUT:_DHRECBTO:TEXT,10),"-",""))
				dDtEmi  := IIf(XmlChildEx(oXmlOk:_INUTNFE:_INFINUT, '_DHRECBTO')  <> Nil, StoD(StrTran(Left(oXmlOk:_INUTNFE:_INFINUT:_DHRECBTO:TEXT,10),"-","")), dDataBase)
				nDocIni	:= Val(oXmlOk:_INUTNFE:_INFINUT:_NNFINI:TEXT)
				nDocFim	:= Val(oXmlOk:_INUTNFE:_INFINUT:_NNFFIN:TEXT)
			EndIf

			cNumDoc:= StrZero(Val(AllTrim(cNumDoc)),TamSx3("F1_DOC")[1])
			cSerDoc:= StrZero(Val(AllTrim(cSerDoc)),TamSx3("F1_SERIE")[1])

			DbSelectArea("SZ1")
			SZ1->(DbSetOrder(1)) // Z1_FILIAL, Z1_DOC, Z1_SERIE, Z1_FORNECE, Z1_LOJA, Z1_TIPO

			For n := nDocIni	to nDocFim
				If !SZ1->(DbSeek(FWxFilial("SZ1") + cNumDoc + cSerDoc + cCliInut + cLojInut + "N"))
					Reclock("SZ1",.T.)
					SZ1->Z1_FILIAL 	:= FWxFilial("SZ1")
					SZ1->Z1_DOC 	:= cNumDoc
					SZ1->Z1_SERIE	:= cSerDoc
					SZ1->Z1_FORNECE	:= cCliInut
					SZ1->Z1_LOJA	:= cLojInut
					SZ1->Z1_ESPECIE	:= 'SPED'
					SZ1->Z1_TIPO	:= 'N'
					SZ1->Z1_EMISSAO	:= dDtEmi
					SZ1->Z1_EMINFE	:= dDataBase
					SZ1->Z1_HORNFE	:= Time()
					SZ1->Z1_CGCEMI	:= cEmit
					SZ1->Z1_EMIT    := 'EMITENTE INUTILIZACAO'
					SZ1->Z1_CGCDES	:= cDest
					SZ1->Z1_DEST    := 'DESTINATARIO INUTILIZACAO'
					SZ1->Z1_TPXML	:= '6'
					SZ1->Z1_COND	:= cCondPag //Condição XML
					SZ1->Z1_TIPOENT	:= '2'
					SZ1->Z1_STATUS	:= '2'
					SZ1->Z1_CADENT	:= '1'
					SZ1->Z1_CADPRO	:= '1'
					SZ1->Z1_VALMERC	:= 0.01
					SZ1->Z1_VALBRUT	:= 0.01
					SZ1->Z1_ARQXML  := cArqXML
					SZ1->(MsUnlock())

					Reclock("SZ2",.T.)
					SZ2->Z2_FILIAL  := FWxFilial('SZ2')
					SZ2->Z2_ITEM	:= PadL('1',TamSX3("C6_ITEM")[1],"0")
					SZ2->Z2_COD		:= cProInut
					SZ2->Z2_QUANT	:= 1
					SZ2->Z2_VUNIT	:= 0.01
					SZ2->Z2_TOTAL	:= 0.01
					SZ2->Z2_DOC		:= cNumDoc
					SZ2->Z2_SERIE	:= cSerDoc
					SZ2->Z2_FORNECE	:= cCliInut
					SZ2->Z2_LOJA	:= '01'
					SZ2->Z2_TIPO	:= 'N'
					SZ2->Z2_EMISSAO	:= dDtEmi
					SZ2->Z2_DTDIGIT	:= dDataBase
					SZ2->Z2_TES 	:= cTesInut
					SZ2->(MsUnlock())

					lContinua := U_TIBNFSXML()

					If lContinua
						lContinua:= U_TIBCANXML()
					Else
						// Não foi possivel concluir a inutilização
						Reclock("SZ1",.F.)
						SZ1->Z1_STATUS := '4'
						SZ1->(MsUnlock())
					EndIf

					If lContinua
						If (Reclock("SZ1",.F.))
							SZ1->Z1_STATUS := '1'
							SZ1->(MsUnlock())
						EndIf
						//Atualizar o Livro Fiscal com o Código
						DbSelectArea("SF3")
						SF3->(DbSetOrder(5)) // F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT
						If SF3->(DbSeek(xFilial("SF3")+ SZ1->Z1_SERIE + SZ1->Z1_DOC + SZ1->Z1_FORNECE + SZ1->Z1_LOJA))
							If (RecLock("SF3", .F.))
								SF3->F3_CODRSEF := '102'
								SF3->F3_OBSERV  := 'NF INUTILIZADA'
								SF3->(MsUnlock())
							EndIf
						EndIf
						//MsgInfo("Inutilização feita com Sucesso!!!")
					Else
						Reclock("SZ1",.F.)
						SZ1->Z1_STATUS := '4'
						SZ1->(MsUnlock())
					EndIf
				EndIf
				cNumDoc := Soma1(cNumDoc)
			Next
		Else
		// NÃO EXISTENTE
		// AGUARDANDO DECISÃO DE TRATAMENTO
		EndIf
	EndIf

	If (lRet .AND. lGrava)
		//Forçar a abertura de um arquivo qualquer
		oFullXML := XmlParserFile("C:\TOTVS\TESTE.XML","_",@cError,@cWarning)
		//Copiar para a Pasta \IMPORTADOS
		nPosArq := RAt("\NAO_PROC", Upper(cDirArq))
		If (nPosArq > 0)
			cNewArq := SubStr(cDirArq, 1, nPosArq - 1) + '\IMPORTADOS\' + aFiles[i, 01]
			If (__CopyFile(cArqXML, cNewArq))
				nHdl := FErase(cArqXML)
				If (nHdl == -1)
					 MsgAlert('Erro na eliminação do arquivo nº ' + STR(FERROR()))
				Else
					//Apagar arquivo de LOCK
					nHdl := FErase(aFiles[i, 02])
					If (nHdl == -1)
						MsgAlert('Erro na eliminação do arquivo de LOCK nº ' + STR(FERROR()))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Next i

//Mostrando Log de Processamento
cLogXML := ''
//Montando Informativos
cLogInf := ''
For nLog := 1 To Len(aLogXML)
	If !(Empty(aLogXML[nLog, 02]))
		cLogXML += aLogXML[nLog, 01] + CHR(13) + CHR(10)
		cLogXML += aLogXML[nLog, 02] + CHR(13) + CHR(10)
		cLogXML += Replicate('_', 15) + CHR(13) + CHR(10)
	EndIf
	If !(Empty(aLogXML[nLog, 03]))
		cLogInf += aLogXML[nLog, 01] + CHR(13) + CHR(10)
		cLogInf += aLogXML[nLog, 03] + CHR(13) + CHR(10)
		cLogInf += Replicate('_', 15) + CHR(13) + CHR(10)
	EndIf
Next nLog
If !(Empty(cLogXML))
	nOpcAv := Aviso('Importação de XML', 'Notas Fiscais não importadas: ' + CHR(13) + CHR(10) + cLogXML, {'OK', 'Salvar'}, 03)
	If (nOpcAv == 2) //Gerando Arquivo Texto
		cArqAux := cGetFile( '*.*' , 'Selecione o Diretório', 1, , .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
		cArqAux := ALLTRIM( cArqAux )
		If !(Empty(cArqAux))
			If !(Right(cArqAux, 01) == '\')
				cArqAux += '\'
			EndIf
			cNomeArq := 'Log_Importacao_XML_' + STrTran(DTOC(dDataBase), '/', '-') + '_' + StrTran(Time(), ':', '-') + '.TXT'
			cArqAux += cNomeArq
			MemoWrite(cArqAux, cLogXML)
			MemoWrite(cDirArq + cNomeArq, cLogXML)
		EndIf
	EndIf
EndIf
If !(Empty(cLogInf))
	nOpcAv := Aviso('Importação de XML', 'Informativos: ' + CHR(13) + CHR(10) + cLogInf, {'OK', 'Salvar'}, 03)
	If (nOpcAv == 2) //Gerando Arquivo Texto
		cArqAux := cGetFile( '*.*' , 'Selecione o Diretório', 1, , .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
		cArqAux := ALLTRIM( cArqAux )
		If !(Empty(cArqAux))
			If !(Right(cArqAux, 01) == '\')
				cArqAux += '\'
			EndIf
			cNomeArq := 'Log_Importacao_XML_' + STrTran(DTOC(dDataBase), '/', '-') + '_' + StrTran(Time(), ':', '-') + '.TXT'
			cArqAux += cNomeArq
			MemoWrite(cArqAux, cLogInf)
			MemoWrite(cDirArq + cNomeArq, cLogInf)
		EndIf
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} XMLCADFOR

@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------

Static Function XMLCADFOR(cCGC,oXML,cFile,cTipoNF)

Local aAreaAnt := GetArea()
Local aAreaSA2 := SA2->( GetArea() )
Local cNome    := ''
Local cNReduz  := ''
Local cEndere  := ''
Local cNroEnd  := ''
Local cBairro  := ''
Local cUF      := ''
Local cCep     := ''
Local cCodMun  := ''
Local cCodPais := ''
Local cFone    := ''
Local cDDD     := '' //DDD
Local cInscr   := ''
Local cInscrM  := ''
Local lRet     := .T.
Local lCadFor  := .T.
Local cCodFor  := "0" + SubStr(cCGC,1,8)
Local cLojFor  := SubStr(cCGC,9,4)
Local cContrib := "" //Contribuinte
Local cComple  := "" //Complemento
Local aRet	   := {}
Local cNatPad  := AllTrim(SuperGetMV('TI_XMLNATS',.F.,'101001'))
Local cCCtbPad := AllTrim(SuperGetMV('ES_XMLCCTF',.F.,'2101010001'))  //Conta Contábil Padrão Fornecedor

Private oInfEmit    := Nil
Private lMsErroAuto := .F.

If Len(AllTrim(cCGC)) < 14
	cCodFor  := SubStr(cCGC,1,9)
	cLojFor  := "0000"
EndIf

SA2->(dbSetOrder(3)) //-- A2_FILIAL + A2_CGC
If !SA2->(dbSeek(xFilial('SA2') + cCGC))

	If lCadFor

		If (cTipoNF == "B") .OR. (cTipoNF == "D")
			oInfEmit    := oXML:_INFNFE:_DEST
		ElseIf !(cTipoNF == 'CTE')
			oInfEmit :=  oXML:_INFNFE:_EMIT
		EndIf

		If (cTipoNF == "B") .OR. (cTipoNF == "D")
			cRazao   := IF(Type("oInfEmit:_XNOME:Text")=='C',oInfEmit:_XNOME:Text,'')
			cNReduz  := IF(Type("oInfEmit:_XFANT:Text")=='C',oInfEmit:_XFANT:Text,'')
			If Empty(cNReduz)
				cNReduz := cRazao
			EndIf

			cEndere  := IF(Type("oInfEmit:_ENDERDEST:_xLgr:Text" )=='C'		,oInfEmit:_ENDERDEST:_xLgr:Text,''				)
			cNroEnd  := IF(Type("oInfEmit:_ENDERDEST:_Nro:Text" )=='C'		,oInfEmit:_ENDERDEST:_Nro:Text,''				)
			cBairro  := IF(Type("oInfEmit:_ENDERDEST:_xBairro:Text" )=='C'	,oInfEmit:_ENDERDEST:_xBairro:Text,''			)
			cUF      := IF(Type("oInfEmit:_ENDERDEST:_UF:Text" )=='C'		,oInfEmit:_ENDERDEST:_UF:Text,''				)
			cCep     := IF(Type("oInfEmit:_ENDERDEST:_CEP:Text" )=='C'		,oInfEmit:_ENDERDEST:_CEP:Text,''				)
			cCodMun  := IF(Type("oInfEmit:_ENDERDEST:_cMun:Text")=='C'		,Substr(oInfEmit:_ENDERDEST:_cMun:Text,3,5),''	)
			cCodPais := IF(Type("oInfEmit:_ENDERDEST:_cPais:Text")=='C'		,'0' + oInfEmit:_ENDERDEST:_cPais:Text,''		)
			cFone    := AllTrim(IF(Type("oInfEmit:_ENDERDEST:_Fone:Text")=='C'		,oInfEmit:_ENDERDEST:_Fone:Text,''				))
			cDDD     := IIf(Len(cFone) > 8, Left(cFone, 02), '') //DDD
			cFone    := IIf(Len(cFone) > 8, SubStr(cFone, 03), cFone) //Fone
			cInscr   := IF(Type("oInfEmit:_IE:Text")=='C'					,oInfEmit:_IE:Text,''    						)
			cInscrM  := IF(Type("oInfEmit:_IM:Text")=='C'					,oInfEmit:_IM:Text,''							)
			cContrib := IF(Type("oInfEmit:_indIEDest:Text")=='C'			,oInfEmit:_indIEDest:Text,'' )
			cComple  := IF(Type("oInfEmit:_ENDERDEST:_xCpl:Text")=='C'		,oInfEmit:_ENDERDEST:_xCpl:Text,''				)
		ElseIf cTipoNF == 'CTE'
			oInfEmit    := oXML:_EMIT
			cRazao   := IF(Type("oInfEmit:_XNOME:Text")=='C',oInfEmit:_XNOME:Text,'')
			cNReduz  := IF(Type("oInfEmit:_XFANT:Text")=='C',oInfEmit:_XFANT:Text,'')
			If Empty(cNReduz)
				cNReduz := cRazao
			EndIf

			cEndere  := IF(Type("oInfEmit:_ENDEREMIT:_xLgr:Text" )=='C'		,oInfEmit:_ENDEREMIT:_xLgr:Text,''				)
			cNroEnd  := IF(Type("oInfEmit:_ENDEREMIT:_Nro:Text" )=='C'		,oInfEmit:_ENDEREMIT:_Nro:Text,''				)
			cBairro  := IF(Type("oInfEmit:_ENDEREMIT:_xBairro:Text" )=='C'	,oInfEmit:_ENDEREMIT:_xBairro:Text,''			)
			cUF      := IF(Type("oInfEmit:_ENDEREMIT:_UF:Text" )=='C'		,oInfEmit:_ENDEREMIT:_UF:Text,''				)
			cCep     := IF(Type("oInfEmit:_ENDEREMIT:_CEP:Text" )=='C'		,oInfEmit:_ENDEREMIT:_CEP:Text,''				)
			cCodMun  := IF(Type("oInfEmit:_ENDEREMIT:_cMun:Text")=='C'		,Substr(oInfEmit:_ENDEREMIT:_cMun:Text,3,5),''	)
			cCodPais := IF(Type("oInfEmit:_ENDEREMIT:_cPais:Text")=='C'		,'0' + oInfEmit:_ENDEREMIT:_cPais:Text,''		)
			cFone    := AllTrim(IF(Type("oInfEmit:_ENDEREMIT:_Fone:Text")=='C'		,oInfEmit:_ENDEREMIT:_Fone:Text,''				))
			cDDD     := IIf(Len(cFone) > 8, Left(cFone, 02), '') //DDD
			cFone    := IIf(Len(cFone) > 8, SubStr(cFone, 03), cFone) //Fone
			cInscr   := IF(Type("oInfEmit:_IE:Text")=='C'					,oInfEmit:_IE:Text,''    						)
			cInscrM  := IF(Type("oInfEmit:_IM:Text")=='C'					,oInfEmit:_IM:Text,''							)
			cContrib := IF(Type("oInfEmit:_indIEDest:Text")=='C'			,oInfEmit:_indIEDest:Text,'' )
			cComple  := IF(Type("oInfEmit:_ENDEREMIT:_xCpl:Text")=='C'		,oInfEmit:_ENDEREMIT:_xCpl:Text,''				)
		Else
			cRazao   := IF(Type("oInfEmit:_XNOME:Text")=='C',oInfEmit:_XNOME:Text,'')
			cNReduz  := IF(Type("oInfEmit:_XFANT:Text")=='C',oInfEmit:_XFANT:Text,'')
			If Empty(cNReduz)
				cNReduz := cRazao
			EndIf

			cEndere  := IF(Type("oInfEmit:_ENDEREMIT:_xLgr:Text" )=='C'		,oInfEmit:_ENDEREMIT:_xLgr:Text,''				)
			cNroEnd  := IF(Type("oInfEmit:_ENDEREMIT:_Nro:Text" )=='C'		,oInfEmit:_ENDEREMIT:_Nro:Text,''				)
			cBairro  := IF(Type("oInfEmit:_ENDEREMIT:_xBairro:Text" )=='C'	,oInfEmit:_ENDEREMIT:_xBairro:Text,''			)
			cUF      := IF(Type("oInfEmit:_ENDEREMIT:_UF:Text" )=='C'		,oInfEmit:_ENDEREMIT:_UF:Text,''				)
			cCep     := IF(Type("oInfEmit:_ENDEREMIT:_CEP:Text" )=='C'		,oInfEmit:_ENDEREMIT:_CEP:Text,''				)
			cCodMun  := IF(Type("oInfEmit:_ENDEREMIT:_cMun:Text")=='C'		,Substr(oInfEmit:_ENDEREMIT:_cMun:Text,3,5),''	)
			cCodPais := IF(Type("oInfEmit:_ENDEREMIT:_cPais:Text")=='C'		,'0' + oInfEmit:_ENDEREMIT:_cPais:Text,''		)
			cFone    := AllTrim(IF(Type("oInfEmit:_ENDEREMIT:_Fone:Text")=='C'		,oInfEmit:_ENDEREMIT:_Fone:Text,''				))
			cDDD     := IIf(Len(cFone) > 8, Left(cFone, 02), '') //DDD
			cFone    := IIf(Len(cFone) > 8, SubStr(cFone, 03), cFone) //Fone
			cInscr   := IF(Type("oInfEmit:_IE:Text")=='C'					,oInfEmit:_IE:Text,''    						)
			cInscrM  := IF(Type("oInfEmit:_IM:Text")=='C'					,oInfEmit:_IM:Text,''							)
			cContrib := IF(Type("oInfEmit:_indIEDest:Text")=='C'			,oInfEmit:_indIEDest:Text,'' )
			cComple  := IF(Type("oInfEmit:_ENDEREMIT:_xCpl:Text")=='C'		,oInfEmit:_ENDEREMIT:_xCpl:Text,''				)
		EndIf

		cCodPais := "01058"

		Do Case
			Case cContrib == '1' //SIM
				cInscr := u_fNoAcento(cInscr)
			Case cContrib == '2' //NÃO
				cInscr := u_fNoAcento(cInscr)
			Case cContrib == '9' //NÃO, COM VALIDAÇÃO DE INSCRIÇÃO
				cInscr := u_fNoAcento(IIf(Empty(cInscr), 'ISENTO', cInscr))
				cContrib := '2'
			OtherWise
				cInscr := u_fNoAcento(cInscr)
		EndCase

		aFornecedor := {}

		AAdd(aFornecedor, {"A2_COD"       	,cCodFor                               	,Nil})
		AAdd(aFornecedor, {"A2_LOJA"       	,cLojFor                               	,Nil})
		AAdd(aFornecedor, {"A2_NOME"       	,Left(u_fNoAcento(cRazao), TamSX3("A2_NOME")[01])	,Nil})
		AAdd(aFornecedor, {"A2_NREDUZ"     	,Left(u_fNoAcento(cNReduz), TamSX3("A2_NREDUZ")[01]), Nil})
		AAdd(aFornecedor, {"A2_CGC"        	,u_fNoAcento(cCGC)                       	,Nil})
		AAdd(aFornecedor, {"A2_TIPO"       	,If(Len(AllTrim(u_fNoAcento(cCGC)))< 14,'F','J')   	,Nil})
		AAdd(aFornecedor, {"A2_END"        	,u_fNoAcento(cEndere + ', ' + cNroEnd)   	,Nil})
		AAdd(aFornecedor, {"A2_BAIRRO"     	,cBairro                               	,Nil})
		AAdd(aFornecedor, {"A2_EST"        	,cUF                                   	,Nil})
		AAdd(aFornecedor, {"A2_CEP"        	,cCep                                  	,Nil})
		AAdd(aFornecedor, {"A2_COD_MUN"    	,cCodMun                               	,Nil})
		AAdd(aFornecedor, {"A2_PAIS"    		,SubStr(cCodPais,2,3)      				,Nil})
		AAdd(aFornecedor, {"A2_CODPAIS"    	,cCodPais                  				,Nil})
		AAdd(aFornecedor, {"A2_DDD"        	,IIf(!Empty(cDDD), StrZero(Val(cDDD), TamSX3('A2_DDD')[01]), cDDD), Nil})
		AAdd(aFornecedor, {"A2_TEL"        	,cFone                                 	,Nil})
		//AAdd(aFornecedor, {"A2_COND"       	,GetMV('ES_CONPGNF',.F.,'')       		,Nil})
		AAdd(aFornecedor, {"A2_INSCR"      	,cInscr                                	,Nil})
		AAdd(aFornecedor, {"A2_XIMPXML"      	,'1'                                	,Nil})
		AAdd(aFornecedor, {"A2_INSCRM"     	,cInscrM                               	,Nil})
		AAdd(aFornecedor, {"A2_MSBLQL"     	,'1'	                               	,Nil})
		AAdd(aFornecedor, {"A2_COMPLEM"     	,cComple                               	,Nil})
		If !(Empty(cContrib))
			AAdd(aFornecedor, {"A2_CONTRIB"     	,cContrib                              	,Nil})
		EndIf
		//AAdd(aFornecedor, {"A2_NATUREZ"     	,cNatPad                              	,Nil})
		//AAdd(aFornecedor, {"A2_CONTA"     	,cCCtbPad                              	,Nil})

		lMsErroAuto := .F.

		MSExecAuto({|x,y| MATA020(x,y)},aFornecedor,3)

		If lMsErroAuto
			MostraErro()
			lRet := .F.
		EndIf
	Else
		Aviso("Erro",If(cTipoNF=='N',"Fonecedor ","Cliente ") + oXML:_INFNFE:_EMIT:_XNOME:Text +" [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.",{"OK"},2,"ReadXML")
		lRet := .F.
	EndIf
EndIf

RestArea( aAreaSA2 )
RestArea( aAreaAnt )

If lRet
	aRet := {cCodFor, cLojFor}
Endif

Return aRet


Static Function XMLCADCLI(cCGC,oXML,cFile,cTipoNF,IdXML)

Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local cNome    := ''
Local cNReduz  := ''
Local cEndere  := ''
Local cNroEnd  := ''
Local cBairro  := ''
Local cUF      := ''
Local cCep     := ''
Local cCodMun  := ''
Local cCodPais := ''
Local cFone    := ''
Local cDDD     := '' //DDD
Local cInscr   := ''
Local cInscrM  := ''
Local lCadCli  := .T.
Local aCliente := {}
Local cCodCli  := "0" + SubStr(cCGC,1,8)
Local cLojCli  := SubStr(cCGC,9,4)
Local oInfDEST := Nil
Local lRet     := .T.
Local aRet	   := {}
Local cContrib := "" //Contribuinte
Local cComple  := "" //Complemento
Local cSuframa := "" //Suframa
Local cNatPad  := AllTrim(SuperGetMV('TI_XMLNATS',.F.,'101001'))
Local cCCtbPad := AllTrim(SuperGetMV('ES_XMLCCTC',.F.,'1102110001')) //Conta Contábil Padrão Cliente
Local lTIBXMLCLI := ExistBlock("TIBXMLCLI") //Verifica se o Ponto de Entrada "TIBXMLCLI" existe
Local aRetXMLCli := {} //Array de Retorno do Ponto de Entrada

DEFAULT oXml   := Nil

Private lMsErroAuto := .F.

//Se o Ponto de Entrada existe, executar
If (lTIBXMLCLI)
	/**
		Informações enviadas ao Ponto de Entrada
		[01] - cCGC (caracter)    --> CNPJ do Cliente
		[02] - oXML (caracter)    --> Objeto XML
		[03] - cFile (caracter)   --> Arquivo XML
		[04] - cTipoNF (caracter) --> Tipo de Nota Fiscal
		[05] - IdXML (caracter)   --> Tipo de Arquivo XML
		Retorno esperado pelo Ponto de Entrada
		[01] - lOK (lógico)       --> Processo dará continuidade ?
		[02] - cMens (caracter)   --> Mensagem de Log
	**/
	aRetXMLCli := ExecBlock("TIBXMLCLI", .F., .F., {cCGC,oXML,cFile,cTipoNF,IdXML})
	If (ValType(aRetXMLCli) == "A")
		If Len(aRetXMLCli) > 0
			//Recuperando retorno
			lRet := aRetXMLCli[01]
		Else
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf
EndIf

//Verifica se pode continuar o processo
If lRet
	If Len(AllTrim(cCGC)) < 14
		cCodCli  := SubStr(cCGC,1,9)
		cLojCli  := "0000"
	EndIf

	If IdXML == "NFE"
		IF ValType(oXML) == "O"
			oInfDEST := oXML:_INFNFE:_DEST
		EndIf
	Else
		IF ValType(oXML) == "O"
			oInfDEST := oXML:_INFNFE:_DEST
		EndIf
	EndIf

	SA1->(dbSetOrder(3)) //-- A1_FILIAL + A1_CGC
	If oInfDEST <> Nil .AND. !SA1->(dbSeek(FWxFilial('SA1') + cCGC))
		If lCadCli
			If __lSX8
				ConfirmSX8()
			EndIf
			cRazao   := IF(XmlChildEx( oInfDEST, "_XNOME" ) <> Nil,oInfDEST:_XNOME:Text                                  ,'')
			// Caso o XML venha sem o campo com o nome fantasia, faz o cadastro utilizando a razão social
			cNReduz  := IF(XmlChildEx( oInfDEST, "_XFANT" ) <> Nil,oInfDEST:_XFANT:Text                                  ,cRazao)
			cInscr   := IF(XmlChildEx( oInfDEST, "_IE"    ) <> Nil,oInfDEST:_IE:Text                                     ,'ISENTO')
			cContrib := IF(XmlChildEx( oInfDEST, "_INDIEDEST") <> Nil,oInfDEST:_INDIEDEST:Text                           ,'')
			cInscrM  := IF(XmlChildEx( oInfDEST, "_IM"    ) <> Nil,oInfDEST:_IM:Text                                     ,'')
			cEndere  := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_XLGR"   ) <> Nil,oInfDEST:_ENDERDEST:_xLgr:Text            ,'')
			cNroEnd  := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_NRO"    ) <> Nil,oInfDEST:_ENDERDEST:_Nro:Text             ,'')
			cBairro  := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_XBAIRRO") <> Nil,oInfDEST:_ENDERDEST:_xBairro:Text         ,'')
			cUF      := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_UF"     ) <> Nil,oInfDEST:_ENDERDEST:_UF:Text              ,'')
			cCep     := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_CEP"    ) <> Nil,oInfDEST:_ENDERDEST:_CEP:Text             ,'')
			cCodMun  := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_CMUN"   ) <> Nil,Substr(oInfDEST:_ENDERDEST:_cMun:Text,3,5),'')
			cCodPais := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_CPAIS"  ) <> Nil,'0' + oInfDEST:_ENDERDEST:_cPais:Text     ,'')
			cFone    := AllTrim(IF(XmlChildEx( oInfDEST:_ENDERDEST, "_FONE"   ) <> Nil,oInfDEST:_ENDERDEST:_Fone:Text            ,''))
			cDDD     := IIf(Len(cFone) > 8, Left(cFone, 02), '') //DDD
			cFone    := IIf(Len(cFone) > 8, SubStr(cFone, 03), cFone) //Fone
			cComple  := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_XCPL"   ) <> Nil,oInfDEST:_ENDERDEST:_xCpl:Text            ,'')
			cSuframa := IF(XmlChildEx( oInfDEST:_ENDERDEST, "_ISUF"   ) <> Nil,oInfDEST:_ENDERDEST:_ISUF:Text            ,'')


			cCodPais := "01058"

			Do Case
				Case cContrib == '1' //SIM
					cInscr := u_fNoAcento(cInscr)
				Case cContrib == '2' //NÃO
					cInscr := 'ISENTO'
				Case cContrib == '9' //NÃO, COM VALIDAÇÃO DE INSCRIÇÃO
					cInscr := u_fNoAcento(IIf(Empty(cInscr), 'ISENTO', cInscr))
					cContrib := '2'
			EndCase

			cTipoCli := AllTrim(SuperGetMV("ES_TIPOCLI", .F., ""))

			If (cContrib == '2')
				cTipoCli := 'F'
			EndIf

			aCliente := {}

			AAdd(aCliente, {"A1_COD"       	,cCodCli                               	,Nil})
			AAdd(aCliente, {"A1_LOJA"       	,cLojCli                               	,Nil})
			AAdd(aCliente, {"A1_NOME"       	,Left(u_fNoAcento(cRazao), TamSX3("A1_NOME")[01]),Nil})
			AAdd(aCliente, {"A1_NREDUZ"     	,Left(u_fNoAcento(cNReduz), TamSX3("A1_NREDUZ")[01]), Nil})
			AAdd(aCliente, {"A1_CGC"        	,u_fNoAcento(cCGC)                       	,Nil})
			AAdd(aCliente, {"A1_PESSOA"       	,If(Len(AllTrim(u_fNoAcento(cCGC)))< 14,'F','J')   	,Nil})
			AAdd(aCliente, {"A1_END"        	,u_fNoAcento(cEndere + ', ' + cNroEnd)   	,Nil})
			AAdd(aCliente, {"A1_BAIRRO"     	,cBairro                               	,Nil})
			AAdd(aCliente, {"A1_EST"        	,cUF                                   	,Nil})
			AAdd(aCliente, {"A1_CEP"        	,cCep                                  	,Nil})
			AAdd(aCliente, {"A1_COD_MUN"    	,cCodMun                               	,Nil})
			AAdd(aCliente, {"A1_PAIS"    		,SubStr(cCodPais,2,3)                   ,Nil})
			AAdd(aCliente, {"A1_CODPAIS"    	,cCodPais			                    ,Nil})
			AAdd(aCliente, {"A1_DDD"        	,IIf(!Empty(cDDD), StrZero(Val(cDDD), TamSX3('A1_DDD')[01]), cDDD),Nil})
			AAdd(aCliente, {"A1_TEL"        	,cFone                                 	,Nil})
			//AAdd(aCliente, {"A1_COND"       	,GetMV('ES_CONPGNF',.F.,'')       		,Nil})
			AAdd(aCliente, {"A1_INSCR"      	,cInscr                                	,Nil})
			AAdd(aCliente, {"A1_INSCRM"     	,cInscrM                               	,Nil})
			AAdd(aCliente, {"A1_XIMPXML"     	,'1'	                               	,Nil})
			AAdd(aCliente, {"A1_MSBLQL"		,'1'	                               	,Nil})
			AAdd(aCliente, {"A1_TIPO"          ,cTipoCli                               ,Nil})
			AAdd(aCliente, {"A1_RISCO"         ,"A"                                    ,Nil})
			AAdd(aCliente, {"A1_LC"            ,Val(Replicate("9", TamSX3("A1_LC")[01] - TamSX3("A1_LC")[02] - Int(TamSX3('A1_LC')[01]/3)) + "." + Replicate("9", TamSX3("A1_LC")[02])),Nil})
			AAdd(aCliente, {"A1_VENCLC"        ,STOD("20491231")                       ,Nil})
			AAdd(aCliente, {"A1_CLASSE"        ,"A"                                    ,Nil})
			AAdd(aCliente, {"A1_COMPLEM"       ,cComple                                ,Nil})
			AAdd(aCliente, {"A1_CONTRIB"       ,cContrib                               ,Nil})
			AAdd(aCliente, {"A1_SUFRAMA"       ,cSuframa                               ,Nil})
			//AAdd(aCliente, {"A1_NATUREZ"       ,cNatPad                                ,Nil})
			//AAdd(aCliente, {"A1_CONTA"         ,cCCtbPad                               ,Nil})

			lMsErroAuto := .F.

			MSExecAuto({|x,y| MATA030(x,y)},aCliente,3)

			If lMsErroAuto
				MostraErro()
				lRet := .F.
			EndIf
		Else
			Aviso("Erro","Cliente [" + Transform(cCGC,"@R 99.999.999/9999-99") +"] inexistente na base.",{"OK"},2,"ReadXML")
			lRet := .F.
		EndIf

	EndIf
EndIf

If lRet
	aRet := {cCodCli, cLojCli}
Endif

RestArea( aArea )
RestArea( aAreaSA1 )

Return aRet


//--------------------------------------------------------------------------------
/*/{Protheus.doc} XMLCADFOR

@author 	Fernando Alves Silva
@since		01/09/2016
@version	P12
/*/
//--------------------------------------------------------------------------------

Static Function fConvTAG(cID,cTAG)

Local cRet:= ""

If cID == 'TPNF'
	Do Case
		Case cTAG == '1'
			cRet:= "N"
		Case cTAG == '2'
			cRet:= "C"
		Case cTAG == '3'
			cRet:= "A"
		Case cTAG == '4'
			cRet:= "D"
	EndCase
EndIf

Return cRet

Static Function fObjArray(oObj)

Local aNotas := {}
Local oObjOk := oObj
Local nCount := 0

//-- Transforma em um array
If ValType(oObjOk:_chave) <> "A"
	XmlNode2Arr(oObjOk:_chave, "_CHAVE")
EndIf

//-- Chaves da nota fiscal eletrônica
For nCount := 1 To Len(oObjOk:_chave)
	Aadd( aNotas , oObjOk:_chave[nCount]:Text )
Next nCount

Return aNotas


Static Function fBuscaTES(G_CFOP, cCST_ICM, cCST_IPI, cCST_PIS, cCST_COF, cENQ_IPI,cTipoCli,lTemIPI,lMajorada,cTipo, cTipoNF, lDevP3, lTemICMS, cEstado)

Local cTES	:= ""
Local cQry	:= ""
Local aTES	:= {}
Local aSaida:= IIf(AllTrim(cEstado) == "EX", {"7"}, {"5", "6", "7"}) //Inicial de CFOP de Saída
Local aEntr := IIf(cTipoNF == "B", IIf(AllTrim(cEstado) == "EX", {"7"}, {"5", "6", "7"}) , IIf(AllTrim(cEstado) == "EX", {"3"}, {"1", "2", "3"})) //Inicial de CFOP de Entrada
Local nX    := 0 //Controle do For

//cQry := " SELECT F4_CODIGO FROM " + RetSqlName("SF4") + " WHERE F4_CF = '"+ IIf(cTipo == "NFS", "5", "3") + SubStr(G_CFOP,2,3) +"' AND F4_MSBLQL <> '1' AND D_E_L_E_T_ = '' "

//Percorrendo o Array
For nX := 1 To Len(aSaida)

	cQry := " SELECT F4_CODIGO, F4_PODER3 FROM " + RetSqlName("SF4") + " WHERE F4_CF = '"+ IIf(cTipo == "NFS", aSaida[nX], aEntr[nX]) + SubStr(G_CFOP,2,3) +"' AND F4_MSBLQL <> '1' AND D_E_L_E_T_ = '' " + CHR(13) + CHR(10)

	If !Empty(cCST_ICM)
		cQry	+= " AND F4_SITTRIB = '"+cCST_ICM+"' " + CHR(13) + CHR(10)
	EndIf

	If !Empty(cCST_IPI)
		cQry	+= " AND F4_CTIPI = '"+cCST_IPI+"' " + CHR(13) + CHR(10)
	EndIf

	If !Empty(cCST_PIS)
		cQry	+= " AND F4_CSTPIS = '"+cCST_PIS+"' " + CHR(13) + CHR(10)
	EndIf

	If !Empty(cCST_COF)
		cQry	+= " AND F4_CSTCOF = '"+cCST_COF+"' " + CHR(13) + CHR(10)
	EndIf

	If !Empty(cENQ_IPI)
		cQry	+= " AND F4_GRPCST = '"+cENQ_IPI+"' " + CHR(13) + CHR(10)
	EndIf

	// ------------------------------------------
	// Conferencia não necessáia para Importação
	// ------------------------------------------
	If cTipo == "NFS"
		If cTipoCli == '0'
			cQry	+= " AND F4_INCIDE = 'N' " + CHR(13) + CHR(10)
		EndIf

		If cTipoCli == '1'
			If lTemIPI .AND. lTemICMS
				cQry	+= " AND F4_INCIDE = 'S' " + CHR(13) + CHR(10)
			Else
				cQry	+= " AND F4_INCIDE = 'N' " + CHR(13) + CHR(10)
			EndIf
		EndIf

		//Beneficiamento
		If (cTipoNF == "B")
			//cQry	+= " AND F4_PODER3 = 'D' " + CHR(13) + CHR(10)
		EndIf
	Else
		If lMajorada
			cQry	+= " AND F4_MALQCOF > 0 " + CHR(13) + CHR(10)
		Else
			cQry	+= " AND F4_MALQCOF = 0 " + CHR(13) + CHR(10)
		EndIf

		//Beneficiamento
		If (cTipoNF == "B")
			//cQry	+= " AND F4_PODER3 = 'D' " + CHR(13) + CHR(10)
			//cQry	+= " AND F4_ESTOQUE = 'N' " + CHR(13) + CHR(10)
		EndIf
	EndIf


	TCQUERY ChangeQuery(cQry) ALIAS "TEMPTES" NEW

	If (TEMPTES->(EOF()))
		//MemoWrite('C:\TOTVS\TES_NAO_' + G_CFOP + '_' + DTOS(dDataBase) + '_' + StrTran(Time(), ":", "-") + '.TXT', cQry)
	EndIf

	While TEMPTES->(!Eof())
		aAdd(aTES, {TEMPTES->F4_CODIGO, TEMPTES->F4_PODER3} )
		TEMPTES->(DbSkip())
	EndDo

	TEMPTES->(DbCloseArea())

	If (Len(aTES) > 0)
		Exit
	EndIf
Next nX

If Len(aTES) == 1
	cTES := aTES[01, 01]
	If (cTipo == "NFS" .AND. aTES[01, 02] == "D")
		lDevP3 := .T.
	Else
		lDevP3 := .F.
	EndIf
Else
	cTES := ""
	//MemoWrite('C:\TOTVS\TES_MAIS_' + G_CFOP + '_' + DTOS(dDataBase) + '_' + StrTran(Time(), ":", "-") + '.TXT', cQry)
EndIf

Return cTES

User Function GeraDoc(aNotas , cNumCte , cSerieCte , cChvCTe, dDtEmisCTe , cFornCTe, cLojaCTe , nValCte , G_BaseIcn , G_AliqIcm, G_ValIcms, nBaseICM60, nAliICM60 , nValICM60 , lJob, cArqXML )
Local lRet		:= .T.
Local nCount	:= 1
Local aArea		:= GetArea()
Local aCabec	:= {}
Local aItensE	:= {}
Local aItensS	:= {}
Local aErroAuto	:= {}
Local cEstCTe   := ""
Local cLogErro	:= ""
Local nTipo		:= 0
Local cEntSai   := '' //Entrada ou Saída ?
Local cTESGen   := AllTrim(SuperGetMV('MV_XTESGEN', .F., '226')) //TES Genérico "226" - Grp 03
Local cPrdGen   := AllTrim(SuperGetMV('MV_XPRDGEN', .F., 'MC010230')) //Produto Genérico
Local cCtbGen   := AllTrim(SuperGetMV('MV_XCTBGEN', .F., '4502510230')) //Conta Contábil Genérica
Local nVlTotal  := 0 //Valor Total dos Produtos
Local cTESNF    := '' //TES Utilizada
Local cCtbNF    := '' //Conta Contábil Utilizada
Local lTesGen   := .F. //Verifica se Utiliza TES Genérica
Local nBasAux   := 0 //Valor da Base do ICMS Auxiliar
Local nValAux   := 0 //Valor Total Auxiliar
Local nICMAux   := 0 //Valor do ICMS Auxiliar

Local lOK         := .F.
Local cXML 	      := ''
Local oFullXML  := NIL
Local oAuxXML   := NIL
Local oXML	    := NIL
Local lFound    := .F.
Local nX        := 0
Local i         := 0
Local cError     := ""
Local cWarning   := ""
Local aCGCFor    := {}
Local dBkpDtBase := dDataBase

Default aNotas		:= {}
Default cNumCTe		:= ""
Default cSerieCte	:= ""
Default dDtEmisCTe	:= dDataBase
Default nValCte		:= 0
Default nBaseICM60	:= 0
Default nValICM60	:= 0
Default lJob		:= .F.
Default cFileOpen	:= ""
Default cNomeArq	:= ""

If (File(cArqXML))
	lOK := .T.
Else
	nPosArq := RAt("\NAO_PROC", Upper(cArqXML))
	nPosBar := RAt("\", Upper(cArqXML))
	If (nPosArq > 0 .AND. nPosBar > 0)
		cArqXML := SubStr(cArqXML, 1, nPosArq - 1) + '\IMPORTADOS\' + SubStr(cArqXML, nPosBar + 1)
		If (File(cArqXML))
			lOK := .T.
		EndIf
	EndIf
EndIf
oFullXML := XmlParserFile(cArqXML,"_",@cError,@cWarning)
lOK  := (ValType(oFullXML) == 'O' .AND. Empty(cError))
If (lOK)
	oXML    := oFullXML
	oAuxXML := oXML

	Do While !lFound
		If ValType(oAuxXML) <> "O"
			lNF:= .F.
			Exit
		EndIf
		oAuxXML := XmlChildEx(oAuxXML,"_NFE")
		lFound := (oAuxXML <> NIL)
		If !lFound
			For nX := 1 To XmlChildCount(oXML)
				oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
				If ValType(oAuxXML) == "O"
					lFound := oAuxXML:_InfNfe # Nil
					If lFound
						oXML := oAuxXML
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndDo
EndIf

If (lOK)
	//Desbloqueando o Fornecedor
	SA2->(DbSetOrder(1))
	IF SA2->(DbSeek(xFilial("SA2") + cFornCTe + cLojaCTe ) ) .And. SA2->A2_MSBLQL == "1"
		aAdd(aCGCFor, SA2->A2_CGC )
		If (RecLock("SA2",.F.))
			SA2->A2_MSBLQL	:= "2"
			SA2->(MsUnLock())
		EndIf
	Endif
	//Gera somente se encontrar todas as chaves

	//-- FILIAL + CHAVENFE
	SF1->(dbSetOrder(8)) //Entrada
	cEntSai := 'E' //Entrada
	For nCount := 1 To Len(aNotas)
		If SF1->(MsSeek(xFilial("SF1") + aNotas[nCount] ))
			Aadd(aItensE,{ {"PRIMARYKEY",	SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA	,Nil } })
			DbSelectArea('SD1')
			SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If (SD1->(DbSeek(FWxFilial('SD1') + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))))
				//Percorrendo os Itens
				While (!SD1->(EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) ==;
					(FWxFilial('SD1') + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
					//Encontrar a TES
					DbSelectArea('ZA3')
					ZA3->(DbSetOrder(2)) //ZA3_FILIAL + ZA3_CFOP + ZA3_TES
					If (ZA3->(DbSeek(FWxFilial('ZA3') + PadR(AllTrim(SD1->D1_CF), TamSX3('ZA3_CFOP')[01]))))
						cTESNF := IIf(G_ValIcms > 0, ZA3->ZA3_TES, ZA3->ZA3_TESNTI)
						cCtbNF := PadR(AllTrim(ZA3->ZA3_CONTA), TamSX3('CT1_CONTA')[01])
						Exit //Caso encontre, sair do Laço
					ElseIf (ZA3->(DbSeek(FWxFilial('ZA3') + PadR(AllTrim("1" + SubStr(SD1->D1_CF, 2 ,3)), TamSX3('ZA3_CFOP')[01]))))
						cTESNF := IIf(G_ValIcms > 0, ZA3->ZA3_TES, ZA3->ZA3_TESNTI)
						cCtbNF := PadR(AllTrim(ZA3->ZA3_CONTA), TamSX3('CT1_CONTA')[01])
						Exit //Caso encontre, sair do Laço
					Else
						lTesGen := .T.
						cTESNF := cTESGen //TES Genérica
						cCtbNF := cCtbGen
					EndIf
					//Pulando registro
					SD1->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nCount

	cNumCte   := StrZero(Val(AllTrim(cNumCte)),TamSx3("F1_DOC")[1])
	cSerieCte := StrZero(Val(AllTrim(cSerieCte)),TamSx3("F1_SERIE")[1])

	If Len(aItensE) == 0 //Saida
		cEntSai := 'S' //Entrada
		//Zera o Cabeçalho
		aCabec := {}
		//Cabelalho da Nota Fiscal de Entrada
		Aadd(aCabec,{"F1_FILIAL"     	,FWxFilial('SF1')  								,Nil})
		Aadd(aCabec,{"F1_DOC"       	,cNumCte    			    					,Nil})
		Aadd(aCabec,{"F1_SERIE"    		,cSerieCte   				   					,Nil})
		Aadd(aCabec,{"F1_FORNECE"    	,cFornCTe										,Nil})
		Aadd(aCabec,{"F1_LOJA"     		,cLojaCTe 								     	,Nil})
		Aadd(aCabec,{"F1_COND"     		,"XML"      				   					,Nil}) //Condição XML
		Aadd(aCabec,{"F1_EMISSAO"     	,dDtEmisCTe			  							,Nil})
		Aadd(aCabec,{"F1_FORMUL"     	,"N"               								,Nil})
		Aadd(aCabec,{"F1_ESPECIE"    	,"CTE"      	            				 	,Nil})
		Aadd(aCabec,{"F1_TIPO"    		,"N"             								,Nil})
		Aadd(aCabec,{"F1_DTDIGIT"    	,dDataBase            							,Nil})
		Aadd(aCabec,{"F1_EST"    		,cEstCTe    	             					,Nil})
		Aadd(aCabec,{"F1_CHVNFE"   		,cChvCTe    	             					,Nil})
		Aadd(aCabec,{"F1_TPCTE"   		,"N"        	             					,Nil})
		aAdd(aCabec,{"F1_BASERET"	    ,nBaseICM60                                     ,Nil})// Valor da base de calculo do ICMS retido
		aAdd(aCabec,{"F1_ICMRET"	    ,nValICM60                                      ,Nil})// Valor do ICMS retido

		If !lFound
			oXmlOk := oXML
		Else
			oXmlOk := oAuxXML
		EndIf
		//Impostos Totais

		SF2->(DBORDERNICKNAME("CHAVENFE"))
		//Compondo Valor Total dos Produtos
		For nCount := 1 To Len(aNotas)
			If SF2->(MsSeek(xFilial("SF2") + aNotas[nCount] ))
				//Posicionar no Item
				DbSelectArea('SD2')
				SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If (SD2->(DbSeek(FWxFilial('SD2') + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))))
					While (!SD2->(EOF()) .AND. SD2->D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ==;
						FWxFilial('SD2') + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
						nVlTotal += SD2->D2_TOTAL
						//Pulando registro
						SD2->(DbSkip())
					EndDo
				EndIf
			EndIf
		Next nCount
		SF2->(DBORDERNICKNAME("CHAVENFE"))
		//Gerando Itens
		//Posicionar no Produto
		DbSelectArea('SB1')
		SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
		SB1->(DbSeek(FWxFilial('SB1') + cPrdGen))
		cItem := Replicate('0', TamSX3('D1_ITEM')[01]) //Item
		For nCount := 1 To Len(aNotas)
			If SF2->(MsSeek(xFilial("SF2") + aNotas[nCount] ))
				//Posicionar no Item
				DbSelectArea('SD2')
				SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If (SD2->(DbSeek(FWxFilial('SD2') + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))))
					While (!SD2->(EOF()) .AND. SD2->D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ==;
						FWxFilial('SD2') + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
						//Somando Item
						cItem := Soma1(cItem)
						//Encontrar a TES
						DbSelectArea('ZA3')
						ZA3->(DbSetOrder(2)) //ZA3_FILIAL + ZA3_CFOP + ZA3_TES
						If (ZA3->(DbSeek(FWxFilial('ZA3') + PadR(AllTrim(SD2->D2_CF), TamSX3('ZA3_CFOP')[01]))))
							cTESNF := IIf(G_ValIcms > 0, ZA3->ZA3_TES, ZA3->ZA3_TESNTI)
							cCtbNF := PadR(AllTrim(ZA3->ZA3_CONTA), TamSX3('CT1_CONTA')[01])
						ElseIf (ZA3->(DbSeek(FWxFilial('ZA3') + PadR(AllTrim("5" + SubStr(SD2->D2_CF, 2 ,3)), TamSX3('ZA3_CFOP')[01]))))
							cTESNF := IIf(G_ValIcms > 0, ZA3->ZA3_TES, ZA3->ZA3_TESNTI)
							cCtbNF := PadR(AllTrim(ZA3->ZA3_CONTA), TamSX3('CT1_CONTA')[01])
						Else
							lTesGen := .T.
							cTESNF := cTESGen //TES Genérica
							cCtbNF := cCtbGen
						EndIf
						aLinha := {}
						nValAux += Round((nValCte / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_TOTAL', 'X3_DECIMAL'))
						nBasAux += Round((G_BaseIcn / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_BASEICM', 'X3_DECIMAL'))
						nICMAux += Round((G_ValIcms / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_BASEICM', 'X3_DECIMAL'))
						aAdd(aLinha,{"D1_TES"    	,cTESNF      						   ,Nil})
						aAdd(aLinha,{"D1_FILIAL"	,FWxFilial('SD1')                      ,Nil})
						aAdd(aLinha,{"D1_ITEM" 		,cItem                                 ,Nil})
						aAdd(aLinha,{"D1_COD"  		,PadR(cPrdGen, TamSX3('D1_COD')[01])   ,Nil})
						Aadd(aLinha,{"D1_UM"        ,SB1->B1_UM                 		   ,Nil})
						aAdd(aLinha,{"D1_QUANT"  	,1   									,Nil})
						aAdd(aLinha,{"D1_VUNIT"  	,Round((nValCte / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_VUNIT', 'X3_DECIMAL')),Nil})
						aAdd(aLinha,{"D1_TOTAL"  	,Round((nValCte / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_TOTAL', 'X3_DECIMAL')),Nil})
						Aadd(aLinha,{"D1_FORNECE"   ,cFornCTe      			   			    ,Nil})
						Aadd(aLinha,{"D1_LOJA"      ,cLojaCTe   	                		,Nil})
						aAdd(aLinha,{"D1_LOCAL"  	,SB1->B1_LOCPAD							,Nil})
						Aadd(aLinha,{"D1_DOC"       ,cNumCte            		    		,Nil})
						Aadd(aLinha,{"D1_EMISSAO"   ,dDataBase      			   			,Nil})
						Aadd(aLinha,{"D1_TIPO"      ,"N"                    				,Nil})
						Aadd(aLinha,{"D1_SERIE"     ,cSerieCte          			 		,Nil})
						Aadd(aLinha,{"D1_FORMUL"    ,"N"                    				,Nil})
						Aadd(aLinha,{"D1_NFORI"     ,SD2->D2_DOC               				,Nil})
						Aadd(aLinha,{"D1_SERIORI"   ,SD2->D2_SERIE         			 		,Nil})
						Aadd(aLinha,{"D1_ITEMORI"   ,SD2->D2_ITEM             				,Nil})
						//Enviar Valores somente se forem maiores que zero
						If (G_ValIcms > 0)
							Aadd(aLinha,{"D1_BASEICM"   ,Round((G_BaseIcn / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_BASEICM', 'X3_DECIMAL')),Nil})
							Aadd(aLinha,{"D1_PICM"      ,G_AliqIcm          			 		,Nil})
							Aadd(aLinha,{"D1_VALICM"    ,Round((G_ValIcms / nVlTotal) * SD2->D2_TOTAL , GetSX3Cache('D1_BASEICM', 'X3_DECIMAL')),Nil})
						EndIf
						AAdd(aLinha,{"D1_CONTA"     ,cCtbNF                                 ,Nil})
						Aadd(aLinha,{"AUTDELETA"    ,"N"                    				,Nil})
						AAdd(aItensS, AClone(aLinha))
						//Pulando registro
						SD2->(DbSkip())
					EndDo
				EndIf
			Else
				lRet:= .F.
				Exit //Sai do Laço
			EndIf
		Next nCount
		//Verifica se utiliza a TES Genérica
		If (lTesGen)
			//Percorrendo o Array de Itens
			For nCount := 1 To Len(aItensS)
				nPosTES := AScan(aItensS[nCount], {|x| AllTrim(x[01]) == "D1_TES"})
				nPosCtb := AScan(aItensS[nCount], {|x| AllTrim(x[01]) == "D1_CONTA"})
				If (nPosTES > 0 .AND. nPosCtb > 0)
					aItensS[nCount][nPosTES, 02] := cTESGen
					aItensS[nCount][nPosCtb, 02] := cCtbGen
				EndIf
			Next nCount
		//Verifica se o Valor Total, Base ICMS ou Valor ICMS estão diferentes e ajusta
		ElseIf !(nValCte == nValAux) .OR. !(G_BaseIcn == nBasAux) .OR. !(G_ValIcms == nICMAux)
			//Posicionando no Ultimo Item
			nCount := Len(aItensS)
			If (nCount > 0)
				nPosBas := AScan(aItensS[nCount], {|x| AllTrim(x[01]) == "D1_BASEICM"})
				nPosICM := AScan(aItensS[nCount], {|x| AllTrim(x[01]) == "D1_VALICM"})
				nPosVUn := AScan(aItensS[nCount], {|x| AllTrim(x[01]) == "D1_VUNIT"})
				nPosVal := AScan(aItensS[nCount], {|x| AllTrim(x[01]) == "D1_TOTAL"})
				If (nPosBas > 0 .AND. nPosICM > 0 .AND. nPosVUn > 0 .AND. nPosVal > 0)
					aItensS[nCount][nPosBas, 02] += (G_BaseIcn - nBasAux)
					aItensS[nCount][nPosICM, 02] += (G_ValIcms - nICMAux)
					aItensS[nCount][nPosVUn, 02] += (nValCte - nValAux)
					aItensS[nCount][nPosVal, 02] += (nValCte - nValAux)
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .AND. cEntSai == 'E'

		//Atualizando o Campo "Z1_TIPO", em casos de CTE de Entrada será gerado como complemento
		If (RecLock("SZ1", .F.))
			SZ1->Z1_TIPO := "C"
		EndIf

		aAdd(aCabec,{""				,dDataBase-90 })       												// Data inicial para filtro das notas
		aAdd(aCabec,{""				,dDataBase    })       												// Data final para filtro das notas
		aAdd(aCabec,{""				,2            })       												// 2-Inclusao ; 1=Exclusao
		aAdd(aCabec,{""				,Space(TamSx3("F1_FORNECE")[1]) } )    								// Rementente das notas contidas no conhecimento
		aAdd(aCabec,{""				,Space(TamSx3("F1_LOJA")[1])    } )  								// Loja do remetente das notas contidas no conhecimento
		aAdd(aCabec,{""				,nTipo   })                											// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
		aAdd(aCabec,{""				,1       })                											// 1=Aglutina itens ; 2=Nao aglutina itens
		aAdd(aCabec,{"F1_EST"		,""      })		  													// UF das notas contidas no conhecimento
		aAdd(aCabec,{""				,nValCte }) 														// Valor do conhecimento
		aAdd(aCabec,{"F1_FORMUL"	,1       })															// Formulario proprio: 1=Nao ; 2=Sim
		aAdd(aCabec,{"F1_DOC"		,PadR(cNumCTE,TamSx3("F1_DOC")[1])     } )							// Numero da nota de conhecimento
		aAdd(aCabec,{"F1_SERIE"		,PadR(cSerieCTE,TamSx3("F1_SERIE")[1]) } )							// Serie da nota de conhecimento
		aAdd(aCabec,{"F1_FORNECE"	,cFornCTe   })														// Fornecedor da nota de conhecimento
		aAdd(aCabec,{"F1_LOJA"		,cLojaCTe   })														// Loja do fornecedor da nota de conhecimento
		aAdd(aCabec,{""				,cTESNF   	})														// TES a ser utilizada nos itens do conhecimento
		aAdd(aCabec,{"F1_BASERET"	,nBaseICM60 })														// Valor da base de calculo do ICMS retido
		aAdd(aCabec,{"F1_ICMRET"	,nValICM60  })														// Valor do ICMS retido
		aAdd(aCabec,{"F1_COND"		,"XML"   	})									   					// Condicao de pagamento //Condição XML
		aAdd(aCabec,{"F1_EMISSAO"	,dDtEmisCTe }) 														// Data de emissao do conhecimento
		aAdd(aCabec,{"F1_ESPECIE"	,"CTE"      })														// Especie do documento
		aAdd(aCabec,{"Natureza"		,"C"        })														// Chave para tratamentos especificos
		Aadd(aCabec,{"F1_TPCTE"     ,"N"        })    //Tipo do CTe
		//Enviar somente se Valor Maior que Zero
		If (G_ValIcms > 0)
			aadd(aCabec,{"NF_BASEICM"   ,G_BaseIcn  })
			aadd(aCabec,{"NF_VALICM"    ,G_ValIcms  })
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a ExecAuto do MATA116 para gravar os itens com o valor de frete rateado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMsErroAuto    := .F.

		SA2->(dbSetOrder(1))
		SF1->(dbSetOrder(1))

		BEGIN TRANSACTION

		MsExecAuto({|x,y| MATA116(x,y)},aCabec,aItensE)

		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			lRet 	:= .F.
		Else
			//MsgInfo("Conhecimento: " + cNumCTE + " incluido com sucesso.")
			lRet := .T.
			//Posicionar na SF1
			DbSelectArea('SF1')
			SF1->(DBSetOrder(1)) //F1_FILIAL +  F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
			If (SF1->(DbSeek(FWxFilial('SZ1') + PadR(cNumCTE,TamSx3("F1_DOC")[01]) + PadR(cSerieCTE,TamSx3("F1_SERIE")[01]) + cFornCTe + cLojaCTe + "C")))
				//Atualizar a Chave no Cabeçalho do Documento
				If (RecLock('SF1', .F.))
					SF1->F1_CHVNFE := cChvCTe
				EndIf
				//Atualizar a Chave no Cabeçalho do Livro Fiscal
				DbSelectArea("SF3")
				DbSetOrder(4) // F3_FILIAL, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE
				If SF3->(DbSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
					While SF3->(!Eof()) .And. SF3->F3_FILIAL + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE == xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
					   	If (Reclock("SF3",.F.))
					   		SF3->F3_CHVNFE := cChvCTe
					   		SF3->(MsUnlock())
					   	EndIf
					   	//Pulando registro
					   	SF3->(DbSkip())
				   	EndDo
				EndIf
				//Posicionar nos Itens do Documento de Entrada
				dbSelectArea("SD1")
				dbSetOrder(1)
				If MsSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
					While SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) ==;
						SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

						//Posicionar nos Itens do Livro Fiscal
						SFT->(DbSetOrder(1))  //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
						SFT->(DbGoTop())
						//corrigir informações na SFT
						If SFT->(DbSeek(FWxFilial("SFT") + "E" + SD1->(D1_SERIE + D1_DOC + D1_FORNECE + D1_LOJA) + Padr(SD1->D1_ITEM, TamSX3("FT_ITEM")[1]) + SD1->D1_COD, .F.))

							nRecSFT := SFT->(Recno())

							If (RecLock('SFT', .F.))
								//Atualizando a Chave
								SFT->FT_CHVNFE := cChvCTe
								SFT->(MsUnLock())
							EndIf
						EndIf
						//Pulando registro
						SD1->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf

		END TRANSACTION
	ElseIf lRet .AND. cEntSai == 'S' //CTe para Saída
		lMsErroAuto    := .F.

		SA2->(dbSetOrder(1))
		SF1->(dbSetOrder(1))

		BEGIN TRANSACTION

		MsExecAuto({|x, y, z| MATA103(x, y, z)}, aCabec, aItensS, 03)

		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			lRet 	:= .F.
		Else
			//MsgInfo("Conhecimento: " + cNumCTE + " incluido com sucesso.")
		EndIf

		END TRANSACTION
	EndIf
EndIf

//Bloqueando o Fornecedor
If Len(aCGCFor) > 0
	For i := 1 to Len(aCGCFor)
		DbSelectArea("SA2")
		SA2->(dbSetOrder(3)) //-- A2_FILIAL + A2_CGC
		If SA2->(dbSeek(xFilial('SA2') + aCGCFor[i]))
			RecLock("SA2",.F.)
				SA2->A2_MSBLQL	:= "1"
			MsUnLock()
	   	EndIf
	Next i
EndIf

//Verifica se encontrou as Notas
If Len(aItensE) == 0 .AND. Len(aItensS) == 0
	cChave := ''
	For i := 1 To Len(aNotas)
		cChave += aNotas[i] + CHR(13) + CHR(10)
	Next i
	If !(Empty(cChave))
		If (Type("aLogXML") == "U")
			Aviso('TOTVS', 'Não foram encontradas Notas Fiscais para a(s) chave(s): ' + CHR(13) + CHR(10) + cChave, {'OK'}, 03)
		Else
			aLogXML[Len(aLogXML), 02] += 'Não foram encontradas Notas Fiscais para a(s) chave(s): ' + CHR(13) + CHR(10) + cChave + CHR(13) + CHR(10)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

Static Function RetUF(cID)

Local cRet := ""

Do Case

// ------------------------------------------
// Região Norte
// ------------------------------------------
	Case cID == '11' // Rondônia
		cRet := "RO"
	Case cID == '12' // Acre
		cRet := "AC"
	Case cID == '13' // Amazonas
		cRet := "AM"
	Case cID == '14' // Roraima
		cRet := "RR"
	Case cID == '15' // Pará
		cRet := "PA"
	Case cID == '16' // Amapá
		cRet := "AP"
	Case cID == '17' // Tocantins
		cRet := "TO"
// ------------------------------------------
// Região Nordeste
// ------------------------------------------
	Case cID == '21' // Maranhão
		cRet := "MA"
	Case cID == '22' // Piauí
		cRet := "PI"
	Case cID == '23' // Ceará
		cRet := "CE"
	Case cID == '24' // Rio Grande do Norte
		cRet := "RN"
	Case cID == '25' // Paraíba
		cRet := "PB"
	Case cID == '26' // Pernambuco
		cRet := "PE"
	Case cID == '27' // Alagoas
		cRet := "AL"
	Case cID == '28' // Sergipe
		cRet := "SE"
	Case cID == '29' // Bahia
		cRet := "BA"
// ------------------------------------------
// Região Sudeste
// ------------------------------------------
	Case cID == '31' // Minas Gerais
		cRet := "MG"
	Case cID == '32' // Espírito Santo
		cRet := "ES"
	Case cID == '33' // Rio de Janeiro
		cRet := "RJ"
	Case cID == '35' // São Paulo
		cRet := "SP"
// ------------------------------------------
// Região Sul
// ------------------------------------------
	Case cID == '41' // Paraná
		cRet := "PR"
	Case cID == '42' // Santa Catarina
		cRet := "SC"
	Case cID == '43' // Rio Grande do Sul
		cRet := "RS"
// ------------------------------------------
// Região C-Oeste
// ------------------------------------------
	Case cID == '50' // Mato Grosso do Sul
		cRet := "MS"
	Case cID == '51' // Mato Grosso
		cRet := "MT"
	Case cID == '52' // Goiás
		cRet := "GO"
	Case cID == '53' // Distrito Federal
		cRet := "DF"
	OtherWise
		cRet := "EX"
EndCase

Return cRet

Static Function fBuscaForn(cNome, cEnder)
	Local aArea  := GetArea() //Reservando a Area
	Local nCount := 0 //Contador
	Local cSQL   := "" //Consulta SQL
	Local cForn  := '' //Fornecedor
	Local cLoja  := '' //Loja
	Local lRet   := .F. //Retorno

	cSQL := " SELECT"
	cSQL += " R_E_C_N_O_ NUMREC, A2_COD, A2_LOJA, A2_NOME"
	cSQL += " FROM " + RetSQLName('SA2')
	cSQL += " WHERE A2_FILIAL = '" + FWxFilial('SA2') + "' AND A2_NOME = '" + AllTrim(cNome) + "' "
	cSQL += " AND A2_END = '" + cEnder + "' AND A2_EST = 'EX' AND D_E_L_E_T_ = ' '"

	If (Select('FFORN') > 0)
		FFORN->(DbCloseArea())
	EndIf

	PlsQuery(cSQL, 'FFORN')

	DbSelectArea('FFORN')
	FFORN->(DbGoTop())

	Count To nCount

	//Caso encontre somente 1, posicionar
	If (nCount == 1)
		DbSelectArea('FFORN')
		FFORN->(DbGoTop())
		cForn := FFORN->A2_COD
		cLoja := FFORN->A2_LOJA
		If (FFORN->NUMREC > 0)
			DbSelectArea('FFORN')
			FFORN->(DbGoTop())
			DbSelectArea('SA2')
			SA2->(DbGoTo(FFORN->NUMREC))
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea) //Restaurando a Area
Return {lRet, cForn, cLoja}

Static Function fBuscaCli(cNome, cEnder)
	Local aArea  := GetArea() //Reservando a Area
	Local nCount := 0 //Contador
	Local cSQL   := "" //Consulta SQL
	Local lRet   := .F. //Retorno
	Local cCli   := '' //Cliente
	Local cLoja  := '' //Loja
	Local cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry
		SELECT SA1.R_E_C_N_O_ SA1REC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME
		FROM %Table:SA1% SA1
		WHERE SA1.A1_FILIAL = %xFilial:SA1% AND
		SA1.A1_NOME = %Exp:cNome% AND
		SA1.A1_EST = 'EX' AND
		SA1.A1_END = %Exp:cEnder% AND
		SA1.%NotDel%
	EndSQL

	Count To nCount

	//Caso encontre somente 1, posicionar
	If (nCount == 1)
		(cAliasQry)->(DbGoTop())
		cCli  := (cAliasQry)->A1_COD
		cLoja := (cAliasQry)->A1_LOJA
		If ((cAliasQry)->SA1REC > 0)
			DbSelectArea('SA1')
			SA1->(DbGoTo((cAliasQry)->SA1REC))
			lRet := .T.
		EndIf
	EndIf

	RestArea(aArea) //Restaurando a Area
Return {lRet, cCli, cLoja}

// ===============================================================================================

Static Function fSelFornec(xNome,xDoc,xSerie,xChave,cArqXML)

Local aRet		:= {}
Local oDlg 		:= Nil
Local oTodos	:= Nil
Local aCampos	:= {}
Local nPosLbx	:= 0
Local lRet		:= .T.
Local nOpcAx2	:= 0
Local oOk      	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo      	:= LoadBitmap( GetResources(), "LBNO" )
Local lMark    	:= .F.
Local lTodos	:= .F.
Local i			:= 0
Local cQry		:= ""
Local nCount	:= 0
Local oFonte1	:= Nil
Local cTemp 	:= GetTempPath()
Local cNewFile	:= cTemp + StrTran(TIME(),":","") + ALLTRIM(SUBSTR(UPPER(xNome),1,AT(" ",UPPER(xNome)))) + ".XML"
Local bLetsGo	:= {|lRet,nRet| lRet:= __CopyFile(cArqXML,cNewFile) , nRet:= ShellExecute("Open", cNewFile , " /k dir", "C:\", 1 ) }

xNome := IIf(AT(" ",UPPER(xNome)) > 0,ALLTRIM(SUBSTR(UPPER(xNome),1,AT(" ",UPPER(xNome)))), AllTrim(Upper(xNome)))

cQry := " SELECT A2_COD, A2_NOME, A2_LOJA, A2_END, YA_DESCR "
cQry += " FROM " + RetSqlName("SA2") + " SA2 "
cQry += " LEFT JOIN "+RetSqlName("SYA")+" ON "
cQry += " YA_CODGI = A2_PAIS AND YA_FILIAL = '"+xFilial("SYA")+"' "
cQry += " WHERE UPPER(A2_NOME) LIKE '" + xNome + "%' AND "
cQry += " A2_EST = 'EX' AND "
cQry += " A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.D_E_L_E_T_ = ' ' "

TCQUERY ChangeQuery(cQry) ALIAS "TEMPFOR" NEW

While TEMPFOR->(!Eof())
	aAdd(aCampos, {.F. 					,;
					TEMPFOR->A2_COD 	,;
					TEMPFOR->A2_LOJA	,;
					TEMPFOR->A2_NOME	,;
					TEMPFOR->A2_END 	,;
					TEMPFOR->YA_DESCR 	})
	TEMPFOR->(DbSkip())
EndDo

TEMPFOR->(DbCloseArea())

If Len(aCampos) > 0

	Define MSDialog oDlg From  0,0 To 340,490 Title "Selecione o Fornecedor de Importação" Pixel

		DEFINE FONT oFonte1 SIZE 07,16

		@ 0,0 Listbox oLbx1 Var nPosLbx Fields HEADER ;
		"",;
		"Codigo",;
		"Loja",;
		"Nome",;
		"Endereco",;
		"Pais",;
		Size 255,110 Of oDlg Pixel ON dblClick(aCampos[oLbx1:nAt,1] := !aCampos[oLbx1:nAt,1],fMarkOne(oLbx1,oLbx1:nAt,aCampos[oLbx1:nAt,1]),oLbx1:Refresh())
		//@ 260,05 CheckBox oTodos Var lTodos Size 130,9 Pixel Of oDlg Prompt "Marca e Desmarca Todos" On Change fMarkAll(oLbx1, lTodos)

		oLbx1:SetArray(aCampos)
		oLbx1:bLine:={||{ 		Iif(aCampos[oLbx1:nAt,1],oOk,oNo),;		// Mark
								aCampos[oLbx1:nAt,2],; 					// Grupo Empresa
								aCampos[oLbx1:nAt,3],; 					// Nome da Empresa
								aCampos[oLbx1:nAt,4],; 					// Código da Filial
								aCampos[oLbx1:nAt,5],; 					// Código da Filial
								aCampos[oLbx1:nAt,6]}} 					// Filial

		DEFINE SBUTTON FROM 155 ,185 TYPE 1 ACTION (nOpcAx2 := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 155	,215 TYPE 2 ACTION (nOpcAx2 := 0,oDlg:End()) ENABLE OF oDlg

	@ 112, 005 	GROUP oGrpCam TO 150, 185 	PROMPT "Informações do Arquivo XML" 	OF oDlg  PIXEL
	@ 115, 188 	GROUP oGrp2   TO 150, 242 	PROMPT "" 	OF oDlg  PIXEL

	@ 123, 010 SAY oSay1 PROMPT "N° Documento:  " + xDoc SIZE 138, 017 OF oGrpCam PIXEL
	@ 123, 100 SAY oSay2 PROMPT "Serie:  " + xSerie SIZE 138, 017 OF oGrpCam PIXEL
	@ 135, 010 SAY oSay3 PROMPT "Chave:  " + xChave SIZE 300, 017 OF oGrpCam PIXEL

	@ 118,191 BUTTON "Ver XML" SIZE 47,29 PIXEL OF oGrpCam ACTION Eval(bLetsGo)



	oSay1:oFont:= oFonte1
	oSay2:oFont:= oFonte1
	oSay3:oFont:= oFonte1

	Activate MSDialog oDlg Centered

	If nOpcAx2 == 1
		For i := 1 to Len(aCampos)
			If aCampos[i][1]
			aAdd(aRet, aCampos[i][2])
			aAdd(aRet, aCampos[i][3])
			nCount++
			EndIf
		Next i
	Endif

EndIf

Return aRet

Static Function fSelCli(xNome,xDoc,xSerie,xChave,cArqXML)

Local aRet		:= {}
Local oDlg 		:= Nil
Local oTodos	:= Nil
Local aCampos	:= {}
Local nPosLbx	:= 0
Local lRet		:= .T.
Local nOpcAx2	:= 0
Local oOk      	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo      	:= LoadBitmap( GetResources(), "LBNO" )
Local lMark    	:= .F.
Local lTodos	:= .F.
Local i			:= 0
Local cQry		:= ""
Local nCount	:= 0
Local oFonte1	:= Nil
Local cTemp 	:= GetTempPath()
Local cNewFile	:= cTemp + StrTran(TIME(),":","") + ALLTRIM(SUBSTR(UPPER(xNome),1,AT(" ",UPPER(xNome)))) + ".XML"
Local bLetsGo	:= {|lRet,nRet| lRet:= __CopyFile(cArqXML,cNewFile) , nRet:= ShellExecute("Open", cNewFile , " /k dir", "C:\", 1 ) }

xNome := IIf(AT(" ",UPPER(xNome)) > 0,ALLTRIM(SUBSTR(UPPER(xNome),1,AT(" ",UPPER(xNome)))), AllTrim(Upper(xNome)))

cQry := " SELECT A1_COD, A1_NOME, A1_LOJA, A1_END, YA_DESCR "
cQry += " FROM " + RetSqlName("SA1") + " SA1 "
cQry += " LEFT JOIN "+RetSqlName("SYA")+" ON YA_CODGI = A1_PAIS AND YA_FILIAL = '"+xFilial("SYA")+"' "
cQry += " WHERE UPPER(A1_NOME) LIKE '" + xNome + "%' AND "
cQry += " A1_EST = 'EX' AND "
cQry += " A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.D_E_L_E_T_ = ' ' "
TCQUERY ChangeQuery(cQry) ALIAS "TEMPCLI" NEW

While TEMPCLI->(!Eof())
	aAdd(aCampos, {.F. 					,;
					TEMPCLI->A1_COD 	,;
					TEMPCLI->A1_LOJA	,;
					TEMPCLI->A1_NOME	,;
					TEMPCLI->A1_END 	,;
					TEMPCLI->YA_DESCR 	})
	TEMPCLI->(DbSkip())
EndDo

TEMPCLI->(DbCloseArea())

If Len(aCampos) > 0

	Define MSDialog oDlg From  0,0 To 340,490 Title "Selecione o Cliente de Exportação" Pixel

		DEFINE FONT oFonte1 SIZE 07,16

		@ 0,0 Listbox oLbx1 Var nPosLbx Fields HEADER ;
		"",;
		"Codigo",;
		"Loja",;
		"Nome",;
		"Endereco",;
		"Pais",;
		Size 255,110 Of oDlg Pixel ON dblClick(aCampos[oLbx1:nAt,1] := !aCampos[oLbx1:nAt,1],fMarkOne(oLbx1,oLbx1:nAt,aCampos[oLbx1:nAt,1]),oLbx1:Refresh())
		//@ 260,05 CheckBox oTodos Var lTodos Size 130,9 Pixel Of oDlg Prompt "Marca e Desmarca Todos" On Change fMarkAll(oLbx1, lTodos)

		oLbx1:SetArray(aCampos)
		oLbx1:bLine:={||{ 		Iif(aCampos[oLbx1:nAt,1],oOk,oNo),;		// Mark
								aCampos[oLbx1:nAt,2],; 					// Grupo Empresa
								aCampos[oLbx1:nAt,3],; 					// Nome da Empresa
								aCampos[oLbx1:nAt,4],; 					// Código da Filial
								aCampos[oLbx1:nAt,5],; 					// Código da Filial
								aCampos[oLbx1:nAt,6]}} 					// Filial

		DEFINE SBUTTON FROM 155 ,185 TYPE 1 ACTION (nOpcAx2 := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 155	,215 TYPE 2 ACTION (nOpcAx2 := 0,oDlg:End()) ENABLE OF oDlg

	@ 112, 005 	GROUP oGrpCam TO 150, 185 	PROMPT "Informações do Arquivo XML" 	OF oDlg  PIXEL
	@ 115, 188 	GROUP oGrp2   TO 150, 242 	PROMPT "" 	OF oDlg  PIXEL

	@ 123, 010 SAY oSay1 PROMPT "N° Documento:  " + xDoc SIZE 138, 017 OF oGrpCam PIXEL
	@ 123, 100 SAY oSay2 PROMPT "Serie:  " + xSerie SIZE 138, 017 OF oGrpCam PIXEL
	@ 135, 010 SAY oSay3 PROMPT "Chave:  " + xChave SIZE 300, 017 OF oGrpCam PIXEL

	@ 118,191 BUTTON "Ver XML" SIZE 47,29 PIXEL OF oGrpCam ACTION Eval(bLetsGo)



	oSay1:oFont:= oFonte1
	oSay2:oFont:= oFonte1
	oSay3:oFont:= oFonte1

	Activate MSDialog oDlg Centered

	If nOpcAx2 == 1
		For i := 1 to Len(aCampos)
			If aCampos[i][1]
			aAdd(aRet, aCampos[i][2])
			aAdd(aRet, aCampos[i][3])
			nCount++
			EndIf
		Next i
	Endif

EndIf

Return aRet

/*/{Protheus.doc} fMarkOne
----------------------------------------------------------------------
Marca apenas 1
@author [Totvs Ibirapuera] - Fernando Alves Silva
@since 11/07/2016
@version P11 | P12

@return Nil
----------------------------------------------------------------------
/*/

Static Function fMarkOne(oLbx1,nPos,lCheck)

Local nI := 0 // Variavel de Controle


For nI := 1 To Len(oLbx1:aArray)

If lCheck
	If nPos <> nI
		oLbx1:aArray[nI][1] := .F.
		oLbx1:Refresh()
	EndIf
EndIf

Next nI

Return(.T.)

Static Function fBuscaOrig(xChaveOri,xTipoNF,xIDXML)

Local aRet:= {}

If PesqChaveNFE(xChaveOri)
	aAdd(aRet, SF3->F3_NFISCAL)
	aAdd(aRet, SF3->F3_SERIE)
EndIf

Return aRet

Static Function PesqChaveNFE(cChaveNF)

Local cTrb		:= GetNextAlias()
Local lRet		:= .T.

Default cChaveNF	:= ''

If Empty(cChaveNF)
	Return .F.
Endif


// Realiza busca da nota fiscal
BEGINSQL Alias cTrb

SELECT TOP 1 F3_CHVNFE, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, R_E_C_N_O_ as SF3REC
FROM %table:SF3% SF3
WHERE SF3.F3_FILIAL = %xFilial:SF3% AND SF3.D_E_L_E_T_ = ' ' AND F3_CHVNFE = %exp:cChaveNF%

ENDSQL

(cTrb)->( DbGoTop() )

IF (cTrb)->SF3REC > 0
	SF3->( DbGoTo( (cTrb)->SF3REC ) )
Else
	lRet := .F.
Endif

(cTrb)->( DbCloseArea() )

Return lRet

/*/{Protheus.doc} fGetUM
Busca a Unidade de Medida
@type function
@author Alison
@since 17/01/2017
@version 1.0
@param cXmlUM, character, Código da Unidade de Medida
@return cRetUM, Unidade de Medida
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetUM(cXmlUM)
	Local aArea  := GetArea() //Reservando a Area
	Local cUMGen := AllTrim(SuperGetMV('ES_UMGENER', .F., '99')) //Unidade de Medida Genérica
	Local cRetUM := cXmlUM //Retorno

	//Posicionar na Tabela
	DbSelectArea('SAH')
	SAH->(DbSetOrder(1)) //AH_FILIAL+AH_UNIMED
	If !(SAH->(DbSeek(FWxFilial('SAH') + cXmlUM)))
		//Verificar se o Código Genérico existe
		If !(SAH->(DbSeek(FWxFilial('SAH') + cUMGen)))
			//Caso não encontre, incluir
			If (RecLock('SAH', .T.))
				SAH->AH_FILIAL := FWxFilial('SAH')
				SAH->AH_UNIMED := cUMGen
				SAH->AH_UMRES := 'UM XML'
				SAH->AH_DESCPO := 'UNIDADE DE MEDIDA GENERICA XML'
				SAH->AH_DESCIN := 'UNIDADE DE MEDIDA GENERICA XML'
				SAH->AH_DESCES := 'UNIDADE DE MEDIDA GENERICA XML'
				SAH->(MsUnlock())
				cRetUM := cUMGen //Setando como retorno a Genérica
			EndIf
		Else
			cRetUM := cUMGen //Setando como retorno a Genérica
		EndIf
	EndIf

	RestArea(aArea) //Restaurando a Area
Return cRetUM

/*/{Protheus.doc} GetItemOri
Retorna o Número do Item da Nota Fiscal de Origem
@type function
@author Alison
@since 15/12/2016
@version 1.0
@param cF3Doc, character, Número da Nota Fiscal
@param cF3Serie, character, Série da Nota Fiscal
@param cF3Chave, character, Chave da Nota Fiscal
@param cF3Prod, character, Código do Produto
@param cF3TipoMov, character, Tipo de Movimento "NFS" Saída ou "NFE" Entrada
@return cF3Item, Número do Item da Nota Fiscal de Origem
/*/
Static Function GetItemOri(cF3Doc, cF3Serie, cF3Chave, cF3Prod, cF3TipoMov)
	Local aArea      := GetArea() //Reservando a Area
	Local cF3Item    := '' //Número do Item da Nota Fiscal de Origem
	Local nCount     := 0 //Contador
	Local aCpos      := {'D2_ITEM', 'B1_COD', 'B1_DESC', 'D2_QUANT', 'D2_PRUNIT', 'D2_TOTAL'} //Campos da GetDados
	Local cCpoRet    := 'D2_ITEM' //Campo Retorno
	Local cFilter    := '' //Filtro
	Local cAliasQry  := GetNextAlias() //Alias da Query

	//Verificando o Tipo
	If (cF3TipoMov == 'NFS') //Saída
		BeginSQL Alias cAliasQry
			SELECT
				SD2.D2_ITEM D2_ITEM,
				SD2.D2_COD B1_COD,
				SB1.B1_DESC B1_DESC,
				SD2.D2_QUANT D2_QUANT,
				SD2.D2_PRUNIT D2_PRUNIT,
				SD2.D2_TOTAL D2_TOTAL
			FROM
				%Table:SD2% SD2
			INNER JOIN %Table:SB1% SB1 ON
				SB1.B1_FILIAL = %xFilial:SB1% AND
				SB1.B1_COD = SD2.D2_COD AND
				SB1.%NotDel%
			WHERE
				SD2.D2_FILIAL = %xFilial:SD2% AND
				SD2.D2_SERIE = %Exp:cF3Serie% AND
				SD2.D2_DOC = %Exp:cF3Doc% AND
				SD2.D2_COD = %Exp:cF3Prod% AND
				SD2.%NotDel%
		EndSQL
	ElseIf (cF3TipoMov == 'NFE') //Saída //Entrada
		BeginSQL Alias cAliasQry
			SELECT
				SD1.D1_ITEM D2_ITEM,
				SD1.D1_COD B1_COD,
				SB1.B1_DESC B1_DESC,
				SD1.D1_QUANT D2_QUANT,
				SD1.D1_VUNIT D2_PRUNIT,
				SD1.D1_TOTAL D2_TOTAL
			FROM
				%Table:SD1% SD1
			INNER JOIN %Table:SB1% SB1 ON
				SB1.B1_FILIAL = %xFilial:SB1% AND
				SB1.B1_COD = SD1.D1_COD AND
				SB1.%NotDel%
			WHERE
				SD1.D1_FILIAL = %xFilial:SD1% AND
				SD1.D1_SERIE = %Exp:cF3Serie% AND
				SD1.D1_DOC = %Exp:cF3Doc% AND
				SD1.D1_COD = %Exp:cF3Prod% AND
				SD1.%NotDel%
		EndSQL
	EndIf

	//Verificando se encontrou registros
	If !(cAliasQry)->(EOF())
		//Valorizando Contador
		Count To nCount
		(cAliasQry)->(DbGoTop())
		//Caso retorne somente um item, será o item de origem da Nota
		If (nCount == 1)
			cF3Item := (cAliasQry)->D2_ITEM
		Else
			aButtons := {} //Array de Botões
			AAdd( aButtons, {"VERXML", {|| u_VERXML()}, "Visualiza XML...", "Visualiza XML" , {|| .T.}} )
			AAdd( aButtons, {"VERDANFE", {|| u_VERDANFE()}, "Visualiza Danfe...", "Visualiza Danfe" , {|| .T.}} )
			//Chamar Tela para seleção do Item
			cF3Item := u_GetDGen('Selecione o Item da Nota Fiscal de Origem', cAliasQry, aCpos, cCpoRet, cFilter, aButtons)
		EndIf
	EndIf

	//Fechando área
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea) //Restaurando a Area
Return cF3Item

/*/{Protheus.doc} fIsBenef
Verifica se o CFOP é de Beneficiamento
@type function
@author Alison
@since 13/01/2017
@version 1.0
@param G_CFOP, caracter, CFOP
@param cIDXML, caracter, ID XML "NFS" - Saída ou "NFE" - Entrada
@return lRet, Controle de Processamento

/*/
Static Function fIsBenef(G_CFOP, cIDXML)
	//Array com os CFOP's de Beneficiamento de Saída
	Local aCFBenefS := StrTokArr(AllTrim(SuperGetMV("ES_CFBNSAI", .F., "5901;5905;5909;5913;5915;5921;5663;")), ";")
	//Array com os CFOP's de Beneficiamento de Entrada
	Local aCFBenefE := StrTokArr(AllTrim(SuperGetMV("ES_CFBNENT", .F., "1901;1904;1909;1913;1914;1915;1918;1919;1921;1415;")), ";")
	//Controle de Processamento
	Local lRet := .F.

	//Verifica se encontrou o CFOP no Array
	If (cIDXML == "NFS")
		If (AScan(aCFBenefS, {|x| AllTrim(x) == "5" + SubStr(G_CFOP, 02, 03)}) > 0)
			lRet := .T.
		EndIf
	Else
		If (AScan(aCFBenefE, {|x| AllTrim(x) == "1" + SubStr(G_CFOP, 02, 03)}) > 0)
			lRet := .T.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} GetTipoCom
Retorna o Tipo do Complemento na Tabela SZ1
@type function
@author Alison
@since 16/12/2016
@version 1.0
@param cZ1Doc, character, Número do Documento
@param cZ1Serie, character, Série do Documento
@param cZ1Forn, character, Código do Fornecedor
@param cZ1Loja, character, Loja do Fornecedor
@return cZ1Tipo, Código do Tipo de Complemento
/*/
Static Function GetTipoCom(cZ1Doc, cZ1Serie, cZ1Forn, cZ1Loja)
	Local aArea     := GetArea() //Reservando a Area
	Local cZ1Tipo   := '' //Código do Tipo de Complemento
	Local cAliasQry := GetNextAlias() //Alias da Query

	//Abrindo Area pelo SQL
	BeginSQL Alias cAliasQry
		SELECT
			Z1_TIPO
		FROM
			%Table:SZ1% SZ1
		WHERE
			SZ1.Z1_FILIAL = %xFilial:SZ1% AND
			SZ1.Z1_DOC = %Exp:cZ1Doc% AND
			SZ1.Z1_SERIE = %Exp:cZ1Serie% AND
			SZ1.Z1_FORNECE = %Exp:cZ1Forn% AND
			SZ1.Z1_LOJA = %Exp:cZ1Loja% AND
			SZ1.%NotDel%
	EndSQL

	//Valorizando o Tipo
	If !(cAliasQry)->(EOF())
		cZ1Tipo := (cAliasQry)->Z1_TIPO
	EndIf

	//Fechando a Area
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea) //Restaurando a Area
Return cZ1Tipo

/*/{Protheus.doc} GetDGen
GetDados Genérica
@type function
@author Alison
@since 18/12/2016
@version 1.0
@param cTitulo, character, Título
@param cTab, character, Nome da Tabela ou Alias Utilizado
@param aCpos, array, Array com os campos da Tabela a serem mostrados
@param cCpoRet, character, Campo da Tabela para Retorno
@param cFilter, character, Filtro a Ser Utilizado por Macro Substituição. Ex: "(cTab)->A1_NOME == 'A'"
@param aButtons, array, Botões da EnchoiceBar
@return xRet, Retorno
/*/
User Function GetDGen(cTitulo, cTab, aCpos, cCpoRet, cFilter, aButtons)
	Local aArea := GetArea() //Reservando a Area
	Local xRet  := Nil //Retorno
	Local aHeadG:= {} //Header
	Local aColsG:= {} //Columns
	Local nI    := 0 //Controle do FOR
	Local lOK   := .T. //Controle de Processamento
	Local cMsg  := '' //Mensagem de Log
	//Variáveis do Dialog
	Private oDlgGen   := Nil
	Private oPanelGen := Nil
	Private oGetDGen  := Nil

	//Verifica se a Tabela/Alias pode ser selecionada
	DbSelectArea(cTab)
	If (Select(cTab) > 0)
		//Adicionando Campos do Header
		For nI := 1 To Len(aCpos)
			DbSelectArea('SX3')
			SX3->(DbSetOrder(2)) //X3_CAMPO
			If (SX3->(DbSeek(aCpos[nI])))
				//Adicionando no Array
				AAdd(aHeadG,;
							{;
								SX3->X3_TITULO,; //01-Titulo
								SX3->X3_CAMPO,; //02-Campo
								SX3->X3_PICTURE,; //03-Picture
								SX3->X3_TAMANHO,; //04-Tamanho
								SX3->X3_DECIMAL,; //05-Decimal
								".F.",; //06-Validacao
								".F.",; //07-Reservado
								SX3->X3_TIPO,; //08-Tipo
							};
					)
			EndIf
		Next nI
		If (Len(aHeadG) > 0)
			//Verifica se o Filtro está em branco, caso esteja preenche com ".T."
			cFilter := IIf(Empty(cFilter), ".T.", cFilter)
			//Percorrendo a Tabela/Alias para adicionar ao Array aCols
			DbSelectArea(cTab)
			(cTab)->(DbGoTop())
			While !(cTab)->(EOF())
				//Verifica se atendo ao Filtro
				If &(cFilter)
					//Adicionando ao array
					AAdd(aColsG, {})
					For nI := 1 To Len(aHeadG)
						AAdd(aColsG[Len(aColsG)], (cTab)->&(aHeadG[nI, 02]))
					Next nI
					//Controle de Exclusão
					AAdd(aColsG[Len(aColsG)], .F.)
				EndIf
				//Pulando registro
				(cTab)->(DBSkip())
			EndDo
			//Verifica se encontrou itens
			If (Len(aColsG) > 0)
				//Verifica se o campo retorno existe na Tabela/Alias
				If (Type(cTab + '->' + cCpoRet) == 'U')
					lOK := .F.
					cMsg += 'Campo de Retorno "' + cCpoRet + '" não encontrado na Tabela/Alias "' + cTab + '"...' + CHR(13) + CHR(10)
				EndIf
			Else
				lOK := .F.
				cMsg += 'Não há registros...' + CHR(13) + CHR(10)
			EndIf
		Else
			lOK := .F.
			cMsg += 'Não há campos compatíveis com o Dicionário de Dados...' + CHR(13) + CHR(10)
		EndIf
	Else
		lOK := .F.
		cMsg += 'Tabela/Alias "' + cTab + '" não pôde ser selecionada...' + CHR(13) + CHR(10)
	EndIf

	If (lOK)
		DEFINE MSDIALOG oDlgGen TITLE OemToAnsi("Consulta Genérica") FROM 000, 000  TO 400, 700 COLORS 0, 16777215 PIXEL
	    	@ 035, 002 MSPANEL oPanelGen PROMPT cTitulo SIZE 345, 015 OF oDlgGen COLORS 0, 14215660 CENTERED RAISED
	    	oGetDGen := MsNewGetDados():New(060,002,172,347,GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue()", , "",,,,,,,oDlgGen,aHeadG,aColsG)
	    	oGetDGen:lNewLine := .F.
			oGetDGen:SetArray(aColsG)
		 	oGetDGen:oBrowse:Refresh()
	  	ACTIVATE MSDIALOG oDlgGen ON INIT EnchoiceBar(oDlgGen,{||Confirma(cTab, cCpoRet, @xRet, aHeadG, aColsG)},{||oDlgGen:End()},,aButtons) CENTERED
	Else
		//Mensagem de Log
		If !(Empty(cMsg))
			Aviso('Log de Processamento', cMsg, {'OK'}, 03)
		EndIf
	EndIf

	RestArea(aArea) //Restaurando a Area
Return xRet

Static Function Confirma(cTab, cCpoRet, xRet, aHeadG, aColsG)
	Local nPosRet := GDFieldPos(cCpoRet, aHeadG) //Posição do Campo Retorno no Array
	Local nLinAt  := oGetDGen:nAt //Linha Atual

	//Caso a Linha Atual esteja zerada, considerar sempre a primeira
	If (nLinAt < 1)
		nLinAt := 1
	EndIf

	//Atribuindo retorno
	xRet := oGetDGen:aCols[nLinAt, nPosRet]

	//Fechando o Dialog
	oDlgGen:End()
Return

/*/{Protheus.doc} GetTipoPrd
Retorna o Tipo do Produto de Acordo com o Grupo
@type function
@author Alison
@since 22/12/2016
@version 1.0
@param IdXML, character, ID do XML
@param G_CFOP, character, CFOP
@return cTpPrd, Tipo do Produto
/*/
User Function GetTipoPrd(IdXML, G_CFOP)
	Local cTpPrd := 'ME' //Tipo do Produto

	//Verificando a Empresa
	Do Case
		Case AllTrim(cEmpAnt) == '02' //Grupo 02
			//Verificando o Tipo de Nota Fiscal
			Do Case
				Case AllTrim(IdXML) == "NFE" //DOC. ENTRADA (EMISSÃO PROPRIA DE IMPORTAÇÃO)
					//Verificando o CFOP
					Do Case
						Case AllTrim(G_CFOP) == "3102"
							cTpPrd := "ME" //Definindo o Tipo
						Case AllTrim(G_CFOP) == "3551"
							cTpPrd := "AI" //Definindo o Tipo
						Case AllTrim(G_CFOP) == "3556"
							cTpPrd := "MC" //Definindo o Tipo
					EndCase
				Case AllTrim(IdXML) == "NFS" //DOC. SAÍDA   (EMISSÃO PROPRIA)
					Do Case
						//Verificando o CFOP
						Case SubStr(AllTrim(G_CFOP), 02, 03) $ "5551"
							cTpPrd := "AI" //Definindo o Tipo
					EndCase
			EndCase
		Case AllTrim(cEmpAnt) == '03' //Grupo 03
			//Verificando o Tipo de Nota Fiscal
			Do Case
				Case AllTrim(IdXML) == "NFE" //DOC. ENTRADA (EMISSÃO PROPRIA DE IMPORTAÇÃO)
					//Verificando o CFOP
					Do Case
						Case AllTrim(G_CFOP) == "3101"
							cTpPrd := "MP" //Definindo o Tipo
						Case AllTrim(G_CFOP) == "3102"
							cTpPrd := "ME" //Definindo o Tipo
						Case AllTrim(G_CFOP) == "3551"
							cTpPrd := "AI" //Definindo o Tipo
						Case AllTrim(G_CFOP) == "3556"
							cTpPrd := "MC" //Definindo o Tipo
					EndCase
				Case AllTrim(IdXML) == "NFS" //DOC. SAÍDA   (EMISSÃO PROPRIA)
					Do Case
						//Verificando o CFOP
						Case "5" + SubStr(AllTrim(G_CFOP), 02, 03) $ "5551"
							cTpPrd := "AI" //Definindo o Tipo
						Case "5" + SubStr(AllTrim(G_CFOP), 02, 03) $ "5101|5105|5109|5111|5113|5116|5118|5122|5401"
							cTpPrd := "PA" //Definindo o Tipo
						Case AllTrim(G_CFOP) == "6107"
							cTpPrd := "PA" //Definindo o Tipo
					EndCase
			EndCase
	EndCase
Return cTpPrd

/*/{Protheus.doc} u_fNoAcento
Remove acentuação e caracteres especiais
@type function
@author Alison
@since 23/12/2016
@version 1.0
@param cTXT, character, Texto
@return cTXTFmt, Texto Formatado
@example
(examples)
@see (links_or_references)
/*/
Static Function fNoAcento(cTXT)
	Local cTXTFmt := '' //Texto Formatado
	Local aChars  := {"/", ".", "\", "-"} //Caracteres que serão substituidas
	Local nI      := 0 //Controle do FOR

	cTXTFmt := NoAcento(AnsiToOem(cTXT)) //Retirada de Acentos

	//Percorrendo o Array e Substituindo
	For nI := 1 To Len(aChars)
		cTXTFmt := StrTran(cTXTFmt, aChars[nI], "")
	Next nI
Return cTXTFmt

User Function AddConhec(cObj,cDescri,cEntidade)
Local lRet       := .F.
Local aEntidade  := {}
Local nPos       := 0
Local cUnico     := ''
Local cCodEnt    := ''
Local aChave     := {}
Local aRecno     := {}
Local nSaveSX8   := 0
Local cDirDocs   := ''
Local cFile      := ''
Local cExtensao  := ''
Local aArea      := GetArea()
Local aAreaAC9   := AC9->(GetArea())
Local aAreaSX2   := SX2->(GetArea())
Local aAreaACC   := ACC->(GetArea())

//-- Variaveis especificas utilizadas nas
//-- funcoes de manipulacao do Banco de Conhecimento:
Private aHeader   := {}
Private aCols     := {}
Private Inclui    := If(ValType('Inclui')=='L',Inclui,.T.)
Private cCadastro := 'Conhecimento'
Private lFilACols := .F.

//-- Estabelece o relacionamento da tabela principal
//-- com o banco de conhecimento:
aEntidade := AC9->(MsRelation())
nPos      := AScan(aEntidade, {|x| x[1] == cEntidade})

If nPos <> 0 .Or. (SX2->(DbSeek(cEntidade)) .And. !Empty(SX2->X2_UNICO))
	If nPos == 0 //--Localiza a chave unica pelo SX2
		//--Macro executa a chave unica
		cUnico    := SX2->X2_UNICO
		cCodEnt   := &cUnico
	Else
		aChave    := aEntidade[nPos, 2]
		cCodEnt   := MaBuildKey(cEntidade, aChave)
	EndIf

	//-- Prepara inclusao no banco de conhecimento:
	ACC->(FillGetDados(3, 'ACC', 1,,,,,,,,, .T., aHeader, aCols))

	//-- Transfere o arquivo p/ diretorio do banco de conhecimento:
	SplitPath(cObj,,, @cFile, @cExtensao)
	cDirDocs := AllTrim(If(FindFunction('MsMultDir') .And. MsMultDir(), MsRetPath(cFile+cExtensao), MsDocPath()))
	cDirDocs += If(Right(cDirDocs, 1) <> '\', '\', '')
	__CopyFile(cObj, cDirDocs + cFile + cExtensao)

	If File(cDirDocs + "\" + cFile + cExtensao)
		nSaveSX8      := GetSX8Len()
		M->ACB_CODOBJ := GetSXENum( "ACB", "ACB_CODOBJ" )
		M->ACB_DESCRI := cDescri
		M->ACB_OBJETO := cObj

	    //-- Realiza a gravacao do objeto
	    //-- e vincula o documento no banco de conhecimento:
		Ft340Grv(1, aRecno)

		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		EndDo

		//Verifica se o registro já existe na Base de Conhecimento
		DbSelectArea('AC9')
		AC9->(DbSetOrder(1)) //AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
		If !(AC9->(DbSeek(FWxFilial('AC9') + ACB->ACB_CODOBJ + cEntidade)))

			aHeader := {}
			aCols   := {}
			AC9->( FillGetDados(3,'AC9',1,,,,,,,,,.T.,aHeader,aCols,,,) )

			GDFieldPut( 'AC9_OBJETO', ACB->ACB_OBJETO, Len(aCols) )
			lRet := MsDocGrv( cEntidade, cCodEnt, {}, .F. )
		EndIf

	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaAC9)
RestArea(aAreaSX2)
RestArea(aAreaACC)

Return(lRet)

Static Function CriaSA7(cCliente,cLoja,cProduto,cCodEnt)
Local aArea := GetArea()

DbSelectArea("SA7")
SA7->(DbSetOrder())

Reclock("SA7",.T.)
SA7->A7_FILIAL  := xFilial("SA7")
SA7->A7_CLIENTE := cCliente
SA7->A7_LOJA    := cLoja
SA7->A7_PRODUTO := cProduto
SA7->A7_CODCLI  := cCodEnt
SA7->(MsUnlock())

RestArea( aArea )

Return Nil

/**
	Retorna Array com Pedidos de Venda Vinculados a Nota Fiscal de Saída
**/
Static Function D2Pedido(cDoc, cSerie, cCliente, cLoja)
	Local aArea    := GetArea() //Reservando a Area
	Local aPedidos := {} //Array de Pedidos de Venda
	Local cSQL     := '' //Consulta SQL

	If (Select('D2PED') > 0)
		//Fechando a Area caso aberta
		D2PED->(DbCloseArea())
	EndIf

	cSQL := "SELECT" + CHR(13) + CHR(10)
	cSQL += "D2_PEDIDO" + CHR(13) + CHR(10)
	cSQL += "FROM" + CHR(13) + CHR(10)
	cSQL += RetSQLName('SD2') + CHR(13) + CHR(10)
	cSQL += "WHERE" + CHR(13) + CHR(10)
	cSQL += "D2_FILIAL = '" + FWxFilial('SD2') + "' AND" + CHR(13) + CHR(10)
	cSQL += "D2_DOC = '" + cDoc + "' AND" + CHR(13) + CHR(10)
	cSQL += "D2_SERIE = '" + cSerie + "' AND " + CHR(13) + CHR(10)
	cSQL += "D2_CLIENTE = '" + cCliente + "' AND" + CHR(13) + CHR(10)
	cSQL += "D2_LOJA = '" + cLoja + "' AND" + CHR(13) + CHR(10)
	cSQL += "D_E_L_E_T_ = ' '" + CHR(13) + CHR(10)
	cSQL += "GROUP BY D2_PEDIDO" + CHR(13) + CHR(10)

	//Abrindo a Area
	PlsQuery(cSQL, 'D2PED')

	//Percorrendo o Array e Adicionando os Pedidos de Venda
	While !(D2PED->(EOF()))
		AAdd(aPedidos, D2PED->D2_PEDIDO)
		D2PED->(DbSkip())
	EndDo

	RestArea(aArea) //Restaurando a Area
Return aPedidos

/**
	Verifica se é CFOP para IPI Obs (campo FT_IPIOBS)
**/
Static Function fIsIPIObs(cCFOP)
	Local aArea := GetArea() //Reservando a Area
	Local aCFOP := StrTokArr(AllTrim(SuperGetMV("ES_CFIPIOB", .F., "5111;5112;5116;5117;")), ";")
	Local lRet  := .F.

	lRet := (AScan(aCFOP, {|x| AllTrim(x) == "5" + SubStr(cCFOP, 02, 03)})) > 0

	RestArea(aArea) //Restaurando a Area
Return lRet