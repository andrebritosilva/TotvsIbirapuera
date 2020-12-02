User Function XFCD2SFT()

Local aSaveArea	:= GetArea()
Local cDoc      := CD2->CD2_DOC

//DbSetOrder(1)

//If DbSeek(xFilial("CD2") + "E" + CD2->CD2_SERIE + CD2->CD2_DOC)

	//While !Eof() .And. cDoc == CD2->CD2_DOC
		//If Alltrim(CD2->CD2_IMP) == "ICM"
			//RecLock("CD2",.F.)
			//CD2_VLTRIB := (CD2_BC * CD2_ALIQ)/100
			//MsUnLock()
		//EndIf
	//	dbSkip()
	//EndDo

//EndIf
RestArea(aSaveArea)

Return .T. 