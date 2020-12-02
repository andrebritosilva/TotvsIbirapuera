#include "totvs.ch"
#include "protheus.ch"
 
User Function TIBIPT()
 
Local cArq    := ""
Local cLinha  := ""
Local lPrim   := .T.
Local aCampos := {}
Local aDados  := {}
Local aPerg   := {}
Local aResp   := {}
Local i := 0
Local j := 0
 
Private aErro := {}

aAdd(aPerg,{1,"Selecione o arquivo: " 	,Space(500) ,"@!",,"DIR",,100,.F.}) 

aResp := {Space(500)}

ParamBox(aPerg,"Importação de Produtos", @aResp,,,,,,) 

cArq := Alltrim(aResp[1])
 
If !File(cArq)
	MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
	Return
EndIf
 
FT_FUSE(cArq)
ProcRegua(RecCount())//ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
 
	IncProc()
 
	cLinha := FT_FREADLN()
 
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP()
EndDo
 
Begin Transaction
	ProcRegua(Len(aDados))
	For i:=1 to Len(aDados)
 
		IncProc("Importando Dados dos Produtos...")
 
		dbSelectArea("ZZ1")
		dbSetOrder(1)
		dbGoTop()
		If !dbSeek(xFilial("ZZ1")+aDados[i,3])
			Reclock("ZZ1",.T.)
			ZZ1->Z1_FILIAL := xFilial("ZZ1")
			For j:=1 to Len(aCampos)
				cCampo  := "ZZ1->ZZ1_" + aCampos[j]
				If cCampo == "ZZ1->ZZ1_QTEST" .Or. cCampo == "ZZ1->ZZ1_QTVD" 
					&cCampo := Val(aDados[i,j])
				Else
					&cCampo := aDados[i,j]
				EndIf
			Next j
			ZZ1->(MsUnlock())
		Else
			Reclock("ZZ1",.F.)
				ZZ1->ZZ1_QTDPR += 1
			ZZ1->(MsUnlock())
		EndIf
	Next i
End Transaction
 
FT_FUSE()
 
ApMsgInfo("Importação dos Produtos concluída com sucesso!")
 
Return