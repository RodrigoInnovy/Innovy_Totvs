//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Variáveis utilizadas no fonte inteiro
Static nPadLeft    := 0
Static nPadRight   := 1            
Static nPadCenter  := 2                                      
Static nPosCod     := 0000                                                              
Static nPosDesc    := 0000
Static nPosUnid    := 0000       
Static nPosQuan    := 0000                             
Static nPosVUni    := 0000                                                     
Static nPosVTot    := 0000
Static nPosBIcm    := 0000
Static nPosVIcm    := 0000                     
Static nPosVIPI    := 0000                                            
Static nPosAIcm    := 0000
Static nPosAIpi    := 0000
Static nPosSTUn    := 0000             
Static nPosSTVl    := 0000                                   
Static nPosSTBa    := 0000                                                        
Static nPosSTTo    := 0000
Static nTamFundo   := 15 
Static cEmpEmail   := Alltrim(SuperGetMV("MV_X_EMAIL", .F., "email@empresa.com.br"))
Static cEmpSite    := Alltrim(SuperGetMV("MV_X_HPAGE", .F., "http://www.empresa.com.br")) 
Static nCorAzul    := RGB(062, 179, 206)
Static cNomeFont   := "Arial"                          
Static nTamFontCab := -10
Static nEspacoLinha:= 10
Static nEspacoDet  := 8
Static oFontDet    := Nil                                                       
Static oFontDetN   := Nil
Static oFontRod    := Nil  
Static oFontTit    := Nil                         
Static oFontCab    := Nil                                                
Static oFontCabN   := Nil
Static cMaskPad    := "@E 999,999.99"
Static cMaskTel    := "@R (99) 99999999"                     
Static cMaskCNPJ   := "@R 99.999.999/9999-99"
Static cMaskCEP    := "@R 99999-999"     
Static cMaskCPF    := "@R 999.999.999-99"                                         
Static cMaskQtd    := PesqPict("SC6", "C6_QTDVEN")
Static cMaskPrc    := PesqPict("SC6", "C6_PRCVEN")                                
Static cMaskVlr    := PesqPict("SC6", "C6_VALOR")
Static cMaskFrete  := PesqPict("SC5", "C5_FRETE")                                 
Static cMaskPBru   := PesqPict("SC5", "C5_PBRUTO")
Static cMaskPLiq   := PesqPict("SC5", "C5_PESOL")                                 

/*/{Protheus.doc} zRPedVen
	Impressão gráfica genérica de Pedido de Venda (em pdf)
	@type function
	@author Atilio (Refatorado - Controle Fixo de Pixels por Fonte)
	@since 19/06/2016
	@version 2.2
/*/
User Function zRPedVen()

	Local aArea      := GetArea()
	Local aAreaC5    := SC5->(GetArea())
	Local aPergs     := {}
	Local aRetorn    := {}
	Local oProcess   := Nil
	Local nTamFont   := 3 // Opção 3 (Tamanho 10) por padrão
	Local nOpcaoRet  := 0
	
	//Variáveis usadas nas outras funções
	Private cLogoEmp := fLogoEmp()
	Private cPedDe   := SC5->C5_NUM
	Private cPedAt   := SC5->C5_NUM
	Private cLayout  := "1"
	Private cTipoBar := "3"
	Private cImpDupl := "1"
	Private cZeraPag := "1"
	
	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Pedido De", cPedDe, "", ".T.", "SC5", ".T.", 80, .T.})
	aAdd(aPergs, {1, "Pedido Até", cPedAt, "", ".T.", "SC5", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Layout", Val(cLayout), {"1=Dados com ST", "2=Dados com IPI"}, 100, ".T.", .F.})
	aAdd(aPergs, {2, "Código de Barras", Val(cTipoBar), {"1=Número do Pedido", "2=Filial + Número do Pedido", "3=Sem Código de Barras"}, 100, ".T.", .F.})
	aAdd(aPergs, {2, "Imprimir Previsão Duplicatas", Val(cImpDupl), {"1=Sim", "2=Não"}, 100, ".T.", .F.})
	aAdd(aPergs, {2, "Zera a Página ao trocar Pedido", Val(cZeraPag), {"1=Sim", "2=Não"}, 100, ".T.", .F.})
	aAdd(aPergs, {2, "Tam. Fonte Geral", nTamFont, {"8", "9", "10", "11", "12"}, 50, ".T.", .F.})
	
	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os parâmetros", @aRetorn, , , , , , , , .F., .F.)
		cPedDe      := aRetorn[1]
		cPedAt      := aRetorn[2]
		cLayout     := cValToChar(aRetorn[3])
		cTipoBar    := cValToChar(aRetorn[4])
		cImpDupl    := cValToChar(aRetorn[5])
		cZeraPag    := cValToChar(aRetorn[6])
		
		// Tratamento de Cache de Pergunta para evitar Type Mismatch
		nOpcaoRet := Val(cValToChar(aRetorn[7]))
		If nOpcaoRet >= 8 .And. nOpcaoRet <= 12
			nTamFontCab := -nOpcaoRet 
		Else
			nTamFontCab := -(nOpcaoRet + 7) 
		EndIf
		
		// Alturas milimétricas justas (espaçamento mínimo vertical)
		nEspacoLinha := Abs(nTamFontCab)
		nEspacoDet   := Abs(nTamFontCab) - 2 
		
		//Função que muda alinhamento e fontes
		fMudaLayout()
		
		//Chama o processamento do relatório
		oProcess := MsNewProcess():New({|| fMontaRel(@oProcess) }, "Impressão Pedidos de Venda", "Processando", .F.)
		oProcess:Activate()
	EndIf
	
	RestArea(aAreaC5)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 *---------------------------------------------------------------------*/
Static Function fMontaRel(oProc)
	Local aDescProd		:= {}
	Local nTotIte       := 0
	Local nItAtu        := 0
	Local nTotPed       := 0
	Local nPedAtu       := 0
	Local cQryPed       := ""
	Local cQryIte       := ""
	Local nBasICM       := 0
	Local nValICM       := 0
	Local nValIPI       := 0
	Local nAlqICM       := 0
	Local nAlqIPI       := 0
	Local nValSol       := 0
	Local nBasSol       := 0
	Local nPrcUniSol    := 0
	Local nTotSol       := 0
	Local cNomeRel      := "pedido_venda_"+FunName()+"_"+RetCodUsr()+"_"+dToS(Date())+"_"+StrTran(Time(), ":", "-")
	Local nI			:= 0
	
	Private oPrintPvt
	Private cHoraEx     := Time()
	Private nPagAtu     := 1
	Private aDuplicatas := {}
	Private nLinAtu     := 0
	Private nLinFin     := 780
	Private nColIni     := 010
	Private nColFin     := 550
	Private nColMeio    := (nColFin-nColIni)/2
	Private nTotFrete   := 0
	Private nValorTot   := 0
	Private nTotalST    := 0
	Private nTotVal     := 0
	Private nTotIPI     := 0
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	DbSelectArea("SC5")
	
	oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
	oPrintPvt:cPathPDF := GetTempPath()
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetPortrait()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)
	
	If TcGetDb() $ "INFORMIX*ORACLE"
		cFuncNull := "NVL"
	ElseIf TcGetDb() $ " DB2*POSTGRES"
		cFuncNull := "COALESCE"
	Else
		cFuncNull := "ISNULL"
	EndIf

	//Selecionando os pedidos
	/*
	cQryPed := " SELECT "                                        + CRLF
	cQryPed += "    C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, " + CRLF
	cQryPed += "    "+cFuncNull+"(A1_NOME, '') AS A1_NOME, "     + CRLF
	cQryPed += "    "+cFuncNull+"(A1_PESSOA, '') AS A1_PESSOA, " + CRLF
	cQryPed += "    "+cFuncNull+"(A1_CGC, '') AS A1_CGC, "       + CRLF
	cQryPed += "    C5_CONDPAG, "                                + CRLF
	cQryPed += "    "+cFuncNull+"(E4_DESCRI, '') AS E4_DESCRI, " + CRLF
	cQryPed += "    C5_TRANSP, "                                 + CRLF
	cQryPed += "    "+cFuncNull+"(A4_NOME, '') AS A4_NOME, "     + CRLF
	cQryPed += "    C5_VEND1, "                                  + CRLF
	cQryPed += "    "+cFuncNull+"(A3_NOME, '') AS A3_NOME, "     + CRLF
	cQryPed += "    C5_TPFRETE, "                                + CRLF
	cQryPed += "    C5_FRETE, "                                  + CRLF
	cQryPed += "    C5_PESOL, "                                  + CRLF
	cQryPed += "    C5_PBRUTO, "                                 + CRLF
	cQryPed += "    C5_MENNOTA, "                                + CRLF
	cQryPed += "    C5_XREC, "                                   + CRLF
	cQryPed += "    SC5.R_E_C_N_O_ AS C5REC "                    + CRLF
	cQryPed += " FROM "                                          + CRLF
	cQryPed += "    "+RetSQLName("SC5")+" SC5 "                  + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( "   + CRLF
	cQryPed += "        A1_FILIAL   = '"+FWxFilial("SA1")+"' "   + CRLF
	cQryPed += "        AND A1_COD  = SC5.C5_CLIENTE "           + CRLF
	cQryPed += "        AND A1_LOJA = SC5.C5_LOJACLI "           + CRLF
	cQryPed += "        AND SA1.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SE4")+" SE4 ON ( "   + CRLF
	cQryPed += "        E4_FILIAL     = '"+FWxFilial("SE4")+"' " + CRLF
	cQryPed += "        AND E4_CODIGO = SC5.C5_CONDPAG "         + CRLF
	cQryPed += "        AND SE4.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA4")+" SA4 ON ( "   + CRLF
	cQryPed += "        A4_FILIAL  = '"+FWxFilial("SA4")+"' "    + CRLF
	cQryPed += "        AND A4_COD = SC5.C5_TRANSP "             + CRLF
	cQryPed += "        AND SA4.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( "   + CRLF
	cQryPed += "        A3_FILIAL  = '"+FWxFilial("SA3")+"' "    + CRLF
	cQryPed += "        AND A3_COD = SC5.C5_VEND1 "              + CRLF
	cQryPed += "        AND SA3.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += " WHERE "                                         + CRLF
	cQryPed += "    C5_FILIAL   = '"+FWxFilial("SC5")+"' "       + CRLF
	cQryPed += "    AND C5_NUM >= '"+cPedDe+"' "                 + CRLF
	cQryPed += "    AND C5_NUM <= '"+cPedAt+"' "                 + CRLF
	cQryPed += "    AND SC5.D_E_L_E_T_ = ' ' "                   + CRLF
		
	TCQuery cQryPed New Alias "QRY_PED"
	
	TCSetField("QRY_PED", "C5_EMISSAO", "D")
	*/
	BeginSql Alias "QRY_PED"

	column C5_EMISSAO as Date

    SELECT 
        SC5.C5_FILIAL,
        SC5.C5_NUM,
        SC5.C5_EMISSAO,
        SC5.C5_CLIENTE,
        SC5.C5_LOJACLI,
        SA1.A1_NOME      AS A1_NOME,
        SA1.A1_PESSOA    AS A1_PESSOA,
        SA1.A1_CGC       AS A1_CGC,
        SC5.C5_CONDPAG,
        SE4.E4_DESCRI    AS E4_DESCRI,
        SC5.C5_TRANSP,
        SA4.A4_NOME      AS A4_NOME,
        SC5.C5_VEND1,
        SA3.A3_NOME      AS A3_NOME,
        SC5.C5_TPFRETE,
        SC5.C5_FRETE,
        SC5.C5_PESOL,
        SC5.C5_PBRUTO,
        SC5.C5_MENNOTA,
        SC5.R_E_C_N_O_    AS C5REC, 
		SC5.C5_XREC

    FROM %Table:SC5% SC5

        LEFT JOIN %Table:SA1% SA1
            ON SA1.A1_FILIAL = %xFilial:SA1%
           AND SA1.A1_COD    = SC5.C5_CLIENTE
           AND SA1.A1_LOJA   = SC5.C5_LOJACLI
           AND SA1.%NotDel%

        LEFT JOIN %Table:SE4% SE4
            ON SE4.E4_FILIAL = %xFilial:SE4%
           AND SE4.E4_CODIGO = SC5.C5_CONDPAG
           AND SE4.%NotDel%

        LEFT JOIN %Table:SA4% SA4
            ON SA4.A4_FILIAL = %xFilial:SA4%
           AND SA4.A4_COD    = SC5.C5_TRANSP
           AND SA4.%NotDel%

        LEFT JOIN %Table:SA3% SA3
            ON SA3.A3_FILIAL = %xFilial:SA3%
           AND SA3.A3_COD    = SC5.C5_VEND1
           AND SA3.%NotDel%

    WHERE 
        SC5.C5_FILIAL = %xFilial:SC5%
        AND SC5.C5_NUM BETWEEN %Exp:cPedDe% AND %Exp:cPedAt%
        AND SC5.%NotDel%

	EndSql

	Count To nTotPed
	oProc:SetRegua1(nTotPed)
	
	If nTotPed != 0
	
		QRY_PED->(DbGoTop())
		While !QRY_PED->(EoF())
			If cZeraPag == "1"
				nPagAtu := 1
			EndIf
			nPedAtu++
			oProc:IncRegua1("Processando o pedido "+cValToChar(nPedAtu)+" de "+cValToChar(nTotPed)+"...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")
			
			fImpCab()
			
			nItAtu   := 0
			nTotIte  := 0
			nTotalST := 0
			nTotIPI  := 0
			SC5->(DbGoTo(QRY_PED->C5REC))
			MaFisIni(SC5->C5_CLIENTE, SC5->C5_LOJACLI, Iif(SC5->C5_TIPO $ "D;B", "F", "C"), SC5->C5_TIPO, SC5->C5_TIPOCLI, MaFisRelImp("MT100", {"SF2", "SD2"}), , , "SB1", "MATA461")
			
			cQryIte := " SELECT C6_PRODUTO, "+cFuncNull+"(C6_DESCRI, '') AS C6_DESCRI, C6_UM, C6_ENTREG, C6_TES, C6_QTDVEN, C6_PRCVEN, C6_VALDESC, C6_NFORI, C6_SERIORI, C6_VALOR " + CRLF
			cQryIte += " FROM "+RetSQLName("SC6")+" SC6 " + CRLF
			cQryIte += " LEFT JOIN "+RetSQLName("SB1")+" SB1 ON ( B1_FILIAL = '"+FWxFilial("SB1")+"' AND B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' ) " + CRLF
			cQryIte += " WHERE C6_FILIAL = '"+FWxFilial("SC6")+"' AND C6_NUM = '"+QRY_PED->C5_NUM+"' AND SC6.D_E_L_E_T_ = ' ' ORDER BY C6_ITEM " + CRLF
			
			TCQuery cQryIte New Alias "QRY_ITE"
			TCSetField("QRY_ITE", "C6_ENTREG", "D")
			Count To nTotIte
			nValorTot := 0
			oProc:SetRegua2(nTotIte)
			
			QRY_ITE->(DbGoTop())
			While !QRY_ITE->(EoF())
				nItAtu++
				oProc:IncRegua2("Calculando impostos - item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")
				SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->C6_PRODUTO))
				MaFisAdd(QRY_ITE->C6_PRODUTO, QRY_ITE->C6_TES, QRY_ITE->C6_QTDVEN, QRY_ITE->C6_PRCVEN, QRY_ITE->C6_VALDESC, QRY_ITE->C6_NFORI, QRY_ITE->C6_SERIORI, 0, 0, 0, 0, 0, QRY_ITE->C6_VALOR, 0, SB1->(RecNo()), 0)
				
				nQtdPeso := QRY_ITE->C6_QTDVEN*SB1->B1_PESO
				MaFisLoad("IT_VALMERC", QRY_ITE->C6_VALOR, nItAtu)				
				MaFisAlt("IT_PESO", nQtdPeso, nItAtu)
				QRY_ITE->(DbSkip())
			EndDo
			
			MaFisAlt("NF_FRETE", SC5->C5_FRETE)
			MaFisAlt("NF_SEGURO", SC5->C5_SEGURO)
			MaFisAlt("NF_DESPESA", SC5->C5_DESPESA) 
			MaFisAlt("NF_AUTONOMO", SC5->C5_FRETAUT)
			
			If SC5->C5_DESCONT > 0
				MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC")-0.01, SC5->C5_DESCONT+MaFisRet(, "NF_DESCONTO")) )
			EndIf
			
			If SC5->C5_PDESCAB > 0
				MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC")*SC5->C5_PDESCAB/100, "C6_VALOR") + MaFisRet(, "NF_DESCONTO"))
			EndIf
			
			oProc:IncRegua2("...")
			oProc:SetRegua2(nTotIte)
			nItAtu := 0
			QRY_ITE->(DbGoTop())
			While !QRY_ITE->(EoF())
				nItAtu++
				oProc:IncRegua2("Imprimindo item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")
				
				SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->C6_PRODUTO))
				aDescProd := QbTexto(Alltrim(QRY_ITE->C6_DESCRI), Iif(cLayout == "1", 58, 40), " ")

				nBasICM    := MaFisRet(nItAtu, "IT_BASEICM")
				nValICM    := MaFisRet(nItAtu, "IT_VALICM")
				nValIPI    := MaFisRet(nItAtu, "IT_VALIPI")
				nAlqICM    := MaFisRet(nItAtu, "IT_ALIQICM")
				nAlqIPI    := MaFisRet(nItAtu, "IT_ALIQIPI")
				nValSol    := (MaFisRet(nItAtu, "IT_VALSOL") / QRY_ITE->C6_QTDVEN) 
				nBasSol    := MaFisRet(nItAtu, "IT_BASESOL")
				nPrcUniSol := QRY_ITE->C6_PRCVEN + nValSol
				nTotSol    := nPrcUniSol * QRY_ITE->C6_QTDVEN
				nTotalST   += MaFisRet(nItAtu, "IT_VALSOL")
				nTotIPI    += nValIPI
				
				// As larguras (quinto parametro) correspondem extamente à posição da próxima coluna 
				// Isso garante que nunca haverá corte ou desalinhamento.
				If cLayout == "1"
					oPrintPvt:SayAlign(nLinAtu, nPosCod,  QRY_ITE->C6_PRODUTO,                               oFontDet, 050, nEspacoDet, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosDesc, aDescProd[1],                                      oFontDet, 270, nEspacoDet, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosQuan, Alltrim(Transform(QRY_ITE->C6_QTDVEN, cMaskQtd)),  oFontDet, 060, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVUni, Alltrim(Transform(QRY_ITE->C6_PRCVEN, cMaskPrc)),  oFontDet, 075, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVTot, Alltrim(Transform(QRY_ITE->C6_VALOR, cMaskVlr)),   oFontDet, 085, nEspacoDet, , nPadRight, )
				Else
					oPrintPvt:SayAlign(nLinAtu, nPosCod, QRY_ITE->C6_PRODUTO,                                oFontDet, 035, nEspacoDet, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosDesc, aDescProd[1],                                      oFontDet, 145, nEspacoDet, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosUnid, QRY_ITE->C6_UM,                                    oFontDet, 025, nEspacoDet, , nPadLeft, )
					oPrintPvt:SayAlign(nLinAtu, nPosQuan, Alltrim(Transform(QRY_ITE->C6_QTDVEN, cMaskQtd)),  oFontDet, 035, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVUni, Alltrim(Transform(QRY_ITE->C6_PRCVEN, cMaskPrc)),  oFontDet, 035, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVTot, Alltrim(Transform(QRY_ITE->C6_VALOR, cMaskVlr)),   oFontDet, 050, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosBIcm, Alltrim(Transform(nBasICM, cMaskPad)),             oFontDet, 045, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVIcm, Alltrim(Transform(nValICM, cMaskPad)),             oFontDet, 045, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosVIPI, Alltrim(Transform(nValIPI, cMaskPad)),             oFontDet, 040, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosAIcm, Alltrim(Transform(nAlqICM, cMaskPad)),             oFontDet, 040, nEspacoDet, , nPadRight, )
					oPrintPvt:SayAlign(nLinAtu, nPosAIpi, Alltrim(Transform(nAlqIPI, cMaskPad)),             oFontDet, 045, nEspacoDet, , nPadRight, )
				EndIf
				
				nLinAtu += nEspacoDet

				If Len(aDescProd) > 1
					For nI := 2 To Len(aDescProd)
						// Mesma largura reservada para quebra de texto
						oPrintPvt:SayAlign(nLinAtu, nPosDesc, aDescProd[nI], oFontDet, Iif(cLayout == "1", 270, 145), nEspacoDet, , nPadLeft, )
						nLinAtu += nEspacoDet
					Next
				EndIf

				// Espaco separador entre itens
				nLinAtu += nEspacoDet

				If nLinAtu >= nLinFin
					fImpRod()
					fImpCab()
				EndIf

				nValorTot += QRY_ITE->C6_VALOR
				QRY_ITE->(DbSkip())
			EndDo
			nTotFrete := MaFisRet(, "NF_FRETE")
			nTotVal := MaFisRet(, "NF_TOTAL")
			fMontDupl()
			QRY_ITE->(DbCloseArea())
			MaFisEnd()
			
			fImpTot()
			
			//Se tiver mensagem da observação
			If !Empty(QRY_PED->C5_XREC)
				fMsgObs()
			EndIf
			
			If cImpDupl == "1"
				fImpDupl()
			EndIf
			
			fImpRod()
			QRY_PED->(DbSkip())
		EndDo
		
		oPrintPvt:Preview()
	
	Else
		MsgStop("Não há pedidos!", "Atenção")
	EndIf
	QRY_PED->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 *---------------------------------------------------------------------*/
Static Function fImpCab()

	Local nLinCab     := 025
	Local nLinCabOrig := nLinCab
	Local cCodBar     := ""
	Local lCNPJ       := (QRY_PED->A1_PESSOA != "F")
	Local cCliAux     := QRY_PED->C5_CLIENTE+" "+QRY_PED->C5_LOJACLI+" - "+QRY_PED->A1_NOME
	Local cCGC        := ""
	Local cFretePed   := ""
	
	Local cEmpresa    := Iif(Empty(SM0->M0_NOMECOM), Alltrim(SM0->M0_NOME), Alltrim(SM0->M0_NOMECOM))
	Local cEmpTel     := Alltrim(Transform(SubStr(SM0->M0_TEL, 3, Len(SM0->M0_TEL)), cMaskTel))
	Local cEmpFax     := Alltrim(Transform(SubStr(SM0->M0_FAX, 3, Len(SM0->M0_FAX)), cMaskTel))
	Local cEmpCidade  := AllTrim(SM0->M0_CIDENT)+" / "+SM0->M0_ESTENT
	Local cEmpCnpj    := Alltrim(Transform(SM0->M0_CGC, cMaskCNPJ))
	Local cEmpCep     := Alltrim(Transform(SM0->M0_CEPENT, cMaskCEP))
	
	Local nAltLin     := nEspacoLinha 
	Local nQtdLinhas  := 8
	Local nAltCaixa   := (nAltLin * nQtdLinhas) + nTamFundo + 4 // +4 para respiro na base do quadro
	
	Local nLargLblEmi, nLargLblPed
	Local nColLblEmi  := 0
	Local nColValEmi  := 0
	Local nWidValEmi  := 0
	Local nColLblPed  := 0
	Local nColValPed  := 0
	Local nWidValPed  := 0
	
	// FIX DEFINITIVO: Configuração manual de Pixels para colar o Rótulo no Valor e NUNCA sumir texto
	If Abs(nTamFontCab) <= 8
		nLargLblEmi := 46
		nLargLblPed := 56
	ElseIf Abs(nTamFontCab) == 9
		nLargLblEmi := 51
		nLargLblPed := 62
	ElseIf Abs(nTamFontCab) == 10
		nLargLblEmi := 56
		nLargLblPed := 68
	ElseIf Abs(nTamFontCab) == 11
		nLargLblEmi := 61
		nLargLblPed := 74
	Else
		nLargLblEmi := 66
		nLargLblPed := 80
	EndIf
	
	nColLblEmi  := nColIni + 65
	nColValEmi  := nColLblEmi + nLargLblEmi 
	nWidValEmi  := (nColMeio - 3) - nColValEmi

	nColLblPed  := nColMeio + 8
	nColValPed  := nColLblPed + nLargLblPed
	nWidValPed  := nColFin - nColValPed 
	
	oPrintPvt:StartPage()
	
	// ==================== EMITENTE ====================
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + nAltCaixa, nColMeio-3)
	oPrintPvt:SayAlign(nLinCab, nColIni+5, "Emitente:", oFontTit, 060, nTamFundo, nCorAzul, nPadLeft, )
	oPrintPvt:Line(nLinCab+nTamFundo, nColIni, nLinCab+nTamFundo, nColMeio-3)
	nLinCab += nTamFundo + 2 
	
	oPrintPvt:SayBitmap(nLinCab, nColIni+5, cLogoEmp, 054, 054)
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "Empresa:", oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpresa,   oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "CNPJ:",    oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpCnpj,   oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "Cidade:",  oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpCidade, oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "CEP:",     oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpCep,    oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "Telefone:",oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpTel,    oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "FAX:",     oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpFax,    oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "e-Mail:",  oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpEmail,  oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblEmi, "Home Page:",oFontCabN, nLargLblEmi, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValEmi, cEmpSite,   oFontCab,  nWidValEmi,  nAltLin, , nPadLeft, )
	
	// ==================== PEDIDO ====================
	nLinCab := nLinCabOrig
	
	oPrintPvt:Box(nLinCab, nColMeio+3, nLinCab + nAltCaixa, nColFin)
	oPrintPvt:SayAlign(nLinCab, nColMeio+8, "Pedido:", oFontTit, nLargLblPed, nTamFundo, nCorAzul, nPadLeft, )
	oPrintPvt:Line(nLinCab+nTamFundo, nColMeio+3, nLinCab+nTamFundo, nColFin)
	nLinCab += nTamFundo + 2
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Núm.Pedido:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, QRY_PED->C5_NUM, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Dt.Emissão:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, dToC(QRY_PED->C5_EMISSAO), oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Cliente:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, cCliAux, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	cCGC := QRY_PED->A1_CGC
	If lCNPJ
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCNPJ)), "-")
		oPrintPvt:SayAlign(nLinCab, nColLblPed, "CNPJ:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	Else
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCPF)), "-")
		oPrintPvt:SayAlign(nLinCab, nColLblPed, "CPF:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	EndIf
	oPrintPvt:SayAlign(nLinCab, nColValPed, cCGC, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Cond.Pagto.:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, QRY_PED->C5_CONDPAG +" - "+QRY_PED->E4_DESCRI, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Transport.:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, QRY_PED->C5_TRANSP +" "+QRY_PED->A4_NOME, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Vendedor:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, QRY_PED->C5_VEND1 + " "+QRY_PED->A3_NOME, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	nLinCab += nAltLin
	
	If QRY_PED->C5_TPFRETE == "C"
		cFretePed := "CIF"
	ElseIf QRY_PED->C5_TPFRETE == "F"
		cFretePed := "FOB"
	ElseIf QRY_PED->C5_TPFRETE == "T"
		cFretePed := "Terceiros"
	Else
		cFretePed := "Sem Frete"
	EndIf
	cFretePed += " - "+Alltrim(Transform(QRY_PED->C5_FRETE, cMaskFrete))
	
	oPrintPvt:SayAlign(nLinCab, nColLblPed, "Frete:", oFontCabN, nLargLblPed, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColValPed, cFretePed, oFontCab, nWidValPed, nAltLin, , nPadLeft, )
	
	// Código de barras
	nLinCab := nLinCabOrig
	If cTipoBar $ "1;2"
		If cTipoBar == "1"
			cCodBar := QRY_PED->C5_NUM
		ElseIf cTipoBar == "2"
			cCodBar := QRY_PED->C5_FILIAL+QRY_PED->C5_NUM
		EndIf
		oPrintPvt:Code128C(nLinCab+30+nTamFundo, nColFin-80, cCodBar, 28)
		oPrintPvt:SayAlign(nLinCab+32+nTamFundo, nColFin-80, cCodBar, oFontRod, 080, nAltLin, , nPadLeft, )
	EndIf
	
	// ==================== SEÇÃO DOS ITENS ====================
	nLinCab := nLinCabOrig + nAltCaixa + 5
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + nTamFundo, nColFin)
	
	oPrintPvt:SayAlign(nLinCab, nColIni, "Relatório de Pedidos de Venda:", oFontTit, nColFin-nColIni, nTamFundo, nCorAzul, nPadCenter, )
	oPrintPvt:Line(nLinCab+nTamFundo, nColIni, nLinCab+nTamFundo, nColFin)
	nLinCab += nTamFundo + 2
	
	// Larguras 100% recalibradas para caber a última coluna (AIcm) com folga no tamanho 12
	If cLayout == "1"
		oPrintPvt:SayAlign(nLinCab, nPosCod,  "Cód.Prod.", oFontDetN, 050, nEspacoDet, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosDesc, "Descrição", oFontDetN, 270, nEspacoDet, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosQuan, "Quant.",    oFontDetN, 060, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVUni, "Vl.Unit.",  oFontDetN, 075, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVTot, "Vl.Total",  oFontDetN, 085, nEspacoDet, , nPadRight, )
	Else
		oPrintPvt:SayAlign(nLinCab, nPosCod, "Cód.Prod.",  oFontDetN, 035, nEspacoDet, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosDesc, "Descrição", oFontDetN, 145, nEspacoDet, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosUnid, "Uni.Med.",  oFontDetN, 025, nEspacoDet, , nPadLeft, )
		oPrintPvt:SayAlign(nLinCab, nPosQuan, "Quant.",    oFontDetN, 035, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVUni, "Vl.Unit.",  oFontDetN, 035, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVTot, "Vl.Total",  oFontDetN, 050, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosBIcm, "BC.ICMS",   oFontDetN, 045, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVIcm, "Vl.ICMS",   oFontDetN, 045, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosVIPI, "Vl.IPI",    oFontDetN, 040, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosAIcm, "A.ICMS",    oFontDetN, 040, nEspacoDet, , nPadRight, )
		oPrintPvt:SayAlign(nLinCab, nPosAIpi, "A.IPI",     oFontDetN, 045, nEspacoDet, , nPadRight, )
	EndIf

	// Linha separadora abaixo do cabecalho das colunas
	nLinCab += nEspacoDet + 1
	oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin)

	nLinAtu := nLinCab + 3
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 *---------------------------------------------------------------------*/
Static Function fImpRod()
	Local nLinRod:= nLinFin + 10
	Local cTexto := ""
	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin)
	nLinRod += 3
	cTexto := "Pedido: "+QRY_PED->C5_NUM+"    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+FunName()+"     "+cUserName
	oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , nPadLeft, )
	cTexto := "Página "+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , nPadRight, )
	oPrintPvt:EndPage()
	nPagAtu++
Return

/*---------------------------------------------------------------------*
 | Func:  fLogoEmp                                                     |
 *---------------------------------------------------------------------*/
Static Function fLogoEmp()
	Local cGrpCompany := AllTrim(FWGrpCompany())
	Local cCodEmpGrp  := AllTrim(FWCodEmp())
	Local cUnitGrp    := AllTrim(FWUnitBusiness())
	Local cFilGrp     := AllTrim(FWFilial())
	Local cLogo       := ""
	Local cCamFim     := GetTempPath()
	Local cStart      := GetSrvProfString("Startpath", "")
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf
	cLogo := cStart + "DANFE" + cDescLogo + ".BMP"
	If !File(cLogo)
		cLogo	:= cStart + "DANFE" + cEmpAnt + ".BMP"
	EndIf
	CpyS2T(cLogo, cCamFim)
	cLogo := cCamFim + StrTran(cLogo, cStart, "")
	If !File(cLogo)
		Sleep(500)
	EndIf
Return cLogo

/*---------------------------------------------------------------------*
 | Func:  fMudaLayout                                                  |
 *---------------------------------------------------------------------*/
Static Function fMudaLayout()
	// Fontes atreladas em cascata matemática
	oFontTit   := TFont():New(cNomeFont, , nTamFontCab - 2, , .T.) // Título ligeiramente maior
	oFontCab   := TFont():New(cNomeFont, , nTamFontCab, , .F.)
	oFontCabN  := TFont():New(cNomeFont, , nTamFontCab, , .T.)
	oFontRod   := TFont():New(cNomeFont, , -10, , .F.)
	
	// A Fonte da Tabela agora escala acompanhando sempre -2 pixels do cabeçalho
	Local nFontTabela := nTamFontCab + 2 
	
	// Recalibrado espremendo a Descrição para dar 45px exatos na última coluna
	If cLayout == "1"
		nPosCod  := 010 
		nPosDesc := 060 
		nPosQuan := 330 
		nPosVUni := 390 
		nPosVTot := 465 
		
		oFontDet   := TFont():New(cNomeFont, , nFontTabela, , .F.)
		oFontDetN  := TFont():New(cNomeFont, , nFontTabela, , .T.)
	Else
		nPosCod  := 010 
		nPosDesc := 045 
		nPosUnid := 190 
		nPosQuan := 215 
		nPosVUni := 250 
		nPosVTot := 285 
		nPosBIcm := 335 
		nPosVIcm := 380 
		nPosVIPI := 425 
		nPosAIcm := 465 
		nPosAIpi := 505 
		
		oFontDet   := TFont():New(cNomeFont, , nFontTabela, , .F.)
		oFontDetN  := TFont():New(cNomeFont, , nFontTabela, , .T.)
	EndIf
Return

/*---------------------------------------------------------------------*
 | Func:  fImpTot                                                      |
 *---------------------------------------------------------------------*/
Static Function fImpTot()

	Local nAltLin    := nEspacoLinha
	Local nWidLbl1, nWidLbl2
	Local nColLbl1 := 0
	Local nColVal1 := 0
	Local nWidVal1 := 0
	Local nColLbl2 := 0
	Local nColVal2 := 0
	Local nWidVal2 := 0
	
	Private nAltCaixa  := (nAltLin * 4) + nTamFundo + 4

	// FIX DEFINITIVO: Ajuste milimétrico fixo para Totais
	If Abs(nTamFontCab) <= 8
		nWidLbl1 := 95  ; nWidLbl2 := 48
	ElseIf Abs(nTamFontCab) == 9
		nWidLbl1 := 105 ; nWidLbl2 := 53
	ElseIf Abs(nTamFontCab) == 10
		nWidLbl1 := 115 ; nWidLbl2 := 58
	ElseIf Abs(nTamFontCab) == 11
		nWidLbl1 := 125 ; nWidLbl2 := 63
	Else
		nWidLbl1 := 135 ; nWidLbl2 := 68
	EndIf
	
	nColLbl1 := nColIni + 5
	nColVal1 := nColLbl1 + nWidLbl1
	nWidVal1 := (nColMeio - 3) - nColVal1 - 5
	
	nColLbl2 := nColMeio + 5
	nColVal2 := nColLbl2 + nWidLbl2
	nWidVal2 := nColFin - nColVal2 - 5

	nLinAtu += 4
	If nLinAtu + nAltCaixa >= nLinFin
		fImpRod()
		fImpCab()
	EndIf
	
	oPrintPvt:Box(nLinAtu, nColIni, nLinAtu + nAltCaixa, nColFin)
	oPrintPvt:SayAlign(nLinAtu, nColIni+5, "Totais:", oFontTit, 060, nTamFundo, nCorAzul, nPadLeft, )
	oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
	nLinAtu += nTamFundo + 2
	
	oPrintPvt:SayAlign(nLinAtu, nColLbl1, "Valor do Frete: ", oFontCab, nWidLbl1, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal1, Alltrim(Transform(nTotFrete, cMaskFrete)), oFontCabN, nWidVal1, nAltLin, , nPadRight, )
	oPrintPvt:SayAlign(nLinAtu, nColLbl2, "Peso.Líq.:", oFontCab, nWidLbl2, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal2, Alltrim(Transform(QRY_PED->C5_PESOL, cMaskPLiq)),  oFontCabN, nWidVal2, nAltLin, , nPadRight, )
	nLinAtu += nAltLin
	
	oPrintPvt:SayAlign(nLinAtu, nColLbl1, "Valor Total Produtos: ", oFontCab, nWidLbl1, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal1, Alltrim(Transform(nValorTot, cMaskVlr)), oFontCabN, nWidVal1, nAltLin, , nPadRight, )
	oPrintPvt:SayAlign(nLinAtu, nColLbl2, "Peso.Bru:", oFontCab, nWidLbl2, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal2, Alltrim(Transform(QRY_PED->C5_PBRUTO, cMaskPBru)), oFontCabN, nWidVal2, nAltLin, , nPadRight, )
	nLinAtu += nAltLin
	
	oPrintPvt:SayAlign(nLinAtu, nColLbl1, "Valor ICMS Substit.: ", oFontCab, nWidLbl1, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal1, Alltrim(Transform(nTotalST, cMaskVlr)), oFontCabN, nWidVal1, nAltLin, , nPadRight, )
	oPrintPvt:SayAlign(nLinAtu, nColLbl2, "Valor do IPI:", oFontCab, nWidLbl2, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal2, Alltrim(Transform(nTotIPI, cMaskVlr)), oFontCabN, nWidVal2, nAltLin, , nPadRight, )
	nLinAtu += nAltLin
	
	oPrintPvt:SayAlign(nLinAtu, nColLbl1, "Valor Total do Pedido: ", oFontCab, nWidLbl1, nAltLin, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColVal1, Alltrim(Transform(nTotVal, cMaskVlr)), oFontCabN, nWidVal1, nAltLin, , nPadRight, )
	
	nLinAtu += nAltLin + 2
Return

/*---------------------------------------------------------------------*
 | Func:  fMsgObs                                                      |
 *---------------------------------------------------------------------*/
Static Function fMsgObs()

	Local aLinhas   := {}
	Local nQueb     := 100
	Local cMsg      := ""
	Local cLinha    := ""
	Local cResto    := ""
	Local nI        := 0
	Local nPos      := 0
	Local nAltLin   := nEspacoLinha
	Local nAltCaixa := 0

	//Garantia de posicionamento
	DbSelectArea("SC5")
	SC5->(DbGoTo(QRY_PED->C5REC))

	cMsg := Alltrim(SC5->C5_XREC)

	// Normaliza quebras de linha: CRLF e CR soltos viram LF
	cMsg := StrTran(cMsg, CHR(13)+CHR(10), CHR(10))
	cMsg := StrTran(cMsg, CHR(13), CHR(10))

	// Quebra o texto respeitando as quebras de linha do campo e o limite de caracteres
	While Len(cMsg) > 0
		nPos := At(CHR(10), cMsg)
		If nPos > 0
			cLinha := SubStr(cMsg, 1, nPos - 1)
			cMsg   := SubStr(cMsg, nPos + 1)
		Else
			cLinha := cMsg
			cMsg   := ""
		EndIf
		cLinha := Alltrim(cLinha)
		// Quebra linhas longas pelo limite nQueb
		While Len(cLinha) > nQueb
			cResto := SubStr(cLinha, 1, nQueb)
			nPos   := RAt(' ', cResto)
			If nPos > 0
				aAdd(aLinhas, SubStr(cResto, 1, nPos))
				cLinha := Alltrim(SubStr(cLinha, nPos + 1))
			Else
				aAdd(aLinhas, cResto)
				cLinha := Alltrim(SubStr(cLinha, nQueb + 1))
			EndIf
		EndDo
		aAdd(aLinhas, cLinha)
	EndDo

	// Garante ao menos uma linha vazia
	If Len(aLinhas) == 0
		aAdd(aLinhas, "")
	EndIf

	nAltCaixa := (nAltLin * Len(aLinhas)) + nTamFundo + 4

	nLinAtu += 4

	nLinAtu += 4
	If nLinAtu + nAltCaixa >= nLinFin
		fImpRod()
		fImpCab()
	EndIf

	oPrintPvt:Box(nLinAtu, nColIni, nLinAtu + nAltCaixa, nColFin)
	oPrintPvt:SayAlign(nLinAtu, nColIni+5, "Observação:", oFontTit, 100, nTamFundo, nCorAzul, nPadLeft, )
	oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
	nLinAtu += nTamFundo + 2

	For nI := 1 To Len(aLinhas)
		// Se no meio das linhas estoura a pagina, quebra e reabre o bloco
		If nLinAtu + nAltLin >= nLinFin
			fImpRod()
			fImpCab()
			nAltCaixa := (nAltLin * (Len(aLinhas) - nI + 1)) + nTamFundo + 4
			oPrintPvt:Box(nLinAtu, nColIni, nLinAtu + nAltCaixa, nColFin)
			oPrintPvt:SayAlign(nLinAtu, nColIni+5, "Observação (cont.):", oFontTit, 150, nTamFundo, nCorAzul, nPadLeft, )
			oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
			nLinAtu += nTamFundo + 2
		EndIf
		oPrintPvt:SayAlign(nLinAtu, nColIni+5, aLinhas[nI], oFontCab, (nColFin - nColIni) - 10, nAltLin, , nPadLeft, )
		nLinAtu += nAltLin
	Next nI

	nLinAtu += 2
Return

/*---------------------------------------------------------------------*
 | Func:  fMontDupl                                                    |
 *---------------------------------------------------------------------*/
Static Function fMontDupl()
	Local aArea    := GetArea()
	Local lDtEmi   := SuperGetMv("MV_DPDTEMI", .F., .T.)
	Local nAcerto  := 0
	Local aEntr    := {}
	Local aDupl    := {}
	Local aDuplTmp := {}
	Local nItem    := 0
	Local nAux     := 0
	
	aDuplicatas := {}
	
	DbSelectarea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
	
	If lDtEmi
		If (SE4->E4_TIPO != "9")
			aDupl := Condicao(MaFisRet(, "NF_BASEDUP"), SC5->C5_CONDPAG, MaFisRet(, "NF_VALIPI"), SC5->C5_EMISSAO, MaFisRet(, "NF_VALSOL"))
			If Len(aDupl) > 0
				For nAux := 1 To Len(aDupl)
					nAcerto += aDupl[nAux][2]
				Next nAux
				aDupl[Len(aDupl)][2] += MaFisRet(, "NF_BASEDUP") - nAcerto
			EndIf
		Else
			aDupl := {{Ctod(""), MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR")}}
		EndIf
	Else
		nItem := 0
		QRY_ITE->(DbGoTop())
		While !QRY_ITE->(EoF())
			nItem++
			If !Empty(QRY_ITE->C6_ENTREG)
				nPosEntr := Ascan(aEntr, {|x| x[1] == QRY_ITE->C6_ENTREG})
 				If nPosEntr == 0
					aAdd(aEntr, {QRY_ITE->C6_ENTREG, MaFisRet(nItem, "IT_BASEDUP"), MaFisRet(nItem, "IT_VALIPI"), MaFisRet(nItem, "IT_VALSOL")})
				Else
					aEntr[nPosEntr][2]+= MaFisRet(nItem, "IT_BASEDUP")
					aEntr[nPosEntr][2]+= MaFisRet(nItem, "IT_VALIPI")
					aEntr[nPosEntr][2]+= MaFisRet(nItem, "IT_VALSOL")
				EndIf
			EndIf
			QRY_ITE->(DbSkip())
		EndDo
		
		If (SE4->E4_TIPO != "9")
			For nItem := 1 to Len(aEntr)
				nAcerto  := 0
				aDuplTmp := Condicao(aEntr[nItem][2], SC5->C5_CONDPAG, aEntr[nItem][3], aEntr[nItem][1], aEntr[nItem][4])
				For nAux := 1 To Len(aDuplTmp)
					nAcerto += aDuplTmp[nAux][2]
				Next nAux
				aDuplTmp[Len(aDuplTmp)][2] += aEntr[nItem][2] - nAcerto
				aEval(aDuplTmp, {|x| aAdd(aDupl, {aEntr[nItem][1], x[1], x[2]})})
			Next
		Else
	    	aDupl := {{Ctod(""), MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR")}}
		EndIf
	EndIf
	
	If Len(aDupl) == 0
		aDupl := {{Ctod(""), MaFisRet(, "NF_BASEDUP"), PesqPict("SE1", "E1_VALOR")}}
	EndIf
	
	aDuplicatas := aClone(aDupl)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fImpDupl                                                     |
 *---------------------------------------------------------------------*/
Static Function fImpDupl()
	Local nLinhas     := NoRound(Len(aDuplicatas)/2, 0) + 1
	Local nAtual      := 0
	Local nLinDup     := 0
	Local nAltLin     := nEspacoLinha 
	Local nAltCaixa   := (nAltLin * nLinhas) + nTamFundo + 6
	Local nLinLim     := nLinAtu + nAltCaixa
	Local nColAux     := nColIni
	
	Local nWidDuplLbl
	Local nWidDuplVal := 0
	
	// FIX DEFINITIVO: Ajuste milimétrico fixo para Duplicatas
	If Abs(nTamFontCab) <= 8
		nWidDuplLbl := 95
	ElseIf Abs(nTamFontCab) == 9
		nWidDuplLbl := 105
	ElseIf Abs(nTamFontCab) == 10
		nWidDuplLbl := 115
	ElseIf Abs(nTamFontCab) == 11
		nWidDuplLbl := 125
	Else
		nWidDuplLbl := 135
	EndIf
	
	nWidDuplVal := (nColMeio - nColIni - 5) - nWidDuplLbl
	
	nLinAtu += 4
	If nLinLim+5 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf
	
	oPrintPvt:Box(nLinAtu, nColIni, nLinLim, nColFin)
	oPrintPvt:SayAlign(nLinAtu, nColIni+5, "Duplicatas:", oFontTit, 100, nTamFundo, nCorAzul, nPadLeft, )
	oPrintPvt:Line(nLinAtu+nTamFundo, nColIni, nLinAtu+nTamFundo, nColFin)
	nLinAtu += nTamFundo + 2
	nLinDup := nLinAtu
	
	For nAtual := 1 To Len(aDuplicatas)
		// Largura devidamente espremida sem cortar
		oPrintPvt:SayAlign(nLinDup, nColAux+5, StrZero(nAtual, 3)+", no dia "+dToC(aDuplicatas[nAtual][1])+":", oFontCab, nWidDuplLbl, nAltLin, , nPadLeft, )
		oPrintPvt:SayAlign(nLinDup, nColAux+5+nWidDuplLbl, Alltrim(Transform(aDuplicatas[nAtual][2], cMaskVlr)), oFontCabN, nWidDuplVal, nAltLin, , nPadRight, )
		nLinDup += nAltLin
		
		If nAtual == nLinhas
			nLinDup := nLinAtu
			nColAux := nColMeio
		EndIf
	Next
	
	nLinAtu += nAltCaixa + 2

Return
