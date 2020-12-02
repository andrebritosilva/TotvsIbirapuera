#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE "FILEIO.CH"
#INCLUDE "apwizard.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE I_ITEM		1
#DEFINE I_PROD		2
#DEFINE I_BASIPI	3
#DEFINE I_VLRIPI	4
#DEFINE I_PIPI		5
#DEFINE I_BASICM	6
#DEFINE I_VLRICM	7
#DEFINE I_PICM		8
#DEFINE I_PCOF		9
#DEFINE I_VLRCOF	10
#DEFINE I_BASCOF	11
#DEFINE I_PERPIS	12
#DEFINE I_VLRPIS	13
#DEFINE I_BASPIS	14
#DEFINE I_PII		15
#DEFINE I_VLRII		16
#DEFINE I_VLRFRETE	17
#DEFINE I_VLRSEGUR	18
#DEFINE I_VLRDESPE	19
#DEFINE I_NRDI		20
#DEFINE I_DOCIMP	21
#DEFINE I_DTDI		22
#DEFINE I_LOCDES	23
#DEFINE I_UFDES		24
#DEFINE I_DTDES		25
#DEFINE I_NADIC	    26
#DEFINE I_NADICSEQ  27
#DEFINE I_BASSII	28
#DEFINE I_AFRMM 	29

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ TIBI   บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Tela de importacao da planilha de despachante              ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User FUnction TIBNFI()
	Local aSay := {}
	Local aButton := {}
	Local lOk := .F.
	
	aAdd( aSay, "Este processo efetua a importa็ใo da planilha de Despachante da Matriz." )

	// Botoes Tela Inicial
	aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
	aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

	FormBatch(  "Importa็ใo da Planilha de Despachante",  aSay,  aButton )

	if lOk
		Processa (	{|| ImpDespachante() } )
	endif

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ TIBJNFI   บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ JOB de importacao da planilha de Despachante             ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


[ONSTART]
Jobs=TIBJNFI
RefreshRate=60


[TIBJPRD]
MAIN=U_TIBJNFI
ENVIRONMENT=OFICIAL
nPARMS=2
PARM1=99
PARM2=01
*/
User FUnction TIBJNFI(aParam)

	ConOut('Inicializando ambiente - processo JOB importa็ใo de despachante...')
	RpcSetType(3)
	RpcSetEnv(aParam[1], aParam[2])

	ImpDespachante()

	RpcClearEnv()
	ConOut('Finalizando processo JOB importa็ใo de despachante...')

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ImpDespachante   บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Processo de importacao da planilha de produtos             ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpDespachante()

	Local lPrimLinha 		:= 	.T. //primeira linha de cabecalho sera ignorada
	Local lHouveErro 		:= 	.F.
	Local cMsgMail 			:= 	''
	Local cStr 				:= 	dtos(dDatabase)
	Local cDtFrmt 			:=  ''
	Local aTmpWrk 			:= 	{}
	Local nCount 			:= 	0
	Local lInserir 			:= 	.F.
	Local aRename			:=	{}
	Local __cProd			:=	''
	Local cCodInvoic 		:= 	" " //Alltrim(aLstRegs[3])
	Local nConta := 0
	LOcal nMax := 0
	Local cAux := ''
	Local nx	:= 0
	Local ny	:= 0
	Local nn	:= 0
	Local __nDI				:=	'', __DtDI := Ctod("  /  /  "), __xLocDesemb	:=	'', __UFDesemb		:=	''
	Local oDlg				:= Nil
	Local oButton1
	Local oButton2
	Local oGet1
	Local oGet2
	Local oSay1
	Local oSay2
	Local oSay3
	Local cItem				:= StrZero(0,TamSX3("D1_ITEM")[1])
	Local aParam := {}
	Local aMvPar := {}
	Local nMv
	
	Private nCapatazia 		:= 0
	Private nSiscomex 		:= 0
	Private nGet1			:= 0
	Private nGet2			:= 0
	Private __nValTot		:= 0
	Private	__nTotAFRMM		:= 0
	Private __DtDesemb		:=	Ctod(  "  /  /  " )   , __TpViaTransp 	:=	'', __cCodExp	:=	''
	Private __nAFRMM        := 0
	Private __TpInterm      := "1"
	Private __BCCOF			:=	0 , 	__PCOF	:=	0 , __VLCOF		:=	0 , __MontaInvoice	:=	'', __nInvoice	:= 0
	Private 	__cUF			:=	'', __NatOp		:=	'', __Serie		:=	'', __nNF			:=	'',	_dtEmiss 	:= ctod('')
	Private __CodMun			:= '' ,	__RazSoc	:=	'', __IE		:=	'', 	_xCnpj		:=	'', _xCPF		:= '',	__cProdAnt	:=	''
	Private _xFullEnd			:=	'', _cBairro	:=	'', _xCodMun	:=	'', _xCodPais		:=	'',__vSegIT		:=	0, 	__vDescIT	:=	0
	Private _NomeEx			:= '' , _Endex1		:=	'',	_EndEx2		:=	'', __NumIt			:=  '', __VLCOF		:=	0, 	__vOutroIT	:=  0
	Private __cProd			:=	'', __Codbar	:=	'',	__DescProd	:=	'', _HoraEmi	:= '', _dtEnt		:= ctod('')
	Private __NCM				:=	'', __CFOP		:=	'', __QCom		:=	0 , __vUnCom		:=	0 , __vTotProd	:=	0, 	__vFreteIt	:=	0
	Private __OrigMerc		:=	'', __TribICMS	:=	'', __ModBC		:=	'', __BCICMS		:=	0 , __AliqICM	:=	0, 	__ValICM	:=	0
	Private __CSTIPI			:=	'', __ValIPI	:=	0 ,	__vBCIPI	:=	0 ,	__AliqIPI		:=	0 , __BCCOF		:=	0, 	__PCOF		:=	0
	Private __BCII			:=	0 , __DespAdu	:=	0 , __VLII_IT	:=	0 ,	__BCPIS			:=	0 , __PPIS		:=	0, 	__VLPIS		:=	0
	Private aLinha 			:= 	{}
	Private cPrefPadrao 	:= GetMV("ES_PREFP" ,, '333' )
	Private cFornPadrao 	:= GetMV("ES_FORNP" ,, '000000'    )
	Private nBloqueio       := 2 //Bloqueio de Movimento Padrao = Nao
	Private cLojPadrao  	:= GetMV("ES_LOJP"  ,, '00'    )
	Private cTESPadrao  	:= ""
	Private cAdicPadrao 	:= GetMV("ES_ADICAO",, '001' )
	Private cLocalPadrao	:= GetMV("ES_ILOCAL",, '01'  )
	Private cMoedaPadrao	:= "01"//GetMV("ES_MOEDA" ,, '01'  )
	Private cEspeciePadrao 	:= GetMV("ES_SPEC"  ,, 'SPED')
	Private cPgtoPadrao 	:= GetMV("ES_PGTO"  ,, '001' )
	Private	cCamArq			:= ""
	Private cPathFTP 	 	:= ''//GetMV("ES_FTPNF",,'')///pedidoweb/telecontrol-hitachi/homolog2/
	Private cMsgErr 		:= '', aLstRegs := {}, aLstErros := {}, __aLst1	:=	{}
	Private cId 			:= '', cUltSeq := ''
	Private lNovoLote 		:= .F., nLinha := 0
	Private cSeparador 		:= "|"
	Private	__separa		:=	";"
	Private cLotNovos 		:= ''
	Private lSimJOB 		:= .F.
	Private nBase 			:= 0, nDespesa:= 0, nSeguro := 0, nFrete := 0
	Private nTotPIS 		:= 0, nTotCofins := 0, nTotII := 0, nTotICMS := 0, nTotIPI := 0, nTotPeso := 0
	Private nTotPBruto      := 0
	Private cEspecieTransp  := ""
	Private nModFrete       := 0
	Private nVolume1Transp  := 0
	Private cCGCTrans		:= ""
	Private	__DespAdu		:=	0
	Private nUsoMoeda 		:= 0, nUsoTxMoeda := 0
	Private cPastaSystem 	:= GetMV("ES_NFSYS",, '')//nesta pasta teremos \SYSTEM\INTMATRIZ\DESPACHANTE\ //INTNFI pasta abaixo do system para carregar os logs
	Private aCaseSensitiveFile := {}
	Private cNfGerada 		:= ''
	Private aItens 			:= {}
	Private aRegsArquivo 	:= {}
	Private __ImposIT		:= {}
	Private __NomArq		:= ''
	Private __Naolido		:=	"C:\ImportacaoNFI\Despachante\NaoLido"
	Private __Processado	:=	"C:\ImportacaoNFI\Despachante\Processados"
	Private	__Logs			:=	"C:\ImportacaoNFI\Despachante\Logs"
	Private cAdicaoNum 		:= ""
	Private cAdicaoSeq  	:= ""
	Private __cCNPJAdq      := ""
	Private __cUFAdq        := ""
	Private cMenNota		:= ""
	
	Private cMarca			:= ""
	Private cNumeracao		:= ""
	
	
	if (onStack("U_TIBJNFI"))//se nใo for JOB
		lSimJOB := .T.
	endif

	if !lSimJOB
		ProcRegua(0)
		IncProc("Lendo o arquivo ...")
	Else
		ConOut("Lendo Arquivo, WFLNFI...")
	endif

	//Senao for por JOBA
	If !lSimJOB
		
		//Backup do Parametro
		//Salva parametros originais		
		For nMv := 1 To 40
			aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
		Next nMv
		

		//Adiciona parametros para escolher o fornecedor e bloqueio de movimento
		aAdd( aParam,  { 1 , 'Fornecedor' , CriaVar('A2_COD',.F.) , PesqPict('SA2','A2_COD') , ,'SA2',,60,.T.})
		aAdd( aParam,  { 1 , 'Loja' , CriaVar('A2_LOJA',.F.) , PesqPict('SA2','A2_LOJA') , ,,,40,.T.})
		//aAdd( aParam ,{2, "Bloqueio de Movimento  " ,"1", {"1=Sim","2=Nao"}, 60,'.T.',.T.})
			
		If ParamBox(aParam,'Parโmetros')
			cFornPadrao := MV_PAR01
			cLojPadrao := MV_PAR02
			//nBloqueio := Val(cValToChar(MV_PAR03))
		Endif
		
		//Restaura parametros
		For nMv := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv
	
	Endif
	//LimpaLogsAntigos()
	//Cria as pastas caso nใo existam

	/* Defini็ใo Padrao de Diretorio

	* Logs erros e inconsitencias
	"C:\ImportacaoNFI\Despachante\Logs"

	* Arquivos ainda nใo processados
	"C:\ImportacaoNFI\Despachante\Naolido"

	* Arquivos jแ processados
	"C:\ImportacaoNFI\Despachante\Processados"

*/
	If !ExistDir("C:\ImportacaoNFI\Despachante")
		Makedir("C:\ImportacaoNFI\")
		Makedir("C:\ImportacaoNFI\Despachante\")
		Makedir("C:\ImportacaoNFI\Despachante\Processados")
		Makedir("C:\ImportacaoNFI\Despachante\NaoLido")
		Makedir("C:\ImportacaoNFI\Despachante\Logs")
	Endif

	//'C:\Temp\ImportacaoNFI\'
	if !lSimJOB
		_cCamArq	:= cGetFile( "(TXT)|*.txt|","Selecione o arquivo txt ...",,__Naolido,.T.,GETF_LOCALHARD+GETF_RETDIRECTORY+128,.T.,.T. ) //"Local para grava็ใo...
	Else
		_cCamArq	:=	__Naolido
	Endif

	if !Empty(_cCamArq)
		aRename 	:= Separa( _cCamArq, "\" )
		__NomArq	:=	aRename[Len(aRename)]
		aCaseSensitiveFile	:=	aClone(aRename)
	Else
		ConOut("Arquivo nใo informado. WFLNFI")
		Return
	Endif


  DEFINE MSDIALOG oDlg TITLE "Valores" FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL

    @ 028, 006 SAY oSay1 PROMPT "Valor Capatazia" SIZE 050, 008 OF oDlg COLORS 0, 16777215 PIXEL
    //-- @ 047, 006 SAY oSay2 PROMPT "Valor Siscomex" SIZE 050, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 073 MSGET oGet1 VAR nGet1 PICTURE "@E 999,999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    //-- @ 047, 072 MSGET oGet2 VAR nGet2 PICTURE "@E 999,999,999.99"SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 006, 080 SAY oSay3 PROMPT "Valores " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 072, 050 BUTTON oButton1 PROMPT "Ok" SIZE 037, 012 OF oDlg PIXEL
    @ 071, 094 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlg PIXEL

    oButton1:bAction	:= {|| Sair(.F.),oDlg:End(),oDlg:End()  }
	oButton2:bAction	:= {|| Sair(.T.),oDlg:End(),oDlg:End() }

  ACTIVATE MSDIALOG oDlg CENTERED


	if !lSimJOB
		IncProc("Lendo arquivos...")
	Else
		ConOut("Lendo Arquivos...")
	endif

	nHandle	:=	FT_FUse( _cCamArq )//Abre o Arquivo
	if nHandle = -1
		return
	endif
	FT_FGoTop()

	nLast := FT_FLastRec()

	aLstRegs 	:= 	{}
	nLinha		:= 	0
	aLstErros 	:= 	{}
	lNovoLote 	:= 	.F.
	cUltSeq 	:= 	''
	aLinha 		:= 	{}
	aItens 		:= 	{}
	__aItem		:=	{}
	__aCab		:=	{}
	aRegsArquivo:= 	{}
	nBase 		:= 	0
	nDespesa 	:=	0
	nSeguro 	:= 	0
	nFrete 		:= 	0
	cMsgErr 	:= 	''
	lInserir 	:= 	.T.
	cNfGerada 	:= 	''
	__cId		:=	''
	cOldNf 		:= ''
	cOldSerie 	:= ''
	cOldFornec 	:= ''
	cOldLoja 	:= ''
	nOldSeqa 	:= 0
	cChaveOldNf := ''
	lPrimLinha 	:= .T.
	nBase    	:= 0
	nSeguro  	:= 0
	nFrete   	:= 0
	nTotPIS   	:= 0
	nTotCofins	:= 0
	nTotII    	:= 0
	nTotICMS  	:= 0
	nTotIPI   	:= 0
	nTotPeso   	:= 0


	While !FT_FEof()
			
		nCount++
		
		__cProdAnt  := ""
		cBuffer		:= 	Alltrim(FT_FReadLn()) //Faz leitura da linha total
		aLstRegs 	:=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador ) // faz leitura da linha separando o array pelos pipes

		if !empty( aLstRegs)
			if Empty(aLstRegs[1])
				exit
			endif
		Endif

		If !Empty(aLstRegs)
			if nCount	== 1
				if !lSimJOB
					if  !(aLstRegs[2]) == "1" //Verifica a quantidade de NFS dentro do Arquivo
						Alert("Arquivo com mais de uma Nota Fiscal!"+CRLF+"Por favor ajuste o formato de importa็ใo para 1 Nota Fiscal por arquivo...")
						Return
					Endif
				Else
					if  !(aLstRegs[2]) == "1" //Verifica a quantidade de NFS dentro do Arquivo
						ConOut("Arquivo com mais de uma Nota Fiscal!"+CRLF+"Por favor ajuste o formato de importa็ใo para 1 Nota Fiscal por arquivo...")
						Return
					Endif
				Endif
			Endif

			if !lSimJOB
				if (aLstRegs[1]) == "A" //Versao Nf-e ID
					if (aLstRegs[2]) <> "3.10" // Programa desenvolvido para versใo 3.10, caso seja diferente sai do processamento
						Alert(UPPER("Versใo nใo Homologada!")+CRLF+UPPER("Importa็ใo desenvolvida apenas para o layout 3.10 da Nf-e, favor verificar!")+CRLF+"O SISTEMA ABANDONARม O PROCESSAMENTO.")
						Return
					Endif
					if !Empty(aLstRegs[3])
						__cId	:=	aLstRegs[3]
					Endif
					FT_FSkip()
					Loop
				Else
					if (aLstRegs[1]) == "A" //Versao Nf-e ID
						if (aLstRegs[2]) <> "3.10" // Programa desenvolvido para versใo 3.10, caso seja diferente sai do processamento
							ConOut(UPPER("Versใo nใo Homologada!")+CRLF+UPPER("Importa็ใo desenvolvida apenas para o layout 3.10 da Nf-e, favor verificar!")+CRLF+"O SISTEMA ABANDONARม O PROCESSAMENTO.")
							Return
						Endif
						if !Empty(aLstRegs[3])
							__cId	:=	aLstRegs[3]
						Endif
					FT_FSkip()
					Loop
					Endif
				Endif

			Endif

			if (aLstRegs[1]) == "B" //Dados da NF
				__cUF		:=	aLstRegs[2] 				// Estado
				__NatOp		:=	aLstRegs[4] 				// Natureza de Operacao
				__Serie		:=	aLstRegs[7] 				// Serie NF
				__nNF		:=	StrZero(Val(aLstRegs[8]),9) // N๚mero da Nota Fiscal (convertendo para 9 digitos pois no arquivo nใo constam os numeros 0)

				if !EMpty(aLstRegs[9])
					_dtEmiss	:=	ctod(  substr(aLstRegs[9],9,2) + "/" + substr(aLstRegs[9],6,2) + "/" + substr(aLstRegs[9],1,4)     )//data da DI
					_HoraEmi	:=	Substr(aLstRegs[9],12,5)
				Else
					_dtEmiss 	:= ctod('')
					_HoraEmi	:=	''
				Endif

				if !EMpty(aLstRegs[10])
					_dtEnt	:=	ctod(  substr(aLstRegs[10],9,2) + "/" + substr(aLstRegs[10],6,2) + "/" + substr(aLstRegs[10],1,4)     )	//data de entrada DI
				Else
					_dtEnt 	:=  ctod('')
				Endif

				if !EMpty(aLstRegs[11]) //Tipo de opera็ใo
					if !lSimJOB
						if (aLstRegs[11])	== "1" //Nf Saida
							Alert("NรO ษ POSSอVEL DAR ENTRADA EM NOTA FISCAL DE SAอDA")
							Return
						Endif
					Else
						if (aLstRegs[11])	== "1" //Nf Saida
							ConOut("NรO ษ POSSอVEL DAR ENTRADA EM NOTA FISCAL DE SAอDA")
							Return
						Endif
					Endif

				Endif
				__CodMun	:= Alltrim(aLstRegs[13])
			Endif

			if (aLstRegs[1]) == "C" // Dados do Emitente (WFL)
				__RazSoc	:=	aLstRegs[2]
				__IE		:=	aLstRegs[4]
			Endif

			if (aLstRegs[1]) == "C02" // CNPJ
				_xCnpj	:=	aLstRegs[2]
			Elseif (aLstRegs[1]) == "C02a" //CPF
				_xCPF	:=	aLstRegs[2]
			Endif
			if (aLstRegs[1]) == "C05" // Dados
				_xFullEnd	:=	Alltrim(aLstRegs[2])+ ", "+Alltrim(aLstRegs[3]) + " - " + Alltrim(aLstRegs[4])//Endere็o + Numero+ Complemento
				_cBairro	:=	Alltrim(aLstRegs[5])+" - "+Alltrim(aLstRegs[7])+" / "+Alltrim(aLstRegs[8])+" - "+Alltrim(aLstRegs[9])+" - "+Alltrim(aLstRegs[11]) // Bairro/Mun/UF/CEP/Pais
				_xCodMun	:=	Alltrim(aLstRegs[6])	// Cod municipio
				_xCodPais	:=	Alltrim(aLstRegs[10]) 	//Cod Pais
			Endif

			if (aLstRegs[1]) == "E" // Dados do exportador
				if !Empty(aLstRegs[2])
					_NomeEx	:=Alltrim((aLstRegs[2]))
				Endif
			Endif

			if (aLstRegs[1]) == "E05" // Dados do exportador
				if !Empty(aLstRegs[2])
					_Endex1	:=	Alltrim((aLstRegs[2]))+ ", "+Alltrim(aLstRegs[3]) + " - " + Alltrim(aLstRegs[4])//Endere็o + Numero+ Complemento
					_EndEx2	:=	Alltrim(aLstRegs[5])+" - "+Alltrim(aLstRegs[7])+" / "+Alltrim(aLstRegs[8])+" - "+Alltrim(aLstRegs[9])+" - "+Alltrim(aLstRegs[11]) // Bairro/Mun/UF/CEP/Pais
				Endif
			Endif

			if (aLstRegs[1]) == "H" // Numero do Item

				if !Empty((aLstRegs[2]))
					__NumIt	:=	StrZero(Val(aLstRegs[2]),4)
				Endif
				
				cItem		:= Soma1(cItem)
				__NumIt		:= cItem
								
				aAdd(aLinha,{"D1_ITEM"  	,__NumIt 			 ,Nil})
				nLinha += 1

				aAdd( __ImposIT , Array(29) )

				__ImposIT[Len(__ImposIT)][I_ITEM]	:= __NumIt

			Endif

			if (aLstRegs[1]) == "I" // Produtos e Servi็os

				if !Empty((aLstRegs[2]))

					if	!Substr(aLstRegs[2],1,4) $ "CFOP" //Se entrar nessa condi็ใo o produto nใo veio com codifica็ใo definida
						__cProd		:=	(aLstRegs[2])
					Endif
					if !Empty(aLstRegs[3])
						__Codbar	:=	(aLstRegs[3]) //Codigo de Barras
					Endif

					if Empty(__cProd) //Caso o c๓digo do Produto nใo tenha sido informado no arquivo e ainda estiver vindo como CFOP9999, assume o c๓d da descri็ใo

						For nx	:=	1 to Len(Alltrim(aLstRegs[4]))
							if !Substr(Alltrim(aLstRegs[4]),nx,1) == "-" .and. Substr(aLstRegs[4],nx,1) $ "0123456789"
								__cProd	+=	Alltrim(Substr(aLstRegs[4],nx,1))
							Endif

							if  Substr(Alltrim(aLstRegs[4]),nx,1) == "-"
								For ny	:= nx to Len(aLstRegs[4])
									nx+=1
									if Alltrim(Substr(aLstRegs[4],ny,1)) $ "ABCDEFGHIJKLMNOPQRSTUVXZWY"
										__DescProd	:=	Substr(aLstRegs[4],ny,Len(aLstRegs[4])) //Descri็ใo de Produto
										Exit
									Endif
								Next
								nx++
								__cProdAnt	:=	__cProd
								__cProd	:=	''
								Exit
							Endif
						Next Nx
					Endif
					__NCM		:=	(aLstRegs[5]) //NCM
					if !Empty(aLstRegs[7])
						__CFOP		:=	(aLstRegs[7])
					Endif
					__QCom		:=	Val(aLstRegs[9])	//Quantidade @E 99999999.99
					__vUnCom	:=	Val(aLstRegs[10])	//Valor Unitario @E 99999999.99
					__vTotProd	:=	Val(aLstRegs[11])	//Valor Total do Item
					__vFreteIt	:=	Val(aLstRegs[16])	//Valor do Frete por Item
					__vSegIT	:=	Val(aLstRegs[17])	//Valor do Seguro por Item
					__vDescIT	:=	Val(aLstRegs[18])	//Valor do Desconto por Item
					__vOutroIT	:=	Val(aLstRegs[19])	//Valor do outras Despesas por Item
					
					//nDespesa	+= __vOutroIT
					
					__ImposIT[Len(__ImposIT)][I_VLRFRETE]	:=	__vFreteIt
					__ImposIT[Len(__ImposIT)][I_VLRSEGUR]	:=	__vSegIT
					__ImposIT[Len(__ImposIT)][I_VLRDESPE]	:=	__vOutroIT

					if Empty(__vDescIT)
						__vDescIT	:=	0
					Endif
					
					/*
						Especํfico MIURA: Somat๓ria do valor unitแrio: 
					*/
					__vUnCom	+= __vFreteIt + __vSegIT	//Valor Unitario @E 99999999.99

					if EMpty(cLocalPadrao) .and. Empty(cMsgErr)
						cMsgErr := "Armaz้m  Padrใo nใo informado"
					endif

					if (__QCom) == 0 .and. Empty(cMsgErr)
						cMsgErr := "Quantidade nใo informada!"
					endif

					if (__vUnCom) == 0 .and. Empty(cMsgErr)
						cMsgErr := "Vlr.Mercadoria nใo informada!"
					endif

					if (__vUnCom) == 0 .and. Empty(cMsgErr)
						cMsgErr := "Unitแrio nใo informada!"
					endif
					
					If Empty(__cProdAnt)
						__cProdAnt	:=	__cProd
					EndIf

					if !ProdExiste(__cProdAnt) .and. Empty(cMsgErr)
						cMsgErr := "Produto [ " + Alltrim(__cProdAnt) +  "] nใo existe no sistema!"
					Else
						If Empty( SB1->B1_TE )
							cTESPadrao := GetMV("ES_TESP"  ,, '111' )
						Else
							cTESPadrao := SB1->B1_TE
						EndIf
					endif
					
					if EMpty(cTESPadrao) .and. Empty(cMsgErr)
						cMsgErr := " TES Padrใo nใo informado"
					endif			t

					aAdd(aLinha,{"D1_COD"  		,PadR( __cProdAnt, TamSX3("D1_COD")[1] ),Nil})
					aAdd(aLinha,{"D1_QUANT"  	,__QCom									,Nil})
//					aAdd(aLinha,{"D1_VUNIT"  	,__vUnCom 					 			,Nil})
//					aAdd(aLinha,{"D1_TOTAL"  	,(__vUnCom * __QCom)   					,Nil})
				//	If nBloqueio == 1
						//aAdd(aLinha,{"D1_TESACLA"    	, cTESPadrao							,Nil})
					//Else
						aAdd(aLinha,{"D1_TES"    	, cTESPadrao							,Nil})
				//	Endif
					
					aAdd(aLinha,{"D1_LOCAL"  	,cLocalPadrao							,Nil})
					If Posicione("SB1",1,xFilial("SB1")+PadR( __cProdAnt, TamSX3("D1_COD")[1] ),"B1_RASTRO") == "L"
						aAdd(aLinha,{"D1_LOTECTL"  	,"0000"									,Nil})
					EndIf
					Aadd( aLinha , {"D1_DESPESA" 	,  __vOutroIT	 , Nil } )
					
					AAdd(aItens,aLinha)  //array para inserir nota

					aLinha := Nil
					aLinha := {}

					__ImposIT[Len(__ImposIT)][I_PROD]	:=	__cProdAnt

				Endif
			Endif

			if (aLstRegs[1]) == "I18" // Dados da DI
				__nDI			:=	aLstRegs[2]
				__DtDI			:=	Ctod(  Substr(aLstRegs[3],9,2) + "/" + Substr(aLstRegs[3],6,2) + "/" + Substr(aLstRegs[3],1,4)     )//AAAA MM DD data da DI
				__xLocDesemb	:=	aLstRegs[4]
				__UFDesemb		:=	aLstRegs[5]
				__DtDesemb		:=	Ctod(  Substr(aLstRegs[6],9,2) + "/" + Substr(aLstRegs[6],6,2) + "/" + Substr(aLstRegs[6],1,4)     )//AAAA MM DD data do desembara็o
				__TpViaTransp 	:=	aLstRegs[7]//1=Marํtima;2=Fluvial;3=Lacustre;4=A้rea;5=Postal;6=Ferroviแria;7=Rodoviแria;8=Conduto / Rede Transmissใo;9=Meios Pr๓prios;10=Entrada / Saํda ficta.
				__nAFRMM        :=  Val(aLstRegs[8]) //Valor da AFRMM - Adicional ao Frete para Renova็ใo da Marinha Mercante
				__TpInterm      :=  aLstRegs[9] //1=Importa็ใo por conta pr๓pria; 2=Importa็ใo por conta e ordem; 3=Importa็ใo por encomenda;
				__cCNPJAdq      :=  aLstRegs[10] // CNPJ do Adquirente
				__cUFAdq        :=  aLstRegs[11] // UF do Adquirente
				__cCodExp		:=	aLstRegs[12] //Cod do exportador
						
				__nTotAFRMM		+= __nAFRMM 	//-- Totalizador do valor da AFRMM
				
				__ImposIT[Len(__ImposIT)][I_NRDI]	:= __nDI
				__ImposIT[Len(__ImposIT)][I_DTDI]	:= __DtDI
				__ImposIT[Len(__ImposIT)][I_LOCDES]	:= __xLocDesemb
				__ImposIT[Len(__ImposIT)][I_UFDES]	:= __UFDesemb
				__ImposIT[Len(__ImposIT)][I_DTDES]	:= __DtDesemb
				__ImposIT[Len(__ImposIT)][I_AFRMM]	:= __nAFRMM
			Endif
			
			if (aLstRegs[1]) == "I25" // Adi็๕es
//				cAdicaoNum	:=	StrZero(Val(aLstRegs[2]),3)
//				cAdicaoSeq	:=	StrZero(Val(aLstRegs[3]),3)
				__ImposIT[Len(__ImposIT)][I_NADIC]	  := StrZero(Val(aLstRegs[2]),3)
				__ImposIT[Len(__ImposIT)][I_NADICSEQ] := StrZero(Val(aLstRegs[3]),3)
			EndIf

			if aLstRegs[1]	== "N02" // ICMS00 Grupo Tributa็ใo do ICMS= 00 / Tributada integralmente

				__OrigMerc	:=	aLstRegs[2]
				__TribICMS	:=	aLstRegs[3]
				__ModBC		:=	aLstRegs[4]
				__BCICMS	:=	Val(aLstRegs[5])
				__AliqICM	:=	Val(aLstRegs[6])
				__ValICM	:=	Val(aLstRegs[7])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N03" //ICMS10 Grupo Tributa็ใo do ICMS = 10 / Tributada e com cobran็a do ICMS por substitui็ใo tributแria

				__BCICMS	:=	Val(aLstRegs[5])
				__AliqICM	:=	Val(aLstRegs[6])
				__ValICM	:=	Val(aLstRegs[7])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N04" //ICMS20 Grupo Tributa็ใo do ICMS = 20 / Tributa็ใo com redu็ใo de base de cแlculo

				__BCICMS	:=	Val(aLstRegs[6])
				__AliqICM	:=	Val(aLstRegs[7])
				__ValICM	:=	Val(aLstRegs[8])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N05" //ICMS30 Grupo Tributa็ใo do ICMS = 30 / Tributa็ใo Isenta ou nใo tributada e com cobran็a do ICMS por substitui็ใo tributแria

				__BCICMS	:=	Val(aLstRegs[7])
				__AliqICM	:=	Val(aLstRegs[8])
				__ValICM	:=	Val(aLstRegs[9])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N06" //ICMS40 Grupo Tributa็ใo ICMS = 40, 41, 50 / Tributa็ใo Isenta, Nใo tributada ou Suspensใo

				__BCICMS	:=	Val(aLstRegs[7])
				__AliqICM	:=	Val(aLstRegs[8])
				__ValICM	:=	Val(aLstRegs[9])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N07" //ICMS51 Grupo Tributa็ใo do ICMS = 51- Tributa็ใo com Diferimento (a exig๊ncia do preenchimento das informa็๕es do ICMS diferido fica a crit้rio de cada UF).

				__BCICMS	:=	Val(aLstRegs[6])
				__AliqICM	:=	Val(aLstRegs[7])
				__ValICM	:=	Val(aLstRegs[8])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N09" //ICMS70 Grupo Tributa็ใo do ICMS = 70 CG /Tributa็ใo ICMS com redu็ใo de base de cแlculo e cobran็a do ICMS por substitui็ใo tributแria

				__BCICMS	:=	Val(aLstRegs[6])
				__AliqICM	:=	Val(aLstRegs[7])
				__ValICM	:=	Val(aLstRegs[8])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N10" //ICMS70 Grupo Tributa็ใo do ICMS = 70 CG /Tributa็ใo ICMS com redu็ใo de base de cแlculo e cobran็a do ICMS por substitui็ใo tributแria

				__BCICMS	:=	Val(aLstRegs[6])
				__AliqICM	:=	Val(aLstRegs[8])
				__ValICM	:=	Val(aLstRegs[9])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N10a" //ICMSPart Grupo de Partilha do ICMS entre a UF de origem e UF de destino ou a UF definida na legisla็ใo.
				//Opera็ใo interestadual para consumidor final com partilha do ICMS devido na opera็ใo entre a UF de origem e a do destinatแrio,
				//ou a UF definida na legisla็ใo. (Ex. UF da concessionแria de entrega do veํculo) (v2.0)

				__BCICMS	:=	Val(aLstRegs[5])
				__AliqICM	:=	Val(aLstRegs[7])
				__ValICM	:=	Val(aLstRegs[8])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif

			if aLstRegs[1]	== "N10h" //ICMSSN900 Grupo CRT=1 – Simples Nacional e CSOSN=900 / Tributa็ใo ICMS pelo Simples Nacional, CSOSN=900 (v2.0)

				__BCICMS	:=	Val(aLstRegs[6])
				__AliqICM	:=	Val(aLstRegs[8])
				__ValICM	:=	Val(aLstRegs[9])

				__ImposIT[Len(__ImposIT)][I_BASICM]	:=	__BCICMS
				__ImposIT[Len(__ImposIT)][I_VLRICM]	:=	__ValICM
				__ImposIT[Len(__ImposIT)][I_PICM]	:=	__AliqICM

			Endif


			If aLstRegs[1]	== "O07" //Fazer para todos os tipos de IPI
				__CSTIPI	:=	aLstRegs[2] //00=Entrada com recupera็ใo de cr้dito; 49=Outras entradas; 50=Saํda tributada; 99=Outra Saํdas
				__ValIPI	:=	Val(aLstRegs[3]) //Valor do IPI
				__ImposIT[Len(__ImposIT)][I_VLRIPI]	:=	__ValIPI
			Endif


			If aLstRegs[1] == "O10"
//				if !Empty(__CSTIPI) .and. !Empty(__ValIPI)
//				If !Empty(__ValIPI)
				__vBCIPI	:=	Val(aLstRegs[2]) 	//Base de calculo do IPI
				__AliqIPI	:=	Val(aLstRegs[3])	//Percentual da Aliquota de IPI
				__ImposIT[Len(__ImposIT)][I_BASIPI]	:=	__vBCIPI
				__ImposIT[Len(__ImposIT)][I_PIPI]	:=	__AliqIPI
//				Endif
			Endif

			//------------------------------------------------------------------------------------------------------------------------------------------------------------
			//                   TIPOS DE SITUAวรO DO IPI SEM INCIDENCIA NESTE CASO ZERAMOS OS VALORES
			//01=Entrada tributada com alํquota zero;02=Entrada isenta;03=Entrada nใo-tributada;04=Entrada imune;05=Entrada com suspensใo;
			//51=Saํda tributada com alํquota zero; 52=Saํda isenta; 53=Saํda nใo-tributada; 54=Saํda imune; 55=Saํda com suspensใo;
			//------------------------------------------------------------------------------------------------------------------------------------------------------------

			if aLstRegs[1]	== "O08"

				_CSTIPI	:=	aLstRegs[2]	//Apenas para opera็๕es onde nใo hแ incidencia de IPI
				__vBCIPI	:=	0		//Base de calculo do IPI
				__AliqIPI	:=	0		//Percentual da Aliquota de IPI
				__ValIPI	:=	0		//Valor do IPI

				__ImposIT[Len(__ImposIT)][I_VLRIPI]	:=	__ValIPI
				__ImposIT[Len(__ImposIT)][I_BASIPI]	:=	__vBCIPI
				__ImposIT[Len(__ImposIT)][I_PIPI]	:=	__AliqIPI

			Endif

			if aLstRegs[1]	== "P" //Imposto de Impota็ใo (II) por Item
				__BCII		:=	Val(aLstRegs[2])
				__DespAdu	:=	Val(aLstRegs[3])
				__VLII_IT	:=	Val(aLstRegs[4])
				
				//-- ESPECอFICO MIURA
				//__vUnCom :=  ( __BCII + __VLII_IT) / __QCom //-- Substitui o valor pela Base + valor de imposto
				
				aAdd(aItens[Len(aItens)],{"D1_VUNIT",__vUnCom 			,Nil})
				aAdd(aItens[Len(aItens)],{"D1_TOTAL",(__vUnCom * __QCom),Nil})
				
								
				__ImposIT[Len(__ImposIT)][I_VLRII]	  :=	__VLII_IT
				__ImposIT[Len(__ImposIT)][I_BASSII]	  :=	__BCII
				//-- __ImposIT[Len(__ImposIT)][I_VLRDESPE] +=	__DespAdu + __nAFRMM
			Endif

			if aLstRegs[1]	== "Q02" //PIS
				__BCPIS		:=	Val(aLstRegs[3])
				__PPIS		:=	Val(aLstRegs[4])
				__VLPIS		:=	Val(aLstRegs[5])

				__ImposIT[Len(__ImposIT)][I_BASPIS]	:=	__BCPIS
				__ImposIT[Len(__ImposIT)][I_PERPIS]	:=	__PPIS
				__ImposIT[Len(__ImposIT)][I_VLRPIS]	:=	__VLPIS
			Endif

			if aLstRegs[1]	== "Q02" //PIS
				__BCPIS		:=	Val(aLstRegs[3])
				__PPIS		:=	Val(aLstRegs[4])
				__VLPIS		:=	Val(aLstRegs[5])

				__ImposIT[Len(__ImposIT)][I_BASPIS]	:=	__BCPIS
				__ImposIT[Len(__ImposIT)][I_PERPIS]	:=	__PPIS
				__ImposIT[Len(__ImposIT)][I_VLRPIS]	:=	__VLPIS
			Endif

			if aLstRegs[1]	== "Q05" //PIS
				__BCPIS		:=	Val(aLstRegs[4])
				__PPIS		:=	Val(aLstRegs[5])
				__VLPIS		:=	Val(aLstRegs[9])

				__ImposIT[Len(__ImposIT)][I_BASPIS]	:=	__BCPIS
				__ImposIT[Len(__ImposIT)][I_PERPIS]	:=	__PPIS
				__ImposIT[Len(__ImposIT)][I_VLRPIS]	:=	__VLPIS
			Endif

			if aLstRegs[1]	== "S02" //COFINS
				__BCCOF		:=	Val(aLstRegs[3])
				__PCOF		:=	Val(aLstRegs[4])
				__VLCOF		:=	Val(aLstRegs[5])

				__ImposIT[Len(__ImposIT)][I_BASCOF]	:=	__BCCOF
				__ImposIT[Len(__ImposIT)][I_PCOF]	:=	__PCOF
				__ImposIT[Len(__ImposIT)][I_VLRCOF]	:=	__VLCOF
			Endif

			if aLstRegs[1]	== "S05" //COFINS
				__BCCOF		:=	Val(aLstRegs[4])
				__PCOF		:=	Val(aLstRegs[5])
				__VLCOF		:=	Val(aLstRegs[9])

				__ImposIT[Len(__ImposIT)][I_BASCOF]	:=	__BCCOF
				__ImposIT[Len(__ImposIT)][I_PCOF]	:=	__PCOF
				__ImposIT[Len(__ImposIT)][I_VLRCOF]	:=	__VLCOF
			Endif


			if aLstRegs[1]	== "W02" //IMPOSTOS POR TOTAL
				Acumulados() //Fun็ใo para recuperar impostos Grupo W - Impostos por total da nota
			Endif
			
			if aLstRegs[1]	== "X"
				nModFrete := Val(aLstRegs[2])
			EndIf
			
			If aLstRegs[1] == "X04"
				cCGCTrans	:= aLstRegs[2]
			EndIf
			
			If aLstRegs[1] == "X05"
				cCGCTrans	:= aLstRegs[2]
			EndIf
			
			if aLstRegs[1]	== "X26"
				nVolume1Transp  :=	Val(aLstRegs[2])
				cEspecieTransp  :=	aLstRegs[3]
				nTotPeso		:=	Val(aLstRegs[6])
				nTotPBruto      :=	Val(aLstRegs[7])
				cMarca			:= Alltrim(aLstRegs[4])  //CUSTOMIZADO B. VINICIUS
				cNumeracao		:= Alltrim(aLstRegs[5]) //CUSTOMIZADO B. VINICIUS
				
			Endif

			if aLstRegs[1]	== "Z"
				__aLst1 		:=	aClone(aLstregs)
				__MontaInvoice	:=	''
				__aLst1 		:=	Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,__Separa ) // faz leitura da linha separando o array pelos pipes

				__nInv		:=	0
				for nn	:= 	1 to Len(__aLst1)
					__MontaInvoice	:=	Substr(__aLst1[nn],1,Len(__aLst1[nn]))
					__nInv	:=	At("FAT:",(__aLst1[nn]))
					if __nInv	> 0
						__nInv	+= 4
						__nInvoice	:=	Val(Substr(Alltrim(__aLst1[nn]),__nInv,Len(__aLst1[nn])))
						Exit
					Endif
				Next
				__ImposIT[Len(__ImposIT)][I_DOCIMP]	:=	cValtoChar(__nInvoice)
				
				If Type("aLstRegs[3]") <> "U"
					cMenNota := StrTran(aLstRegs[3],"  ", " " )
				EndIf
				
			Endif
		Else
			cMsgErr	:= "Arquivo Vazio, WFLNFI." + "Verifique linhas em branco no arquivo."
			Conout("Arquivo Vazio, WFLNFI")
			Exit

		Endif

		cMsgErr := ''

		if !Empty(__nInvoice) // Grava invoice apenas para o ultimo registros pois nใo vem por item
			for nCount := 1 to Len(__ImposIT) // tratamento para gravar a todos os itens
				if Empty(__ImposIT[nCount][I_DOCIMP]) //INVOICE
					__ImposIT[nCount][I_DOCIMP]	:= cValtoChar(__nInvoice)
				Endif
			Next
		Endif

		if Empty(cMsgErr)
			if !lSimJOB
				IncProc("Verificando Itens da Nota ...") // + AllTrim(aCaseSensitiveFile[nCount][1]))
			endif
		endif

		aadd( aRegsArquivo , aClone(aLstRegs) )//array para update da SD1

		if !lSimJOB
			IncProc("Verificando Itens da Nota ... ") //+Alltrim(aCaseSensitiveFile[nCount][1]) )
		endif

		FT_FSkip()
	End

	FT_FUse()

	if Empty(cPrefPadrao)
		cMsgErr := "S้rie Padrใo nใo informada!"
	endif

	if EMpty(cFornPadrao) .and. Empty(cMsgErr)
		cMsgErr := "Fornecedor Padrใo nใo informado"
	endif

	if Empty(cLojPadrao) .and. Empty(cMsgErr)
		cMsgErr := "Loja do Fornecedor  Padrใo nใo informado"
	endif

	if EMpty(__nDI) .and. Empty(cMsgErr)
		cMsgErr := "N๚mero da DI nใo informada!"
	endif

	if EMpty(__DtDI) .and. Empty(cMsgErr)
		cMsgErr := "Data da DI nใo informada!"
	endif

	if EMpty(__DtDesemb) .and. Empty(cMsgErr)
		cMsgErr := "Data desembara็o nใo informada!"
	endif


	if Empty(__UFDesemb) .and. Empty(cMsgErr)
		cMsgErr := "Estado(UF) nใo informado !"
	endif

	if Empty(__xLocDesemb) .and. Empty(cMsgErr)
		cMsgErr := "Cidade nใo informada !"
	endif

	/*if (__nInvoice)==0 .and. Empty(cMsgErr)
		cMsgErr := "N๚mero da Invoice nใo informado !"
	endif*/

	if !Empty(cMsgErr)
		lInserir := .F.
		lHouveErro := .T.
		LogErro(__Logs+"\"+"Erro_"+__NomArq)  //(cPath +"\"+ __NomArq)
	Endif


	if lInserir
		if nLinha > 9999
			cMsgErr := "Sistema nแo aceita Notas com mais de 9999 itens !"
			lHouveErro := .T.
			LogErro(__Logs+"\"+"Erro_"+__NomArq)
		else
			if !lSimJOB
				IncProc("Inserindo\Atualizando a Nota Fiscal... ")// Alltrim(aCaseSensitiveFile[nCount][1]) )
			endif
			if FOrnecEX()
				DocNOVO()
			else
				lHouveErro := .T.
			endif

			if !Empty(cMsgErr)
				lInserir := .F.
				lHouveErro := .T.
				LogErro(__Logs+"\"+"Erro_"+__NomArq)//<-- o log nasce no diretorio indica do PC do usuario
			endif
		endif
	endif


	if Len(aCaseSensitiveFile) > 0
		ArqRenomeia(__Naolido+"\"+__NomArq,__Processado)
	Endif

	aLinha 			:= NIL
	aLinha 			:= {}
	aItens 			:= Nil
	aItens 			:= {}
	aRegsArquivo 	:= Nil
	aRegsArquivo 	:= {}


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ProdExiste() บ Autor ณ TOTVS Protheus บ Data ณ  1/12/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ confere se ja existe SB1                                   ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProdExiste(cCod)
	Local lRet := .F.

	dbselectarea('SB1')
	dbsetorder(1)
	SB1->(dbseek(xfilial('SB1')+ cCod ) )

	if SB1->(!Eof())
		lRet := .T.
	endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ UpdProd() บ Autor ณ TOTVS Protheus บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ atualiza SB1                                         ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function UpdProd(cCod, nICMS, nIPI)


	dbselectarea('SB1')
	dbsetorder(1)
	SB1->(dbseek(xfilial('SB1')+ cCod ) )

	if SB1->(!Eof())
		Reclock('SB1',.F.)

		if (nICMS) <> 0   .and. nICMS <> 18/*defini็ใo Daniel(parceiro)*/
			SB1->B1_PICM :=  nICMS
		endif

		if (nIPI) <> 0
			SB1->B1_IPI :=  nIPI
		endif

		MsUnLock()
	endif

Return
//=====================================================


//-----------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ LogErro  บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Inconsist๊ncias de Erros                                     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LogErro(cNome)
	Local cFIleOpen := cNome
	Local nHandleCr := 0


	cFIleOpen := strtran (cFIleOpen,".TXT","_ERROS.TXT",1,1)
	nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )

	if nHandleCr  == -1
		nHandleCr := FCreate(cFileOpen)//esta fun็ใo cria o arquivo automaticamente sempre no protheus_data\system
	else
		fseek(nHandleCr, 0, FS_END)
	EndIf


	FWrite(nHandleCr,  AllTrim(STR(nLinha)) + cSeparador + cMsgErr + Chr(13) + CHr(10))

	FClose(nHandleCr)
Return

Static function LimpaLogsAntigos()
	LOCAL cSystemPasta := GetMV("ES_NFSYS",, '')
	Local cystemc      := cSystemPasta   + "ERROS\"
	Local nCOunt       := 1
	Local aLstArqs     := {}


	cSystemPasta += "ERROS\*.csv"

	aLstArqs := directory(cSystemPasta)//por defini็ใo, sempre limpar todo o diret๓rio e re-gerar boletos.

	for nCount := 1 to Len(aLstArqs)
		ferase(cystemc +  aLstArqs[nCount][1] )
	Next

	sleep(10)//protheus se perde e passa para a proxima instru็ใo mesmo antes que o windows tenha terminado de excluir os arquivos
return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ InsereNf บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Inserir a nota fiscal                                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function InsereNf (cSerie, cFornec, cLoja, cEspecie, cCond, cNomeCSV)
	Local cProxNum 			:= NxtSX5Nota(cSerie,, GetNewPar("MV_TPNRNFS","1"))//Posicione("SX5",1,xFilial("SX5")+"01"+cSerie,"X5_DESCRI")
	Local nContador 		:= 1
	Local aCabec 			:= {}
	Local cArqErrAuto     	:= ''
	Local cErrAuto 			:= ''
	Local nCOunt 			:= 1
	Local aImpostos         := __ImposIT
	Local nX				:= 0
	Local nPos				:= 0
	PRIVATE lMsErroAuto 	:= .F.
	
//	cProxNum := Soma1(cProxNum)
	//Pergunte("MTA103",.F.)
	
	//MV_PAR17 := nBloqueio
	
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	if SF1->(dbSeek(xFilial("SF1")+cProxNum+cSerie+PadR( cFornec, TamSX3("A2_COD")[1] )+PadR( cLoja, TamSX3("A2_LOJA")[1] )))
		if !lSimJOB		
			Msginfo("N๚mero de NF jแ utilizada")
			Return
		Else
			ConOut("N๚mero de NF jแ utilizada, WFLNFI")
			Return
		Endif	
	Endif

	aAdd(aCabec,{"F1_TIPO"    ,	"N"   			  						 ,Nil})
	aAdd(aCabec,{"F1_FORMUL"  ,	"S"      								 ,Nil})
	aAdd(aCabec,{"F1_DOC"     ,	cProxNum								 ,Nil})
	aAdd(aCabec,{"F1_SERIE"   ,	cSerie      							 ,Nil})
	aAdd(aCabec,{"F1_EMISSAO" ,	dDataBase      							 ,Nil})
	aAdd(aCabec,{"F1_FORNECE" , PadR( cFornec, TamSX3("A2_COD")[1] )     ,Nil})
	aAdd(aCabec,{"F1_LOJA"    , PadR( cLoja, TamSX3("A2_LOJA")[1] )      ,Nil})
	aAdd(aCabec,{"F1_ESPECIE" ,	cEspecie								 ,Nil})
	aAdd(aCabec,{"F1_COND"    ,	cCond									 ,Nil})
	aAdd(aCabec,{"F1_DESPESA" , nDespesa								 ,Nil })
	aAdd(aCabec,{"F1_BASEICM" , nBase									 ,Nil })
	aAdd(aCabec,{"F1_VALICM"  , nTotICMS								 ,Nil })	
	If !Empty(cMenNota)
		aAdd(aCabec,{"F1_MENNOTA" , cMenNota								 ,Nil })
	EndIf
	
	aAdd(aCabec,{"F1_XMARCA"  , cMarca								 ,Nil })	
	aAdd(aCabec,{"F1_XNUMERA"  , cNumeracao 								 ,Nil })	
	
	For nCount := 1 To Len(aImpostos)
		nPos	:= aScan(aItens , {|X| AllTrim(X[2,2]) == AllTrim(aImpostos[nCount][2])  })
		If nPos > 0 
			Aadd( aItens[nPos] , {  "D1_BASEICM"   	, aImpostos[nCount][I_BASICM]	, Nil     })
			Aadd( aItens[nPos] , {  "D1_VALICM"   	, aImpostos[nCount][I_VLRICM]	, Nil     })
			Aadd( aItens[nPos] , {  "D1_PICM"   	, aImpostos[nCount][I_PICM]		, Nil     })
		EndIf
	Next nCount
	
	SetFunName("MATA103")
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3) //Inclusao

	cErrAuto    := Memoread(cArqErrAuto)
	If lMsErroAuto
		Mostraerro()
		cArqErrAuto := NomeAutoLog()
		cMsgErr     := cErrAuto
		LogErro(cPastaSystem +"\"+ __NomArq)   		//LogErro(cPath + cNomeCSV)//<-- o log nasce no diretorio indica do PC do usuario
		//Ferase(cArqErrAuto)
	ELSE
		cProxNum	:= SF1->F1_DOC
		cNfGerada := cProxNum
		
		dbselectarea('SF1')
		SF1->(dbsetorder(1))
		If SF1->( MsSeek( xfilial('SF1')+PadR(cProxNum,TamSX3("F1_DOC")[1])+PadR(cSerie,TamSX3("F1_SERIE")[1])+PadR(cFornec,TamSX3("F1_FORNECE")[1])+PadR(cLoja,TamSX3("F1_LOJA")[1])  ) )

			Update(cProxNum,cSerie, cFornec, cLoja, cEspecie, cCond,aImpostos)
			ApagaLivro( SF1->F1_FORNECE , SF1->F1_LOJA , SF1->F1_DOC , SF1->F1_SERIE )
			Reprocessar (cProxNum,cSerie, cFornec, cLoja, cEspecie, cCond, cNomeCSV)

		endif
		
		MsgInfo("O arquivo texto foi importado para o sistema com sucesso!","Importa็ใo de NFI")
		
	endif

	aCabec := Nil

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Update   บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ muda manualmente os impostos                               ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Update(cDoc,cSerie, cFornec, cLoja, cEspecie, cCond, aImpostos)

	Local cAliasSD1 := GetNextALias(), cquery := ""
	Local nPos      := 0
	local nIndex    := 0
	Local nTotal    := 0
	Local nCOunt    := 0
	Local cTipImp   := GetNewPar("ES_TIPIMP" ,"0")
	Local cLocServ  := GetNewPar("ES_LOCSERV","0")

	RecLock("SF1",.F.)

	SF1->F1_SEGURO  := nSeguro
	SF1->F1_FRETE   := nFrete
	//-- SF1->F1_DESPESA := nDespesa

	SF1->F1_BASEICM := nBase
	SF1->F1_VALICM  := nTotICMS

	SF1->F1_BASEIPI := nBase
	SF1->F1_VALIPI  := nTotIPI
	SF1->F1_PLIQUI  := nTotPeso//peso liquido
	
	If Empty(cCGCTrans)
		SF1->F1_TRANSP  := Posicione("SA2",1,xFilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA,"A2_TRANSP")
	Else
		SA4->(dbSetOrder(3))
		If SA4->(MsSeek(xFilial("SA4") + cCGCTrans ))		
			SF1->F1_TRANSP  := SA4->A4_COD
		EndIf
	EndIf
	
	SF1->F1_ESPECI1 := cEspecieTransp
	SF1->F1_PBRUTO  := nTotPBruto
	SF1->F1_VOLUME1 := nVolume1Transp
	
	If nModFrete == 0
		SF1->F1_TPFRETE := "C"
	ElseIf nModFrete == 1
		SF1->F1_TPFRETE := "F"
	ElseIf nModFrete == 2
		SF1->F1_TPFRETE := "T"
	ElseIf nModFrete == 9
		SF1->F1_TPFRETE := "S"
	EndIf

	SF1->F1_BASPIS  := nBase
	SF1->F1_VALPIS  := nTotPIS //VALOR PIS

	SF1->F1_BASCOFI := nBase
	SF1->F1_VALCOFI := nTotCofins //VALOR COFINS

	SF1->F1_II      := nTotII//VALOR IMPOSTO DE IMPORTACAO

	MsUnlock()
	
	DbSelectArea('SD1')
	SD1->(DbSetOrder())

	for nCount := 1 to Len(aImpostos)

		cquery := "SELECT SD1.R_E_C_N_O_ AS RECNOSD1 FROM " + RETSQLNAME('SD1') + " SD1 WHERE D1_FILIAL = '" + XFILIAL('SD1') + "' AND D_E_L_E_T_ <> '*' AND D1_DOC = '" + cDoc + "' "
		cquery += " AND D1_SERIE = '" + cSerie + "' AND D1_FORNECE = '" + cFOrnec + "' AND D1_LOJA = '" + cLoja + "' "
		cquery += " AND D1_ITEM = '" +  StrZero(Val(aImpostos[nCount][I_ITEM]),4) + "' AND D1_COD = '" + aImpostos[nCount][I_PROD]  + "'"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

		if (cAliasSD1)->(!Eof())
			
			SD1->(DbGoTo((cAliasSD1)->RECNOSD1))

			SD1->( RecLock("SD1",.F.) )

			//-- TRATAMENTO MIURA
			//aImpostos[nCount][I_VLRDESPE]	:= (  ( SD1->D1_TOTAL / __nValTot )  *  nSiscomex ) + aImpostos[nCount][I_AFRMM]

			
			SD1->D1_BASEIPI    := aImpostos[nCount][I_BASIPI] 	//  BASE DE IPI
			SD1->D1_VALIPI     := aImpostos[nCount][I_VLRIPI] 	//  VALOR DE IPI
			SD1->D1_IPI        := aImpostos[nCount][I_PIPI]     //  % IPI

			SD1->D1_BASEICM    := aImpostos[nCount][I_BASICM]	// BASE DO ICM
			SD1->D1_VALICM     := aImpostos[nCount][I_VLRICM]   //VALOR DO ICM
			SD1->D1_PICM       := aImpostos[nCount][I_PICM]     //% ICM
			
			SD1->D1_ALIQII     := aImpostos[nCount][I_PII]      // % ALIQUOTA DE IMPORTACAO
			SD1->D1_II         := aImpostos[nCount][I_VLRII]    // VALOR DO IMPOSTO DE IMPORTACAO

			/*SD1->D1_ALQCOF     := aImpostos[nCount][I_PCOF]     // % ALIQUOTA COF
			SD1->D1_VALCOF     := aImpostos[nCount][I_VLRCOF]   //VALOR COFINS
			SD1->D1_BASECOF    := aImpostos[nCount][I_BASCOF]   //BASE DE COFINS*/
			
			SD1->D1_BASIMP5	   := aImpostos[nCount][I_BASCOF] 
			SD1->D1_VALIMP5    := aImpostos[nCount][I_VLRCOF]
			SD1->D1_ALQIMP5    := aImpostos[nCount][I_PCOF] 

			/*SD1->D1_ALQPIS     := aImpostos[nCount][I_PERPIS]   // % ALIQUOTA PIS
			SD1->D1_VALPIS     := aImpostos[nCount][I_VLRPIS]   //VALOR PIS
			SD1->D1_BASEPIS    := aImpostos[nCount][I_BASPIS]   // BASE PIS*/
			
			SD1->D1_BASIMP6    := aImpostos[nCount][I_BASPIS]
			SD1->D1_VALIMP6    := aImpostos[nCount][I_VLRPIS]
			SD1->D1_ALQIMP6    := aImpostos[nCount][I_PERPIS] 

			//SD1->D1_VALFRE     := aImpostos[nCount][I_VLRFRETE] //VALOR DO FRETE
			//SD1->D1_SEGURO     := aImpostos[nCount][I_VLRSEGUR] //VALOR SEGURO
			//SD1->D1_DESPESA    := aImpostos[nCount][I_VLRDESPE] //VALOR DESPESA
			
			/*If Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_RASTRO") == "L"
				SD1->D1_LOTECTL    := "0000"
			EndIf*/

			SD1->(MsUnlock())

			UpdProd(aImpostos[nCount][I_PROD], aImpostos[nCount][I_PICM], aImpostos[nCount][I_PIPI]) //atualiza alguns dados do produto de estoque

		ENDIF

		(cAliasSD1)->(dbCLoseArea())

		Reclock("CD5",.T.)
		CD5->CD5_FILIAL  := XFILIAL('CD5')
		CD5->CD5_DOC     := cDOc
		CD5->CD5_SERIE   := cSerie
		CD5->CD5_FORNEC  := cFornec
		CD5->CD5_LOJA    := cLoja
		CD5->CD5_ITEM    := StrZero(Val(aImpostos[nCount][I_ITEM]),4)
		CD5->CD5_ESPEC   := cEspeciePadrao
		CD5->CD5_CODFAB  := cFornec
		CD5->CD5_LOJFAB  := cLoja
		CD5->CD5_CODEXP  := cFornec
		CD5->CD5_LOJEXP  := cLoja
		CD5->CD5_LOCAL   := cLocServ
		CD5->CD5_TPIMP   := cTipImp
		CD5->CD5_CNPJAE  := __cCNPJAdq
		CD5->CD5_UFTERC  := __cUFAdq 
		CD5->CD5_DSPAD   := aImpostos[nCount][I_VLRDESPE]
		CD5->CD5_VAFRMM  := aImpostos[nCount][I_AFRMM]
		
		cAdicaoNum := StrZero(Val(aImpostos[nCount][I_NADIC]),3)
		cAdicaoSeq := StrZero(Val(aImpostos[nCount][I_NADICSEQ]),3)

		CD5->CD5_NDI   		:= aImpostos[nCount][I_NRDI]//NUM DI
		CD5->CD5_NADIC 		:= IF(!Empty(cAdicaoNum),cAdicaoNum,cAdicPadrao)
		CD5->CD5_SQADIC     := If(!Empty(cAdicaoSeq),cAdicaoSeq,StrZero(Val(aImpostos[nCount][I_ITEM]),3))
		CD5->CD5_DOCIMP 	:= aImpostos[nCount][I_NRDI] //NUM DI
		CD5->CD5_VTRANS     := __TpViaTransp
		CD5->CD5_INTERM     := __TpInterm
		CD5->CD5_BCIMP 		:= aImpostos[nCount][I_BASSII]
		CD5->CD5_VLRII  	:= aImpostos[nCount][I_VLRII]
		CD5->CD5_BSPIS  	:= aImpostos[nCount][I_BASPIS]
		CD5->CD5_ALPIS  	:= aImpostos[nCount][I_PERPIS]//PERC PIS
		CD5->CD5_VLPIS  	:= aImpostos[nCount][I_VLRPIS]//vlr PIS
		CD5->CD5_BSCOF  	:= aImpostos[nCount][I_BASCOF]
		CD5->CD5_ALCOF  	:= aImpostos[nCount][I_PCOF]//PERC COF
		CD5->CD5_VLCOF  	:= aImpostos[nCount][I_VLRCOF]//VLR COF
		CD5->CD5_DTDI   	:= aImpostos[nCount][I_DTDI]//aRegsArquivo[nCOunt][10]//DATA DI
		CD5->CD5_LOCDES 	:= aImpostos[nCount][I_LOCDES]//aRegsArquivo[nCOunt][5]//CIDADE DESEMBARACO
		CD5->CD5_UFDES 		:= aImpostos[nCount][I_UFDES]//aRegsArquivo[nCOunt][4]
		CD5->CD5_DTDES 		:= aImpostos[nCount][I_DTDES]//aRegsArquivo[nCOunt][11]//DT DESEMBARACAO
		MsUnLock()

	Next nCount
	
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ TIBI   บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ  Daods acumulados para poisterior update                 ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Acumulados()

	nBase   	 += Val(aLstRegs[2]) //Base ICM para todos os impostos
	nSeguro  	 += Val(aLstRegs[9]) //aLstRegs[20]
	nFrete   	 += Val(aLstRegs[8]) //aLstRegs[19]
	nTotPIS   	 += Val(aLstRegs[13])
	nTotCofins	 += Val(aLstRegs[14])
	nTotII    	 += Val(aLstRegs[11])
	nTotICMS  	 += Val(aLstRegs[3])
	nTotIPI   	 += Val(aLstRegs[12])
	
	__nValTot	+= Val(aLstRegs[16])
	
	nDespesa 	+= Val(aLstRegs[15]) 

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ    บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Identifica a primeira remessa de um dado docto do despachanteณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DocNOVO(cNomeCSV)

	InsereNf (cPrefPadrao, cFornPadrao, cLojPadrao, cEspeciePadrao, cPgtoPadrao,  cNomeCSV)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ    บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Executa o reprocessamento do livro fiscal                  ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function Reprocessar(cDoc,cSerie, cFornec, cLoja, cEspecie, cCond, cNomeArq)
	Local _aPergA930 := {}
	Local   cArqErrAuto     := ''
	Local   cErrAuto := '', cMsgErr := ''
	Private lMsErroAuto := .F.
	PRIVATE MV_PAR12
	PRIVATE MV_PAR13
	PRIVATE MV_PAR14
	PRIVATE MV_PAR15

	AAdd( _aPergA930, DTOC(SF1->F1_EMISSAO) )
	aAdd( _aPergA930, DTOC(SF1->F1_EMISSAO) )
	AAdd( _aPergA930, 1 )//flag nf de compra
	AAdd( _aPergA930, SF1->F1_DOC )
	AAdd( _aPergA930, SF1->F1_DOC )
	AAdd( _aPergA930, SF1->F1_SERIE )
	AAdd( _aPergA930, SF1->F1_SERIE )
	AAdd( _aPergA930, SF1->F1_FORNECE )
	AAdd( _aPergA930, SF1->F1_FORNECE )
	AAdd( _aPergA930, SF1->F1_LOJA )  //MV_CHA
	AAdd( _aPergA930, SF1->F1_LOJA )  //MV_CHB

	MV_PAR01 := DTOC(SF1->F1_EMISSAO)
	MV_PAR02 := DTOC(SF1->F1_EMISSAO)
	MV_PAR03 := 1
	MV_PAR04 := SF1->F1_DOC
	MV_PAR05 := SF1->F1_DOC
	MV_PAR06 := SF1->F1_SERIE
	MV_PAR07 := SF1->F1_SERIE
	MV_PAR08 := SF1->F1_FORNECE
	MV_PAR09 := SF1->F1_FORNECE
	MV_PAR10 := SF1->F1_LOJA
	MV_PAR11 := SF1->F1_LOJA

	MV_PAR12 := ''
	MV_PAR13 := 'ZZZZZZ'
	MV_PAR14 := 2
	MV_PAR15 := 2


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณReprocessamento do Livro de entradaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lMsErroAuto := .F.
	MATA930(.T.,_aPergA930)

	//Ma930Param(,.T.,,_aPergA930)

	If lMsErroAuto
		MostraErro()
		//cArqErrAuto := NomeAutoLog()
		//cErrAuto    := Memoread(cArqErrAuto)
		//cMsgErr     := cErrAuto

		cMsgErr += " Este Documento ocasionou erro no ato do reprocessamento fiscal (MATA930)!"
		//LogErro(cPath + cNomeArq)

		//Ferase(cArqErrAuto)

		DesligaReprocessamentoLF(cFornec , cLoja , cDoc , cSerie)
		//else
		//	DesligaReprocessamentoLF(cFornec , cLoja , cDoc , cSerie)

		//	if !Empty(cOldNf)//tratando-se de um complemento incrementa contador de importacoes no cabecalho na nota
		//		reclock('SF1',.F.)
		//		SF1->F1_XSEQA := ALLTRIM(STR(nOldSeqa))
		//		MsUnLock()
		//	endif
	ENDIF
	DesligaReprocessamentoLF(cFornec , cLoja , cDoc , cSerie)

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ           บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ  deixada a nota marcada para jamais reprocessar LF        ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function  DesligaReprocessamentoLF(cFornec , cLoja , cDoc , cSerie)
	DBSELECTAREA('SF3')
	SF3->(DBSETORDER(4))
	SF3->( DBSEEK( XFILIAL('SF3') + cFornec + cLoja + cDoc + cSerie )  )

	if SF3->(!Eof())
		reclock('SF3',.F.)
		SF3->F3_REPROC := "N"
		MsUnLock()
	endif
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ           บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ  deixada a nota marcada para  reprocessar LF               ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function  LigarReprocessamentoLF(cFornec , cLoja , cDoc , cSerie)
	DBSELECTAREA('SF3')
	SF3->(DBSETORDER(4))
	SF3->( DBSEEK( XFILIAL('SF3') + cFornec + cLoja + cDoc + cSerie )  )

	if SF3->(!Eof())
		reclock('SF3',.F.)
		SF3->F3_REPROC := "S"
		MsUnLock()
	endif
return



//=================================================================================================
//testa se o tipo do fornecedor vale para importa็ใo
Static function FOrnecEX()
	Local lRet := .T.

	Local nTamFornec 	:= TamSX3("A2_COD")[1]

	dbselectarea('SA2')
	dbsetorder(1)
	SA2->( dbseek(xfilial('SA2') + PADR(cFornPadrao,nTamFornec) +  cLojPadrao) )

	if SA2->(!Eof())
		if Alltrim(SA2->A2_EST) != "EX"  .or. Alltrim(SA2->A2_TIPO) != 'X'
			cMsgErr := "Este processo trabalha somente com Notas de entrada de importa็ใo. O fornecedor deve possuir Estado(UF) igual a 'EX' e Tipo igual a 'Outros' !"
			lRet := .F.
		ENDIF
	endif

return lRet


Static Function PatchArq()

	Local _PastaLoc	:=	GetSrvProfString("StartPath", "\Importacao_NFI")

Return _PastaLoc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ OnSTack บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ ve a pilha pra saber qual funcao usou                     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OnStack(cFunc)
	Local lRet := .F.
	Local cProc := ""
	Local nX := 0

	While !Empty(cProc := ProcName( nX++ )) .And. !lRet
		lRet := (Alltrim(Upper(cProc)) == cFunc)
	End

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ArqRenomeia บ Autor ณ TOTVS Protheus     บ Data ณ  1/12/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ renomear arquivo no PC e no FTP    (para _LIDO)            ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ArqRenomeia (cNome, cDestino)
	Local cNew 		:= ''
	Local __cArqPed := ''
	Local aNameArq 	:= {}

	//if Val(cNroComplemento) == 0

	IF !EMPTY(cNfGerada)
		cNew := strtran (Upper(cNome),".TXT",  ("_" + AllTrim(cNfGerada) + ".OLD")   ,1,1)
	ELSE
		cNew := strtran (Upper(cNome),".TXT",  (".OLD")   ,1,1)
	ENDIF

	if FRename(Upper(cNome), Upper(cNew)) = -1
	  	cNew	:=	cNome
	Endif

		aNameArq 	:= Separa( cNew, "\" )
		__cArqPed	:=	aNameArq[Len(aNameArq)]

	If Copia2Lidos( cNew , cDestino+"\"+__cArqPed ) //MsCopyFile(cOrigem,cDestino) //AvCpyFile(cOrigem, cDestino,.f.)
	   	fErase(cNew)
	Endif

Return


/*/{Protheus.doc} Copia2Lidos
Fun็ใo copia arquivos e verifica se a copia deu certo
@author Giane
@since 27/04/2015
@version 1.0
@param cOrigem, character, (Descri็ใo do parโmetro)
@param cDestino, character, (Descri็ใo do parโmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Copia2Lidos( cOrigem , cDestino )

Local nTry		:= 1
Local lRet 		:= .F.

While nTry <= 15 .AND. !File( cDestino )

	__CopyFile( lower(cOrigem) , lower(cDestino) )
	Sleep(100)
	nTry += 1

End
lRet := File(cDestino)

Return lRet

/*/{Protheus.doc} Sair

@author Caio
@since 04/11/2015
@version 1.0

/*/
Static Function Sair(lSair)

Default lSair	:= .F. 

If lSair
	//-- Zera valores
	nCapatazia	:= 0
	// nSiscomex	:= 0
Else
	//-- Zera valores
	nCapatazia	:= nGet1
	// nSiscomex	:= nGet2
EndIf

Return .T. 

/*/{Protheus.doc} ApagaLivro
Fun็ใo apaga SFT e SF3 antes de reprocessar

@obs Necessแrio apagar para o sistema recalcular corretamente os valores de ICMS de acordo com SD1 e SF1

@author Caio
@since 08/06/2016
@version 1.0

/*/
Static Function ApagaLivro(cFornec , cLoja , cDoc , cSerie)
Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())

Default cFornec	:= ""
Default cLoja	:= ""
Default cDoc	:= ""
Default cSerie	:= ""

SFT->(dbSetOrder(1))
SF3->(dbSetOrder(4))
If SF3->( MsSeek( xFilial("SF3") + cFornec + cLoja + cDoc + cSerie ))
	//MsgAlert("Encontrou SF3")
	While SF3->(!Eof() ) .And. SF3->(F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_SERIE ) == xFilial("SF3") + cFornec + cLoja + cDoc + cSerie  
		RecLock("SF3",.F.)
		SF3->(dbDelete())
		MsUnlock()
		SF3->(dbSkip())
	EndDo
	
	If SFT->(MsSeek(xFilial("SFT") + "E" + cSerie + cDoc + cFornec + cLoja ))
		//MsgAlert("Encontrou SFT")
		While SFT->(!Eof()) .And. SFT->(FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA ) == xFilial("SFT") + "E" + cSerie + cDoc + cFornec + cLoja 
			RecLock("SFT",.F.)
			SFT->(dbDelete())
			MsUnlock()
			SFT->(dbSkip())
		EndDo
	Else
		//MsgAlert("Nใo Encontrou SFT")
	EndIf
Else
	//MsgAlert("Nใo Encontrou SF3")
EndIf

RestArea(aAreaSF1)
RestArea(aArea)
Return


