User Function Testado()

Local aCampos := {}
Local cAlias  := ""

AADD(aCampos,{"E2_FORAGE"   ,"C",TamSX3("E2_FORAGE" )[1],0})
AADD(aCampos,{"E2_FORCTA"   ,"C",TamSX3("E2_FORCTA" )[1],0})
AADD(aCampos,{"E2_NOMFOR"   ,"C",TamSX3("E2_NOMFOR" )[1],0})
AADD(aCampos,{"E2_CNPJRET"  ,"C",TamSX3("E2_CNPJRET")[1],0})
AADD(aCampos,{"E2_EMISSAO"  ,"C",TamSX3("E2_EMISSAO")[1],0})
AADD(aCampos,{"E2_NUM"      ,"C",TamSX3("E2_NUM"    )[1],0})
AADD(aCampos,{"E2_VALOR"    ,"C",TamSX3("E2_VALOR"  )[1],0})
AADD(aCampos,{"E2_VENCTO"   ,"C",TamSX3("E2_VENCTO" )[1],0})

cAlias := "SE2TRB"

// Criando o Objeto de ArqTemporario  
_oTIB := FwTemporaryTable():New("SE2TRB")

// Criando a Strutura do objeto  
_oTIB:SetFields(aCampos)

// Criando o Indicie da Tabela
_oTIB:AddIndex("1",{"E2_NUM"})

_oTIB:Create()

DbselectArea("SE2")
dbGoTop()

Do While !SA1->(Eof())
	RecLock("SE2TRB",.T.)
	SE2TRB->E2_FORAGE    := SE2TRB->E2_FORAGE 
	SE2TRB->E2_FORCTA    := SE2TRB->E2_FORCTA
	SE2TRB->E2_NOMFOR    := SE2TRB->E2_NOMFOR
	SE2TRB->E2_CNPJRET   := SE2TRB->E2_CNPJRET
	SE2TRB->E2_EMISSAO   := SE2TRB->E2_EMISSAO
	SE2TRB->E2_NUM       := SE2TRB->E2_NUM
	SE2TRB->E2_VALOR     := SE2TRB->E2_VALOR
	SE2TRB->E2_VENCTO    := SE2TRB->E2_VENCTO
	MsUnLock()
	SE2->(dbskip())
Enddo

DbSelectArea("SE2")

Return