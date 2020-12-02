#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MATA103.CH"

#DEFINE VALMERC 01	// Valor total do mercadoria
#DEFINE VALDESC 02	// Valor total do desconto
#DEFINE TOTPED	 03	// Total do Pedido
#DEFINE FRETE   04	// Valor total do Frete
#DEFINE VALDESP 05	// Valor total da despesa
#DEFINE TOTF1	 06	// Total de Despesas Folder 1
#DEFINE SEGURO	 07	// Valor total do seguro
#DEFINE TOTF3	 08	// Total utilizado no Folder 3
#DEFINE VNAGREG	 09	// Valor total nao agregado ao total do documento
#DEFINE _CRLF	Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} CBL00104
Notas Fiscais de Emissão de Terceiros

@author eric do nascimento
@since 99/99/9999
@version P11
/*/
//-------------------------------------------------------------------
User Function CBL00104()
Local oBrowse	:= Nil
Local nX		:= 0
Local aCores	:= {	{ "SZ1->Z1_TPXML=='1'" 	, "BR_VERDE"	, "Nota Fiscal de Entrada"		},;
						{ "SZ1->Z1_TPXML=='2'" 	, "BR_AZUL"		, "Nota Fiscal de Saída"		},;
						{ "SZ1->Z1_TPXML=='4'" 	, "BR_BRANCO"	, "Nota Fiscal Complementar"	},;
						{ "SZ1->Z1_TPXML=='3'" 	, "BR_PINK"		, "Conhecimento de Transporte"	},;
						{ "SZ1->Z1_TPXML=='5'" 	, "BR_VERMELHO"	, "Evento de Cancelamento"		},;
						{ "SZ1->Z1_TPXML=='6'" 	, "BR_AMARELO"	, "Evento de Inutilização"		},;
						{ "SZ1->Z1_TPXML=='7'" 	, "BR_VERMELHO" , "NF Cancelada/Recusada"		}}

// Coluna Virtual para controlar o status do processo de vendas.
Local aLStatus  	:=  {"",{|| TIBXMLEG0("S") },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| TIBXMLEG1("S") },,,,.F.}
Local aLPendCad  	:=  {"",{|| TIBXMLEG0("C") },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| TIBXMLEG1("C") },,,,.F.}

/*
Private lGravaAuto 	:= .T.
PRIVATE l103Auto	:= .T.
PRIVATE lGravaG	:= .T.
PRIVATE aAutoCab	:= {}
PRIVATE aAutoImp    := {}
PRIVATE aAutoItens 	:= {}
PRIVATE aRateioCC		:= {}
PRIVATE aParamAuto 	:= {}
PRIVATE cCadastro	:= OemToAnsi("Documento de Entrada") //"Documento de Entrada"
PRIVATE aBackSD1    := {}
PRIVATE aBackSDE    := {}
PRIVATE aNFEDanfe   := {}
PRIVATE bBlockSev1	:= {|| Nil}
PRIVATE bBlockSev2	:= {|| Nil}
PRIVATE aAutoAFN	:= {}
PRIVATE aDanfeComp  := {}
PRIVATE aRegsLock	:={}
PRIVATE lMT100TOK   := .T.
PRIVATE lImpPedido	:= .F.
PRIVATE aColsOrig   := {}
PRIVATE cCodRSef    := ""
*/

PRIVATE _aDivPNF    := {}	  // Inicializa array do cadastro de divergencias - FW

Private xRateioCC:= {}
Private xCodRSef := ""
Private L103VISUAL 	:= .T.
Private	l103Class	:= .T.
Private	l103TolRec  := .T.
Private lWhenGet	:= .F.

Private cTESAnt		:= ""
Private CCADASTRO 	:= ""
Private	oPanelE		:= Nil
Private aPosObj		:= {}
Private cProdPad 	:= SuperGetMV('TI_PRODPAD',.F.,'0000002')

PRIVATE aRotina 	:= {} //MenuDef() // Foi modificado para o SIGAGSP.

//Aumentando Tamanho máximo de Strings em ADVPL
u_SetStrSize()

Processa( {|| AjustaSX3() }, "Aguarde...", "Atualizando Valid do SX3 para uso do MATXFIS...",.F.)

// ----------------------
// Filtro através de F12
// ----------------------
SetKey( VK_F12 ,{|| FAtiva() })

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SZ1' )
oBrowse:SetDescription( 'TIB XML - PRÉ NOTA EMISSÃO TERCEIROS' )
// Adiciona as legendas do ponto de entrada.
For nX := 1 To Len(aCores)
	oBrowse:AddLegend(aCores[nX][1],aCores[nX][2],aCores[nX][3])
Next nX

If AliasInDic("SZ1")
	oBrowse:AddColumn(aLStatus)
	oBrowse:AddColumn(aLPendCad)
EndIf

//Setando o Filtro para Notas de Emissão Própria
oBrowse:SetFilterDefault("SZ1->Z1_CGCDES == SM0->M0_CGC .AND. !(SZ1->Z1_CGCEMI == SZ1->Z1_CGCDES) .AND. !(SZ1->Z1_TPXML $ '3|6')")

oBrowse:Activate()
SetKey( VK_F12, Nil )

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aRotXML  := {}
Local aRotRel  := {}

ADD OPTION aRotXML   Title 'XML' 		 Action 'U_VERXML'   		OPERATION 4 ACCESS 0
ADD OPTION aRotXML   Title 'XML Canc.'   Action 'U_VXMLCANC' 		OPERATION 4 ACCESS 0

ADD OPTION aRotRel  Title 'Pend. Escrit.'   Action 'U_PLFISR04' 		OPERATION 2 ACCESS 0

ADD OPTION aRotina Title 'Visualizar'  			Action 'U_VERNOTA' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Alt. Doc.'			Action 'U_ALTNOTA' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Classificar' 			Action 'U_ClassNo3'			OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Cancelar'         	Action 'U_CancXML2'			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Estornar'         	Action 'U_EstoXML2'			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Excluir'  			Action 'U_ExclXML2'			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Visualizar Danfe'  	Action 'U_VERDANFE'			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Visualizar XML'		Action aRotXML   			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Vis. Pré-Nota'		Action 'VIEWDEF.CBL00104' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Relatórios'    		Action aRotRel              OPERATION 2 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruSZ1 := FWFormStruct( 1, 'SZ1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSZ2 := FWFormStruct( 1, 'SZ2', /*bAvalCampo*/, /*lViewUsado*/ )
Local aCposSZ1 := {}
Local nC       := 0
//Local oStruZA2 := FWFormStruct( 1, 'ZA2', /*bAvalCampo*/, /*lViewUsado*/ )

Local oModel

oModel := MPFormModel():New( 'COMP021M', { |oModel| PreNotaPVld(oModel) } , { |oModel| u_PreNotaTOk( oModel ) } , /*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'SZ1MASTER', /*cOwner*/, oStruSZ1 )

oModel:AddGrid( 'SZ2DETAIL', 'SZ1MASTER', oStruSZ2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//oModel:AddGrid( 'ZA2DETAIL', 'SZ1MASTER', oStruZA2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation( 'SZ2DETAIL', { { 'Z2_FILIAL', 'FWxFilial( "SZ2" )' }, { 'Z2_DOC', 'Z1_DOC' }, { 'Z2_SERIE', 'Z1_SERIE' }, { 'Z2_FORNECE', 'Z1_FORNECE' }, { 'Z2_LOJA', 'Z1_LOJA' } 		}, SZ2->( IndexKey( 18 ) ) )
//oModel:SetRelation( 'ZA2DETAIL', { { 'ZA2_FILIAL', 'xFilial( "ZA2" )' }, { 'ZA2_DOC', 'Z1_DOC' } 	}, ZA2->( IndexKey( 1 ) ) )

oModel:SetDescription( 'TIB XML - PRÉ NOTA' )

oModel:GetModel( 'SZ1MASTER' ):SetDescription( 'Cabeçalho do Documento' )
oModel:GetModel( 'SZ2DETAIL' ):SetDescription( 'Itens do Documento'  )

oStruSZ2:SetProperty("Z2_TES" 	,MODEL_FIELD_VALID, {|| u_ATVALIDTES(oModel)  } )
oStruSZ2:SetProperty("Z2_CF", MODEL_FIELD_WHEN, {||.F.})

aCposSZ1 := oStruSZ1:GetFields() //Campos da Tabela SZ1
For nC := 1 To Len(aCposSZ1)
	//oStruSZ1:SetProperty(aCposSZ1[nC, 03], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, "u_VldCpoZ1(SZ1->Z1_DOC, SZ1->Z1_SERIE, SZ1->Z1_FORNECE, SZ1->Z1_LOJA , SZ1->Z1_TIPO, '" + aCposSZ1[nC, 03] + "')"))
	oStruSZ1:SetProperty(aCposSZ1[nC, 03], MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysFalse()"))
Next nC

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruSZ1 := FWFormStruct( 2, 'SZ1' )
Local oStruSZ2 := FWFormStruct( 2, 'SZ2' )
//Local oStruZA2 := FWFormStruct( 2, 'ZA2' )

Local oModel   := FWLoadModel( 'CBL00104' )
Local oView

Local cCpoSZ1	:= ""
Local cCpoSZ2	:= ""

Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize(,.F.,400)
Local aInfForn	:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"","","",""}
Local a103Var		:= {0,0,0,0,0,0,0,0,0}
Local aInfo		:= {}
Local aPosGet	:= {}
Local aCposSZ2  := Arr2Order() //Array com Campos da SZ2
Local nSZ2      := 0

AAdd( aObjects, { 0,    41, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 0,    75, .T., .F. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

cPaisLoc := "BRA"

aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
{If(cPaisLoc<>"PTG",{8,35,75,100,194,220,260,280},{8,35,78,100,140,160,200,230,250,270}),;
If( .T.,{8,35,75,100,100,194,220,260,280},{8,35,75,108,135,160,190,220,244,265} ) ,;
{5,70,160,205,295},;
{6,34,200,215},;
{6,34,75,103,148,164,230,253},;
{6,34,200,218,280},;
{11,50,150,190},;
{273,130,190,293,205},;
{005,035,075,105,145,175,215,245},;
{11,35,80,110,165,190},;
{3,35,95,150,205,255,170,230,265,;
55,115,155,217,185,245,280,167,222,272},;
{3, 4}})

cCpoSZ1 += " Z1_DOC|Z1_SERIE|Z1_TIPO|Z1_EMISSAO|Z1_FORNECE|Z1_LOJA|Z1_ESPECIE|Z1_EST"
cCpoSZ2 += " Z2_ITEM|Z2_COD|Z2_QUANT|Z2_VUNIT|Z2_CODENT|Z2_XDESC|Z2_TES|Z2_CF|Z2_BRICMS|Z2_ICMSRET|Z2_ALIQSOL|Z2_TOTAL|Z2_DOC|Z2_SERIE|Z2_FORNECE|Z2_LOJA|Z2_TIPO|Z2_EMISSAO|Z2_DTDIGIT|Z2_BASEICM|Z2_PICM|Z2_VALICM|Z2_CLASFIS|Z2_BASEIPI|Z2_IPI|Z2_VALIPI|Z2_BASEPIS|Z2_ALIQPIS|Z2_VALPIS|Z2_BASECOF|Z2_ALIQCOF|Z2_VALCOF|Z2_II|Z2_FORMUL|Z2_CODENT|Z2_XDESC|Z2_NFORI|Z2_SERIORI|Z2_ITEMORI|"

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField( 'VIEW_SZ1', oStruSZ1, 'SZ1MASTER' )
oView:AddGrid(  'VIEW_SZ2', oStruSZ2, 'SZ2DETAIL' )
//oView:AddGrid(  'VIEW_ZA2', oStruZA2, 'ZA2DETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 28 )
oView:CreateHorizontalBox( 'INFERIOR', 42 )

oView:CreateHorizontalBox( 'IMPOSTOS', 30 )
oView:CreateFolder( 'PASTAS' , 'IMPOSTOS' )

// ---------------------------------------------------------------------------------------
// FOLDER TOTAIS
// ---------------------------------------------------------------------------------------
oView:AddSheet('PASTAS','SHEET1','Totais')
oView:CreateHorizontalBox( 'BOXFORM1', 100, , , 'PASTAS', 'SHEET1')

oView:AddOtherObject("A_OTHER_PANEL", {|oPanelA| fTelaTot(oPanelA,a103Var,aPosGet[3] )})
oView:SetOwnerView("A_OTHER_PANEL","BOXFORM1")


// ---------------------------------------------------------------------------------------
// FOLDER FORNECEDOR / CLIENTE
// ---------------------------------------------------------------------------------------
oView:AddSheet('PASTAS','SHEET2','Inf. Fornecedor/Cliente')
oView:CreateHorizontalBox( 'BOXFORM2', 100, , , 'PASTAS', 'SHEET2')

oView:AddOtherObject("B_OTHER_PANEL", {|oPanelB| fTelaFor(oPanelB,aInfForn,{aPosGet[4],aPosGet[5],aPosGet[6]} )})
oView:SetOwnerView("B_OTHER_PANEL","BOXFORM2")

// ---------------------------------------------------------------------------------------
// FOLDER DESCONTOS / FRETE / DESPESAS
// ---------------------------------------------------------------------------------------
oView:AddSheet('PASTAS','SHEET3','Descontos/Frete/Despesas')
oView:CreateHorizontalBox( 'BOXFORM3', 100, , , 'PASTAS', 'SHEET3')

oView:AddOtherObject("C_OTHER_PANEL", {|oPanelC| fTelaDisp(oPanelC,a103Var,{aPosGet[7],aPosGet[8]},oModel )})
oView:SetOwnerView("C_OTHER_PANEL","BOXFORM3")

// ---------------------------------------------------------------------------------------
// FOLDER LIVROS FISCAIS
// ---------------------------------------------------------------------------------------
//oView:AddSheet('PASTAS','SHEET4','Livros Fiscais')
//oView:CreateHorizontalBox( 'BOXFORM4', 100, , , 'PASTAS', 'SHEET4')

//oView:AddOtherObject("D_OTHER_PANEL", {|oPanelD| MaFisBrwLivro(oPanelD,{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,53},.T.,/*IIf(!l103Class,aRecSF3,Nil)*/, IIf(!lWhenGet , IIf( l103Class , .T. , l103Visual ) , .T. ) ) })
//oView:SetOwnerView("D_OTHER_PANEL","BOXFORM4")

// ---------------------------------------------------------------------------------------
// FOLDER IMPOSTOS
// ---------------------------------------------------------------------------------------
oView:AddSheet('PASTAS','SHEET5','Impostos')
oView:CreateHorizontalBox( 'BOXFORM5', 100, , , 'PASTAS', 'SHEET5')

oView:AddOtherObject("E_OTHER_PANEL", {|oPanelE| U_TIBBoxI2(oPanelE,oModel)  })
oView:SetOwnerView("E_OTHER_PANEL","BOXFORM5")


// ---------------------------------------------------------------------------------------
// FOLDER DUPLICATAS
// ---------------------------------------------------------------------------------------
//oView:AddSheet('PASTAS','SHEET6','Duplicatas')
//oView:CreateHorizontalBox( 'BOXFORM6', 100, , , 'PASTAS', 'SHEET6')

// ---------------------------------------------------------------------------------------
// FOLDER INFORMAÇÕES DANFE
// ---------------------------------------------------------------------------------------
//oView:AddSheet('PASTAS','SHEET7','Informações Danfe')
//oView:CreateHorizontalBox( 'BOXFORM7', 100, , , 'PASTAS', 'SHEET7')

// ---------------------------------------------------------------------------------------
// FOLDER INFORMAÇÕES DANFE
// ---------------------------------------------------------------------------------------
//oView:AddSheet('PASTAS','SHEET8','Informações Complementares')
//oView:CreateHorizontalBox( 'BOXFORM8', 100, , , 'PASTAS', 'SHEET8')



oView:SetOwnerView( 'VIEW_SZ1', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_SZ2', 'INFERIOR' )
//oView:SetOwnerView( 'VIEW_ZA2', 'BOXFORM8' )

oView:EnableTitleView('VIEW_SZ1' , "Cabeçalho do Documento" )
oView:EnableTitleView('VIEW_SZ2' , "Itens" )

SX3->(dbGoTop())
SX3->(dbSetOrder(1))

If SX3->(dbSeek("SZ1"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SZ1"
		If !(AllTrim(SX3->X3_CAMPO) $ cCpoSZ1	)
			oStruSZ1:RemoveField(AllTrim(SX3->X3_CAMPO))
		EndIf
		SX3->(dbSkip())
	EndDo
EndIf

//Ordenação de Campos
aAux := AClone(oStruSZ2:GetFields())
For nSZ2 := 1 To Len(aAux)
	//Caso o campo exista, ordenar
	If (nPosSZ2 := AScan(aCposSZ2, {|x| AllTrim(x) == AllTrim(aAux[nSZ2, 01])})) > 0
		cOrdem := ProxOrdem(nPosSZ2, 02) //Retorna a Ordem no Formato correto
		oStruSZ2:SetProperty(aAux[nSZ2, 01], MVC_VIEW_ORDEM, cOrdem) //Ordenar
	Else //Senão remove o campo
		oStruSZ2:RemoveField(AllTrim(aAux[nSZ2, 01]))
	EndIf
Next nSZ2

/*
SX3->(dbGoTop())
SX3->(dbSetOrder(1))

If SX3->(dbSeek("SZ2"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SZ2"
		If !(AllTrim(SX3->X3_CAMPO) $ cCpoSZ2	)
			oStruSZ2:RemoveField(AllTrim(SX3->X3_CAMPO))
		EndIf
		SX3->(dbSkip())
	EndDo
EndIf
*/

Return oView

Static Function TIBXMLEG0(cId)

Local cLeg:= ""

If cId == "S"
	Do Case

		Case SZ1->Z1_STATUS == '1' // NF Importada
			cLeg:= "BR_VERDE"
		Case SZ1->Z1_STATUS == '2' // NF Importada (Pendente de Classificação)
			cLeg:= "BR_PRETO"
		Case SZ1->Z1_STATUS == '3' // NF Importada (Aguardando Liberação)
			cLeg:= "BR_BRANCO"
		Case SZ1->Z1_STATUS == '4' // NF Não Importada
			cLeg:= "BR_VERMELHO"
		Case SZ1->Z1_STATUS == '5' // NF Importada (Pendente de Reclassificação)
			cLeg := "BR_MARROM"
	EndCase
Else
	Do Case

		Case SZ1->Z1_CADENT == '1' .AND. SZ1->Z1_CADPRO == '1'
			cLeg:= "BR_VERDE"
		Case SZ1->Z1_CADENT == '2' .AND. SZ1->Z1_CADPRO == '1'
			cLeg:= "BR_AMARELO"
		Case SZ1->Z1_CADENT == '1' .AND. SZ1->Z1_CADPRO == '2'
			cLeg:= "BR_VERMELHO"
		Case SZ1->Z1_CADENT == '2' .AND. SZ1->Z1_CADPRO == '2'
			cLeg:= "BR_PRETO"
		Case SZ1->Z1_CADENT == '3'
			cLeg:= "BR_PINK"
		Case SZ1->Z1_CADPRO == '3' .AND. SZ1->Z1_CADENT == '1'
			cLeg:= "BR_AZUL"
		Case SZ1->Z1_CADENT == '2' .AND. SZ1->Z1_CADPRO == '3'
			cLeg:= "BR_LARANJA"
	EndCase
EndIf

Return cLeg

Static Function TIBXMLEG1(cId)

Local oLegenda  :=  FWLegend():New()

If cId == "S"
	oLegenda:Add("","BR_VERDE"	 	,"NF Gerada"								)
	oLegenda:Add("","BR_PRETO" 		,"Pré Nota (Pendente de Classificação)"	)
	oLegenda:Add("","BR_BRANCO"		,"Pré Nota (Aguardando Liberação)"		)
	oLegenda:Add("","BR_VERMELHO"	,"NF Não Gerada \ Revisar"							)
	oLegenda:Add("","BR_MARROM"		,"Pré Nota (Pendente de Reclassificação)"	)
Else
	oLegenda:Add("","BR_VERDE"	 	,"OK - Sem Pendências Cadastrais"			)
	oLegenda:Add("","BR_AMARELO"	,"Pendente - Cadastro de Fornecedor/Cliente")
	oLegenda:Add("","BR_VERMELHO"	,"Pendente - Cadastro de Produto x For/Cli"			)
	oLegenda:Add("","BR_PRETO"		,"Pendente - Cadastro de Produto e For/Cli"	)
	oLegenda:Add("","BR_PINK"		,"Pendente - Cadastro de Fornecedor de Importação"	)
	oLegenda:Add("","BR_LARANJA"	,"Pendente - Fornecedor/Cliente Bloqueado"	)
	oLegenda:Add("","BR_AZUL"		,"Pendente - Cadastro de Produto"	)
	oLegenda:Add("","BR_ROXO"		,"NF Cancelada/Recusada" )
EndIf

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return( .T. )


Static Function fTelaFor(oDlg,aGets,aPosGet,bRefresh)

Local lOk 			:= .F.
Local cGetOper	:= Space(60)
Local cGetGrup	:= Space(60)
Local cGetOrig	:= Space(60)
Local cXGetOrig	:= Space(60)

Local oGetOper	:= Nil
Local oGetGrup	:= Nil
Local oGetOrig	:= Nil

Local aObjetos 	:= Array(Len(aGets))
Local nObj 		:= 1
Local cTabEmit	:= ""

If SZ1->Z1_TIPOENT == '1'
	cTabEmit := "SA1"
	CCADASTRO:= "Cadastro de Clientes"
Else
	cTabEmit := "SA2"
	CCADASTRO:= "Cadastro de Fornecedor"
EndIf

(cTabEmit)->(dbSetOrder(1))
If (cTabEmit)->(dbSeek(xFilial(cTabEmit)+SZ1->Z1_FORNECE+SZ1->Z1_LOJA))
	aGets[1] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_NOME")
	aGets[2] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_TEL")
	aGets[3] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_PRICOM")
	aGets[4] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_ULTCOM")
	aGets[5] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_END")
	aGets[6] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_EST")
	aGets[7] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_CGC")
	aGets[8] := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_INSCR")
EndIf

@ 06,aPosGet[1,1] SAY RetTitle("A2_NOME") Of oDlg PIXEL SIZE 37,09
@ 05,aPosGet[1,2] MSGET aObjetos[nObj] VAR aGets[1] ;
	PICTURE PesqPict('SA2','A2_NOME');
	When .F. ;
	OF oDlg PIXEL SIZE 159,09
nObj++
@ 06,aPosGet[1,3] SAY RetTitle("A2_TEL") Of oDlg PIXEL SIZE 23,09
@ 05,aPosGet[1,4]+5 MSGET aObjetos[nObj] VAR aGets[2] ;
	When .F. ;
	OF oDlg PIXEL SIZE 74,09
nObj++
@ 43,aPosGet[2,1] SAY RetTitle("A2_PRICOM") Of oDlg PIXEL SIZE 32,09
@ 42,aPosGet[2,2] MSGET aObjetos[3] VAR aGets[3] ;
	PICTURE PesqPict('SA2','A2_PRICOM') ;
	When .F. ;
	OF oDlg PIXEL SIZE 40,09
nObj++
@ 43,aPosGet[2,3] SAY RetTitle("A2_ULTCOM") Of oDlg PIXEL SIZE 36,09
@ 42,aPosGet[2,4] MSGET aObjetos[nObj] VAR aGets[4] ;
	PICTURE PesqPict('SA2','A2_ULTCOM');
	WHEN .F. OF oDlg PIXEL SIZE 40,09
nObj++
@ 43,aPosGet[2,5]-5 SAY RetTitle("A2_CGC") Of oDlg PIXEL SIZE 21,09
@ 42,aPosGet[2,6]+5 MSGET aObjetos[nObj] VAR aGets[7] ;
	PICTURE PesqPict('SA2','A2_CGC');
	WHEN .F. OF oDlg PIXEL SIZE 76,09
nObj++
If Len(aGets)>=8
	@ 43,aPosGet[2,7] SAY RetTitle("A2_INSCR") Of oDlg PIXEL SIZE 30,09
	@ 42,aPosGet[2,8] MSGET aObjetos[6] VAR aGets[8] ;
		PICTURE PesqPict('SA2','A2_INSCR');
		WHEN .F. OF oDlg PIXEL SIZE 60,09
	nObj++
Endif
@ 24,aPosGet[3,1] SAY RetTitle("A2_END") Of oDlg PIXEL SIZE 49,09
@ 23,aPosGet[3,2] MSGET aObjetos[nObj] VAR aGets[5];
	PICTURE PesqPict('SA2','A2_END');
	WHEN .F. OF oDlg PIXEL SIZE 205,9
nObj++
@ 24,aPosGet[3,3] SAY RetTitle("A2_EST") Of oDlg PIXEL SIZE 32,09
@ 23,aPosGet[3,4] MSGET aObjetos[nObj] VAR aGets[6] ;
	PICTURE PesqPict('SA2','A2_EST');
	WHEN .F. OF oDlg PIXEL SIZE 21,09
@ If(Len(aGets)>=8,5,42),aPosGet[3,5] BUTTON 'Mais Inf.' SIZE 30 ,11 FONT oDlg:oFont ; //"Mais Inf."
	ACTION AxVisual(cTabEmit,(cTabEmit)->(Recno()),4)  OF oDlg PIXEL

Return Nil

Static Function fTelaTot(oDlg,aGets,aPosGet,bRefresh)

Local aObjetos := Array(Len(aGets))

aGets[VALMERC]	:= SZ1->Z1_VALMERC
aGets[VALDESC]	:= SZ1->Z1_DESCONT
aGets[FRETE]	:= SZ1->Z1_FRETE
aGets[SEGURO]	:= SZ1->Z1_SEGURO
aGets[VALDESP]	:= SZ1->Z1_DESPESA
aGets[TOTPED]	:= SZ1->Z1_VALBRUT

@ 06,aPosGet[1] SAY RetTitle("F1_VALMERC") Of oDlg PIXEL SIZE 55 ,9 //"Valor da Mercadoria"
@ 05,aPosGet[2] MSGET aObjetos[VALMERC] VAR aGets[VALMERC] PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F. SIZE 80,09
@ 06,aPosGet[3] SAY RetTitle("F1_DESCONT") Of oDlg PIXEL SIZE 49 ,9 //"Descontos"
@ 05,aPosGet[4] MSGET aObjetos[VALDESC] VAR aGets[VALDESC]  PICTURE PesqPict('SD1','D1_VALDESC') OF oDlg PIXEL When .F. SIZE 80,09
If Len(aGets)>3
	@ 20,aPosGet[1] SAY RetTitle("F1_FRETE") Of oDlg PIXEL SIZE 45 ,9 //"Valor do Frete"
	@ 19,aPosGet[2] MSGET aObjetos[FRETE] VAR aGets[FRETE]  PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F. SIZE 80,09
	@ 20,aPosGet[3] SAY RetTitle("F1_SEGURO") Of oDlg PIXEL SIZE 50 ,9 //"Vlr. do Seguro"
	@ 19,aPosGet[4] MSGET aObjetos[SEGURO] VAR aGets[SEGURO]  PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F. SIZE 80,09
	@ 34,aPosGet[3] SAY RetTitle("F1_DESPESA") Of oDlg PIXEL SIZE 50 ,9 //"Despesas"
	@ 33,aPosGet[4] MSGET aObjetos[VALDESP] VAR aGets[VALDESP]  PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F.  SIZE 80,09
	If SF1->(FieldPos("F1_VNAGREG")) > 0 .And. GetNewPar("MV_VNAGREG",.F.)
		If Len(aGets) < 9
			Aadd(aGets,0)
			Aadd(aObjetos,0)
		Endif
		@ 51,aPosGet[1] SAY "Valor não Agregado" Of oDlg PIXEL SIZE 58 ,9 //"Valor não Agregado"
		@ 49,aPosGet[2] MSGET aObjetos[VNAGREG] VAR aGets[VNAGREG]  PICTURE PesqPict('SF1','F1_VNAGREG') OF oDlg PIXEL When .F. SIZE 80,09
	Endif
EndIf
@ 51,aPosGet[3] SAY RetTitle("F1_VALBRUT") Of oDlg PIXEL SIZE 58 ,9 //"Total do Doc."
@ 49,aPosGet[4] MSGET aObjetos[TOTPED] VAR aGets[TOTPED]  PICTURE PesqPict('SF1','F1_VALBRUT') OF oDlg PIXEL When .F. SIZE 80,09

@ 43,3 TO 46,aPosGet[5] LABEL '' OF oDlg PIXEL

Return

Static Function fTelaDisp(oDlg,aGets,aPosGet,bRefresh)

Local aObjetos := Array(Len(aGets))

aGets[VALDESC]	:= SZ1->Z1_DESCONT
aGets[FRETE]	:= SZ1->Z1_FRETE
aGets[SEGURO]	:= SZ1->Z1_SEGURO
aGets[VALDESP]	:= SZ1->Z1_DESPESA
aGets[TOTF3]	:= SZ1->Z1_DESCONT + SZ1->Z1_FRETE + SZ1->Z1_SEGURO + SZ1->Z1_DESPESA

@ 09,aPosGet[1,1] SAY RetTitle("F1_DESCONT") Of oDlg PIXEL SIZE 48,09
@ 08,aPosGet[1,2] MSGET aObjetos[VALDESC] VAR aGets[VALDESC] ;
	PICTURE PesqPict("SD1","D1_VALDESC") ;
	OF oDlg PIXEL ;
	WHEN !l103Visual .And. A103LCF("F1_DESCONT") .And. IIf(Type("cTipo") == "U", .T., !cTipo$"PI") ;
	VALID CheckSX3("F1_DESCONT",aGets[VALDESC]) .And. aGets[VALDESC]>=0 .And. NfeVldRef("NF_DESCONTO",aGets[VALDESC]) SIZE 80,09 HASBUTTON
@ 09,aPosGet[1,3] SAY RetTitle("F1_FRETE") Of oDlg PIXEL SIZE 35,09
@ 08,aPosGet[1,4] MSGET aObjetos[FRETE] VAR aGets[FRETE] ;
	PICTURE PesqPict("SF1","F1_FRETE") ;
	OF oDlg PIXEL ;
	WHEN !l103Visual .and. A103LCF("F1_FRETE");
	VALID CheckSX3("F1_FRETE",aGets[FRETE]) .And. aGets[FRETE]>=0 .And. NfeVldRef("NF_FRETE",aGets[FRETE]) SIZE 80,09 HASBUTTON
@ 26,aPosGet[1,1] SAY RetTitle("F1_DESPESA") Of oDlg PIXEL SIZE 42,09
@ 25,aPosGet[1,2] MSGET aObjetos[VALDESP] VAR aGets[VALDESP] ;
	PICTURE PesqPict("SF1","F1_DESPESA") ;
	OF oDlg PIXEL ;
	WHEN !l103Visual .And. A103LCF("F1_DESPESA");
	VALID CheckSX3("F1_DESPESA",aGets[VALDESP]) .And. aGets[VALDESP]>=0 .And. NfeVldRef("NF_DESPESA",aGets[VALDESP]) SIZE 80,09 HASBUTTON
@ 26,aPosGet[1,3] SAY RetTitle("F1_SEGURO") Of oDlg PIXEL SIZE 35,09
@ 25,aPosGet[1,4] MSGET aObjetos[SEGURO] VAR aGets[SEGURO] ;
	PICTURE PesqPict("SF1","F1_SEGURO") ;
	OF oDlg PIXEL ;
	WHEN !l103Visual .And. A103LCF("F1_SEGURO");
	VALID CheckSX3("F1_SEGURO",aGets[SEGURO]) .And. aGets[SEGURO]>=0 .And. NfeVldRef("NF_SEGURO",aGets[SEGURO]) SIZE 80,9	HASBUTTON
@ 38,11 TO 40 ,aPosGet[2,1] LABEL "" OF oDlg PIXEL
@ 48,aPosGet[2,2] SAY "Total ( Frete+Despesas)" Of oDlg PIXEL SIZE 60,09 //"Total ( Frete+Despesas)"
@ 47,aPosGet[2,3] MSGET aObjetos[TOTF3] VAR aGets[TOTF3] ;
	PICTURE PesqPict("SF1","F1_VALBRUT") ;
	OF oDlg PIXEL ;
	WHEN .F. SIZE 80,09 HASBUTTON

Return

User Function XMLLIB3()

Local cTipoNF := SZ1->Z1_TPXML
Local Status  := SZ1->Z1_OK
Local cTpEnt  := SZ1->Z1_TIPOENT
Local cArqXML     := AllTrim(SZ1->Z1_ARQXML)
Local cXML 	      := ''
Local lOK         := .F.
Local cTIPO       := ''

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

If (lOk)
	cXML := MemoRead(cArqXML)
	If ("<DI>" $ Upper(cXML))
		cTIPO := "IMP"
	Else
		cTIPO := "PRE"
	EndIf
EndIf

If SZ1->Z1_STATUS == '3' .Or. SZ1->Z1_CADENT == '3'

	Do Case

		Case cTipoNF == '1' // Nota Fiscal de Entrada

			If SZ1->Z1_CADENT == '3'
				DbSelectArea("SA2")
				SA2->(DbSetOrder(2))
				If SA2->(DbSeek(xFilial("SA2")+UPPER(SZ1->Z1_EMIT)))
					Reclock("SZ1",.F.)
						SZ1->Z1_FORNECE := SA2->A2_COD
						SZ1->Z1_LOJA 	:= SA2->A2_LOJA
					SZ1->(MsUnlock())

					lOk:= U_TIBNFEXML(cTIPO)

					If lOk
						Reclock("SZ1",.F.)
							SZ1->Z1_STATUS := '1'
						SZ1->(MsUnlock())
					Else
						Reclock("SZ1",.F.)
							SZ1->Z1_STATUS := '4'
						SZ1->(MsUnlock())
					EndIf
				Else
					MsgInfo("Não foi possivél localizar o Fornecedor " + UPPER(SZ1->Z1_EMIT) + ". Verifique o cadastro!","Cadastro Não Localizado")
				EndIf

			Else
				MsgInfo("Opção inválida para este tipo de Documento!","Atenção")
			EndIf

		Case cTipoNF == '2' // Nota Fiscal de Saída
			lOk:= U_TIBNFSXML()

			If lOk
				Reclock("SZ1",.F.)
					SZ1->Z1_STATUS := '1'
				SZ1->(MsUnlock())
			Else
				Reclock("SZ1",.F.)
					SZ1->Z1_STATUS := '4'
				SZ1->(MsUnlock())
			EndIf
		Case cTipoNF == '3' // Conhecimento de Trasporte

		Case cTipoNF == '4' // Nota Fiscal Complementar

			If cTpEnt == '1'
				lOk:= U_TIBNFSXML()
			Else
				lOk:= U_TIBNFEXML(cTIPO)
			EndIf

			If lOk
				Reclock("SZ1",.F.)
					SZ1->Z1_STATUS := '1'
				SZ1->(MsUnlock())
			Else
				Reclock("SZ1",.F.)
					SZ1->Z1_STATUS := '4'
				SZ1->(MsUnlock())
			EndIf

		Case cTipoNF == '5' // Evento de Cancelamento

		Case cTipoNF == '6' // Evento de Inutilização

	EndCase
Else
	MsgInfo("Não é possível efetual a liberação deste documento.","Status Inválido para Liberação")
EndIf

Return .T.

Static Function PreNotaPVld(oModel)

Local oMdlSZ2	:= oModel:GetModel("SZ2DETAIL")
Local oViewSZ2  := FWViewActive()
Local nLinLe	:= 1
Local nLin   	:= oMdlSZ2:GetLine()
Local aArea		:= GetArea()
Local oDlg		:= Nil
Local lRet		:= .T.

If ALTERA
	For nLinLe := 1 to oMdlSZ2:Length()
		oMdlSZ2:GoLine( nLinLe )
		If !oMdlSZ2:IsDeleted()
			oMdlSZ2:SetValue( 'Z2_TES' , oMdlSZ2:GetValue("Z2_TES") )
		EndIf
	Next nLinLe

oMdlSZ2:GoLine(nLin)

EndIf

Return .T.

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

Static Function AjustaSX3()

Local aAreaAnt := GetArea()
Local aAreaSX3 := SX3->(GetArea())

DbSelectArea("SX3")
SX3->(dbGoTop())
SX3->(dbSetOrder(1))

If SX3->(dbSeek("SZ2"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SZ2"
		Reclock("SX3",.F.)
		SX3->X3_VALID := ""
		MsUnlock()
	SX3->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSX3)

Return

User Function VERDANF3()
	Local cArqXML := AllTrim(SZ1->Z1_ARQXML)
	Local lOK     := .F.

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

	If lOK
		Processa( {|| U_TIBXMLDANFE(cArqXML) }, "Aguarde...", "Gerando DANFE a partir do arquivo XML...",.F.)
	Else
		MsgInfo("Arquivo XML não encontrado!","Atenção")
	EndIf
Return

User Function VERXML3()

Local cArqXML := AllTrim(SZ1->Z1_ARQXML)
Local lOK     := .F.
Local cXML 	  := ''
Local cTemp   := GetTempPath()
Local cArq	  := cTemp + StrTran(TIME(),":","") + ".XML"

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

If lOK
	cXML := MemoRead(cArqXML)
	MemoWrite(cArq,cXML)
	nRet:= ShellExecute("Open", cArq , " /k dir", "C:\", 1 )
Else
	MsgInfo("Arquivo XML não encontrado!","Atenção")
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FAtiva   ³ Autor ³ Edson Maricate        ³ Data ³ 18.10.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a pergunte do mata103                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FAtiva()
Pergunte("MTA103",.T.)
Return

/**
	Rotina que retorna os campos da Tabela para ordenação
**/
Static Function Arr2Order()
	Local aOrder := {}

	//Adicionar no Array de Acordo com a Ordem Desejada
	AAdd(aOrder, "Z2_ITEM")
	AAdd(aOrder, "Z2_COD")
	AAdd(aOrder, "Z2_XDESC")
	AAdd(aOrder, "Z2_TIPO")
	AAdd(aOrder, "Z2_CF")
	AAdd(aOrder, "Z2_UM")
	AAdd(aOrder, "Z2_QUANT")
	AAdd(aOrder, "Z2_VUNIT")
	AAdd(aOrder, "Z2_TOTAL")
	AAdd(aOrder, "Z2_TES")
	AAdd(aOrder, "Z2_BASEICM")
	AAdd(aOrder, "Z2_PICM")
	AAdd(aOrder, "Z2_VALICM")
	AAdd(aOrder, "Z2_BASEIPI")
	AAdd(aOrder, "Z2_IPI")
	AAdd(aOrder, "Z2_VALIPI")
	AAdd(aOrder, "Z2_BRICMS")
	AAdd(aOrder, "Z2_ALIQSOL")
	AAdd(aOrder, "Z2_ICMSRET")
	AAdd(aOrder, "Z2_BASEPIS")
	AAdd(aOrder, "Z2_ALQPIS")
	AAdd(aOrder, "Z2_VALPIS")
	AAdd(aOrder, "Z2_BASECOF")
	AAdd(aOrder, "Z2_ALQCOF")
	AAdd(aOrder, "Z2_VALCOF")
	AAdd(aOrder, "Z2_BASIMP1")
	AAdd(aOrder, "Z2_ALIQII")
	AAdd(aOrder, "Z2_II")
	AAdd(aOrder, "Z2_DESPESA")
	AAdd(aOrder, "Z2_VALFRE")
	AAdd(aOrder, "Z2_VALDESC")
	AAdd(aOrder, "Z2_SEGURO")
	AAdd(aOrder, "Z2_NFORI")
	AAdd(aOrder, "Z2_SERIORI")
	AAdd(aOrder, "Z2_ITEMORI")
Return aOrder

/**
	Retorna a Proxima Ordem de acordo com o Soma1
**/
Static Function ProxOrdem(nOrdem, nTam)
	Local cOrdem := Replicate('0', nTam) //Ordem
	Local nI     := 0 //Indice do FOR

	For nI := 1 To nOrdem
		cOrdem := Soma1(cOrdem, nTam)
	Next nI
Return cOrdem