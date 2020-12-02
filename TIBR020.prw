#INCLUDE 'TOTVS.CH'
#INCLUDE 'MSOLE.CH'

Static cRootPath   := AllTrim(GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97()) + If(Right(AllTrim(GetPvProfString(GetEnvServer(), 'RootPath', 'ERROR', GetADV97())), 1) == '/', '', '/'))
Static cStartPath  := AllTrim(GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97()) + If(Right(AllTrim(GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97())), 1) == '/', '', '/'))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³PROGRAMA  ³TIBR020   ³Autor  ³V RASPA                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Impressao grafica do documento RECIBO DE LOCACAO            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function TIBR020()
Local lOk        := .F.
Local aSays      := {}
Local aButtons   := {}
Local aParams    := {}

aAdd(aParams, {1, 'Série'				, Space(TamSX3('F2_SERIE')[1]),,,,, 20, .F.})			//-- MV_PAR01
aAdd(aParams, {1, 'Do Documento'		, Space(TamSX3('F2_DOC')[1]),,,,, 50, .F.})				//-- MV_PAR02
aAdd(aParams, {1, 'Até o Documento'		, Space(TamSX3('F2_DOC')[1]),,,,, 50, .F.})				//-- MV_PAR03
aAdd(aParams, {1, 'Do Cliente'			, Space(TamSX3('F2_CLIENTE')[1]),,, 'SA1',, 60, .F.})	//-- MV_PAR04
aAdd(aParams, {1, 'Da Loja'				, Space(TamSX3('F2_LOJA')[1]),,, 'SA1',, 40, .F.})		//-- MV_PAR05
aAdd(aParams, {1, 'Até o Cliente'		, Space(TamSX3('F2_CLIENTE')[1]),,, 'SA1',, 60, .F.})	//-- MV_PAR06
aAdd(aParams, {1, 'Até a Loja'			, Space(TamSX3('F2_LOJA')[1]),,, 'SA1',, 40, .F.})		//-- MV_PAR07
aAdd(aParams, {1, 'Da Emissão'			, CtoD(Space(TamSX3('F2_EMISSAO')[1])),,,,, 70, .F.})	//-- MV_PAR08
aAdd(aParams, {1, 'Até a Emissão'		, CtoD(Space(TamSX3('F2_EMISSAO')[1])),,,,, 70, .F.})	//-- MV_PAR09
aAdd(aParams, {3, 'Destino/Saída'	, 1, {'Impressora', 'Salvar em Disco'}, 90,, .T.})			//-- MV_PAR10
aAdd(aParams, {3, 'Salvar como'		, 1, {'PDF', 'DOC'}, 90,, .T.})								//-- MV_PAR11
aAdd(aParams, {3, 'Versão MS Word'	, 1, {'Word 97/2003', 'Word 2010/2013'}, 100,, .T.})		//-- MV_PAR12

If ParamBox(aParams, 'Parâmetros')
	// -----------------------------------------------------
	// Dialogo principal para parametrizacao
	// -----------------------------------------------------
	AAdd(aSays, 'Este programa tem por objetivo realizar a impressao dos Recibos de Locação conforme parâmetros informados ')
	AAdd(aSays, 'utilizando a integracao com o Microsoft Word. O modelo para impressão deverá')
	AAdd(aSays, 'estar disponível na pasta: ' + cStartPath + 'MODELOS\')
	AAdd(aButtons, {5, .T., {|| ParamBox(aParams, 'Parâmetros')}})
	AAdd(aButtons, {1, .T., {|o| lOk := .T.,o:oWnd:End()}})
	AAdd(aButtons, {2, .T., {|o| o:oWnd:End()}})

	FormBatch('Impressão Nota de Débito', aSays, aButtons,,, 650)

	If lOk
		Processa({|lEnd| TIBR020Prc(@lEnd)}, 'Aguarde...', 'Realizando a impressao do documento...', .T.)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TIBR020Prc ³ Autor ³V.RASPA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a impressao do Documento                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TIBR020Prc(lEnd)
Local cAliasQry  := ''
Local lContinua  := .T.
Local cArqModel  := ''
Local cExtension := ''
Local cPathDest  := ''
Local cDestino   := MV_PAR10
Local cSaveAs    := MV_PAR11
Local cVersWord  := MV_PAR12
Local aDadosEmp  := {}
Local _cVencto   := ''

// --------------------------------------------
// TRATA A VERSAO DO MS WORD
// --------------------------------------------
If cVersWord == 1
	cArqModel := cStartPath + 'modelos/tibr020.dot'
	//-- Se a versao do Ms Word for a 97/2003 nao permite
	//-- a saida do relatorio em PDF
	If cSaveAs == 1
		Aviso('ATENÇÃO', 'Não é possível realizar a geração do documento no formato "PDF" para versao 97/2003 do Microsoft Word. O formato do documento será reajustado para "DOC"', {'OK'}, 2)
		cSaveAs := 2
	EndIf
Else
	cArqModel   := cStartPath + 'modelos/tibr020.dotm'
EndIf


// ---------------------------------------
// VERIFICA SE O ARQUIVO "MODELO" EXISTE
// ---------------------------------------
If !File(cArqModel)
	lContinua := .F.
	Aviso('ATENÇÃO', 'O arquivo ' + cArqModel + ' não existe! Entre em contato com o Administrador do sistema.', {'OK'}, 2)
EndIf


// ---------------------------------------
// TRATA GRAVACAO EM DISCO
// ---------------------------------------
If lContinua
	If cDestino == 2
		cExtension := If(cSaveAs == 1, '*.PDF', If(cVersWord == 1, '*.DOC', '*.DOCX'))
		cPathDest  := Alltrim(cGetFile ('Arquivo' + cExtension + '|' + cExtension +'|' , 'Selecione a pasta para gravação.', 1, '', .T., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.))
		If Empty(cPathDest)
			Aviso('ATENÇÃO', 'Processo cancelado pelo usuário!', {'OK'}, 2)
			lContinua := .F.
		Else
			lContinua := ChkPerGrv(cPathDest)
			If !lContinua
				Aviso('ATENÇÃO', 'Você não possuí permissão de gravação para pasta selecionada. Tente Selecionar outra pasta.', {'OK'}, 2)
			EndIf
		EndIf
	Endif
EndIf


// ------------------------------------------------
// TRANSFERE MODELO WORD DO SERVIDOR P/ ESTACAO
// ------------------------------------------------
If lContinua
	If !CpyS2T(cArqModel, AllTrim(GetTempPath()))
		lContinua := .F.
		Aviso('ATENÇÃO',;
				'Não foi possível transferir o modelo Word do Servidor para sua estação de trabalho! Tente reiniciar o computador. Caso o problema persista, entre em contato com o Administrador do sistema', {'OK'}, 2)
	Else
		// --------------------------------------------------------
		// SE CONSEGUIU TRANSFERIR O ARQUIVO, RENOMEIA O MESMO
		// PARA PREVENIR, EM CASO DE ERRO, O TRAVAMENTO DO ARQUIVO
		// DE MODELO
		// --------------------------------------------------------
		cArqTemp  := GetNextAlias() + If(cVersWord == 1, '.dot', '.dotm')

		FRename(AllTrim(GetTempPath()) + If(Right(AllTrim(GetTempPath()), 1) == '\', '', '\') + 'tibr020' + If(cVersWord == 1, '.dot', '.dotm'),;
				AllTrim(GetTempPath()) + If(Right(AllTrim(GetTempPath()), 1) == '\', '', '\') + cArqTemp)

		cArqTemp := AllTrim(GetTempPath()) + If(Right(AllTrim(GetTempPath()), 1) == '\', '', '\') + cArqTemp

	EndIf
EndIf

// ------------------------------------------
// IMPRESSAO DO DOCUMENTO
// ------------------------------------------
If lContinua
	// -------------------------
	// OBTEM OS DADOS DO SIGAMAT
	// -------------------------
	aDadosEmp := { 	SM0->M0_NOMECOM,;
					SM0->M0_ENDENT,;
					SM0->M0_COMPENT,;
					SM0->M0_BAIRENT,;
					SM0->M0_CIDENT,;
					SM0->M0_ESTENT,;
					SM0->M0_CEPENT,;
					SM0->M0_TEL,;
					SM0->M0_CGC,;
					SM0->M0_INSC }

	// ------------------------------------------
	// PROCESSA QUERY PARA IMPRESSAO DO DOCUMENTO
	// ------------------------------------------
	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT SF2.F2_DOC, SF4.F4_TEXTO, SF2.F2_EMISSAO,SF2.F2_SERIE, SA1.A1_NOME, SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_PESSOA,
		       SA1.A1_MUN, SA1.A1_BAIRRO, SA1.A1_CGC, SA1.A1_CEP, SA1.A1_EST, SA1.A1_INSCR, SA1.A1_INSCRM, 
		       SE4.E4_DESCRI, SC5.C5_MENNOTA, SB1.B1_DESC, SUM(SD2.D2_QUANT) D2_QUANT, SUM(SD2.D2_PRCVEN) D2_PRCVEN, 
		       SUM(SD2.D2_TOTAL) D2_TOTAL
		  FROM %Table:SF2% SF2
		  JOIN %Table:SA1% SA1
		    ON SA1.A1_FILIAL = %xFilial:SA1%
		   AND SA1.A1_COD    = SF2.F2_CLIENTE
		   AND SA1.A1_LOJA   = SF2.F2_LOJA
		   AND SA1.%NotDel%
		  JOIN %Table:SE4% SE4
		    ON SE4.E4_FILIAL = %xFilial:SE4%
		   AND SE4.E4_CODIGO = F2_COND
		   AND SE4.%NotDel%
		  JOIN %Table:SD2% SD2
		    ON SD2.D2_FILIAL  = %xFilial:SD2%
		   AND SD2.D2_DOC     = SF2.F2_DOC
		   AND SD2.D2_SERIE   = SF2.F2_SERIE
		   AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
		   AND SD2.D2_LOJA    = SF2.F2_LOJA
		   AND SD2.%NotDel% 
		  JOIN %Table:SF4% SF4
		    ON SF4.F4_FILIAL = %xFilial:SF4%
		   AND SF4.F4_CODIGO = SD2.D2_TES
		   AND SF4.%NotDel%
		  JOIN %Table:SB1% SB1
		    ON SB1.B1_FILIAL = %xFilial:SB1%
		   AND SB1.B1_COD    = SD2.D2_COD
		   AND SB1.%NotDel%
		  JOIN %Table:SC5% SC5
		    ON SC5.C5_FILIAL = %xFilial:SC5%
		   AND SC5.C5_NUM    = SD2.D2_PEDIDO
		   AND SC5.%NotDel%
		 WHERE SF2.F2_FILIAL = %xFilial:SF2%
		   AND SF2.F2_SERIE  = %Exp:MV_PAR01%
		   AND SF2.F2_DOC BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
		   AND SF2.F2_CLIENTE BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
		   AND SF2.F2_LOJA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR07%
		   AND SF2.F2_EMISSAO BETWEEN %Exp:DtoS(MV_PAR08)% AND %Exp:DtoS(MV_PAR09)%
		   AND SF2.%NotDel% 
		 GROUP BY SF2.F2_DOC, SF4.F4_TEXTO, SF2.F2_EMISSAO, SF2.F2_SERIE, SA1.A1_NOME, SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_PESSOA,
		       SA1.A1_MUN, SA1.A1_BAIRRO, SA1.A1_CGC, SA1.A1_CEP, SA1.A1_EST, SA1.A1_INSCR, SA1.A1_INSCRM,
		       SE4.E4_DESCRI, SC5.C5_MENNOTA, SB1.B1_DESC
	EndSQL

	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof())
			//-- Arquivo que sera gerado:
			cNewFile := cPathDest + If(Right(cPathDest, 1) == '\', '', '\') + DtoS(dDataBase) + '_' + StrTran(Time(), ':', '') + '_tibr020' + StrTran(cExtension, '*', '')

			// --------------------------------------
			// ESTABELECE COMUNICACAO COM O MS WORD
			// --------------------------------------
			oWord := OLE_CreateLink()
			OLE_SetProperty(oWord, oleWdVisible, .F.)
			If oWord == "-1"
				Aviso('ATENÇÃO', 'Não foi possível estabelecer a conexao com o MS-Word!', {'OK'}, 2)
				Exit
			Else
				// -----------------------------------
				// CARREGA MODELO
				// -----------------------------------
				OLE_NewFile(oWord, Alltrim(cArqTemp))

				// -------------------------------------------
				// REALIZA O PROCESSO DE MACRO SUBSTITUICAO
				// DOS CAMPOS DO MODELO WORD
				// -------------------------------------------
				OLE_SetDocumentVar(oWord, 'cRazaoSocial'	, AllTrim(aDadosEmp[01]))
				OLE_SetDocumentVar(oWord, 'cEnd'			, AllTrim(aDadosEmp[02]))
				OLE_SetDocumentVar(oWord, 'cBairro'			, AllTrim(aDadosEmp[04]))
				OLE_SetDocumentVar(oWord, 'cCEP'			, aDadosEmp[07])
				OLE_SetDocumentVar(oWord, 'cMunic'			, AllTrim(aDadosEmp[05]))
				OLE_SetDocumentVar(oWord, 'cUF'				, aDadosEmp[06])
				OLE_SetDocumentVar(oWord, 'cCNPJ'			, Transform(aDadosEmp[09], '@R 99.999.999/9999-99'))
				OLE_SetDocumentVar(oWord, 'cTel'			, aDadosEmp[08])
				
				SE1->(DbSetOrder(1)) // Indice 1 - E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->(DbSeek(xFilial('SE1')+(cAliasQry)->F2_SERIE +(cAliasQry)->F2_DOC))
					
					While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial('SE1') .And. SE1->E1_PREFIXO == (cAliasQry)->F2_SERIE  .And.;
					SE1->E1_NUM == (cAliasQry)->F2_DOC
						
						If !Empty(_cVencto)
							_cVencto += ', '
						EndIf
						
						_cVencto += DToC(SE1->E1_VENCTO)
						
						SE1->(DbSkip())
					EndDo
					
				EndIf
				OLE_SetDocumentVar(oWord, 'dDtVenc'			, AllTrim(_cVencto))
				OLE_SetDocumentVar(oWord, 'cNum'			, (cAliasQry)->F2_DOC )
				OLE_SetDocumentVar(oWord, 'cDtEmissExt'		, Right((cAliasQry)->F2_EMISSAO, 2) + ' de ' + MesExtenso(Month(StoD((cAliasQry)->F2_EMISSAO))) + ' de ' + Left((cAliasQry)->F2_EMISSAO, 4))
				OLE_SetDocumentVar(oWord, 'cRazaoSocialCli'	, AllTrim((cAliasQry)->A1_NOME))
				OLE_SetDocumentVar(oWord, 'cEndCli'			, AllTrim((cAliasQry)->A1_END))
				OLE_SetDocumentVar(oWord, 'cComplCli'		, AllTrim((cAliasQry)->A1_COMPLEM))
				OLE_SetDocumentVar(oWord, 'cBairroCli'		, AllTrim((cAliasQry)->A1_BAIRRO))
				OLE_SetDocumentVar(oWord, 'cMunicCli'		, AllTrim((cAliasQry)->A1_MUN))
				OLE_SetDocumentVar(oWord, 'cCEPCli'			, Transform((cAliasQry)->A1_CEP, PesqPict('SA1', 'A1_CEP')))
				OLE_SetDocumentVar(oWord, 'cUFCli'			, (cAliasQry)->A1_EST)
				OLE_SetDocumentVar(oWord, 'cCNPJCli'		, Transform((cAliasQry)->A1_CGC, If((cAliasQry)->A1_PESSOA == 'J', '@R 99.999.999/9999-99', '@R 999.999.999-99')))
				OLE_SetDocumentVar(oWord, 'nQtde'			, Transform((cAliasQry)->D2_QUANT, '@E 999,999,999'))
				OLE_SetDocumentVar(oWord, 'cDescr'			, AllTrim((cAliasQry)->B1_DESC))
				OLE_SetDocumentVar(oWord, 'nVlrUnit'		, Transform((cAliasQry)->D2_TOTAL, PesqPict('SD2', 'D2_TOTAL')))
				OLE_SetDocumentVar(oWord, 'nVlrBruto'		, Transform((cAliasQry)->D2_TOTAL, PesqPict('SD2', 'D2_TOTAL')))	
				OLE_SetDocumentVar(oWord, 'nVlrLiq'			, Transform((cAliasQry)->D2_TOTAL, PesqPict('SD2', 'D2_TOTAL')))
				OLE_SetDocumentVar(oWord, 'nVlrTot'			, Transform((cAliasQry)->D2_TOTAL, PesqPict('SD2', 'D2_TOTAL')))
				OLE_SetDocumentVar(oWord, 'cObserv'			, AllTrim((cAliasQry)->C5_MENNOTA))

				//-- Atualiza os campos
				OLE_UpDateFields(oWord)

				//-- Determina a saida do relatorio:
				If cDestino == 1
					OLE_PrintFile(oWord, cNewFile,,, 1)
					Sleep(1000)
				Else
					OLE_SaveAsFile(oWord, cNewFile,,,, If(cSaveAs == 1, '17', NIL)) //--Parametro '17' salva em pdf
				Endif

				//--Fecha link com MS-Word
				OLE_CloseFile(oWord)
				OLE_CloseLink(oWord)
			EndIf
			(cAliasQry)->(DbSkip())
		End
		(cAliasQry)->(DbCloseArea())
		MsgInfo('Impressão/Geração realizada com sucesso!')
	Else
		MsgAlert('Não há dados para impressão. Verifique os parâmetros informados!')
	EndIf
	
	//-- Exclui arquivo modelo na estacao:
	FErase(cArqTemp)
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ChkPerGrv ³ Autor ³V.RASPA                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa permissao de gravacao na pasta indicada para geracao  ³±±
±±³          ³do relatorio                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChkPerGrv(cPath)
Local cFileTmp := CriaTrab(NIL, .F.)
Local nHdlTmp  := 0
Local lRet     := .F.

cPath   := AllTrim(cPath)
nHdlTmp := MSFCreate(cPath + If(Right(cPath, 1) <> '\', '\', '') + cFileTmp + '.TMP', 0)
If nHdlTmp <= 0
	lRet := .F.
Else
	lRet := .T.
	FClose(nHdlTmp)
	FErase(cPath + If(Right(cPath, 1) <> '\', '\', '') + cFileTmp + '.TMP')
EndIf

Return(lRet)
