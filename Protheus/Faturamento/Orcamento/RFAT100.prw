#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} RFAT100
    Impressao Grafica e Exportacao em HTML do Orcamento de Venda
    Gera arquivo HTML moderno salvo no diretorio %temp% do usuario
    e abre automaticamente no navegador padrao com suporte a impressao (PDF/Papel).
    @author  Protheus / Totvs
    @since   17/09/2026
    @version 3.0
    @obs     Removidas as colunas de PIS, COFINS e ICMS, mantendo somente o IPI.
             Layout modernizado em HTML/CSS corporativo sem sobreposicao de linhas.
             Nome Innovy removido mantendo somente Protheus.
/*/
User Function RFAT100()

	Local cPerg       := "RFAT100"
	Local cQuery      := ""
	Local cAliasSCK   := GetNextAlias()
	Local nItemSeq    := 0
	Local cHtml       := ""
	Local cPathTemp   := GetTempPath()
	Local cNomeArq    := "Orcamento_" + AllTrim(SCJ->CJ_NUM) + "_" + StrTran(Time(), ":", "") + ".html"
	Local cArquivo    := cPathTemp + cNomeArq
	Local nHandle     := 0
	Local cStartPath  := ""
	Local nOrientacao := 1 // 1=Retrato (padrao corporativo), 2=Paisagem

	// Variaveis de Controle e Flags
	Local lEmail      := .F.
	Local lxVend1     := FieldPos("CJ_XVEND1")  > 0
	Local lxTrans     := FieldPos("CJ_XTRANSP") > 0
	Local lxPrazo     := FieldPos("CJ_XPRAZOD") > 0
	Local lxFrete     := FieldPos("CJ_XFRETE")  > 0
	Local lxOBS       := FieldPos("CJ_XOBS")    > 0
	Local lxLacre     := FieldPos("CK_XLACRE")  > 0
	Local lxAplic     := FieldPos("CK_XAPLICA") > 0

	// Variaveis de Impostos e Totais (Somente IPI mantido)
	Local lIpi        := .F.
	Local nIpi        := 0
	Local nVlrIpi     := 0
	Local nTotalItem  := 0
	Local nTotProd    := 0
	Local nTotIpi     := 0
	Local nTotFrete   := 0
	Local nTotGer     := 0

	// Dados da Empresa (Emitente)
	Local cEmpNome    := IIf(!Empty(SM0->M0_NOMECOM), Alltrim(SM0->M0_NOMECOM), Alltrim(SM0->M0_NOME))
	Local cEmpCnpj    := Alltrim(Transform(SM0->M0_CGC, "@r 99.999.999/9999-99"))
	Local cEmpInsc    := Alltrim(SM0->M0_INSC)
	Local cEmpTel     := Alltrim(Transform(SM0->M0_TEL, "@r (99) 9999-9999"))
	Local cEmpFax     := ""
	Local cEmpEnd     := ""
	Local cEmpCid     := ""
	Local cEmpLogra   := ""
	Local cEmpBairro  := ""
	Local cEmpMun     := ""
	Local cEmpUf      := ""
	Local cEmpCep     := ""

	// Formatacao de Fax (somente exibe se contiver numeros)
	If !Empty(SM0->M0_FAX) .And. !Empty(StrTran(StrTran(StrTran(AllTrim(SM0->M0_FAX), " ", ""), "-", ""), "(", ""))
		cEmpFax := Alltrim(Transform(SM0->M0_FAX, "@r (99) 9999-9999"))
	EndIf

	// Municipio e UF da Empresa
	If !Empty(SM0->M0_CIDENT)
		cEmpMun := AllTrim(SM0->M0_CIDENT)
	ElseIf !Empty(SM0->M0_CIDCOB)
		cEmpMun := AllTrim(SM0->M0_CIDCOB)
	Else
		cEmpMun := "Sorocaba"
	EndIf

	If !Empty(SM0->M0_ESTENT)
		cEmpUf := AllTrim(SM0->M0_ESTENT)
	ElseIf !Empty(SM0->M0_ESTCOB)
		cEmpUf := AllTrim(SM0->M0_ESTCOB)
	Else
		cEmpUf := "SP"
	EndIf

	// Bairro da Empresa
	If !Empty(SM0->M0_BAIRENT)
		cEmpBairro := AllTrim(SM0->M0_BAIRENT)
	ElseIf !Empty(SM0->M0_BAIRCOB)
		cEmpBairro := AllTrim(SM0->M0_BAIRCOB)
	Else
		cEmpBairro := "Cajuru do Sul"
	EndIf

	// Logradouro: Evita duplicar a cidade se o campo de endereco estiver cadastrado apenas como a cidade (ex: SOROCABA)
	If !Empty(SM0->M0_ENDENT) .And. !(Upper(AllTrim(SM0->M0_ENDENT)) == Upper(cEmpMun))
		cEmpLogra := AllTrim(SM0->M0_ENDENT)
	ElseIf !Empty(SM0->M0_ENDCOB) .And. !(Upper(AllTrim(SM0->M0_ENDCOB)) == Upper(cEmpMun))
		cEmpLogra := AllTrim(SM0->M0_ENDCOB)
	Else
		cEmpLogra := "Av. Parana, 852"
	EndIf

	// CEP da Empresa
	If !Empty(SM0->M0_CEPENT)
		cEmpCep := AllTrim(Transform(SM0->M0_CEPENT, "@r 99999-999"))
	ElseIf !Empty(SM0->M0_CEPCOB)
		cEmpCep := AllTrim(Transform(SM0->M0_CEPCOB, "@r 99999-999"))
	Else
		cEmpCep := "18105-000"
	EndIf

	cEmpEnd := cEmpLogra + IIf(!Empty(cEmpBairro), " - " + cEmpBairro, "")
	cEmpCid := cEmpMun + " - " + cEmpUf + " | CEP: " + cEmpCep

	// Dados do Cliente
	Local cRazao      := ""
	Local cEnd        := ""
	Local cNr         := ""
	Local cBairro     := ""
	Local cCidade     := ""
	Local cEstado     := ""
	Local cCep        := ""
	Local cCNPJ       := ""
	Local cIE         := ""
	Local cContato    := ""
	Local cTelCli     := ""
	Local cEmailCli   := ""

	// Dados Comerciais
	Local cVendedor   := ""
	Local cTransp     := ""
	Local cCondPag    := ""
	Local cTipoFre    := ""
	Local cNumLacre   := "SEQUENCIAL"
	Local cObsGeral   := ""

	// Logotipo da Empresa
	Local cLogoSrv    := ""
	Local cLogoCli    := cPathTemp + "lgmid.png"
	Local cLogoSrc    := "lgmid.png"
	Local cLogoBase64 := ""
	Local nHLogo      := -1
	Local nTamLogo    := 0
	Local cBufLogo    := ""

	// Mascaras de Formatacao
	Local cPicVal     := PesqPict("SCK", "CK_VALOR")
	Local cPicPrc     := PesqPict("SCK", "CK_PRCVEN")
	Local cPicQtd     := PesqPict("SCK", "CK_QTDVEN")
	Local cPicIpi     := PesqPict("SB1", "B1_IPI")
	Local cPicFre     := PesqPict("SCJ", "CJ_FRETE")

	// Itens HTML
	Local cLinhasItens:= ""
	Local cDescProd   := ""
	Local cUM         := ""
	Local cObsItem    := ""

	// Fallbacks de mascaras
	If Empty(cPicVal); cPicVal := "@E 999,999,999.92"; EndIf
	If Empty(cPicPrc); cPicPrc := "@E 999,999.9999"; EndIf
	If Empty(cPicQtd); cPicQtd := "@E 999,999.99"; EndIf
	If Empty(cPicIpi); cPicIpi := "@E 99.99"; EndIf
	If Empty(cPicFre); cPicFre := "@E 999,999.99"; EndIf

	// Se a tabela SCJ nao estiver posicionada (ex: chamada via Menu), solicita o orcamento
	If SCJ->(EoF()) .Or. Empty(SCJ->CJ_NUM)
		AjustaSX1(cPerg)
		If !Pergunte(cPerg, .T.)
			Return
		EndIf
		SCJ->(DbSetOrder(1))
		If !SCJ->(DbSeek(xFilial("SCJ") + mv_par01))
			MsgStop("Orcamento de venda nao localizado!", "Atencao")
			Return
		EndIf
		If Type("mv_par02") == "N" .And. mv_par02 == 2
			nOrientacao := 2
		EndIf
	EndIf

	If MsgYesNo("Deseja enviar o orcamento por E-mail apos a geracao?", "Envio de Orcamento")
		lEmail := .T.
	EndIf

	SCK->(DbSetOrder(1))
	If !SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM))
		MsgStop("Nao ha itens cadastrados para este orcamento!", "Atencao")
		Return
	EndIf

	// =========================================================================
	// 1. OBTENCAO DO LOGOTIPO NA PASTA SYSTEM / STARTPATH DO SERVIDOR
	// =========================================================================
	cStartPath := AllTrim(GetSrvProfString("Startpath", "\system\"))
	If Empty(cStartPath)
		cStartPath := "\system\"
	EndIf
	If !(Right(cStartPath, 1) $ "\/")
		cStartPath += "\"
	EndIf

	// Busca o logotipo lgmid.png na pasta system / startpath do servidor Protheus
	cLogoSrv := cStartPath + "lgmid.png"
	If !File(cLogoSrv)
		If File("\system\lgmid.png")
			cLogoSrv := "\system\lgmid.png"
		ElseIf File("system\lgmid.png")
			cLogoSrv := "system\lgmid.png"
		ElseIf File("lgmid.png")
			cLogoSrv := "lgmid.png"
		ElseIf File("\lgmid.png")
			cLogoSrv := "\lgmid.png"
		ElseIf File("\protheus_data\system\lgmid.png")
			cLogoSrv := "\protheus_data\system\lgmid.png"
		ElseIf File("\protheus_data\lgmid.png")
			cLogoSrv := "\protheus_data\lgmid.png"
		EndIf
	EndIf

	// Leitura binaria com FOpen/FRead e conversao para Base64.
	// Dessa forma o logotipo fica 100% embutido no arquivo HTML, garantindo que
	// qualquer estacao de trabalho, terminal ou e-mail exiba a imagem perfeitamente.
	cLogoBase64 := ""
	If File(cLogoSrv)
		nHLogo := FOpen(cLogoSrv, 0) // FO_READ = 0
		If nHLogo >= 0
			nTamLogo := FSeek(nHLogo, 0, 2) // FS_END
			FSeek(nHLogo, 0, 0)             // FS_SET
			If nTamLogo > 0
				cBufLogo := Space(nTamLogo)
				FRead(nHLogo, @cBufLogo, nTamLogo)
				If !Empty(cBufLogo) .And. FindFunction("Encode64")
					cLogoBase64 := Encode64(cBufLogo)
					cLogoBase64 := StrTran(cLogoBase64, Chr(13), "")
					cLogoBase64 := StrTran(cLogoBase64, Chr(10), "")
					cLogoBase64 := StrTran(cLogoBase64, " ", "")
				EndIf
			EndIf
			FClose(nHLogo)
		EndIf
	EndIf

	// Segunda tentativa de obtencao via Encode64 direto por arquivo
	If Empty(cLogoBase64) .And. File(cLogoSrv) .And. FindFunction("Encode64")
		cLogoBase64 := Encode64(, cLogoSrv, .F., .F.)
		If !Empty(cLogoBase64)
			cLogoBase64 := StrTran(cLogoBase64, Chr(13), "")
			cLogoBase64 := StrTran(cLogoBase64, Chr(10), "")
			cLogoBase64 := StrTran(cLogoBase64, " ", "")
		EndIf
	EndIf

	// Se obteve o Base64, embute no HTML (independente de estacao). Senao, usa arquivo relativo
	If !Empty(cLogoBase64)
		cLogoSrc := "data:image/png;base64," + cLogoBase64
	Else
		cLogoSrc := "lgmid.png"
	EndIf

	// Por seguranca e compatibilidade adicional, copia para o cliente via CpyS2T
	If File(cLogoSrv)
		CpyS2T(cLogoSrv, cPathTemp)
		CpyS2T(cLogoSrv, cPathTemp + "lgmid.png")
	EndIf

	// =========================================================================
	// 2. BUSCA DE DADOS DO CLIENTE E CONDICOES COMERCIAIS
	// =========================================================================
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
		cRazao    := Alltrim(SA1->A1_NOME)
		cEnd      := Alltrim(MyGetEnd(SA1->A1_END, "SA1")[1])
		cNr       := IIf(MyGetEnd(SA1->A1_END, "SA1")[2] <> 0, cValToChar(MyGetEnd(SA1->A1_END, "SA1")[2]), "SN")
		cBairro   := Alltrim(SA1->A1_BAIRRO)
		cCidade   := Alltrim(SA1->A1_MUN)
		cEstado   := SA1->A1_EST
		cCep      := Alltrim(Transform(SA1->A1_CEP, "@r 99999-999"))
		cCNPJ     := Alltrim(Transform(SA1->A1_CGC, "@r 99.999.999/9999-99"))
		cIE       := Alltrim(SA1->A1_INSCR)
		cContato  := IIf(!Empty(SA1->A1_CONTATO), Alltrim(SA1->A1_CONTATO), "")
		cTelCli   := "(" + Alltrim(SA1->A1_DDD) + ") " + Alltrim(SA1->A1_TEL)
		cEmailCli := Alltrim(SA1->A1_EMAIL)
	EndIf

	// Vendedor
	SA3->(DbSetOrder(1))
	If lxVend1 .And. SA3->(DbSeek(xFilial("SA3") + SCJ->CJ_XVEND1))
		cVendedor := Alltrim(SA3->A3_NOME)
	ElseIf FieldPos("CJ_VEND1") > 0 .And. SA3->(DbSeek(xFilial("SA3") + SCJ->CJ_VEND1))
		cVendedor := Alltrim(SA3->A3_NOME)
	ElseIf FieldPos("CJ_VEND") > 0 .And. SA3->(DbSeek(xFilial("SA3") + SCJ->CJ_VEND))
		cVendedor := Alltrim(SA3->A3_NOME)
	EndIf

	// Transportadora
	SA4->(DbSetOrder(1))
	If lxTrans .And. SA4->(DbSeek(xFilial("SA4") + SCJ->CJ_XTRANSP))
		cTransp := Alltrim(SA4->A4_NOME)
	ElseIf FieldPos("CJ_TRANSP") > 0 .And. SA4->(DbSeek(xFilial("SA4") + SCJ->CJ_TRANSP))
		cTransp := Alltrim(SA4->A4_NOME)
	EndIf

	// Condicao de Pagamento
	cCondPag := POSICIONE("SE4", 1, xFilial("SE4") + SCJ->CJ_CONDPAG, "E4_DESCRI")

	// Tipo de Frete
	If lxFrete
		cTipoFre := IIf(SCJ->CJ_XFRETE == "F", "FOB - Conta Destinatario", "CIF - Conta Remetente")
	ElseIf FieldPos("CJ_TPFRETE") > 0
		cTipoFre := IIf(SCJ->CJ_TPFRETE == "F", "FOB - Conta Destinatario", "CIF - Conta Remetente")
	Else
		cTipoFre := "Por Conta do Destinatario"
	EndIf

	// Observacoes Gerais do Orcamento
	If lxOBS .And. !Empty(SCJ->CJ_XOBS)
		cObsGeral := Alltrim(SCJ->CJ_XOBS)
	EndIf

	// =========================================================================
	// 3. PROCESSAMENTO DOS ITENS DO ORCAMENTO (SOMENTE IPI)
	// =========================================================================
	While SCK->(!Eof()) .And. SCK->(CK_FILIAL + CK_NUM) == SCJ->(CJ_FILIAL + CJ_NUM)

		nItemSeq++

		cDescProd := Alltrim(POSICIONE("SB1", 1, xFilial("SB1") + SCK->CK_PRODUTO, "B1_DESC"))
		cUM       := IIf(FieldPos("CK_UM") > 0 .And. !Empty(SCK->CK_UM), SCK->CK_UM, POSICIONE("SB1", 1, xFilial("SB1") + SCK->CK_PRODUTO, "B1_UM"))

		// Calculo exclusivo de IPI (PIS, COFINS e ICMS foram removidos)
		lIpi      := .F.
		nIpi      := 0
		nVlrIpi   := 0

		SF4->(DbSetOrder(1))
		If SF4->(DbSeek(xFilial("SF4") + SCK->CK_TES))
			If SF4->F4_CREDIPI == "S" .Or. (SF4->(FieldPos("F4_IPI")) > 0 .And. SF4->F4_IPI == "S")
				nIpi := POSICIONE("SB1", 1, xFilial("SB1") + SCK->CK_PRODUTO, "B1_IPI")
				If nIpi > 0
					lIpi    := .T.
					nVlrIpi := Round((nIpi * SCK->CK_VALOR) / 100, 2)
				EndIf
			EndIf
		EndIf

		nTotalItem := SCK->CK_VALOR + nVlrIpi

		// Acumuladores de Totais
		nTotProd += SCK->CK_VALOR
		nTotIpi  += nVlrIpi

		// Montagem da Linha HTML do Item
		cLinhasItens += "<tr>"
		cLinhasItens += "<td class='col-center col-seq'>" + StrZero(nItemSeq, 2) + "</td>"
		cLinhasItens += "<td class='col-left col-desc'>"
		cLinhasItens += "  <div class='prod-nome'>" + cDescProd + "</div>"
		If !Empty(SCK->CK_OBS)
			cLinhasItens += "  <div class='prod-obs'>Obs: " + Alltrim(SCK->CK_OBS) + "</div>"
		EndIf
		cLinhasItens += "</td>"
		cLinhasItens += "<td class='col-center col-um'>" + cUM + "</td>"
		cLinhasItens += "<td class='col-right col-qtd'>" + Alltrim(Transform(SCK->CK_QTDVEN, cPicQtd)) + "</td>"
		cLinhasItens += "<td class='col-right col-prc'>" + Alltrim(Transform(SCK->CK_PRCVEN, cPicPrc)) + "</td>"
		
		// Exibicao de IPI
		If lIpi
			cLinhasItens += "<td class='col-right col-ipi-aliq'>" + Alltrim(Transform(nIpi, cPicIpi)) + "%</td>"
			cLinhasItens += "<td class='col-right col-ipi-val'>" + Alltrim(Transform(nVlrIpi, cPicVal)) + "</td>"
		Else
			cLinhasItens += "<td class='col-right col-ipi-aliq text-muted'>-</td>"
			cLinhasItens += "<td class='col-right col-ipi-val text-muted'>0,00</td>"
		EndIf

		cLinhasItens += "<td class='col-right col-tot font-bold'>" + Alltrim(Transform(nTotalItem, cPicVal)) + "</td>"
		cLinhasItens += "</tr>"

		SCK->(DbSkip())
	EndDo

	// Frete e Total Geral
	nTotFrete := SCJ->CJ_FRETE
	nTotGer   := nTotProd + nTotIpi + nTotFrete

	// =========================================================================
	// 4. CONSTRUCAO DO DOCUMENTO HTML MODERNO
	// =========================================================================
	cHtml := "<!DOCTYPE html>" + CRLF
	cHtml += "<html lang='pt-BR'>" + CRLF
	cHtml += "<head>" + CRLF
	cHtml += "  <meta charset='utf-8'>" + CRLF
	cHtml += "  <meta name='viewport' content='width=device-width, initial-scale=1.0'>" + CRLF
	cHtml += "  <title>Orcamento de Venda " + SCJ->CJ_NUM + "</title>" + CRLF
	cHtml += "  <style id='page-orientation-style'>" + CRLF
	cHtml += "    @page { size: A4 " + IIf(nOrientacao == 2, "landscape", "portrait") + "; margin: 8mm; }" + CRLF
	cHtml += "  </style>" + CRLF
	cHtml += "  <style>" + CRLF
	cHtml += "    * { box-sizing: border-box; margin: 0; padding: 0; }" + CRLF
	cHtml += "    html, body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }" + CRLF
	cHtml += "    body {" + CRLF
	cHtml += "      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;" + CRLF
	cHtml += "      background-color: #f1f5f9;" + CRLF
	cHtml += "      color: #1e293b;" + CRLF
	cHtml += "      font-size: 13px;" + CRLF
	cHtml += "      line-height: 1.45;" + CRLF
	cHtml += "      padding: 20px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .action-bar {" + CRLF
	cHtml += "      max-width: 1100px;" + CRLF
	cHtml += "      margin: 0 auto 16px auto;" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      justify-content: space-between;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "      background: #ffffff;" + CRLF
	cHtml += "      padding: 12px 20px;" + CRLF
	cHtml += "      border-radius: 8px;" + CRLF
	cHtml += "      box-shadow: 0 1px 3px rgba(0,0,0,0.08);" + CRLF
	cHtml += "      border: 1px solid #e2e8f0;" + CRLF
	cHtml += "      gap: 16px;" + CRLF
	cHtml += "      flex-wrap: wrap;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .action-left {" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "      gap: 14px;" + CRLF
	cHtml += "      flex-wrap: wrap;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .btn-print {" + CRLF
	cHtml += "      background-color: #1e3a8a;" + CRLF
	cHtml += "      color: #ffffff;" + CRLF
	cHtml += "      border: none;" + CRLF
	cHtml += "      padding: 9px 20px;" + CRLF
	cHtml += "      border-radius: 6px;" + CRLF
	cHtml += "      font-size: 13px;" + CRLF
	cHtml += "      font-weight: 600;" + CRLF
	cHtml += "      cursor: pointer;" + CRLF
	cHtml += "      display: inline-flex;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "      gap: 8px;" + CRLF
	cHtml += "      transition: background-color 0.15s;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .btn-print:hover { background-color: #172554; }" + CRLF
	cHtml += "    .orientation-control {" + CRLF
	cHtml += "      display: inline-flex;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "      background: #f1f5f9;" + CRLF
	cHtml += "      border: 1px solid #cbd5e1;" + CRLF
	cHtml += "      border-radius: 6px;" + CRLF
	cHtml += "      padding: 3px;" + CRLF
	cHtml += "      gap: 2px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .orientation-lbl {" + CRLF
	cHtml += "      font-size: 11.5px;" + CRLF
	cHtml += "      font-weight: 600;" + CRLF
	cHtml += "      color: #475569;" + CRLF
	cHtml += "      padding: 0 8px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .btn-orient {" + CRLF
	cHtml += "      background: transparent;" + CRLF
	cHtml += "      border: none;" + CRLF
	cHtml += "      padding: 5px 12px;" + CRLF
	cHtml += "      border-radius: 4px;" + CRLF
	cHtml += "      font-size: 12px;" + CRLF
	cHtml += "      font-weight: 600;" + CRLF
	cHtml += "      color: #475569;" + CRLF
	cHtml += "      cursor: pointer;" + CRLF
	cHtml += "      display: inline-flex;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "      gap: 5px;" + CRLF
	cHtml += "      transition: all 0.15s;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .btn-orient:hover { color: #0f172a; }" + CRLF
	cHtml += "    .btn-orient.active {" + CRLF
	cHtml += "      background: #ffffff;" + CRLF
	cHtml += "      color: #1e3a8a;" + CRLF
	cHtml += "      box-shadow: 0 1px 2px rgba(0,0,0,0.1);" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .file-tag { font-size: 11px; color: #64748b; }" + CRLF
	cHtml += "    .quote-page {" + CRLF
	cHtml += "      margin: 0 auto;" + CRLF
	cHtml += "      background: #ffffff;" + CRLF
	cHtml += "      padding: 24px 28px;" + CRLF
	cHtml += "      border-radius: 8px;" + CRLF
	cHtml += "      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.06), 0 2px 4px -2px rgba(0,0,0,0.04);" + CRLF
	cHtml += "      border: 1px solid #e2e8f0;" + CRLF
	cHtml += "      transition: max-width 0.2s ease;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .quote-page.portrait-mode  { max-width: 840px; }" + CRLF
	cHtml += "    .quote-page.landscape-mode { max-width: 1100px; }" + CRLF
	cHtml += "    .header-card {" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      justify-content: space-between;" + CRLF
	cHtml += "      align-items: stretch;" + CRLF
	cHtml += "      border: 1px solid #cbd5e1;" + CRLF
	cHtml += "      border-radius: 6px;" + CRLF
	cHtml += "      margin-bottom: 16px;" + CRLF
	cHtml += "      background: #ffffff;" + CRLF
	cHtml += "      overflow: hidden;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .company-block {" + CRLF
	cHtml += "      flex: 1;" + CRLF
	cHtml += "      padding: 18px 22px;" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      gap: 20px;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .logo-img {" + CRLF
	cHtml += "      max-height: 75px;" + CRLF
	cHtml += "      max-width: 220px;" + CRLF
	cHtml += "      object-fit: contain;" + CRLF
	cHtml += "      flex-shrink: 0;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .company-details h1 {" + CRLF
	cHtml += "      font-size: 16px;" + CRLF
	cHtml += "      font-weight: 700;" + CRLF
	cHtml += "      color: #1e3a8a;" + CRLF
	cHtml += "      margin-bottom: 4px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .company-details p {" + CRLF
	cHtml += "      font-size: 11.5px;" + CRLF
	cHtml += "      color: #334155;" + CRLF
	cHtml += "      margin-bottom: 2px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .quote-badge-block {" + CRLF
	cHtml += "      width: 320px;" + CRLF
	cHtml += "      border-left: 1px solid #cbd5e1;" + CRLF
	cHtml += "      background: #f8fafc;" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      flex-direction: column;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .badge-title {" + CRLF
	cHtml += "      background: #1e3a8a;" + CRLF
	cHtml += "      color: #ffffff;" + CRLF
	cHtml += "      font-size: 13px;" + CRLF
	cHtml += "      font-weight: 700;" + CRLF
	cHtml += "      text-align: center;" + CRLF
	cHtml += "      padding: 7px 10px;" + CRLF
	cHtml += "      letter-spacing: 0.5px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .badge-num-box {" + CRLF
	cHtml += "      padding: 10px 16px;" + CRLF
	cHtml += "      text-align: center;" + CRLF
	cHtml += "      border-bottom: 1px solid #e2e8f0;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .badge-num-lbl { font-size: 11px; color: #64748b; font-weight: 600; text-transform: uppercase; }" + CRLF
	cHtml += "    .badge-num-val { font-size: 24px; font-weight: 800; color: #1e3a8a; line-height: 1.1; margin-top: 2px; }" + CRLF
	cHtml += "    .badge-meta {" + CRLF
	cHtml += "      padding: 8px 16px;" + CRLF
	cHtml += "      display: grid;" + CRLF
	cHtml += "      grid-template-columns: 1fr 1fr;" + CRLF
	cHtml += "      gap: 4px 12px;" + CRLF
	cHtml += "      font-size: 11px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .badge-meta span { color: #64748b; }" + CRLF
	cHtml += "    .badge-meta strong { color: #0f172a; }" + CRLF
	cHtml += "    .cards-row {" + CRLF
	cHtml += "      display: grid;" + CRLF
	cHtml += "      grid-template-columns: 65% 35%;" + CRLF
	cHtml += "      gap: 16px;" + CRLF
	cHtml += "      margin-bottom: 16px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .data-card {" + CRLF
	cHtml += "      border: 1px solid #cbd5e1;" + CRLF
	cHtml += "      border-radius: 6px;" + CRLF
	cHtml += "      overflow: hidden;" + CRLF
	cHtml += "      background: #ffffff;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .card-header {" + CRLF
	cHtml += "      background: #f1f5f9;" + CRLF
	cHtml += "      border-bottom: 1px solid #cbd5e1;" + CRLF
	cHtml += "      font-size: 11.5px;" + CRLF
	cHtml += "      font-weight: 700;" + CRLF
	cHtml += "      color: #1e3a8a;" + CRLF
	cHtml += "      padding: 7px 14px;" + CRLF
	cHtml += "      text-transform: uppercase;" + CRLF
	cHtml += "      letter-spacing: 0.4px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .card-body {" + CRLF
	cHtml += "      padding: 10px 14px;" + CRLF
	cHtml += "      font-size: 11.5px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .grid-2col {" + CRLF
	cHtml += "      display: grid;" + CRLF
	cHtml += "      grid-template-columns: 58% 42%;" + CRLF
	cHtml += "      gap: 6px 14px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .grid-1col {" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      flex-direction: column;" + CRLF
	cHtml += "      gap: 6px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .field-item { display: flex; gap: 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }" + CRLF
	cHtml += "    .field-lbl { color: #64748b; font-weight: 600; flex-shrink: 0; }" + CRLF
	cHtml += "    .field-val { color: #0f172a; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }" + CRLF
	cHtml += "    .table-container {" + CRLF
	cHtml += "      border: 1px solid #cbd5e1;" + CRLF
	cHtml += "      border-radius: 6px;" + CRLF
	cHtml += "      overflow: hidden;" + CRLF
	cHtml += "      margin-bottom: 16px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    table.items-table {" + CRLF
	cHtml += "      width: 100%;" + CRLF
	cHtml += "      border-collapse: collapse;" + CRLF
	cHtml += "      font-size: 11.5px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    table.items-table thead tr {" + CRLF
	cHtml += "      background: #1e3a8a;" + CRLF
	cHtml += "      color: #ffffff;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    table.items-table th {" + CRLF
	cHtml += "      padding: 9px 10px;" + CRLF
	cHtml += "      font-weight: 600;" + CRLF
	cHtml += "      text-transform: uppercase;" + CRLF
	cHtml += "      letter-spacing: 0.3px;" + CRLF
	cHtml += "      padding: 10px 10px;" + CRLF
	cHtml += "      font-weight: 700;" + CRLF
	cHtml += "      text-transform: uppercase;" + CRLF
	cHtml += "      letter-spacing: 0.4px;" + CRLF
	cHtml += "      font-size: 11px;" + CRLF
	cHtml += "      color: #ffffff !important;" + CRLF
	cHtml += "      border: none;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    table.items-table th.col-seq { color: #ffffff !important; }" + CRLF
	cHtml += "    table.items-table tbody tr {" + CRLF
	cHtml += "      border-bottom: 1px solid #e2e8f0;" + CRLF
	cHtml += "      transition: background-color 0.1s;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    table.items-table tbody tr:nth-child(even) { background-color: #f8fafc; }" + CRLF
	cHtml += "    table.items-table tbody tr:hover { background-color: #f1f5f9; }" + CRLF
	cHtml += "    table.items-table td {" + CRLF
	cHtml += "      padding: 8px 10px;" + CRLF
	cHtml += "      vertical-align: middle;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .col-center { text-align: center; }" + CRLF
	cHtml += "    .col-left   { text-align: left; }" + CRLF
	cHtml += "    .col-right  { text-align: right; }" + CRLF
	cHtml += "    .col-seq  { width: 5%; font-weight: 600; color: #1e293b; }" + CRLF
	cHtml += "    .col-desc { width: 47%; }" + CRLF
	cHtml += "    .col-um   { width: 6%; }" + CRLF
	cHtml += "    .col-qtd  { width: 10%; }" + CRLF
	cHtml += "    .col-prc  { width: 10%; }" + CRLF
	cHtml += "    .col-ipi-aliq { width: 6%; }" + CRLF
	cHtml += "    .col-ipi-val  { width: 7%; }" + CRLF
	cHtml += "    .col-tot  { width: 9%; color: #1e3a8a; font-weight: 700; }" + CRLF
	cHtml += "    .prod-nome { font-weight: 600; color: #000000; font-size: 12px; }" + CRLF
	cHtml += "    .prod-obs {" + CRLF
	cHtml += "      font-size: 11px;" + CRLF
	cHtml += "      color: #334155;" + CRLF
	cHtml += "      font-style: italic;" + CRLF
	cHtml += "      margin-top: 3px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .font-bold { font-weight: 700; }" + CRLF
	cHtml += "    .text-muted { color: #64748b; }" + CRLF
	cHtml += "    .footer-cards {" + CRLF
	cHtml += "      display: grid;" + CRLF
	cHtml += "      grid-template-columns: 60% 40%;" + CRLF
	cHtml += "      gap: 16px;" + CRLF
	cHtml += "      margin-bottom: 16px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .terms-box p { margin-bottom: 5px; color: #334155; font-size: 11.5px; }" + CRLF
	cHtml += "    .signature-area {" + CRLF
	cHtml += "      margin-top: 30px;" + CRLF
	cHtml += "      text-align: center;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .sig-line {" + CRLF
	cHtml += "      width: 70%;" + CRLF
	cHtml += "      margin: 0 auto 4px auto;" + CRLF
	cHtml += "      border-top: 1px solid #475569;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .sig-label { font-size: 10.5px; color: #64748b; font-weight: 600; text-transform: uppercase; }" + CRLF
	cHtml += "    .totals-box {" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      flex-direction: column;" + CRLF
	cHtml += "      gap: 6px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .total-row {" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      justify-content: space-between;" + CRLF
	cHtml += "      font-size: 12px;" + CRLF
	cHtml += "      padding: 2px 4px;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .total-row .lbl { color: #64748b; font-weight: 600; }" + CRLF
	cHtml += "    .total-row .val { color: #0f172a; font-weight: 600; }" + CRLF
	cHtml += "    .grand-total {" + CRLF
	cHtml += "      margin-top: 6px;" + CRLF
	cHtml += "      padding: 10px 14px;" + CRLF
	cHtml += "      background: #eff6ff;" + CRLF
	cHtml += "      border: 1.5px solid #1e3a8a;" + CRLF
	cHtml += "      border-radius: 6px;" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      justify-content: space-between;" + CRLF
	cHtml += "      align-items: center;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    .grand-total .lbl { font-size: 13px; font-weight: 800; color: #1e3a8a; text-transform: uppercase; }" + CRLF
	cHtml += "    .grand-total .val { font-size: 18px; font-weight: 800; color: #1e3a8a; }" + CRLF
	cHtml += "    .audit-bar {" + CRLF
	cHtml += "      display: flex;" + CRLF
	cHtml += "      justify-content: space-between;" + CRLF
	cHtml += "      font-size: 10.5px;" + CRLF
	cHtml += "      color: #94a3b8;" + CRLF
	cHtml += "      padding-top: 8px;" + CRLF
	cHtml += "      border-top: 1px solid #e2e8f0;" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    @media print {" + CRLF
	cHtml += "      * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }" + CRLF
	cHtml += "      body { background: #ffffff !important; padding: 0 !important; color: #000000 !important; font-size: 11px !important; }" + CRLF
	cHtml += "      .action-bar { display: none !important; }" + CRLF
	cHtml += "      .quote-page {" + CRLF
	cHtml += "        box-shadow: none !important;" + CRLF
	cHtml += "        border: none !important;" + CRLF
	cHtml += "        max-width: 100% !important;" + CRLF
	cHtml += "        padding: 0 !important;" + CRLF
	cHtml += "        margin: 0 !important;" + CRLF
	cHtml += "      }" + CRLF
	cHtml += "      .table-container { border: 1.5px solid #0f172a !important; border-radius: 4px !important; }" + CRLF
	cHtml += "      table.items-table thead tr {" + CRLF
	cHtml += "        background-color: #f1f5f9 !important;" + CRLF
	cHtml += "        border-bottom: 2px solid #0f172a !important;" + CRLF
	cHtml += "      }" + CRLF
	cHtml += "      table.items-table th {" + CRLF
	cHtml += "        background-color: #f1f5f9 !important;" + CRLF
	cHtml += "        color: #0f172a !important;" + CRLF
	cHtml += "        font-weight: 800 !important;" + CRLF
	cHtml += "        font-size: 10.5px !important;" + CRLF
	cHtml += "        border-bottom: 2px solid #0f172a !important;" + CRLF
	cHtml += "        padding: 7px 6px !important;" + CRLF
	cHtml += "      }" + CRLF
	cHtml += "      table.items-table th.col-seq { color: #0f172a !important; }" + CRLF
	cHtml += "      table.items-table td {" + CRLF
	cHtml += "        color: #000000 !important;" + CRLF
	cHtml += "        border-bottom: 1px solid #cbd5e1 !important;" + CRLF
	cHtml += "        padding: 6px !important;" + CRLF
	cHtml += "      }" + CRLF
	cHtml += "      .prod-nome { color: #000000 !important; font-weight: 700 !important; font-size: 11.5px !important; }" + CRLF
	cHtml += "      .prod-obs { color: #1e293b !important; font-style: italic !important; font-size: 10.5px !important; }" + CRLF
	cHtml += "      .col-tot { color: #000000 !important; font-weight: 700 !important; }" + CRLF
	cHtml += "      .text-muted { color: #334155 !important; }" + CRLF
	cHtml += "      .card-header {" + CRLF
	cHtml += "        background-color: #f1f5f9 !important;" + CRLF
	cHtml += "        color: #0f172a !important;" + CRLF
	cHtml += "        border-bottom: 1.5px solid #0f172a !important;" + CRLF
	cHtml += "        font-weight: 800 !important;" + CRLF
	cHtml += "      }" + CRLF
	cHtml += "      .badge-title { background: #0f172a !important; color: #ffffff !important; }" + CRLF
	cHtml += "      .grand-total { background: #f8fafc !important; border: 2px solid #0f172a !important; }" + CRLF
	cHtml += "      .grand-total .lbl, .grand-total .val { color: #0f172a !important; }" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "  </style>" + CRLF
	cHtml += "</head>" + CRLF
	cHtml += "<body>" + CRLF
	cHtml += "  <div class='action-bar'>" + CRLF
	cHtml += "    <div class='action-left'>" + CRLF
	cHtml += "      <button class='btn-print' onclick='window.print()'>&#128438; Imprimir / Salvar em PDF</button>" + CRLF
	cHtml += "      <div class='orientation-control'>" + CRLF
	cHtml += "        <span class='orientation-lbl'>Orientacao:</span>" + CRLF
	cHtml += "        <button id='btn-portrait' class='btn-orient " + IIf(nOrientacao == 1, "active", "") + "' onclick='setPortrait()'>&#128196; Retrato</button>" + CRLF
	cHtml += "        <button id='btn-landscape' class='btn-orient " + IIf(nOrientacao == 2, "active", "") + "' onclick='setLandscape()'>&#128209; Paisagem</button>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "    </div>" + CRLF
	cHtml += "    <span class='file-tag'>Arquivo gravado em: <strong>" + cArquivo + "</strong></span>" + CRLF
	cHtml += "  </div>" + CRLF
	cHtml += "  <div class='quote-page " + IIf(nOrientacao == 2, "landscape-mode", "portrait-mode") + "'>" + CRLF

	// 1. Cabecalho com Logo e Numero do Orcamento
	cHtml += "    <div class='header-card'>" + CRLF
	cHtml += "      <div class='company-block'>" + CRLF
	cHtml += "        <img src='" + cLogoSrc + "' alt='Logo' class='logo-img' />" + CRLF
	cHtml += "        <div class='company-details'>" + CRLF
	cHtml += "          <h1>" + cEmpNome + "</h1>" + CRLF
	cHtml += "          <p><strong>CNPJ:</strong> " + cEmpCnpj + " &nbsp;|&nbsp; <strong>I.E.:</strong> " + cEmpInsc + "</p>" + CRLF
	cHtml += "          <p>" + cEmpEnd + "</p>" + CRLF
	cHtml += "          <p>" + cEmpCid + "</p>" + CRLF
	cHtml += "          <p><strong>Telefone:</strong> " + cEmpTel + IIf(!Empty(cEmpFax), " | <strong>Fax:</strong> " + cEmpFax, "") + " &nbsp;|&nbsp; <strong>Site:</strong> www.rewplastic.com.br</p>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "      <div class='quote-badge-block'>" + CRLF
	cHtml += "        <div class='badge-title'>ORCAMENTO DE VENDA</div>" + CRLF
	cHtml += "        <div class='badge-num-box'>" + CRLF
	cHtml += "          <div class='badge-num-lbl'>Numero da Proposta</div>" + CRLF
	cHtml += "          <div class='badge-num-val'>" + SCJ->CJ_NUM + "</div>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "        <div class='badge-meta'>" + CRLF
	cHtml += "          <div><span>Emissao:</span> <strong>" + DTOC(SCJ->CJ_EMISSAO) + "</strong></div>" + CRLF
	cHtml += "          <div><span>Validade:</span> <strong>3 Dias Uteis</strong></div>" + CRLF
	cHtml += "          <div><span>Hora:</span> <strong>" + Time() + "</strong></div>" + CRLF
	cHtml += "          <div><span>Vendedor:</span> <strong>" + cVendedor + "</strong></div>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "    </div>" + CRLF

	// 2. Cards de Dados do Cliente e Condicoes Comerciais
	cHtml += "    <div class='cards-row'>" + CRLF
	cHtml += "      <div class='data-card'>" + CRLF
	cHtml += "        <div class='card-header'>Dados do Destinatario / Cliente</div>" + CRLF
	cHtml += "        <div class='card-body grid-2col'>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Razao Social:</span><span class='field-val'>" + cRazao + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>CNPJ/CPF:</span><span class='field-val'>" + cCNPJ + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Contato:</span><span class='field-val'>" + cContato + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Insc. Estadual:</span><span class='field-val'>" + cIE + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Endereco:</span><span class='field-val'>" + cEnd + IIf(!Empty(cNr) .And. cNr != "SN", ", " + cNr, "") + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Bairro:</span><span class='field-val'>" + cBairro + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Cidade/UF:</span><span class='field-val'>" + cCidade + " - " + cEstado + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>CEP:</span><span class='field-val'>" + cCep + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Telefone:</span><span class='field-val'>" + cTelCli + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>E-mail:</span><span class='field-val'>" + cEmailCli + "</span></div>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "      <div class='data-card'>" + CRLF
	cHtml += "        <div class='card-header'>Condicoes Comerciais e Fornecimento</div>" + CRLF
	cHtml += "        <div class='card-body grid-1col'>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Cond. Pagto.:</span><span class='field-val'>" + cCondPag + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Transportadora:</span><span class='field-val'>" + cTransp + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Tipo de Frete:</span><span class='field-val'>" + cTipoFre + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Vendedor:</span><span class='field-val'>" + cVendedor + "</span></div>" + CRLF
	cHtml += "          <div class='field-item'><span class='field-lbl'>Identificacao:</span><span class='field-val'>" + cNumLacre + "</span></div>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "    </div>" + CRLF

	// 3. Tabela de Itens (PIS, COFINS e ICMS removidos - somente IPI)
	cHtml += "    <div class='table-container'>" + CRLF
	cHtml += "      <table class='items-table'>" + CRLF
	cHtml += "        <thead>" + CRLF
	cHtml += "          <tr>" + CRLF
	cHtml += "            <th class='col-center col-seq'>Item</th>" + CRLF
	cHtml += "            <th class='col-left col-desc'>Descricao do Produto / Servico</th>" + CRLF
	cHtml += "            <th class='col-center col-um'>UM</th>" + CRLF
	cHtml += "            <th class='col-right col-qtd'>Quantidade</th>" + CRLF
	cHtml += "            <th class='col-right col-prc'>Preco Unit.</th>" + CRLF
	cHtml += "            <th class='col-right col-ipi-aliq'>% IPI</th>" + CRLF
	cHtml += "            <th class='col-right col-ipi-val'>Valor IPI</th>" + CRLF
	cHtml += "            <th class='col-right col-tot'>Total Item</th>" + CRLF
	cHtml += "          </tr>" + CRLF
	cHtml += "        </thead>" + CRLF
	cHtml += "        <tbody>" + CRLF
	cHtml +=            cLinhasItens + CRLF
	cHtml += "        </tbody>" + CRLF
	cHtml += "      </table>" + CRLF
	cHtml += "    </div>" + CRLF

	// 4. Rodape: Termos / Aceite e Resumo Financeiro
	cHtml += "    <div class='footer-cards'>" + CRLF
	cHtml += "      <div class='data-card terms-box'>" + CRLF
	cHtml += "        <div class='card-header'>Informacoes Gerais e Aceite da Proposta</div>" + CRLF
	cHtml += "        <div class='card-body'>" + CRLF
	cHtml += "          <p>Em caso de confirmacao, favor retornar assinado ou responder o e-mail com <strong>'Orcamento Aprovado'</strong>.</p>" + CRLF
	cHtml += "          <p>Precos e prazos de entrega validos durante a vigencia desta proposta comercial (3 dias uteis).</p>" + CRLF
	If !Empty(cObsGeral)
		cHtml += "          <p><strong>Obs. Geral:</strong> " + cObsGeral + "</p>" + CRLF
	EndIf
	cHtml += "          <div class='signature-area'>" + CRLF
	cHtml += "            <div class='sig-line'></div>" + CRLF
	cHtml += "            <div class='sig-label'>De Acordo / Assinatura do Cliente &bull; Data: ____/____/________</div>" + CRLF
	cHtml += "          </div>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "      <div class='data-card'>" + CRLF
	cHtml += "        <div class='card-header'>Resumo Financeiro do Orcamento</div>" + CRLF
	cHtml += "        <div class='card-body totals-box'>" + CRLF
	cHtml += "          <div class='total-row'><span class='lbl'>Total dos Produtos:</span><span class='val'>" + Alltrim(Transform(nTotProd, cPicVal)) + "</span></div>" + CRLF
	cHtml += "          <div class='total-row'><span class='lbl'>Total do IPI:</span><span class='val'>" + Alltrim(Transform(nTotIpi, cPicVal)) + "</span></div>" + CRLF
	cHtml += "          <div class='total-row'><span class='lbl'>Valor do Frete:</span><span class='val'>" + Alltrim(Transform(nTotFrete, cPicFre)) + "</span></div>" + CRLF
	cHtml += "          <div class='grand-total'>" + CRLF
	cHtml += "            <span class='lbl'>TOTAL DO ORCAMENTO:</span>" + CRLF
	cHtml += "            <span class='val'>" + Alltrim(Transform(nTotGer, cPicVal)) + "</span>" + CRLF
	cHtml += "          </div>" + CRLF
	cHtml += "        </div>" + CRLF
	cHtml += "      </div>" + CRLF
	cHtml += "    </div>" + CRLF

	// 5. Barra de Auditoria / Sistema (Mantendo apenas Protheus, sem Innovy)
	cHtml += "    <div class='audit-bar'>" + CRLF
	cHtml += "      <span>Protheus ERP - Faturamento</span>" + CRLF
	cHtml += "      <span>Emitido em: " + DTOC(dDataBase) + " as " + Time() + "</span>" + CRLF
	cHtml += "    </div>" + CRLF

	cHtml += "  </div>" + CRLF
	cHtml += "  <script>" + CRLF
	cHtml += "    function setPortrait() {" + CRLF
	cHtml += "      var style = document.getElementById('page-orientation-style');" + CRLF
	cHtml += "      var btnP = document.getElementById('btn-portrait');" + CRLF
	cHtml += "      var btnL = document.getElementById('btn-landscape');" + CRLF
	cHtml += "      var page = document.querySelector('.quote-page');" + CRLF
	cHtml += "      style.innerHTML = '@page { size: A4 portrait; margin: 8mm; }';" + CRLF
	cHtml += "      btnP.classList.add('active');" + CRLF
	cHtml += "      btnL.classList.remove('active');" + CRLF
	cHtml += "      page.classList.remove('landscape-mode');" + CRLF
	cHtml += "      page.classList.add('portrait-mode');" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "    function setLandscape() {" + CRLF
	cHtml += "      var style = document.getElementById('page-orientation-style');" + CRLF
	cHtml += "      var btnP = document.getElementById('btn-portrait');" + CRLF
	cHtml += "      var btnL = document.getElementById('btn-landscape');" + CRLF
	cHtml += "      var page = document.querySelector('.quote-page');" + CRLF
	cHtml += "      style.innerHTML = '@page { size: A4 landscape; margin: 8mm; }';" + CRLF
	cHtml += "      btnL.classList.add('active');" + CRLF
	cHtml += "      btnP.classList.remove('active');" + CRLF
	cHtml += "      page.classList.remove('portrait-mode');" + CRLF
	cHtml += "      page.classList.add('landscape-mode');" + CRLF
	cHtml += "    }" + CRLF
	cHtml += "  </script>" + CRLF
	cHtml += "</body>" + CRLF
	cHtml += "</html>" + CRLF

	// =========================================================================
	// 5. CONVERSAO UTF-8 E GRAVACAO DO ARQUIVO NA PASTA %TEMP% DO USUARIO
	// =========================================================================
	If FindFunction("EncodeUTF8")
		cHtml := EncodeUTF8(cHtml)
	EndIf

	nHandle := FCreate(cArquivo)
	If nHandle >= 0
		FWrite(nHandle, cHtml)
		FClose(nHandle)
	Else
		MemoWrite(cArquivo, cHtml)
	EndIf

	// Abre o HTML diretamente no navegador padrao
	ShellExecute("open", cArquivo, "", "", 1)

	// =========================================================================
	// 6. ENVIO POR E-MAIL (SE SOLICITADO)
	// =========================================================================
	If lEmail
		EnvMail(cArquivo + ";", SCJ->CJ_NUM)
	EndIf

Return

/*/{Protheus.doc} AjustaSX1
    Configuracao de perguntas de relatorio
    @type  Static Function
    @author Microsiga / Protheus
/*/
Static Function AjustaSX1(cPerg)

	Local aAreaAtu := GetArea()
	Local aAreaSX1 := SX1->(GetArea())

	PutSx1(cPerg, "01", "Orcamento de Venda ? ", "", "", "Mv_ch1", "C", TAMSX3("CJ_NUM")[1], 0, 2, "G", "", "SCJ", "", "", "Mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe o numero do orcamento para impressao", ""}, {""}, {""}, "")
	PutSx1(cPerg, "02", "Orientacao Pagina ?   ", "", "", "Mv_ch2", "N", 1, 0, 1, "C", "", "", "", "", "Mv_par02", "Retrato", "Paisagem", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Escolha a orientacao inicial: 1=Retrato, 2=Paisagem", ""}, {""}, {""}, "")

	RestArea(aAreaSX1)
	RestArea(aAreaAtu)

Return

/*/{Protheus.doc} MyGetEnd
    Tratamento de endereco para retorno correto de logradouro e numero
    @type  Static Function
    @author Liber De Esteban
/*/
Static Function MyGetEnd(cEndereco, cAlias)

	Local cCmpEndN := SubStr(cAlias, 2, 2) + "_ENDNOT"
	Local cCmpEst  := SubStr(cAlias, 2, 2) + "_EST"
	Local aRet     := {"", 0, "", ""}

	If (&(cAlias + "->" + cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlias + "->" + cCmpEndN) == "1")
		aRet[1] := cEndereco
		aRet[3] := "SN"
	Else
		aRet := FisGetEnd(cEndereco)
	EndIf

Return aRet

/*/{Protheus.doc} EnvMail
    Interface e envio de e-mail com anexo do orcamento HTML
    @type  Static Function
    @author Microsiga / Protheus
/*/
Static Function EnvMail(cAnexo, cOrc)

	Private mCorpo    := ""
	Private cAssunto  := "Orcamento - " + AllTrim(SA1->A1_NOME) + " - No. " + cOrc
	Private cServer   := Trim(GetMV("MV_RELSERV"))
	Private cDe       := Trim(GetMV("MV_RELACNT"))
	Private cPass     := Trim(GetMV("MV_RELPSW"))
	Private lAutentic := GetMv("MV_RELAUTH", , .F.)
	Private cPara     := SA1->A1_EMAIL
	Private cCC       := IIf(FieldPos("CJ_XVEND1") > 0, Posicione("SA3", 1, xFilial("SA3") + SCJ->CJ_XVEND1, "A3_EMAIL"), "")
	Private lConectou := .F.
	Private lRet      := .F.
	Private lEnviado  := .F.
	Private cMensagem := ""

	mCorpo += "Segue em anexo a proposta comercial do Orcamento: " + cOrc + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	mCorpo += "Ficamos a disposicao para quaisquer esclarecimentos." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	mCorpo += "Atenciosamente," + Chr(13) + Chr(10)
	mCorpo += IIf(FieldPos("CJ_XVEND1") > 0, Capital(Posicione("SA3", 1, xFilial("SA3") + SCJ->CJ_XVEND1, "A3_NOME")), "") + Chr(13) + Chr(10)
	mCorpo += IIf(FieldPos("CJ_XVEND1") > 0, Posicione("SA3", 1, xFilial("SA3") + SCJ->CJ_XVEND1, "A3_EMAIL"), "") + Chr(13) + Chr(10)
	mCorpo += "Departamento Comercial" + Chr(13) + Chr(10)
	mCorpo += "Site: www.rewplastic.com.br" + Chr(13) + Chr(10)

	// Dialog de confirmacao de envio
	@ 122, 67 To 531, 733 Dialog maildlg Title OemToAnsi("Envio de E-Mail")
	@ 2, 4 To 78, 324
	@ 80, 4 To 182, 324
	@ 11, 15 Say OemToAnsi("De :") Size 30, 8
	@ 23, 15 Say OemToAnsi("Para :") Size 25, 8
	@ 35, 15 Say OemToAnsi("CC :") Size 30, 8
	@ 47, 15 Say OemToAnsi("Assunto :") Size 30, 8
	@ 59, 15 Say OemToAnsi("Anexos :") Size 30, 8
	@ 10, 40 Get cDe Size 270, 10 When .F.
	@ 22, 40 Get cPara Size 270, 10 Object oPara
	@ 34, 40 Get cCC Size 270, 10 Object oCC
	@ 46, 40 Get cAssunto Size 270, 10
	@ 58, 40 Get cAnexo Size 270, 10
	@ 88, 9  Get mCorpo MEMO Size 310, 90
	@ 187, 276 Button OemToAnsi("_Enviar") Size 36, 16 Action IIf(!Empty(cPara), Close(maildlg), FWAlertWarning("E-Mail sem destinatario!", "E-MAIL"))
	Activate Dialog maildlg centered

	CONNECT SMTP ;
	SERVER   GetMV("MV_RELSERV") ;
	ACCOUNT  GetMV("MV_RELACNT") ;
	PASSWORD GetMV("MV_RELPSW")  ;
	Result   lConectou

	If lAutentic
		lRet := Mailauth(cDe, cPass)
	Else
		lRet := lConectou
	EndIf

	If lRet
		cPara    := Rtrim(cPara)
		cCC      := Rtrim(cCC)
		cAssunto := Rtrim(cAssunto)

		SEND MAIL FROM cDe ;
		     To       cPara ;
		     CC       cCC ;
		     SUBJECT  cAssunto ;
		     Body     mCorpo ;
		     ATTACHMENT cAnexo ;
		     RESULT   lEnviado

		DISCONNECT SMTP SERVER
	EndIf

	If !(lConectou .And. lEnviado)
		GET MAIL ERROR cMensagem
	EndIf

Return
