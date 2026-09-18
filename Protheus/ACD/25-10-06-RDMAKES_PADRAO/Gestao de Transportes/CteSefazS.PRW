#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} XmlCteN
// Função para CT-e SIMPLIFICADO
@author Daniel Leme
@since 20/03/2025
@type function
/*/
User Function XmlCteS(cTipo,cSerie,cNota,cClieFor,cLoja)

Local cString     := ""
Local cStringCh   := ""
Local cNFe        := ""
Local cCFOP       := ""

Local aCarga      := {0,0,0,0,""}

//-- Inicio das variaveis para CTe //
Local cAliasDT6   := ''
Local cAliasCD2   := ''
Local cAliasAll   := ''
Local cAliasTagE  := ''
Local cAliasTagJ  := ''
Local cQuery      := ''
Local nSerieCTe   := 0
Local cAmbiente   := PARAMIXB[2]
Local cVerAmb     := PARAMIXB[3]
Local cModalidade := PARAMIXB[4]
Local cTimeZone   := PARAMIXB[5]
Local aMotivoCont := PARAMIXB[1,7] //-- Obtem as informacoes de contigencia
Local aXMLCTe     := {}
Local cCT         := ''
Local cChvAcesso  := ''
Local nCount      := 0
Local cProdPred   := ''
Local cCodPred    := ''
Local cCodUF      := ''
Local cCodUFRem   := ''
Local cCodUFDes   := ''
Local cCodUFRec   := '' //--Codigo IBGE da UF do Recebedor
Local cCodUFExp   := '' //--Codigo IBGE da UF do Expedidor
Local cCodUFCon   := ''
Local cCodUFDpc   := ''
Local cCodUFDUL   := ''
Local lTMSCTe     := SuperGetMv( "MV_TMSCTE" , .F., .F. )
Local cTmsAntt    := SuperGetMv( "MV_TMSANTT", .F., .F. )
Local cpRedBC     := ''
Local cInsRemOpc  := ''
Local cInsDesOpc  := ''
Local cSeqEntr    := ''
Local cObs        := ''
Local cDTCObs     := ''
Local cCtrDpc     := ''
Local cSerDpc     := ''
Local cTpDocAnt   := ''
Local cDtEmi      := ''
Local cCTEDocAnt  := ''
Local cTipoNF     := '2'
Local cDevFre	  := ''
Local lCTEVPRE    := SuperGetMv("MV_CTEVPRE",.F.,.F.)
Local cSelOri     := '2'
Local cCodUFOri   := ''
Local lDocApoio   := .F.
Local cAliasDT5   := ''
Local cFilOri     := ''
Local cNumSol     := ''
Local cTpEmis     := ''
Local cDtCont     := ''
Local cChvCTG     := ''
Local cFilDco 	  := ''
Local cDocDco 	  := ''
Local cSerDco 	  := ''
Local lContrib    := .F.
Local nVcred      := 0
Local nBASEICM    := 0
Local nBASICMRET  := 0
Local nCREDPRES   := 0
Local nALIQICM    := 0
Local nVALICM     := 0
Local nALIQSOL    := 0
Local nICMSRET    := 0
Local cCliExp     := ""
Local cLojExp 	  := ""
Local cCliRec	  := ""
Local cLojRec	  := ""
Local cInsAuxOpc  := ""
Local lEPEC		  := .F.

Local nBCICMS 	:= 0
Local nPERFCP 	:= 0
Local nALQTER 	:= 0
Local nALQINT 	:= 0
Local nPEDDES 	:= 0
Local nVALFCP 	:= 0
Local nVALDES 	:= 0
Local nVLTRIB 	:= 0	

Local lUsaColab		:= UsaColaboracao("2")
Local aNFEID		:= {}

Local cMVSINAC 		:= SuperGetMv("MV_CODREG")
Local aAreaSM0		:= SM0->(GetArea())
Local cSubTrib		:= ""
Local cUFST			:= ""
Local lMOC300A      := .T.
Local aRetXML   	:= {}
Local lTMSCTESEF    := ExistBlock("TMSCTESEF",,.T.)
Local cMVURLQCOD	:= SUPERGETMV("MV_URLQCOD", .T., "")
Local aCFOP 		:= {}
Local lDifal        := .T.
Local cCodBenef     := ""
Local lSubConVei := DTC->( FieldPos("DTC_SUBVEI") ) > 0
Local cObsSub		:= ""
Local cKeyInfNFe    := ''
Local aMunDoc		:= {}
Local aAgrDet 		:= {}
Local nVPrest		:= 0
Local nVRec			:= 0
Local nCntDet		:= 0

Local aTamDocs      := IIf(FindFunction('TMSTamDocs'), TMSTamDocs("CTE"), {9, 3})
Local nTamDocumen	:= 0
Local nTamSerie	    := 0

Private aUF       	:= {}
Private aCNPJAntt	:= StrTokArr(SuperGetMv( "MV_CNPJANT", .F., "" ),';') 

Default cTipo     := PARAMIXB[1,1]
Default cSerie    := PARAMIXB[1,3]
Default cNota     := PARAMIXB[1,4]
Default cClieFor  := PARAMIXB[1,5]
Default cLoja     := PARAMIXB[1,6]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aUF,{"RO","11"})
aAdd(aUF,{"AC","12"})
aAdd(aUF,{"AM","13"})
aAdd(aUF,{"RR","14"})
aAdd(aUF,{"PA","15"})
aAdd(aUF,{"AP","16"})
aAdd(aUF,{"TO","17"})
aAdd(aUF,{"MA","21"})
aAdd(aUF,{"PI","22"})
aAdd(aUF,{"CE","23"})
aAdd(aUF,{"RN","24"})
aAdd(aUF,{"PB","25"})
aAdd(aUF,{"PE","26"})
aAdd(aUF,{"AL","27"})
aAdd(aUF,{"MG","31"})
aAdd(aUF,{"ES","32"})
aAdd(aUF,{"RJ","33"})
aAdd(aUF,{"SP","35"})
aAdd(aUF,{"PR","41"})
aAdd(aUF,{"SC","42"})
aAdd(aUF,{"RS","43"})
aAdd(aUF,{"MS","50"})
aAdd(aUF,{"MT","51"})
aAdd(aUF,{"GO","52"})
aAdd(aUF,{"DF","53"})
aAdd(aUF,{"SE","28"})
aAdd(aUF,{"BA","29"})
aAdd(aUF,{"EX","99"})

If cTipo == "1" //-- Saida
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona NF                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DA3")
	DA3->(DbSetOrder(1))
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	If MsSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento temporario do CTe                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lTMSCTe) .Or. (AModNot(SF2->F2_ESPECIE)=="57") .Or. (FunName()$"TMSA200" .Or. FunName()$"TMSA500")
			cAliasDT6 := "DT6_TMP"

			If (Select(cAliasDT6) > 0)
				(cAliasDT6)->(DbCloseArea())
			EndIf

			cQuery := " SELECT CTRC.DT6_FILDOC, " + CRLF
			cQuery += 	" CTRC.DT6_FILORI, " + CRLF
			cQuery += 	" CTRC.DT6_SERIE,  " + CRLF
			cQuery += 	" CTRC.DT6_DOC,    " + CRLF
			cQuery += 	" CTRC.DT6_DATEMI, " + CRLF
			cQuery += 	" CTRC.DT6_HOREMI, " + CRLF
			cQuery += 	" CTRC.DT6_DOCTMS, " + CRLF
			cQuery += 	" CTRC.DT6_TIPTRA, " + CRLF
			cQuery += 	" CTRC.DT6_FILIAL, " + CRLF
			cQuery += 	" CTRC.DT6_FILDOC, " + CRLF
			cQuery += 	" CTRC.DT6_CLIDEV, " + CRLF
			cQuery += 	" CTRC.DT6_LOJDEV, " + CRLF
			cQuery += 	" CTRC.DT6_CLIREM, " + CRLF
			cQuery += 	" CTRC.DT6_LOJREM, " + CRLF
			cQuery += 	" CTRC.DT6_CLIDES, " + CRLF
			cQuery += 	" CTRC.DT6_LOJDES, " + CRLF
			cQuery += 	" CTRC.DT6_CLICON, " + CRLF
			cQuery += 	" CTRC.DT6_LOJCON, " + CRLF
			cQuery += 	" CTRC.DT6_CLIDPC, " + CRLF
			cQuery += 	" CTRC.DT6_LOJDPC, " + CRLF
			cQuery += 	" CTRC.DT6_VALFRE, " + CRLF
			cQuery += 	" CTRC.DT6_VALTOT, " + CRLF
			cQuery += 	" CTRC.DT6_VALFAT, " + CRLF
			cQuery += 	" CTRC.DT6_VALIMP, " + CRLF
			cQuery += 	" CTRC.DT6_PRZENT, " + CRLF
			cQuery += 	" CTRC.DT6_VOLORI, " + CRLF
			cQuery += 	" CTRC.DT6_SERVIC, " + CRLF
			cQuery += 	" CTRC.DT6_LOTNFC, " + CRLF
			cQuery += 	" CTRC.DT6_VALMER, " + CRLF
			cQuery += 	" CTRC.DT6_FILDCO, " + CRLF
			cQuery += 	" CTRC.DT6_DOCDCO, " + CRLF
			cQuery += 	" CTRC.DT6_SERDCO, " + CRLF
			cQuery += 	" CTRC.DT6_CODMSG, " + CRLF
			cQuery += 	" CTRC.DT6_CDRORI, " + CRLF
			cQuery += 	" CTRC.DT6_CDRDES, " + CRLF
			cQuery += 	" CTRC.DT6_PREFIX, " + CRLF
			cQuery += 	" CTRC.DT6_NUM,    " + CRLF
			cQuery += 	" CTRC.DT6_TIPO,   " + CRLF
			cQuery += 	" CTRC.DT6_CODOBS, " + CRLF
			cQuery += 	" CTRC.DT6_CHVCTE, " + CRLF
			cQuery += 	" CTRC.DT6_SITCTE, " + CRLF
			cQuery += 	" CTRC.DT6_DEVFRE, " + CRLF
			cQuery += 	" CTRC.DT6_PESCOB, " + CRLF
			cQuery += 	" CTRC.DT6_CLIEXP, " + CRLF
			cQuery += 	" CTRC.DT6_LOJEXP, " + CRLF
			cQuery += 	" CTRC.DT6_CLIREC, " + CRLF
			cQuery += 	" CTRC.DT6_LOJREC, " + CRLF
			cQuery += 	" CTRC.DT6_SQEDES, " + CRLF
			cQuery += 	" CTRC.DT6_RETIRA, " + CRLF
			
			//-- Remetente
			cQuery += 	" CLIREM.A1_CGC REM_CNPJ, " 	+ CRLF
			cQuery += 	" CLIREM.A1_INSCR REM_INSC,	" 	+ CRLF
			cQuery += 	" CLIREM.A1_CONTRIB REM_CONTRIB, " 	+ CRLF
			cQuery += 	" CLIREM.A1_NOME REM_NOME,"			+ CRLF
			cQuery += 	" CLIREM.A1_NREDUZ REM_NMEFANT,	" 	+ CRLF
			cQuery += 	" CLIREM.A1_DDD REM_DDDTEL,	" 		+ CRLF
			cQuery += 	" CLIREM.A1_TEL REM_TEL," 			+ CRLF
			cQuery += 	" CLIREM.A1_END REM_END," 			+ CRLF
			cQuery += 	" CLIREM.A1_COMPLEM REM_CPL, " 		+ CRLF
			cQuery += 	" CLIREM.A1_BAIRRO REM_BAIRRO, " 	+ CRLF
			cQuery += 	" CLIREM.A1_MUN REM_MUNICI, " 		+ CRLF
			cQuery += 	" CLIREM.A1_CEP REM_CEP, " 			+ CRLF
			cQuery += 	" CLIREM.A1_EST REM_UF,	" 			+ CRLF
			cQuery += 	" CLIREM.A1_PAIS REM_PAIS," 		+ CRLF
			cQuery += 	" CLIREM.A1_CODPAIS REM_CBACEN,	" 	+ CRLF
			cQuery += 	" CLIREM.A1_PESSOA REM_TPPESSOA, " 	+ CRLF
			cQuery += 	" CLIREM.A1_SUFRAMA REM_SUFRAMA, " 	+ CRLF
			cQuery += 	" CLIREM.A1_COD_MUN REM_COD_MUN, " 	+ CRLF
			cQuery += 	" CLIREM.A1_EMAIL REM_EMAIL," 		+ CRLF

			//-- Expedidor
			cQuery += " CLIEXP.A1_CGC EXP_CNPJ, " 			+ CRLF
			cQuery += " CLIEXP.A1_INSCR EXP_INSC, " 		+ CRLF
			cQuery += " CLIEXP.A1_CONTRIB EXP_CONTRIB, " 	+ CRLF
			cQuery += " CLIEXP.A1_NOME EXP_NOME," 			+ CRLF
			cQuery += " CLIEXP.A1_NREDUZ EXP_NMEFANT, " 	+ CRLF
			cQuery += " CLIEXP.A1_DDD EXP_DDDTEL, " 		+ CRLF
			cQuery += " CLIEXP.A1_TEL EXP_TEL, " 			+ CRLF
			cQuery += " CLIEXP.A1_END EXP_END, " 			+ CRLF
			cQuery += " CLIEXP.A1_COMPLEM EXP_CPL, " 		+ CRLF
			cQuery += " CLIEXP.A1_BAIRRO EXP_BAIRRO, " 		+ CRLF
			cQuery += " CLIEXP.A1_MUN EXP_MUNICI, " 		+ CRLF
			cQuery += " CLIEXP.A1_CEP EXP_CEP, " 			+ CRLF
			cQuery += " CLIEXP.A1_EST EXP_UF, " 			+ CRLF
			cQuery += " CLIEXP.A1_PAIS EXP_PAIS, " 			+ CRLF
			cQuery += " CLIEXP.A1_CODPAIS EXP_CBACEN, " 	+ CRLF
			cQuery += " CLIEXP.A1_PESSOA EXP_TPPESSOA,	" 	+ CRLF
			cQuery += " CLIEXP.A1_SUFRAMA EXP_SUFRAMA,	" 	+ CRLF
			cQuery += " CLIEXP.A1_COD_MUN EXP_COD_MUN,	" 	+ CRLF
			cQuery += " CLIEXP.A1_EMAIL   EXP_EMAIL, " 		+ CRLF

			//-- Destinatario
			cQuery += " CLIDES.A1_CGC DES_CNPJ,	" 			+ CRLF
			cQuery += " CLIDES.A1_INSCR DES_INSC, " 		+ CRLF
			cQuery += " CLIDES.A1_CONTRIB DES_CONTRIB, " 	+ CRLF
			cQuery += " CLIDES.A1_NOME DES_NOME, " 			+ CRLF
			cQuery += " CLIDES.A1_DDD DES_DDDTEL, " 		+ CRLF
			cQuery += " CLIDES.A1_TEL DES_TEL,	" 			+ CRLF
			cQuery += " CLIDES.A1_PESSOA DES_TPPESSOA, " 	+ CRLF
			cQuery += " CLIDES.A1_SUFRAMA	DES_SUFRAMA, " 	+ CRLF
			cQuery += " CLIDES.A1_END DES_END, " 			+ CRLF
			cQuery += " CLIDES.A1_COMPLEM DES_CPL, " 		+ CRLF
			cQuery += " CLIDES.A1_BAIRRO DES_BAIRRO, " 		+ CRLF
			cQuery += " CLIDES.A1_MUN DES_MUNICI, " 	 	+ CRLF
			cQuery += " CLIDES.A1_CEP DES_CEP, " 			+ CRLF
			cQuery += " CLIDES.A1_EST DES_UF, " 			+ CRLF
			cQuery += " CLIDES.A1_PAIS DES_PAIS, " 			+ CRLF
			cQuery += " CLIDES.A1_CODPAIS DES_CBACEN, " 	+ CRLF			
			cQuery += " CLIDES.A1_COD_MUN DES_COD_MUN, " 	+ CRLF
			cQuery += " CLIDES.A1_EMAIL DES_EMAIL, " 		+ CRLF

			//-- Recebedor
			cQuery += " CLIREC.A1_CGC REC_CNPJ,	" 			+ CRLF
			cQuery += " CLIREC.A1_INSCR REC_INSC, " 		+ CRLF
			cQuery += " CLIREC.A1_CONTRIB REC_CONTRIB, " 	+ CRLF
			cQuery += " CLIREC.A1_NOME REC_NOME, " 			+ CRLF
			cQuery += " CLIREC.A1_NREDUZ REC_NMEFANT, " 	+ CRLF
			cQuery += " CLIREC.A1_DDD REC_DDDTEL, " 		+ CRLF
			cQuery += " CLIREC.A1_TEL REC_TEL, " 			+ CRLF
			cQuery += " CLIREC.A1_END REC_END, " 			+ CRLF
			cQuery += " CLIREC.A1_COMPLEM REC_CPL, " 		+ CRLF
			cQuery += " CLIREC.A1_BAIRRO REC_BAIRRO, " 		+ CRLF
			cQuery += " CLIREC.A1_MUN REC_MUNICI, " 		+ CRLF
			cQuery += " CLIREC.A1_CEP REC_CEP, " 			+ CRLF
			cQuery += " CLIREC.A1_EST REC_UF, " 			+ CRLF
			cQuery += " CLIREC.A1_PAIS REC_PAIS, " 			+ CRLF
			cQuery += " CLIREC.A1_CODPAIS REC_CBACEN, " 	+ CRLF
			cQuery += " CLIREC.A1_PESSOA REC_TPPESSOA, " 	+ CRLF
			cQuery += " CLIREC.A1_SUFRAMA REC_SUFRAMA, " 	+ CRLF
			cQuery += " CLIREC.A1_COD_MUN REC_COD_MUN, " 	+ CRLF
			cQuery += " CLIREC.A1_EMAIL   REC_EMAIL, " 		+ CRLF

			//-- Consignatario			
			cQuery += " CLICON.A1_CGC CON_CNPJ,	" 			+ CRLF
			cQuery += " CLICON.A1_INSCR CON_INSC, " 		+ CRLF
			cQuery += " CLICON.A1_CONTRIB CON_CONTRIB,	" 	+ CRLF
			cQuery += " CLICON.A1_NOME CON_NOME, " 			+ CRLF
			cQuery += " CLICON.A1_DDD CON_DDDTEL, " 		+ CRLF
			cQuery += " CLICON.A1_TEL CON_TEL,	" 			+ CRLF
			cQuery += " CLICON.A1_PESSOA CON_TPPESSOA,	" 	+ CRLF
			cQuery += " CLICON.A1_SUFRAMA	CON_SUFRAMA," 	+ CRLF
			cQuery += " CLICON.A1_END CON_END, " 			+ CRLF
			cQuery += " CLICON.A1_COMPLEM CON_CPL,	" 		+ CRLF
			cQuery += " CLICON.A1_BAIRRO CON_BAIRRO, " 		+ CRLF
			cQuery += " CLICON.A1_MUN CON_MUNICI, " 		+ CRLF
			cQuery += " CLICON.A1_CEP CON_CEP, " 			+ CRLF
			cQuery += " CLICON.A1_EST CON_UF, " 			+ CRLF
			cQuery += " CLICON.A1_PAIS CON_PAIS, " 			+ CRLF
			cQuery += " CLICON.A1_COD_MUN CON_COD_MUN, " 	+ CRLF
			cQuery += " CLICON.A1_EMAIL   CON_EMAIL," 		+ CRLF
			//-- Despachante
			cQuery += " CLIDPC.A1_CGC DPC_CNPJ,	" 			+ CRLF
			cQuery += " CLIDPC.A1_INSCR DPC_INSC, " 		+ CRLF
			cQuery += " CLIDPC.A1_CONTRIB DPC_CONTRIB," 	+ CRLF
			cQuery += " CLIDPC.A1_NOME DPC_NOME, " 			+ CRLF
			cQuery += " CLIDPC.A1_DDD DPC_DDDTEL, " 		+ CRLF
			cQuery += " CLIDPC.A1_TEL DPC_TEL, " 			+ CRLF
			cQuery += " CLIDPC.A1_PESSOA DPC_TPPESSOA,	" 	+ CRLF
			cQuery += " CLIDPC.A1_SUFRAMA DPC_SUFRAMA,	" 	+ CRLF
			cQuery += " CLIDPC.A1_END DPC_END,	" 			+ CRLF
			cQuery += " CLIDPC.A1_COMPLEM DPC_CPL,	" 		+ CRLF
			cQuery += " CLIDPC.A1_BAIRRO DPC_BAIRRO, " 		+ CRLF
			cQuery += " CLIDPC.A1_MUN DPC_MUNICI, " 		+ CRLF
			cQuery += " CLIDPC.A1_CEP DPC_CEP, " 			+ CRLF
			cQuery += " CLIDPC.A1_EST DPC_UF," 				+ CRLF
			cQuery += " CLIDPC.A1_PAIS DPC_PAIS, " 			+ CRLF
			cQuery += " CLIDPC.A1_COD_MUN DPC_COD_MUN,	" 	+ CRLF
			cQuery += " CLIDPC.A1_EMAIL   DPC_EMAIL	" 		+ CRLF

			cQuery += " FROM " + RetSqlName('DT6') + " CTRC " + CRLF
			cQuery += " INNER JOIN " + RetSqlName('SA1') + " CLIREM  ON (CLIREM.A1_COD = CTRC.DT6_CLIREM AND CLIREM.A1_LOJA = CTRC.DT6_LOJREM ) " + CRLF
			cQuery += " LEFT JOIN " + RetSqlName('SA1') + " CLIEXP  ON (CLIEXP.A1_FILIAL = '" + xFilial('SA1') + "' AND CLIEXP.A1_COD = CTRC.DT6_CLIEXP AND CLIEXP.A1_LOJA = CTRC.DT6_LOJEXP AND CLIEXP.D_E_L_E_T_ = ' '  ) " + CRLF
			cQuery += " INNER JOIN " + RetSqlName('SA1') + " CLIDES  ON (CLIDES.A1_COD = CTRC.DT6_CLIDES AND CLIDES.A1_LOJA = CTRC.DT6_LOJDES   ) " + CRLF
			cQuery += " LEFT  JOIN " + RetSqlName('SA1') + " CLIREC  ON (CLIREC.A1_FILIAL = '" + xFilial('SA1') + "' AND CLIREC.A1_COD = CTRC.DT6_CLIREC AND CLIREC.A1_LOJA = CTRC.DT6_LOJREC AND CLIREC.D_E_L_E_T_ = ' '  ) " + CRLF

			cQuery += " LEFT  JOIN " + RetSqlName('SA1') + " CLICON  ON (CLICON.A1_FILIAL = '" + xFilial('SA1') + "' AND CLICON.A1_COD = CTRC.DT6_CLICON AND CLICON.A1_LOJA = CTRC.DT6_LOJCON AND CLICON.D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery += " LEFT  JOIN " + RetSqlName('SA1') + " CLIDPC  ON (CLIDPC.A1_FILIAL = '" + xFilial('SA1') + "' AND CLIDPC.A1_COD = CTRC.DT6_CLIDPC AND CLIDPC.A1_LOJA = CTRC.DT6_LOJDPC AND CLIDPC.D_E_L_E_T_ = ' ' ) " + CRLF

			cQuery += " WHERE CTRC.DT6_FILIAL   = '" + xFilial('DT6') + "'" + CRLF
			cQuery += 	" AND CTRC.DT6_FILDOC   = '" + cFilAnt + "'" + CRLF
			cQuery += 	" AND CTRC.DT6_DOC      = '" + cNota + "'" + CRLF
			cQuery += 	" AND CTRC.DT6_SERIE    = '" + cSerie + "'" + CRLF
			cQuery += 	" AND CTRC.D_E_L_E_T_   = ' '" + CRLF
			
			cQuery += 	" AND CLIREM.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
			cQuery += 	" AND CLIREM.D_E_L_E_T_ = ' '" + CRLF
			
			cQuery += 	" AND CLIDES.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
			cQuery += 	" AND CLIDES.D_E_L_E_T_ = ' '"
			
			cQuery += " ORDER BY CTRC.DT6_FILDOC, " + CRLF
			cQuery += 	" CTRC.DT6_DOC, " + CRLF
			cQuery += 	" CTRC.DT6_SERIE"
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDT6, .F., .T.)
			(cAliasDT6)->(DbGoTop())
			
			If (!(cAliasDT6)->(Eof())) // (01)
				cString := ''
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Header do Arquivo XML                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cString := '<?xml version="1.0" encoding="UTF-8"?>'
				cString += '<CTeSimp xmlns="http://www.portalfiscal.inf.br/cte">'
				aAdd( aXMLCTe, AllTrim(cString) )

				aAreaSM0 := SM0->(GetArea())
				
				// While !(cAliasDT6)->(Eof()) // (02)
					
					If aScan(aUF,{|x| x[1] ==  AllTrim(SM0->M0_ESTENT) }) != 0 // Confere se Uf do Emitente esta OK
						cCodUF := aUF[ aScan(aUF,{|x| x[1] == AllTrim(SM0->M0_ESTENT) }), 2]						
					Else
						cCodUF := ''
					EndIf
					lMOC300A := !(cCodUF == '41' .And. dDataBase < CToD('05/09/2019'))
					
					If aScan(aUF,{|x| x[1] == (cAliasDT6)->REM_UF }) != 0   //Confere se Uf do Remetente esta OK
						cCodUFRem  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT6)->REM_UF }), 2]						
					Else
						cCodUFRem  := ''
					EndIf
					
					If aScan(aUF,{|x| x[1] == (cAliasDT6)->DES_UF }) != 0   //Confere se Uf do Destinatario esta OK
						cCodUFDes  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT6)->DES_UF }), 2]
					Else
						cCodUFDes := ''
					EndIf

					If aScan(aUF, {|x| x[1] == (cAliasDT6)->REC_UF }) != 0 //Confere se UF do Recebedor esta Ok
						cCodUFRec  := aUF[ aScan(aUF, {|x| x[1] == (cAliasDT6)->REC_UF }), 2]
					Else
						cCodUFRec  := ''
					EndIf
					
					If aScan(aUF, {|x| x[1] == (cAliasDT6)->EXP_UF }) != 0 //Confere se UF do Expedidor esta Ok
						cCodUFExp  := aUF[ aScan(aUF, {|x| x[1] == (cAliasDT6)->EXP_UF }), 2]
					Else
						cCodUFExp  := ''
					EndIf
					
					cMail := AllTrim( Posicione( 'SA1', 1, xFilial('SA1') + (cAliasDT6)->(DT6_CLIDEV+DT6_LOJDEV), 'A1_EMAIL' ) )
					
					If Empty((cAliasDT6)->DT6_SQEDES)
						cUFST := Posicione('SA1',1,xFilial('SA1')+(cAliasDT6)->(DT6_CLIDES+DT6_LOJDES),'A1_EST')
					Else
						cSeqEntr   := (cAliasDT6)->DT6_SQEDES

						DUL->(DbSetOrder(1))
						If DUL->(MsSeek(xFilial("DUL") + cSeqEntr))
							cUFST := DUL->DUL_EST 
						EndIf							

					EndIf
					
					dbSelectArea("SFT")
					SFT->(DbSetOrder(1))
					If SFT->(Dbseek(xFilial("SFT")+"S"+(cAliasDT6)->(DT6_SERIE+DT6_DOC+DT6_CLIDEV+DT6_LOJDEV)))
						cCFOP := SFT->FT_CFOP
					EndIf
					
					If !Empty((cAliasDT6)->CON_UF) // Confere se Uf do Consignatario esta OK
						If (aScan(aUF,{|x| x[1] == (cAliasDT6)->CON_UF }) != 0)
							cCodUFCon  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT6)->CON_UF }), 2]
						Else
							cCodUFCon := ''
						EndIF
					EndIf
					
					If !Empty((cAliasDT6)->DPC_UF)
						If (aScan(aUF,{|x| x[1] == (cAliasDT6)->DPC_UF }) != 0) //Confere se Uf do Despachante esta OK
							cCodUFDpc  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT6)->DPC_UF }), 2]
						Else
							cCodUFDpc  := ''
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gerar Chave de Acesso do CT-e                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSerieCTe := Val( AllTrim((cAliasDT6)->DT6_SERIE))
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Formato de Impressao do CT-e                                    ³
					//³ 1 - Normal    
					//³ 4 - EPEC  	                                                    ³
					//³ 5 - Contingencia versao 1.04 - 7-Contingência FS-DA             ³
					//³ 7 - Contingencia versao 1.04 - SVC-RS                           ³
					//³ 8 - Contingencia versao 1.04 - SVC-SP                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaColab
						cTpEmis := cModalidade
					Else
						If (cModalidade == '1')
							cTpEmis := '1'
						ElseIf cModalidade == '5'
							cTpEmis := '4'
						ElseIf cModalidade == '7'
							cTpEmis := '5'
						ElseIf cModalidade == '8'
							cTpEmis := '8'
						ElseIf cModalidade == '9'
							cTpEmis := '7'
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Voltar rotina abaixo                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty((cAliasDT6)->DT6_CHVCTE)  
						cCT := Inverte()
						cChvAcesso := CTeCHVAC( cCodUF,;
												( SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 3, 2) + SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 5, 2) ),;
												AllTrim(SM0->M0_CGC),;
												'57',;
												StrZero(nSerieCTe, 3),;
												StrZero(Val(PadR((cAliasDT6)->DT6_DOC,9)), 9),;
												cTpEmis + cCT)
					Else
						If Substr(AllTrim((cAliasDT6)->DT6_CHVCTE), 35, 1) $ '4' .And. cTpEmis == '1'
							cCT := Substr(AllTrim((cAliasDT6)->DT6_CHVCTE), 36, 8)
							cChvAcesso := CTeCHVAC( cCodUF,;
												( SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 3, 2) + SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 5, 2) ),;
												AllTrim(SM0->M0_CGC),;
												'57',;
												StrZero(nSerieCTe, 3),;
												StrZero(Val(PadR((cAliasDT6)->DT6_DOC,9)), 9),;
												cTpEmis + cCT)
							lEPEC := .T.
						Else
							cChvAcesso := AllTrim((cAliasDT6)->DT6_CHVCTE)		
							cCT := Substr(AllTrim((cAliasDT6)->DT6_CHVCTE), 36, 8)
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG Responsavel em Fechar os Dados do CTe                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If !lUsaColab .And. (Empty((cAliasDT6)->DT6_CHVCTE) .Or. (cModalidade $ '5;7;8;9' .And. (cAliasDT6)->DT6_SITCTE <> '1')) .Or. lEPEC
						cQuery := " UPDATE " + RetSqlName("DT6") + CRLF
						cQuery += "    SET DT6_CHVCTE = '" + cChvAcesso + "' " + CRLF
						cQuery += "  WHERE DT6_FILIAL = '" + xFilial('DT6') + "'" + CRLF
						cQuery += "    AND DT6_FILDOC = '" + (cAliasDT6)->DT6_FILDOC + "' " + CRLF
						cQuery += "    AND DT6_DOC    = '" + (cAliasDT6)->DT6_DOC    + "' " + CRLF
						cQuery += "    AND DT6_SERIE  = '" + (cAliasDT6)->DT6_SERIE  + "' " + CRLF
						cQuery += "    AND D_E_L_E_T_ = ' ' "
						TCSqlExec( cQuery )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicio dos Dados do CTe                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cNFe    := 'CTe' + AllTrim(cChvAcesso)
					cString := ''
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Versao do Ct-e, de acordo com o parametro                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString += '<infCte Id="CTe' + AllTrim(cChvAcesso) + '" versao="' + cVerAmb + '">'

					aAdd(aXMLCTe,AllTrim(cString))

					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG: B - IdentIficação do Conhecimento de Transporte Eletronico ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ CFOP - Natureza da Prestacao                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					cString := ''
					cString += '<ide>'
					cString += '<cUF>'  + NoAcentoCte( cCodUF )		+ '</cUF>'
					cString += '<cCT>'  + NoAcentoCte( cCT )		+ '</cCT>'
					cString += '<CFOP>' + NoAcentoCte( cCFOP )		+ '</CFOP>'
					aCFOP := FWGetSX5('13',PadR(cCFOP, TamSX3("X5_CHAVE")[1]))
					cString += '<natOp>'+ NoAcentoCte( SubStr(AllTrim(IIf(!Empty(aCFOP), aCFOP[1][4], "")),1,55) )	+ '</natOp>'

					If (cAliasDT6)->DT6_DEVFRE == '1' .And. (cAliasDT6)->REM_CONTRIB == '1'
						lContrib := .T.				
					ElseIf (cAliasDT6)->DT6_DEVFRE == '2' .And. (cAliasDT6)->DES_CONTRIB == '1'
						lContrib := .T.
					ElseIf (cAliasDT6)->DT6_DEVFRE == '3' .And. (cAliasDT6)->CON_CONTRIB == '1'
						lContrib := .T.
					ElseIf (cAliasDT6)->DT6_DEVFRE == '4' .And. (cAliasDT6)->DPC_CONTRIB == '1'
						lContrib := .T.
					ElseIf (cAliasDT6)->DT6_DEVFRE == '6' .And. (cAliasDT6)->EXP_CONTRIB == '1'
						lContrib := .T.
					ElseIf (cAliasDT6)->DT6_DEVFRE == '7' .And. (cAliasDT6)->REC_CONTRIB == '1'
						lContrib := .T.
					EndIf
					
					cCliExp := (cAliasDT6)->( DT6_CLIEXP )
					cLojExp := (cAliasDT6)->( DT6_LOJEXP )
					cCLiRec := (cAliasDT6)->( DT6_CLIREC )
					cLojRec := (cAliasDT6)->( DT6_LOJREC )
					
					cString += '<mod>' 	+ "57" + '</mod>'
					cString += '<serie>'+ NoAcentoCte( cValtoChar( nSerieCTe ) ) + '</serie>'
					cString += '<nCT>'	+ NoAcentoCte( cValtoChar( Val( AllTrim((cAliasDT6)->DT6_DOC) ) ) ) + '</nCT>'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Data e hora de emissão                                           ³
					//³Formato = AAAA-MM-DDTHH:MM:SS                                    ³
					//³Preenchido com data e hora de emissão.                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString += '<dhEmi>' + SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 1, 4) + "-";
					+ SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 5, 2) + "-";
					+ SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 7, 2) + "T";
					+ SubStr(AllTrim((cAliasDT6)->DT6_HOREMI), 1, 2) + ":";
					+ SubStr(AllTrim((cAliasDT6)->DT6_HOREMI), 3, 2) + ':00';
					+ cTimeZone + '</dhEmi>'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Formato de Impressao do DACTE                                   ³
					//³ 1 - Retrato                                                     ³
					//³ 2 - Paisagem                                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString += '<tpImp>1</tpImp>'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Formato de Impressao do CT-e                                    ³
					//³ 1 - Normal                                                      ³
					//³ 4 - EPEC                                                        ³
					//³ 5 - Contingencia versao 1.04                                    ³
					//³ 7 - Contingencia versao 1.04  - SVC-RS                          ³
					//³ 8 - Contingencia versao 1.04  - SVC-SP                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaColab
						cString += '<tpEmis>'+cModalidade+'</tpEmis>'
					Else
						If (cModalidade == '1')
							cString += '<tpEmis>1</tpEmis>'
						ElseIf cModalidade == '5'
							cString += '<tpEmis>4</tpEmis>'
						ElseIf cModalidade == '7'
							cString += '<tpEmis>5</tpEmis>'
						ElseIf cModalidade == '8'
							cString += '<tpEmis>8</tpEmis>'
						ElseIf cModalidade == '9'
							cString += '<tpEmis>7</tpEmis>'
						EndIf
					EndIf
					cString += '<cDV>' + SubStr( AllTrim(cChvAcesso), len( AllTrim(cChvAcesso) ), 1) + '</cDV>'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Identificacao do Ambiente.                                      ³
					//³ 1 - Producao                                                    ³
					//³ 2 - Homologacao                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString += '<tpAmb>' + cAmbiente + '</tpAmb>'

	
					cString += '<tpCTe>5</tpCTe>'
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Processo de Emissao do CT-e                                     ³
					//³ 0 - emissao com aplicativo do contribuinte                      ³
					//³ 1 - avulsa pelo fisco                                           ³
					//³ 2 - avulsa pelo contrinbuinte com seu certificado digital,      ³
					//³     atraves do site do Fisco                                    ³
					//³ 3 - pelo contribuinte com aplicativo fornecido pelo Fisco       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString += '<procEmi>0</procEmi>'					
											
					cFilDco := ""
					cDocDco := ""
					cSerDco := ""	
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tipo de Servico                                                 ³
					//³ 0 - Normal                                                      ³
					//³ 1 - SubContratacao                                              ³
					//³ 2 - Redespacho                                                  ³
					//³ 3 - Redespacho Intermediario                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ DTC - Notas Fiscais: (Informacao do campo DTC_TIPNFC)           ³
					//³ 0 - Normal                                                      ³
					//³ 1 - Devolucao                                                   ³
					//³ 2 - SubContratacao                                              ³
					//³ 3 - Dcto Nao Fiscal                                             ³
					//³ 4 - Exportacao                                                  ³
					//³ 5 - Redespacho                                                  ³
					//³ 6 - Dcto Nao Fiscal 1                                           ³
					//³ 7 - Dcto Nao Fiscal 2                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona as informacoes do produto, baseado na DTC             ³
					//³ Pega o produto com maior valor de mercadoria, definido como     ³
					//³ o produto predominante                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					cAliasAll := GetNextAlias()
					cQuery := " SELECT MAX(DTC.DTC_VALOR),		" + CRLF
					cQuery += " 		 DTC.DTC_TIPNFC,		" + CRLF
					cQuery += " 		 DTC.DTC_DEVFRE,		" + CRLF
					cQuery += " 		 DTC.DTC_CODOBS,		" + CRLF
					cQuery += " 		 DTC.DTC_CTRDPC,		" + CRLF
					cQuery += " 		 DTC.DTC_SERDPC,		" + CRLF
					cQuery += " 		 DTC.DTC_TIPANT,		" + CRLF
					cQuery += " 		 DTC.DTC_DPCEMI,		" + CRLF
					cQuery += " 		 DTC.DTC_CTEANT,		" + CRLF
					cQuery += " 		 DTC.DTC_SELORI,		" + CRLF
					cQuery += " 		 DTC.DTC_CLIDES,		" + CRLF
					cQuery += " 		 DTC.DTC_LOJDES,		" + CRLF
					cQuery += " 		 DTC.DTC_SQEDES,		" + CRLF
					cQuery += " 		 DTC.DTC_FILORI,		" + CRLF
					cQuery += " 		 DTC.DTC_NUMSOL,		" + CRLF
					cQuery += " 		 DTC.DTC_CLIEXP,	" + CRLF
					cQuery += " 		 DTC.DTC_LOJEXP,	" + CRLF
					cQuery += "			 DTC.DTC_CLIREC,	" + CRLF
					cQuery += "			 DTC.DTC_LOJREC,	" + CRLF
					cQuery += "		''	 DTC_CLIREC,	" + CRLF
					cQuery += "		''	 DTC_LOJREC,	" + CRLF
					If lSubConVei
						cQuery += 			" DTC.DTC_SUBVEI,"
					EndIf
					cQuery += " 		 DV3REM.DV3_INSCR REMDV3_INSCR,		" + CRLF
					cQuery += " 		 DV3DES.DV3_INSCR DESDV3_INSCR,		" + CRLF
					cQuery += " 		 SB1.B1_DESC,			" + CRLF
					cQuery += " 		 SB1.B1_COD,			" + CRLF
					cQuery += " 		 SB1.B1_UM				" + CRLF
					cQuery += "   FROM " + RetSqlName("DTC") + " DTC "

					cQuery += " 		INNER JOIN " + RetSqlName('SB1') + " SB1 " 		+ CRLF
					cQuery += "					ON ( SB1.B1_COD = DTC.DTC_CODPRO ) "   + CRLF
					cQuery += "					AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'" + CRLF
					cQuery += "					AND SB1.D_E_L_E_T_ = ' '"

					cQuery += " 		 LEFT JOIN " + RetSqlName('DV3') + " DV3REM " + CRLF
					cQuery += "					ON (DV3REM.DV3_FILIAL = '" + xFilial("DV3") + "'"  + CRLF
					cQuery += "					AND DV3REM.DV3_CODCLI = DTC.DTC_CLIREM " + CRLF
					cQuery += "					AND DV3REM.DV3_LOJCLI = DTC.DTC_LOJREM " + CRLF
					cQuery += "					AND DV3REM.DV3_SEQUEN = DTC.DTC_SQIREM " + CRLF
					cQuery += "					AND DV3REM.D_E_L_E_T_ = ' ') "

					cQuery += " 		 LEFT JOIN " + RetSqlName('DV3') + " DV3DES " + CRLF
					cQuery += "					ON (DV3DES.DV3_FILIAL = '" + xFilial("DV3") + "'"  + CRLF
					cQuery += "					AND DV3DES.DV3_CODCLI = DTC.DTC_CLIDES " + CRLF
					cQuery += "					AND DV3DES.DV3_LOJCLI = DTC.DTC_LOJDES " + CRLF
					cQuery += "					AND DV3DES.DV3_SEQUEN = DTC.DTC_SQIDES " + CRLF
					cQuery += "					AND DV3DES.D_E_L_E_T_ = ' ') "

					cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 " + CRLF
					cQuery += "	  ON DT6.DT6_FILIAL   = '" + xFilial("DT6") + "'"  + CRLF
					cQuery += "  AND DT6.DT6_CLIDEV   = '" + (cAliasDT6)->DT6_CLIDEV + "'" + CRLF
					cQuery += "  AND DT6.DT6_LOJDEV   = '" + (cAliasDT6)->DT6_LOJDEV + "'" + CRLF
					cQuery += "  AND DT6.DT6_PREFIX   = '" + (cAliasDT6)->DT6_PREFIX + "'" + CRLF
					cQuery += "  AND DT6.DT6_NUM      = '" + (cAliasDT6)->DT6_NUM    + "'" + CRLF
					cQuery += "  AND DT6.DT6_TIPO     = '" + (cAliasDT6)->DT6_TIPO   + "'" + CRLF
					cQuery += "  AND DT6.DT6_DOCTMS   = 'U' " 
					cQuery += "  AND DT6.D_E_L_E_T_   = ' '" + CRLF

					cQuery += " WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "'" + CRLF
					cQuery += "  AND DTC.DTC_FILDOC   = DT6.DT6_FILDOC " + CRLF
					cQuery += "  AND DTC.DTC_DOC      = DT6.DT6_DOC    " + CRLF
					cQuery += "  AND DTC.DTC_SERIE    = DT6.DT6_SERIE  " + CRLF
					cQuery += "  AND DTC.D_E_L_E_T_   = ' '" + CRLF

					cQuery += " GROUP BY DV3REM.DV3_INSCR, DV3DES.DV3_INSCR, DTC.DTC_TIPNFC, DTC.DTC_DEVFRE, DTC.DTC_CODOBS, DTC.DTC_CTRDPC, DTC.DTC_SERDPC, DTC.DTC_TIPANT, "+ CRLF
					cQuery += "          DTC.DTC_DPCEMI, DTC.DTC_CTEANT, DTC.DTC_SELORI, DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_SQEDES, DTC.DTC_FILORI, DTC.DTC_NUMSOL, " + CRLF
					cQuery += " 		 DTC.DTC_CLIEXP,	DTC.DTC_LOJEXP, " + CRLF
					cQuery += "			 DTC.DTC_CLIREC, DTC.DTC_LOJREC,	" + CRLF
					If lSubConVei
						cQuery +=			" DTC.DTC_SUBVEI,"
					EndIf
					cQuery += "          SB1.B1_DESC, SB1.B1_COD , SB1.B1_UM " + CRLF
					
					cQuery += " ORDER BY MAX(DTC.DTC_VALOR) DESC" + CRLF
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAll, .F., .T.)
					lDocApoio := !(cAliasAll)->(Eof())

					If !(cAliasAll)->(Eof())
						cCtrDpc    := NoAcentoCte( (cAliasALL)->DTC_CTRDPC )
						cSerDpc    := NoAcentoCte( (cAliasALL)->DTC_SERDPC )
						cTpDocAnt  := NoAcentoCte( (cAliasALL)->DTC_TIPANT )
						cDtEmi     := SubStr(AllTrim((cAliasALL)->DTC_DPCEMI), 1, 4) + "-";
									+ SubStr(AllTrim((cAliasALL)->DTC_DPCEMI), 5, 2) + "-";
									+ SubStr(AllTrim((cAliasALL)->DTC_DPCEMI), 7, 2)
						cCTEDocAnt := NoAcentoCte( (cAliasALL)->DTC_CTEANT)

						cTipoNF    := NoAcentoCte( (cAliasAll)->DTC_TIPNFC ) 
						cDevFre	 := (cAliasAll)->( DTC_DEVFRE )
						cSelOri    := (cAliasAll)->( DTC_SELORI )
						if (AllTrim((cAliasAll)->DTC_CLIDES) + AllTrim((cAliasAll)->DTC_LOJDES)) ==;
						   (AllTrim((cAliasDT6)->DT6_CLIDES) + AllTrim((cAliasDT6)->DT6_LOJDES))
							cSeqEntr   := (cAliasAll)->( DTC_SQEDES )						
						EndIF						
						
						cFilOri    := (cAliasAll)->( DTC_FILORI )
						cNumSol    := (cAliasAll)->( DTC_NUMSOL )

						If !Empty((cAliasAll)->REMDV3_INSCR)
							cInsRemOpc := NoPontos((cAliasALL)->REMDV3_INSCR)
						EndIf
						If !Empty((cAliasAll)->DESDV3_INSCR)
							cInsDesOpc := NoPontos((cAliasALL)->DESDV3_INSCR)
						EndIf
						
						If AllTrim((cAliasDT6)->DT6_DOCTMS) == "6"							
							cInsAuxOpc := cInsDesOpc
							cInsDesOpc := cInsRemOpc
							cInsRemOpc := cInsAuxOpc
						EndIf

						If lSubConVei .AND. !Empty( (cAliasALL)->DTC_SUBVEI ) .AND. DA3->(DbSeek( FWxFilial("DA3") + (cAliasALL)->DTC_SUBVEI ) )
							cObsSub := RetObsSub( DA3->DA3_CODFOR, DA3->DA3_LOJFOR, DA3->DA3_PLACA, DA3->DA3_ESTPLA, DA3->DA3_MARVEI )
						EndIf

						cProdPred := NoAcentoCte( (cAliasAll)->B1_DESC )
						cCodPred  := NoAcentoCte( (cAliasAll)->B1_COD )
						aCarga[5] := NoAcentoCte( (cAliasAll)->B1_UM )

						While (CAliasAll)->(!Eof())
							cDTCObs    := NoAcentoCte( StrTran(MsMM((cAliasALL)->DTC_CODOBS),Chr(13),"") )
							(CAliasAll)->(dbSkip())
						EndDo
					EndIf
					(cAliasAll)->(DbCloseArea())


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³                                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString += '<verProc>' + cVerAmb + '</verProc>'
					
					cString += '<cMunEnv>' + NoAcentoCte( SM0->M0_CODMUN ) + '</cMunEnv>'
					cString += '<xMunEnv>' + NoAcentoCte( SM0->M0_CIDENT ) + '</xMunEnv>'
					cString += '<UFEnv>'   + NoAcentoCte( SM0->M0_ESTENT ) + '</UFEnv>'
				
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Modal                                                           ³
					//³ 01 - Rodoviario;                                                ³
					//³ 02 - Aereo;                                                     ³
					//³ 03 - Aquaviario;                                                ³
					//³ 04 - Ferroviario;                                               ³
					//³ 05 - Dutoviario.                                                ³
					//³ 06 - Multimodal                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If (cAliasDT6)->DT6_TIPTRA == '6'
						cString += '<modal>06</modal>'
					Else
						cString += '<modal>01</modal>'
					EndIf

					If cTipoNF $ '0,1,3,4,6,7'
						cString   += '<tpServ>0</tpServ>'
					ElseIf cTipoNF == '2'
						cString   += '<tpServ>1</tpServ>'
					ElseIf cTipoNF == '5'
						cString   += '<tpServ>2</tpServ>'
					ElseIf	cTipoNF $ '8/A'
						cString   += '<tpServ>4</tpServ>'					
					ElseIf	cTipoNF == '9'
						cString   += '<tpServ>3</tpServ>'
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Municipio inicio e termino da prestacao                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cSelOri == StrZero(1,Len(DTC->DTC_SELORI)) .Or.  AllTrim((cAliasDT6)->DT6_DOCTMS) $ "6/7"  //Transportadora ou CT-e de Devolução e Reentrega
						DUY->(DbSetOrder(1))
						If DUY->(MsSeek(xFilial("DUY")+(cAliasDT6)->DT6_CDRORI))
							If (aScan(aUF,{|x| x[1] == DUY->DUY_EST }) != 0)
								cCodUFOri := aUF[ aScan(aUF,{|x| x[1] == DUY->DUY_EST }), 2]
							Else
								cCodUFOri := ''
							EndIf
							cString += '<UFIni>'   + NoAcentoCte( DUY->DUY_EST ) + '</UFIni>'
						EndIf
					ElseIf cSelOri == StrZero(2,Len(DTC->DTC_SELORI))   //Remetente
						
						cString += '<UFIni>'   + NoAcentoCte( (cAliasDT6)->(REM_UF) ) + '</UFIni>'

					ElseIf cSelOri == StrZero(3,Len(DTC->DTC_SELORI))   //Coleta ou expedidor.

						If !Empty((cAliasDT6)->DT6_CLIEXP) //--Origem Expedidor?
							cString += '<UFIni>'   + NoAcentoCte( (cAliasDT6)->(EXP_UF) ) + '</UFIni>'
						Else //-- ou Coleta
							cAliasDT5:= GetNextAlias()
							cQuery := " SELECT DUE_MUN, DUE_CODMUN, DUE_EST, DUL_MUN, DUL_CODMUN, DUL_EST "
							cQuery += "  FROM " + RetSQLName("DT5") + " DT5 "
							cQuery += "  JOIN " + RetSQLName("DUE") + " DUE "
							cQuery += "    ON DUE_FILIAL = '" + xFilial("DUE") + "' "
							cQuery += "    AND DUE_CODSOL = DT5_CODSOL "
							cQuery += "    AND DUE.D_E_L_E_T_ = ' ' "
							cQuery += "  LEFT JOIN " + RetSQLName("DUL") + " DUL "
							cQuery += "    ON DUL_FILIAL = '" + xFilial("DUL") + "' "
							cQuery += "    AND DUL_CODSOL = DT5_CODSOL "
							cQuery += "    AND DUL_SEQEND = DT5_SEQEND "
							cQuery += "    AND DUL.D_E_L_E_T_ = ' ' "
							cQuery += "  WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
							cQuery += "    AND DT5_FILORI = '" + cFilOri + "' "
							cQuery += "    AND DT5_NUMSOL = '" + cNumSol + "' "
							cQuery += "    AND DT5.D_E_L_E_T_ = ' ' "
							cQuery := ChangeQuery(cQuery)

							DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT5,.T.,.T.)
							If !(cAliasDT5)->(Eof())
								//-- Endereco do Solicitante
								If !Empty((cAliasDT5)->DUL_CODMUN)
									If aScan(aUF,{|x| x[1] == (cAliasDT5)->DUL_EST }) != 0   //Confere se Uf do End.Solicitante esta OK
										cCodUFOri  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT5)->DUL_EST }), 2]
									Else
										cCodUFOri  := ''
									EndIf
									cString += '<UFIni>'   + NoAcentoCte( (cAliasDT5)->(DUL_EST) ) + '</UFIni>'
								Else
									//-- Solicitante
									If aScan(aUF,{|x| x[1] == (cAliasDT5)->DUE_EST }) != 0   //Confere se Uf do Solicitante esta OK
										cCodUFOri  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT5)->DUE_EST }), 2]
									Else
										cCodUFOri  := ''
									EndIf
									cString += '<UFIni>'   + NoAcentoCte( (cAliasDT5)->(DUE_EST) ) + '</UFIni>'
								EndIf
							EndIf
							(cAliasDT5)->(DbCloseArea())
						EndIf
					EndIf
					
				
					If !Empty(cSeqEntr)//-- Seq.Entrega preenchida

						If !Empty((cAliasDT6)->DT6_CLIREC)//-- Recebedor preenchido
							cString += '<UFFim>'	+ NoAcentoCte( (cAliasDT6)->REC_UF   )  + '</UFFim>'
						Else
							DUL->(DbSetOrder(1))
								If DUL->(MsSeek(xFilial("DUL") + (cAliasDT6)->DT6_SQEDES)) .AND. (cAliasDT6)->DT6_CDRDES != DUL->DUL_CDRDES .And. !(cAliasDT6)->DT6_DOCTMS $ '67' //Devolução ou Reentrega
									If aScan(aUF,{|x| x[1] == DUL->DUL_EST }) != 0   //Confere se Uf da DUL esta OK
										cCodUFDUL  := aUF[ aScan(aUF,{|x| x[1] == DUL->DUL_EST }), 2]
										cString += '<UFFim>'	+ NoAcentoCte( DUL->DUL_EST ) + '</UFFim>'
									EndIf
							
								Else
									cString += '<UFFim>'	+ NoAcentoCte( (cAliasDT6)->DES_UF ) + '</UFFim>'
								EndIf
						EndIf

					ElseIf Empty(cSeqEntr) .And. !Empty((cAliasDT6)->DT6_CLIREC)
						cString += '<UFFim>'	+ NoAcentoCte( (cAliasDT6)->REC_UF   )  + '</UFFim>'
					Else
						cString += '<UFFim>'	+ NoAcentoCte( (cAliasDT6)->DES_UF ) + '</UFFim>'
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Recebedor retira no aeroporto,filial, porto ou Estacao Destino? ³
					//³ 0 - SIM / 1 - NAO                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If  (cAliasDT6)->DT6_RETIRA == '1'
						cString += '<retira>0</retira>'
						cString += '<xDetRetira>NAO SE APLICA</xDetRetira>'
					Else
						cString += '<retira>1</retira>'							
					EndIf

					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Contigencia 1.04                                                 ³
					//³Data e hora de entrada em contigencia                            ³
					//³Formato = AAAA-MM-DDTHH:MM:SS                                    ³
					//³Justificativa da Contigencia -                                   ³
					//³Preenchida no momento de escolha da opcao de Contigencia FSDA    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaColab
						If	cModalidade == '5'
							cString += '<dhCont>' + ColGetPar("MV_CTINCON","") + '</dhCont>'
							cString += '<xJust>'  + ColGetPar("MV_CTXJUST","") + '</xJust>'
						EndIf
					Else
						If	cModalidade == '7'
							If	Len(aMotivoCont) >= 3
								cDtCont := DTOS(aMotivoCont[2])
								cString += '<dhCont>' + SubStr(AllTrim(cDtCont), 1, 4) + "-";
								+ SubStr(AllTrim(cDtCont), 5, 2) + "-";
								+ SubStr(AllTrim(cDtCont), 7, 2) + "T";
								+ SubStr(AllTrim(aMotivoCont[3]), 1, 2) + ":";
								+ SubStr(AllTrim(aMotivoCont[3]), 4, 2) + ':00';
								+ cTimeZone + '</dhCont>'
								cString += '<xJust>' + aMotivoCont[1] + '</xJust>'
							EndIf
						EndIf
					EndIf
					
					cString += '</ide>'
					aAdd(aXMLCTe,AllTrim(cString))
					
					//--Valor do credito presumido
					SFT->(DbSetOrder(1))
					If SFT->(Dbseek(xFilial("SFT")+"S"+cSerie+cNota+cClieFor+cLoja)) .And. SFT->FT_CRDPRES > 0
						nVcred := SFT->FT_CRDPRES
					EndIf 
			
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG:  Informacoes relativas ICMS para a UF de término da `     //
					// prestação do serviço de transporte nas operações interestaduais //
					// para consumidor final  Emenda Constitucional 87 de 2015.        //
					// Nota Técnica 2015/003 e 2015/004                                //
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					If SFT->FT_DIFAL != 0 
						//--Zerar Variaveis
						nBCICMS := 0
						nPERFCP := 0
						nALQTER := 0
						nALQINT := 0
						nPEDDES := 0
						nVALFCP := 0
						nVALDES := 0
						nVLTRIB := 0
							
						cAliasCD2 := GetNextAlias()					
						cQuery := " SELECT SUM(CD2.CD2_BC) CD2_BC,"+ CRLF
						cQuery += " CD2.CD2_PFCP," + CRLF
						cQuery += " CD2.CD2_ALIQ," + CRLF
						cQuery += " CD2.CD2_ADIF," + CRLF
						cQuery += " CD2.CD2_PDDES," + CRLF
						cQuery += " SUM(CD2.CD2_VFCP) CD2_VFCP," + CRLF
						cQuery += " SUM(CD2.CD2_VDDES) CD2_VDDES,"+ CRLF
						cQuery += " SUM(CD2.CD2_VLTRIB) CD2_VLTRIB, " + CRLF	
						cQuery += " SUM(CD2.CD2_PREDBC) CD2_PREDBC " + CRLF
						cQuery += "   FROM "+ RetSqlName("SD2") + " D2," + RetSqlName("CD2") + " CD2 "  + CRLF	
						cQuery += "    WHERE D2.D2_FILIAL  = '" + xFilial('SD2') + "'" + CRLF
						cQuery += "    AND D2.D2_DOC     = '" + cNota    + "'" + CRLF      
						cQuery += "    AND D2.D2_SERIE   = '" + cSerie   + "'" + CRLF      
						cQuery += "    AND D2.D2_CLIENTE = '" + cClieFor + "'" + CRLF      
						cQuery += "    AND D2.D2_LOJA    = '" + cLoja    + "'" + CRLF      
						cQuery += "    AND D2.D_E_L_E_T_ = ''" + CRLF       
													
						cQuery += "    AND CD2.CD2_FILIAL = '"  + xFilial('CD2') + "'" + CRLF							
						cQuery += "    AND CD2.CD2_CODCLI = D2.D2_CLIENTE " + CRLF
						cQuery += "    AND CD2.CD2_LOJCLI = D2.D2_LOJA " + CRLF
						cQuery += "    AND CD2.CD2_DOC    = D2.D2_DOC " + CRLF
						cQuery += "    AND CD2.CD2_SERIE  = D2.D2_SERIE " + CRLF
						cQuery += "    AND CD2.CD2_ITEM   = D2.D2_ITEM " + CRLF
						cQuery += "    AND CD2.CD2_IMP    = '" + PadR("CMP",TamSX3("CD2_IMP")[1]) + "'" + CRLF
						cQuery += "    AND CD2.D_E_L_E_T_=' '" + CRLF	
						
						cQuery += " GROUP BY CD2.CD2_PFCP,CD2.CD2_ALIQ,CD2.CD2_ADIF,CD2.CD2_PDDES "	+ CRLF						  
											
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCD2, .F., .T.)
						If !(cAliasCD2)->(Eof())
							nBCICMS := (cAliasCD2)->CD2_BC
							nPERFCP := (cAliasCD2)->CD2_PFCP
							nALQTER := (cAliasCD2)->CD2_ALIQ
							nALQINT := (cAliasCD2)->CD2_ADIF
							nPEDDES := (cAliasCD2)->CD2_PDDES
							nVALFCP := (cAliasCD2)->CD2_VFCP
							nVALDES := (cAliasCD2)->CD2_VDDES
							nVLTRIB := (cAliasCD2)->CD2_VLTRIB
							cpRedBC := (cAliasCD2)->CD2_PREDBC
						EndIf			

						(cAliasCD2)->(DbCloseArea())
					
					ElseIf SFT->FT_VALFECP != 0

						//--Zerar Variaveis
						nBCICMS := 0
						nPERFCP := 0
						nALQTER := 0
						nALQINT := 0
						nPEDDES := 0
						nVALFCP := 0
						nVALDES := 0
						nVLTRIB := 0
							
						cAliasCD2 := GetNextAlias()					
						cQuery := " SELECT SUM(CD2.CD2_BC) CD2_BC,"+ CRLF
						cQuery += " CD2.CD2_PFCP," + CRLF
						cQuery += " CD2.CD2_ALIQ," + CRLF
						cQuery += " CD2.CD2_ADIF," + CRLF
						cQuery += " CD2.CD2_PDDES," + CRLF
						cQuery += " SUM(CD2.CD2_VFCP) CD2_VFCP," + CRLF
						cQuery += " SUM(CD2.CD2_VDDES) CD2_VDDES,"+ CRLF
						cQuery += " SUM(CD2.CD2_VLTRIB) CD2_VLTRIB, " + CRLF	
						cQuery += " SUM(CD2.CD2_PREDBC) CD2_PREDBC " + CRLF
																						
						cQuery += "   FROM "+ RetSqlName("SD2") + " D2," + RetSqlName("CD2") + " CD2 "  + CRLF	
						cQuery += "    WHERE D2.D2_FILIAL  = '" + xFilial('SD2') + "'" + CRLF
						cQuery += "    AND D2.D2_DOC     = '" + cNota    + "'" + CRLF      
						cQuery += "    AND D2.D2_SERIE   = '" + cSerie   + "'" + CRLF      
						cQuery += "    AND D2.D2_CLIENTE = '" + cClieFor + "'" + CRLF      
						cQuery += "    AND D2.D2_LOJA    = '" + cLoja    + "'" + CRLF      
						cQuery += "    AND D2.D_E_L_E_T_ = ''" + CRLF       
													
						cQuery += "    AND CD2.CD2_FILIAL = '"  + xFilial('CD2') + "'" + CRLF							
						cQuery += "    AND CD2.CD2_CODCLI = D2.D2_CLIENTE " + CRLF
						cQuery += "    AND CD2.CD2_LOJCLI = D2.D2_LOJA " + CRLF
						cQuery += "    AND CD2.CD2_DOC    = D2.D2_DOC " + CRLF
						cQuery += "    AND CD2.CD2_SERIE  = D2.D2_SERIE " + CRLF
						cQuery += "    AND CD2.CD2_ITEM   = D2.D2_ITEM " + CRLF
						cQuery += "    AND CD2.CD2_IMP    = '" + PadR("ICM",TamSX3("CD2_IMP")[1]) + "'" + CRLF
						cQuery += "    AND CD2.D_E_L_E_T_=' '" + CRLF	
						
						cQuery += " GROUP BY CD2.CD2_PFCP,CD2.CD2_ALIQ,CD2.CD2_ADIF,CD2.CD2_PDDES "	+ CRLF						  
											
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCD2, .F., .T.)
						If !(cAliasCD2)->(Eof())
							nBCICMS := (cAliasCD2)->CD2_BC
							nPERFCP := (cAliasCD2)->CD2_PFCP
							nALQTER := (cAliasCD2)->CD2_ALIQ
							nALQINT := (cAliasCD2)->CD2_ADIF
							nPEDDES := (cAliasCD2)->CD2_PDDES
							nVALFCP := (cAliasCD2)->CD2_VFCP
							nVALDES := (cAliasCD2)->CD2_VDDES
							nVLTRIB := (cAliasCD2)->CD2_VLTRIB
							cpRedBC := (cAliasCD2)->CD2_PREDBC
						EndIf			

						(cAliasCD2)->(DbCloseArea())

					Else
						//--Valores para BASE Reduziada de ICMS
						cAliasCD2 := GetNextAlias()					
						cQuery := " SELECT CD2_PREDBC"+ CRLF
						cQuery += "   FROM "+ RetSqlName("CD2") + " CD2 "  + CRLF
						cQuery += "   WHERE CD2.CD2_FILIAL  = '" + xFilial('CD2') + "'" + CRLF
						cQuery += "    AND CD2.CD2_CODCLI = '" + cClieFor + "'" + CRLF
						cQuery += "    AND CD2.CD2_LOJCLI = '" + cLoja    + "'" + CRLF
						cQuery += "    AND CD2.CD2_DOC    = '" + cNota    + "'" + CRLF
						cQuery += "    AND CD2.CD2_SERIE  = '" + cSerie   + "'" + CRLF   
						cQuery += "    AND CD2.CD2_IMP    = '" + PadR("ICM",TamSX3("CD2_IMP")[1]) + "'" + CRLF
						cQuery += "    AND CD2.D_E_L_E_T_=' '" + CRLF

						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCD2, .F., .T.)

						If !(cAliasCD2)->(Eof())
							If (cAliasCD2)->CD2_PREDBC > 0
								cpRedBC := (cAliasCD2)->CD2_PREDBC
							EndIf 
						EndIf

						(cAliasCD2)->(DbCloseArea()) 
						
						//Tratamento para que nao sejam geradas as TAGs no XML caso nao atenda as condiçoes
						lDifal := .F.
					EndIf
					//--Valor do ICMS de partilha para a UF de término da prestação do serviço de transporte
					If nVALDES > 0
						cDTCObs += "Valor do ICMS de partilha para a UF de termino da prestacao do servico de transporte.R$ " + cValtochar(nVALDES)						
					EndIf
					If !Empty(cObsSub)
						cDTCObs += cObsSub
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG: Dados complementares do CT-e para fins operacionais ou      ³
					//³ comerciaisEmitente do CT-e                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cDTCObs) .Or. (cAliasDT6)->DT6_VALIMP > 0 .Or. SF2->F2_TOTIMP > 0
						cString := '<compl>'
						//-- Observacoes Gerais
						If !Empty(cDTCObs)
							cString += '<xObs>' + NoAcentoCte(SubStr(cDTCObs,1,1000)) + '</xObs>'
						EndIf						
						//-- Observacoes Contribuintes - Uso exclusivo do emissor CT-E
						If SF2->F2_TOTIMP > 0
							cTxtObs := 'O valor aproximado de tributos incidentes sobre o preco deste servico e de R$ ' + PADL(Transform(SF2->F2_TOTIMP,'@E 999,999.99'),20)
							cString +=  '<ObsCont xCampo="LeidaTransparencia">'
							cString +=    '<xTexto>'+cTxtObs+'</xTexto>'
							cString +=  '</ObsCont>'
							cString += '</compl>'						
						//-- Observacoes Contribuintes - Uso exclusivo do emissor CT-E
						ElseIf (cAliasDT6)->DT6_VALIMP > 0
							cTxtObs := 'O valor aproximado de tributos incidentes sobre o preco deste servico e de R$ ' + PADL(Transform((cAliasDT6)->DT6_VALIMP,'@E 999,999.99'),20)
							cString +=  '<ObsCont xCampo="LeidaTransparencia">'
							cString +=    '<xTexto>'+cTxtObs+'</xTexto>'
							cString +=  '</ObsCont>'
							cString += '</compl>'
						Else
							cString += '</compl>'	
						EndIf
						aAdd(aXMLCTe,AllTrim(cString))
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG: D - Emitente do CT-e                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cString := '<emit>'
					cString += '<CNPJ>' + NoPontos(SM0->M0_CGC) + '</CNPJ>' 
					
					If !(AllTrim(SM0->M0_INSC) == 'ISENTO')
						cString += '<IE>' + NoPontos(SM0->M0_INSC) + '</IE>'
					EndIf
					
					If lDifal .And. !Empty(cUFST)						
					    cSubTrib := GetSubTrib(cUFST,lDifal) 
						If !Empty(cSubTrib)
							cString += '<IEST>' + NoPontos(cSubTrib) + '</IEST>'		
						EndIf				
					EndIf 

					cString += '<xNome>' + NoAcentoCte(SubStr(SM0->M0_NOMECOM,1,60)) + '</xNome>'
					cString += '<xFant>' + NoAcentoCte(SM0->M0_NOME) + '</xFant>'
					cString += '<enderEmit>'
					cString += '<xLgr>' + NoAcentoCte(FisGetEnd(SM0->M0_ENDENT)[1]) + '</xLgr>'
					cString += '<nro>'  + Iif(FisGetEnd(SM0->M0_ENDENT)[2]<>0, AllTrim(cValtoChar( FisGetEnd(SM0->M0_ENDENT)[2])),"S/N") + '</nro>'
					If !Empty(NoAcentoCte(FisGetEnd(SM0->M0_ENDENT)[4]))
						cString += '<xCpl>' + NoAcentoCte(FisGetEnd(SM0->M0_ENDENT)[4]) + '</xCpl>'
					EndIf
					If Empty(AllTrim(SM0->M0_BAIRENT))
						cString += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
					Else
						cString += '<xBairro>' + NoAcentoCte( SM0->M0_BAIRENT ) + '</xBairro>'
					EndIf

					cString += '<cMun>' + NoAcentoCte( SM0->M0_CODMUN ) + '</cMun>'
					cString += '<xMun>' + NoAcentoCte( SM0->M0_CIDENT ) + '</xMun>'
					cString += '<CEP>'  + NoAcentoCte( SM0->M0_CEPENT ) + '</CEP>'
					cString += '<UF>'   + NoAcentoCte( SM0->M0_ESTENT ) + '</UF>'
					If !Empty (NoPontos(SM0->M0_TEL))
						cString += '<fone>' + cValtoChar(NoPontos(SM0->M0_TEL)) + '</fone>'
					EndIf
					cString += '</enderEmit>'
					If AllTrim(cVerAmb) == '4.00'
						cString += '<CRT>' + cMVSINAC + '</CRT>'
					EndIf
					cString += '</emit>'

					aAdd(aXMLCTe,AllTrim(cString))
					cString := ""

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG Tomador do Serviço ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					cString += CTeToma(cAliasDT6, 1, cCodUFRem,cCodUFDes,cCodUFRec,cCodUFExp,cCodUFCon,cCodUFDpc,cCodUFDUL)
					If cAmbiente == '2'
						cString := Substring(cString,1,At('<xNome>',cString)-1) + ;
								  '<xNome>' + (SubStr('CTE EMITIDO EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL',1,60)) +;
								   AllTrim(Substring(cString,At('</xNome>',cString),Len(cString)))
					EndIf
					aAdd(aXMLCTe,AllTrim(cString))
					cString := ""


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG: E - Grupos de informacoes das NF                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If FindFunction("TmsPsqDY4") .And. TmsPsqDY4( (cAliasDT6)->DT6_FILDOC, (cAliasDT6)->DT6_DOC, (cAliasDT6)->DT6_SERIE )							
						cAliasTagE := GetNextAlias()
						cQuery := " SELECT DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_EMINFC, " + CRLF
						cQuery += "        DTC.DTC_NFEID, DTC.DTC_CLIDES, DTC.DTC_LOJDES,  " + CRLF
						cQuery += "        DTC.DTC_SQEDES, DTC.DTC_TIPNFC, DTC.DTC_TIPNFC, " + CRLF
						cQuery += "        DTC.DTC_FILORI, DTC.DTC_NUMSOL,DTC.DTC_SELORI,  " + CRLF
						cQuery += "        DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE,     " + CRLF
						cQuery += "        DTC_CF, DTC_DTENTR, DTC_FILCFS, DTC.DTC_DEVFRE, " + CRLF
						cQuery += "        SUM(DTC.DTC_BASICM) DTC_BASICM, SUM(DTC.DTC_VALICM) DTC_VALICM, " + CRLF
						cQuery += "        SUM(DTC.DTC_BASESU) DTC_BASESU, SUM(DTC.DTC_VALIST) DTC_VALIST, " + CRLF
						cQuery += "        SUM(DTC.DTC_VALOR)  DTC_VALOR,  SUM(DTC.DTC_PESO)   DTC_PESO,   " + CRLF
						cQuery += "        SUM(DTC.DTC_PESOM3) DTC_PESOM3, SUM(DTC.DTC_METRO3) DTC_METRO3, " + CRLF
						cQuery += "        SUM(DTC.DTC_QTDVOL) DTC_QTDVOL " + CRLF
						cQuery += "   FROM " + RetSqlName('DTC') + " DTC " + CRLF
							
						cQuery += "    INNER JOIN " + RetSqlName('DY4') + " DY4 ON " + CRLF
						cQuery += "    DTC.DTC_FILORI = DY4.DY4_FILORI " + CRLF		
						cQuery += "    AND DTC.DTC_NUMNFC = DY4.DY4_NUMNFC " + CRLF							
						cQuery += "    AND DTC.DTC_SERNFC = DY4.DY4_SERNFC " + CRLF
						cQuery += "    AND DTC.DTC_CLIREM = DY4.DY4_CLIREM " + CRLF
						cQuery += "    AND DTC.DTC_LOJREM = DY4.DY4_LOJREM " + CRLF
						cQuery += "    AND DTC.DTC_CODPRO = DY4.DY4_CODPRO " + CRLF
						cQuery += "    AND DTC.D_E_L_E_T_  = ' '" + CRLF						
							
						//-- DTC - Documento Cliente para Transporte
						cQuery += "  WHERE DY4.DY4_FILIAL	= '" + xFilial('DY4') + "'" + CRLF
							
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o tipo de Conhecimento for de Complemento, seleciona as       ³
						//³ informacoes do CTR principal, pois o complemento nao tem DTC     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
						
						cQuery += "    AND DY4.DY4_FILDOC   = '" + (cAliasDT6)->DT6_FILDOC + "'" + CRLF
						cQuery += "    AND DY4.DY4_DOC      = '" + (cAliasDT6)->DT6_DOC    + "'" + CRLF
						cQuery += "    AND DY4.DY4_SERIE    = '" + (cAliasDT6)->DT6_SERIE  + "'" + CRLF
						
						cQuery += "  AND DY4.D_E_L_E_T_ = ' '" + CRLF
						cQuery += "  GROUP BY DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_EMINFC, DTC_FILCFS,  "    + CRLF
						cQuery += "           DTC.DTC_NFEID,  DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_SQEDES, " + CRLF
						cQuery += "           DTC.DTC_TIPNFC, DTC_DTENTR,     DTC.DTC_FILORI, DTC.DTC_NUMSOL, " + CRLF
						cQuery += "           DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE,                     " + CRLF
						cQuery += "			  DTC.DTC_SELORI, DTC_CF, 	     DTC_DEVFRE "                      + CRLF
					Else						
						cAliasTagE := GetNextAlias()
						cQuery := " SELECT DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_EMINFC, " + CRLF
						cQuery += "        DTC.DTC_NFEID,  DTC.DTC_CLIDES, DTC.DTC_LOJDES, " + CRLF
						cQuery += "        DTC.DTC_SQEDES, DTC.DTC_TIPNFC, DTC.DTC_TIPNFC, " + CRLF
						cQuery += "        DTC.DTC_FILORI, DTC.DTC_NUMSOL,DTC.DTC_SELORI, DTC_CF, DTC_DTENTR, " + CRLF
						cQuery += "        DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE,     " + CRLF
						cQuery += "        DTC_FILCFS, DTC.DTC_DEVFRE, " + CRLF
						cQuery += "        SUM(DTC.DTC_BASICM) DTC_BASICM, SUM(DTC.DTC_VALICM) DTC_VALICM, " + CRLF
						cQuery += "        SUM(DTC.DTC_BASESU) DTC_BASESU, SUM(DTC.DTC_VALIST) DTC_VALIST, " + CRLF
						If AllTrim((cAliasDT6)->DT6_DOCTMS) <> "P"
							cQuery += "        SUM(DTC.DTC_VALOR)  DTC_VALOR,  SUM(DTC.DTC_PESO)   DTC_PESO,   " + CRLF
							cQuery += "        SUM(DTC.DTC_PESOM3) DTC_PESOM3, SUM(DTC.DTC_METRO3) DTC_METRO3, " + CRLF
							cQuery += "        SUM(DTC.DTC_QTDVOL) DTC_QTDVOL " + CRLF
						Else
							cQuery += "        SUM(DT6.DT6_VALMER)  DTC_VALOR,  SUM(DT6.DT6_PESO)   DTC_PESO,   " + CRLF
							cQuery += "        SUM(DT6.DT6_PESOM3) DTC_PESOM3, SUM(DT6.DT6_METRO3) DTC_METRO3, " + CRLF
							cQuery += "        SUM(DT6.DT6_QTDVOL) DTC_QTDVOL " + CRLF
						EndIf
						cQuery += "   FROM " + RetSqlName('DTC') + " DTC " + CRLF
						If	lDocApoio
							cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 " + CRLF
							cQuery += "   ON DT6.DT6_CLIDEV   = '" + (cAliasDT6)->DT6_CLIDEV + "'" + CRLF
							cQuery += "  AND DT6.DT6_LOJDEV   = '" + (cAliasDT6)->DT6_LOJDEV + "'" + CRLF
							cQuery += "  AND DT6.DT6_PREFIX   = '" + (cAliasDT6)->DT6_PREFIX + "'" + CRLF
							cQuery += "  AND DT6.DT6_NUM      = '" + (cAliasDT6)->DT6_NUM    + "'" + CRLF
							cQuery += "  AND DT6.DT6_TIPO     = '" + (cAliasDT6)->DT6_TIPO   + "'" + CRLF
							cQuery += "  AND DT6_DOCTMS       = 'U' " 
							cQuery += "  AND DT6.D_E_L_E_T_   = ' '" + CRLF
						EndIf
						cQuery += "  WHERE DTC.DTC_FILIAL	= '" + xFilial('DTC') + "'" + CRLF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se o tipo de Conhecimento for de Complemento, seleciona as       ³
						//³ informacoes do CTR principal, pois o complemento nao tem DTC     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lDocApoio
							cQuery += "  AND DTC.DTC_FILDOC   = DT6.DT6_FILDOC " + CRLF
							cQuery += "  AND (DTC.DTC_DOC     = DT6.DT6_DOC OR DTC.DTC_DOCPER = DT6.DT6_DOC )" + CRLF
							cQuery += "  AND DTC.DTC_SERIE    = DT6.DT6_SERIE  " + CRLF
						Else
							cQuery += "    AND DTC.DTC_FILDOC   = '" + (cAliasDT6)->DT6_FILDOC + "'" + CRLF
							cQuery += "    AND (DTC.DTC_DOC     = '" + (cAliasDT6)->DT6_DOC    + "' OR DTC.DTC_DOCPER = '" + (cAliasDT6)->DT6_DOC + "')" + CRLF
							cQuery += "    AND DTC.DTC_SERIE    = '" + (cAliasDT6)->DT6_SERIE  + "'" + CRLF
						EndIf
						cQuery += "  AND DTC.D_E_L_E_T_ = ' '" + CRLF
						cQuery += "  GROUP BY DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_EMINFC, DTC_FILCFS,       " + CRLF
						cQuery += "           DTC.DTC_NFEID,  DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_SQEDES,   " + CRLF
						cQuery += "           DTC.DTC_TIPNFC, DTC_DTENTR,     DTC.DTC_FILORI, DTC.DTC_NUMSOL,   " + CRLF
						cQuery += "           DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE,                       " + CRLF
						cQuery += "           DTC.DTC_SELORI, DTC_CF, DTC_DEVFRE                                " + CRLF                
					Endif
					//-- IMPORTANTE: A Ordenação tem q ser a mesma q a Quebra do cKeyInfNF2
					cQuery += "  ORDER BY DTC.DTC_FILDOC, DTC.DTC_DOC, DTC.DTC_SERIE, DTC.DTC_NUMNFC" + CRLF
					
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTagE, .F., .T.)

					//-- Processa NF's dos Doctos de apoio para criar array por OrigemxDestino
					cKeyInfNFe := ''
					While (cAliasTagE)->(!Eof())

						//-- Quebra por Docto de Apoio 
						If cKeyInfNFe <> (cAliasTagE)->(DTC_FILDOC+DTC_DOC+DTC_SERIE)
							cKeyInfNFe := (cAliasTagE)->(DTC_FILDOC+DTC_DOC+DTC_SERIE)
							aMunDoc    := (cAliasTagE)->(TMSCTUFMun(DTC_FILDOC,DTC_DOC,DTC_SERIE))
							If lCTEVPRE
								nVPrest := Posicione("DT6",1,xFilial("DT6")+(cAliasTagE)->(DTC_FILDOC+DTC_DOC+DTC_SERIE),"DT6_VALFRE")
							Else
								nVPrest := Posicione("DT6",1,xFilial("DT6")+(cAliasTagE)->(DTC_FILDOC+DTC_DOC+DTC_SERIE),"DT6_VALTOT")
							EndIf
							nVRec := Posicione("DT6",1,xFilial("DT6")+(cAliasTagE)->(DTC_FILDOC+DTC_DOC+DTC_SERIE),"DT6_VALFAT")

							If (nCntDet := aScan(aAgrDet, {|x| x[1]+x[2]+x[3]+x[4] == aMunDoc[1]+aMunDoc[2]+aMunDoc[3]+aMunDoc[4] })) == 0
								aAdd(aAgrDet,{aMunDoc[1],aMunDoc[2],aMunDoc[3],aMunDoc[4],nVPrest,nVRec,{}})
								nCntDet := Len(aAgrDet)
							Else
								aAgrDet[nCntDet][5] += nVPrest
								aAgrDet[nCntDet][6] += nVRec
							EndIf
							aNFEID := aAgrDet[nCntDet][7]
						EndIf
						// Efetuar a inclusão da CHAVE da NF-e na TAG, somente quando não inserida ainda //
						If aScan(aNFEID,{|x| x == (cAliasTagE)->DTC_NFEID }) == 0
							AAdd(aNFEID, (cAliasTagE)->DTC_NFEID)
						EndIf
						
						aCarga[1] += (cAliasTagE)->DTC_PESO
						aCarga[2] += (cAliasTagE)->DTC_PESOM3
						aCarga[3] += (cAliasTagE)->DTC_METRO3
						aCarga[4] += (cAliasTagE)->DTC_QTDVOL								

						(cAliasTagE)->(dbSkip())
					EndDo						
					(cAliasTagE)->(DbCloseArea())

					//-- Percorre array de Agrupamento para gerar a tag
					For nCntDet := 1 To Len(aAgrDet)
						cStringCh := '<det nItem="'+AllTrim(Str(nCntDet))+'">' 
						cStringCh += '<cMunIni>'+aUF[ aScan(aUF,{|x| x[1] == aAgrDet[nCntDet][1] }), 2]+ aAgrDet[nCntDet][2]                         +'</cMunIni>'
						cStringCh += '<xMunIni>'+NoAcentoCte( Posicione('CC2',1,xFilial("CC2")+ aAgrDet[nCntDet][1] + aAgrDet[nCntDet][2],"CC2_MUN"))+'</xMunIni>'
						cStringCh += '<cMunFim>'+aUF[ aScan(aUF,{|x| x[1] == aAgrDet[nCntDet][3] }), 2]+ aAgrDet[nCntDet][4]                         +'</cMunFim>'
						cStringCh += '<xMunFim>'+NoAcentoCte( Posicione('CC2',1,xFilial("CC2")+ aAgrDet[nCntDet][3] + aAgrDet[nCntDet][4],"CC2_MUN"))+'</xMunFim>'
						cStringCh += '<vPrest>' +ConvType(aAgrDet[nCntDet][5],15,2)+'</vPrest>'
						cStringCh += '<vRec>'   +ConvType(aAgrDet[nCntDet][6],15,2)+'</vRec>'
						aEval(aAgrDet[nCntDet][7],{|x| cStringCh += '<infNFe><chNFe>'+AllTrim(x)+'</chNFe></infNFe>'})
						cStringCh += '</det>'
					Next nCntDet

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG: J- Informacoes relativas aos Impostos                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Incluso as TAGS referentes as modalidades de tributacao do ICMS ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cAliasTagJ := GetNextAlias()
					cQuery := "SELECT SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLASFIS, " + CRLF
					cQuery += "  MAX(SFT.FT_ALIQICM) FT_ALIQICM, " + CRLF
					cQuery += "	 MAX(SFT.FT_ALIQSOL) FT_ALIQSOL, " + CRLF
					cQuery += "  SUM(SFT.FT_BASEICM) FT_BASEICM, " + CRLF
					cQuery += "  SUM(SFT.FT_BASERET) FT_BASERET, " + CRLF
					cQuery += "  SUM(SFT.FT_VALICM)  FT_VALICM,  " + CRLF
					cQuery += "  SUM(SFT.FT_CRPRST)  FT_CRPRST,  " + CRLF
					cQuery += "  SUM(SFT.FT_ICMSRET) FT_ICMSRET, " + CRLF
					cQuery += "  MAX(SD2.D2_ALIQSOL) D2_ALIQSOL, " + CRLF
					cQuery += "  SUM(SD2.D2_BASEICM) D2_BASEICM, " + CRLF 
					cQuery += "  SUM(SD2.D2_VALICM)  D2_VALICM,  " + CRLF
					cQuery += "  MAX(SD2.D2_PICM)  D2_PICM,  " + CRLF
					cQuery += "  SUM(SD2.D2_ICMSRET) D2_ICMSRET  " + CRLF
					cQuery += "  FROM " + RetSqlName('SFT') + " SFT, "+ RetSqlName('SD2') +" SD2   " + CRLF
					cQuery += "  WHERE SFT.FT_FILIAL  = '" + xFilial('SFT') + "'" + CRLF
					cQuery += " AND SFT.FT_NFISCAL = '" + (cAliasDT6)->DT6_DOC   + "'" + CRLF
					cQuery += " AND SFT.FT_SERIE   = '" + (cAliasDT6)->DT6_SERIE + "'" + CRLF
					cQuery += " AND SFT.FT_CLIEFOR = '" + (cAliasDT6)->DT6_CLIDEV + "'" + CRLF
					cQuery += " AND SFT.FT_LOJA    = '" + (cAliasDT6)->DT6_LOJDEV + "'" + CRLF
					cQuery += " AND SFT.D_E_L_E_T_ = ' '" + CRLF
					cQuery += " AND SD2.D2_FILIAL  = '" + xFilial('SD2') + "'" + CRLF
					cQuery += " AND SD2.D2_DOC   = SFT.FT_NFISCAL " + CRLF
					cQuery += " AND SD2.D2_SERIE = SFT.FT_SERIE   " + CRLF
					cQuery += " AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR " + CRLF
					cQuery += " AND SD2.D2_LOJA    = SFT.FT_LOJA    " + CRLF
					cQuery += " AND SD2.D2_ITEM    = SFT.FT_ITEM    " + CRLF
					cQuery += " AND SD2.D_E_L_E_T_ = ' '" + CRLF
					cQuery += " GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLASFIS "
					cQuery += " ORDER BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLASFIS "
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTagJ, .F., .T.)
					cString := '<imp>'
					cString += '<ICMS>'
					nCount := 0
					While !(cAliasTagJ)->(Eof())
						nCount++
						If (cAliasTagJ)->FT_VALICM > 0
							nBASEICM := (cAliasTagJ)->FT_BASEICM
							nALIQICM := (cAliasTagJ)->FT_ALIQICM
							nVALICM  := (cAliasTagJ)->FT_VALICM
							nALIQSOL := (cAliasTagJ)->FT_ALIQSOL
							nICMSRET := (cAliasTagJ)->FT_ICMSRET
                      Else
							nBASEICM := (cAliasTagJ)->D2_BASEICM
							nALIQICM := (cAliasTagJ)->D2_PICM
							nVALICM  := (cAliasTagJ)->D2_VALICM
							nALIQSOL := (cAliasTagJ)->D2_ALIQSOL
							nICMSRET := (cAliasTagJ)->D2_ICMSRET
						EndIf 
						
						If (cAliasTagJ)->FT_BASERET > 0
							nBASICMRET 	:= (cAliasTagJ)->FT_BASERET
							nALIQSOL 	:= (cAliasTagJ)->FT_ALIQSOL
							nICMSRET	:= (cAliasTagJ)->FT_ICMSRET  
							nCREDPRES	:= (cAliasTagJ)->FT_CRPRST  
						EndIf				
						
						//-- CT-e complemento ICMS campos preenchidos somente para permitir a validacao do CT-e
						If (cAliasDT6)->DT6_DOCTMS == "8" .And. (nBASEICM == 0 .Or. nALIQICM == 0) .And. nVALICM > 0 .And. SF3->F3_TIPO == "I"
							nBASEICM := nVALICM
							nALIQICM := 100
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Informacoes relativas ao ICMS   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nCount == 1
							If cMVSINAC == '1'
							//--Simples Nacional(MV_CODREG == 1)
								cString += '<ICMSSN>'
								cString += '<CST>90</CST>'
								cString += '<indSN>1</indSN>'							 
								cString += '</ICMSSN>'						
							ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == '00' 
								cString += '<ICMS00>'
								cString += '<CST>00</CST>'
								cString += '<vBC>'  + ConvType(nBASEICM, 15, 2) + '</vBC>'
								cString += '<pICMS>'+ ConvType(nALIQICM,  6, 2) + '</pICMS>'
								cString += '<vICMS>'+ ConvType(nVALICM , 15, 2) + '</vICMS>'
								cString += '</ICMS00>'						
							ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) $ "40,41,51"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ ICMS Isento, nao Tributado ou dIferido  ³
								//³ - 40: ICMS Isencao                      ³
								//³ - 41: ICMS Nao Tributada                ³
								//³ - 51: ICMS DIferido                     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cString += '<ICMS45>'
								If SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2)  == '40'
									cString += '<CST>40</CST>'
									
									cCodBenef := tagcBenef((cAliasDT6)->(DT6_FILDOC),(cAliasDT6)->(DT6_DOC),(cAliasDT6)->(DT6_SERIE),(cAliasDT6)->(DT6_CLIDEV),(cAliasDT6)->(DT6_LOJDEV))
									If !Empty(cCodBenef)
										cString += '<vICMSDeson>0</vICMSDeson>'
										cString += '<cBenef>'+cCodBenef+'</cBenef>'
									EndIf
								
								ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == '41'
									cString += '<CST>41</CST>'
								ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == '51'
									cString += '<CST>51</CST>'
								EndIf
								cString += '</ICMS45>'
							ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == "60"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ - 60: ICMS cobrado por substituição tributária.                 ³
								//³ Responsabilidade do recolhimento do ICMS atribuído              ³
								//³ ao tomadorou 3o por ST.                                         ³
								//³ CST60 - ICMS cobrado anteriormente por substituicao tributaria  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cString += '<ICMS60>'
								//-- ICMS cobrado anteriormente por substituicao tributaria
								cString += '<CST>60</CST>'
								cString += '<vBCSTRet>'  + ConvType(nBASICMRET, 15, 2) + '</vBCSTRet>'
								cString += '<vICMSSTRet>'+ ConvType(nICMSRET + nCREDPRES , 15, 2) + '</vICMSSTRet>'
								cString += '<pICMSSTRet>'+ ConvType(nALIQSOL,  6, 2) + '</pICMSSTRet>'
								cString += '<vCred>'     + ConvType(nCREDPRES, 15, 2) + '</vCred>'
								cString += '</ICMS60>'
							ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) $ "10,30,70"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ - 80: ICMS pagto atribuido ao tomador ou ao 3o previsto para    ³
								//³ substituicao tributaria                                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cString += '<ICMS90>'
								cString += '<CST>90</CST>'
								If !Empty(cpRedBC)
									cString += '<pRedBC>' + ConvType(cpRedBC, 5, 2) + '</pRedBC>'
								EndIf
								cString += '<vBC>'    + ConvType(nBASEICM, 15, 2) + '</vBC>'
								cString += '<pICMS>'  + ConvType(nALIQICM,  6, 2) + '</pICMS>'
								cString += '<vICMS>'  + ConvType(nVALICM , 15, 2) + '</vICMS>'
								cString += '<vCred>'  + ConvType(nVcred  , 15, 2) + '</vCred>'
								cString += '</ICMS90>'
							ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) $ '20,90' .And. !(AllTrim(cCFOP) $ "5932,6932")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ - 81: ICMS DEVIDOS A OUTRAS UF'S                                ³
								//³ - 90: ICMS Outros                                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == '20'
									cString += '<ICMS20>'
									cString += '<CST>20</CST>'
									If !Empty(cpRedBC)
										cString += '<pRedBC>' + ConvType(cpRedBC, 5, 2) + '</pRedBC>'
									EndIf
									cString += '<vBC>'  + ConvType(nBASEICM, 15, 2) + '</vBC>'
									cString += '<pICMS>'+ ConvType(nALIQICM,  6, 2) + '</pICMS>'
									cString += '<vICMS>'+ ConvType(nVALICM , 15, 2) + '</vICMS>'
									cString += '</ICMS20>'
								Else
									If SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == '90'
										cString += '<ICMS90>'
									Else
										cString += '<CST81>'
									EndIf
									cString += '<CST>90</CST>'
									If !Empty(cpRedBC)
										cString += '<pRedBC>' + ConvType(cpRedBC, 5, 2) + '</pRedBC>'
									EndIf
									cString += '<vBC>'    + ConvType(nBASEICM, 13, 2) + '</vBC>'
									cString += '<pICMS>'  + ConvType(nALIQICM,  6, 2) + '</pICMS>'
									cString += '<vICMS>'  + ConvType(nVALICM , 13, 2) + '</vICMS>'
									cString += '<vCred>'  + ConvType(nICMSRET, 15, 2) + '</vCred>'
									If SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) == '90'
										cString += '</ICMS90>'
									Else
										cString += '</CST81>'
									EndIf
								EndIf
							ElseIf SubStr((cAliasTagJ)->FT_CLASFIS, 2, 2) $ '20,90' .And. AllTrim(cCFOP) $ "5932,6932"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ - 81: ICMS DEVIDOS A OUTRAS UF'S                                ³
								//³ - 90: ICMS Outros                                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cString += '<ICMSOutraUF>'
								cString += '<CST>90</CST>'
								If !Empty(cpRedBC)
									cString += '<pRedBCOutraUF>' + ConvType(cpRedBC, 5, 2) + '</pRedBCOutraUF>'
								EndIf
								cString += '<vBCOutraUF>'    + ConvType(nBASEICM	, 13, 2) + '</vBCOutraUF>'
								cString += '<pICMSOutraUF>'  + ConvType(nALIQICM	,  6, 2) + '</pICMSOutraUF>'
								cString += '<vICMSOutraUF>'  + ConvType(nVALICM  , 13, 2) + '</vICMSOutraUF>'
								cString += '</ICMSOutraUF>'
							EndIf
						EndIf //-- If nCount == 1

						
						(cAliasTagJ)->(dbSkip())
						
					EndDo
					
					(cAliasTagJ)->(DbCloseArea())

					cString += '</ICMS>'
					//-- Valor Total dos impostos - Lei da Transparencia
					If !Empty(SF2->F2_TOTIMP)
						cString += '<vTotTrib>' + ConvType(SF2->F2_TOTIMP, 13, 2) + '</vTotTrib>'
					Else
						cString += '<vTotTrib>' + ConvType((cAliasDT6)->DT6_VALIMP, 13, 2) + '</vTotTrib>'
					EndIf
					//-- Observações das regras de Tributação (campo Memo)
					DbSelectArea("DT6")
					cObs := StrTran(MsMM((cAliasDT6)->DT6_CODMSG),Chr(13),"")
					If !Empty(cObs)
						cString +=  '<infAdFisco>' + NoAcentoCte(SubStr(cObs,1,320)) + '</infAdFisco>'
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG:  Informacoes relativas ICMS para a UF de término da `     //
					// prestação do serviço de transporte nas operações interestaduais //
					// para consumidor final  Emenda Constitucional 87 de 2015.        //
					// Nota Técnica 2015/003 e 2015/004                                //
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					If !lContrib   //-- Não Contribuinte e Campo Difal
						cString += '<ICMSUFFim>'						
						cString += '<vBCUFFim>'   		+ ConvType(nBCICMS,  15, 2) + '</vBCUFFim>'
						cString += '<pFCPUFFim>'  		+ ConvType(nPERFCP,   5, 2) + '</pFCPUFFim>'
						cString += '<pICMSUFFim>' 		+ ConvType(nALQTER,   5, 2) + '</pICMSUFFim>'
						cString += '<pICMSInter>' 		+ ConvType(nALQINT,   5, 2) + '</pICMSInter>'
						If !lMOC300A
							cString += '<pICMSInterPart>'	+   cvaltochar(nPEDDES)     + '</pICMSInterPart>'
						EndIf
						cString += '<vFCPUFFim>' 		+ ConvType(nVALFCP,  15, 2) + '</vFCPUFFim>'
						cString += '<vICMSUFFim>'  		+ ConvType(nVALDES,  15, 2) + '</vICMSUFFim>'
						cString += '<vICMSUFIni>' 		+ ConvType(nVLTRIB,  15, 2) + '</vICMSUFIni>'							
						cString += '</ICMSUFFim>'									
					EndIf				
					
					cString += '</imp>'
					cStringImp := cString

					cString := ''
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ TAG: K - Informacoes de CT-e Normal                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If	!AllTrim((cAliasDT6)->DT6_DOCTMS) == StrZero( 8, Len(DT6->DT6_DOCTMS)) .And.;
						!AllTrim((cAliasDT6)->DT6_DOCTMS) == "M"
						
						cString := ''
						cAliasAll := GetNextAlias()
						cQuery    := " SELECT DB0.DB0_TIPCAR" + CRLF
						cQuery    += "   FROM " +	RetSqlName("SB1") + " SB1 " + CRLF
						cQuery    += "        INNER JOIN " + RetSqlName("DB0") + " DB0 " + CRLF
						cQuery    += "                ON DB0.DB0_FILIAL = '"  + xFilial("DB0")	+ "'" + CRLF
						cQuery    += "               AND DB0.DB0_CODMOD = SB1.B1_TIPCAR " + CRLF
						cQuery    += "               AND DB0.D_E_L_E_T_ = ' ' " + CRLF
						cQuery    += "  WHERE SB1.B1_FILIAL  = '" + xFilial("SB1")	+ "'" + CRLF
						cQuery    += "               AND SB1.B1_COD = '" + cCodPred + "'" + CRLF
						cQuery    += "               AND SB1.D_E_L_E_T_ = ' '" + CRLF
						cQuery    := ChangeQuery(cQuery)
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAll, .F., .T.)
						
						cString += '<infCarga>'
						//-- Produto predominante.
						cString += '<vCarga>'   + ConvType((cAliasDT6)->DT6_VALMER, 15, 2) + '</vCarga>'
						cString += '<proPred>' + NoAcentoCte( cProdPred ) + '</proPred>'
						If !Empty((cAliasAll)->DB0_TIPCAR)
							cString += '<xOutCat>' + NoAcentoCte( FWGetSX5('DU',PadR((cAliasAll)->DB0_TIPCAR, TamSX3("X5_CHAVE")[1]))[1][4] ) + '</xOutCat>'
						EndIf
						(cAliasAll)->(DbCloseArea())
						
						//-- Caracteristica de todos os produtos.
						//-- DTC_PESO - KG
						cString += '<infQ>'
						cString += '<cUnid>' + '01' + '</cUnid>'
						cString += '<tpMed>' + '02' + '</tpMed>' //-- PESO DECLARADO
						cString += '<qCarga>' + ConvType(aCarga[1], 15, 4) + '</qCarga>'
						cString += '</infQ>'
						
						cString += '<infQ>'
						cString += '<cUnid>' + '01' + '</cUnid>'
						cString += '<tpMed>' + '05' + '</tpMed>' // PESO BASE DE CALCULO
						cString += '<qCarga>' +  ConvType((cAliasDT6)->DT6_PESCOB, 15, 4) + '</qCarga>'
						cString += '</infQ>'

						//-- PESO AFERIDO = PESOM3
						cString += '<infQ>'
						cString += '<cUnid>' + '01' + '</cUnid>'
						cString += '<tpMed>' + '03' + '</tpMed>' //-- PESO AFERIDO
						cString += '<qCarga>' + ConvType(aCarga[2], 15, 4) + '</qCarga>'
						cString += '</infQ>'
						
						//-- DTC_PESOM3 - M3
						cString += '<infQ>'
						cString += '<cUnid>' + '01' + '</cUnid>'
						cString += '<tpMed>' + '04' + '</tpMed>' //-- PESO CUBADO
						cString += '<qCarga>' + ConvType(aCarga[2], 15, 4) + '</qCarga>'
						cString += '</infQ>'
						
						//-- DT6_METRO3 - M3
						cString += '<infQ>'
						cString += '<cUnid>' + '00' + '</cUnid>'
						cString += '<tpMed>' + '00' + '</tpMed>' //-- METROS CUBICOS 
						cString += '<qCarga>' + ConvType(aCarga[3], 15, 4) + '</qCarga>'
						cString += '</infQ>'
						
						//-- DTC_QTDVOL - UNI
						cString += '<infQ>'
						If AllTrim(aCarga[5]) == 'L'
							cString += '<cUnid>' + '04' + '</cUnid>'
							cString += '<tpMed>' + '14' + '</tpMed>' //-- LITRAGEM
						Else
							cString += '<cUnid>' + '03' + '</cUnid>'
							cString += '<tpMed>' + '99' + '</tpMed>' //-- Outros
						EndIf
						cString += '<qCarga>' + ConvType(aCarga[4], 15, 4) + '</qCarga>'
						cString += '</infQ>'
						
						aCarga := {0,0,0,0,""}							
						
						If (cAliasDT6)->DT6_VALMER > 0
							cString += '<vCargaAverb>' + ConvType((cAliasDT6)->DT6_VALMER, 15, 2) + '</vCargaAverb>'	
						EndIf
						
						cString += '</infCarga>'
						aAdd(aXMLCTe,AllTrim(cString))
						cString :='' 
						
						If !(cTipoNF $ '8/9/A')  
							If !Empty(cStringCh)						
								aAdd(aXMLCTe,AllTrim(cStringCh))
								cStringCh :=''	
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Chave auxiliar para contigencia                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If	cModalidade == IIf(lUsaColab,'5','7')
						VALTOT:= padL(Alltrim(str(round(noround((cAliasDT6)->DT6_VALTOT,3),2)*100)),14,'0')
						cChvCTG := CTeCHCTG(	cCodUF,;
												cTpEmis,;
												AllTrim(SM0->M0_CGC),;
												VALTOT,;
												'2',;
												'2',;
												SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 7, 2))
					Else
						cChvCTG := ""
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  Variavel Private Responsavel Pela Gravação da Chave de contingencia na DT6 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cChvCTG)
						aAdd(aPChvCtg,{(cAliasDT6)->DT6_FILDOC,(cAliasDT6)->DT6_DOC,(cAliasDT6)->DT6_SERIE ,cChvCTG})
					EndIf

				// 	(cAliasDT6)->(DbSkip())
				// EndDo // (02)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ TAG: M - Dados Especificos do Modal Rodoviario                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cString := '<infModal versaoModal="'+cVerAmb+'">'
				cString += '<rodo>'
				If !Empty(cTmsAntt)
					cString += '<RNTRC>' + SubStr(AllTrim(cTmsAntt),1,8) + '</RNTRC>'
				Else
					cString += '<RNTRC>ISENTO</RNTRC>'
				EndIf
				cString += '</rodo>'
				cString += '</infModal>'
				aAdd(aXMLCTe,AllTrim(cString))

				//-- String Imposto
				aAdd(aXMLCTe,AllTrim(cStringImp))

				//-- String Total
				//nVPrest := 0
				//nVRec   := 0
				//--aEval(aAgrDet,{|x| nVPrest += x[3], nVRec == x[4]})
				If lCTEVPRE
					nVPrest := (cAliasDT6)->DT6_VALFRE
				Else
					nVPrest := (cAliasDT6)->DT6_VALTOT
				EndIf
				nVRec := (cAliasDT6)->DT6_VALFAT
				cString := '<total>'
				cString += '<vTPrest>'+ConvType(nVPrest,15,2)+'</vTPrest>'
				cString += '<vTRec>'  +ConvType(nVRec  ,15,2)+'</vTRec>'
				cString += '</total>'
				aAdd(aXMLCTe,AllTrim(cString))

				//Responsável Técnico
				cString := TMSIdResp()
				aAdd(aXMLCTe,AllTrim(cString))

				cString := '</infCte>'
				aAdd(aXMLCTe,AllTrim(cString))
				
				If !Empty(cMVURLQCOD)
					//-- TAG: infCTeSupl -- Informações suplementares do CTe QRCode
					If !lUsaColab //Normal
						cString := '<infCTeSupl>'
						cString +=  '<qrCodCTe>'
						cString +=  AllTrim(cMVURLQCOD) + '?chCTe='+ cChvAcesso + '&amp;tpAmb=' + cAmbiente
						cString +=  '</qrCodCTe>'
						cString += '</infCTeSupl>'	
						aAdd(aXMLCTe,AllTrim(cString))
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Botton do Arquivo XML                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cString := ''
				cString += '</CTeSimp>'
				
				aAdd(aXMLCTe,AllTrim(cString))
				RestArea(aAreaSM0)	
			EndIf // (01)
			
			cString := ''
			
			For nCount := 1 To Len(aXMLCTe)
				cString += AllTrim(aXMLCTe[nCount])
			Next nCount
		EndIf
	EndIf		
EndIf
 
If lTMSCTESEF
	aRetXML := ExecBlock("TMSCTESEF",.F.,.F., {cNota,cSerie,aXMLCTe})
	If ValType(aRetXML) == 'A' .And. Len(aRetXML) > 0
		aXMLCTe := aClone(aRetXML)
	EndIf
	
	cString := ''
	For nCount := 1 To Len(aXMLCTe)
		cString += AllTrim(aXMLCTe[nCount])
	Next nCount	
EndIf

nTamDocumen	  := aTamDocs[1][1]
nTamSerie	  := aTamDocs[1][2]

PadR(cNota,   nTamDocumen)
PadR(cSerie,  nTamSerie)

Return({cNfe,EncodeUTF8(cString),cNota,cSerie} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NFESEFAZ  ºAutor  ³Microsiga           º Data ³  08/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvType(xValor,nTam,nDec,lInt)

Local   cNovo := ""
Default nDec  := 0
Default lInt  := .F.

Do Case
	Case ValType(xValor)=="N"
		If lInt .And. nDec=0
			xValor := Int(xValor)
		EndIf
		cNovo := AllTrim(Str(xValor,nTam,nDec))
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		Default nTam := 60
		cNovo := NoAcentoCte(SubStr(xValor,1,nTam))
EndCase
Return(cNovo)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NFESEFAZ  ºAutor  ³Microsiga           º Data ³  08/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Inverte()

Local cRet := ""
Local cFunc := "Random"

If FindFunction(cFunc)
	cRet := AllTrim(Str(&cFunc.( 10000000, 99999999 )))
Else
	cRet := AllTrim(Str(Randomize( 10000000, 99999999 )))
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTeCHVAC ³       ³ N3-DL                 ³ Data ³19.03.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel em montar a Chave de Acesso             ³±±
±±³          ³ a SEFAZ e calcular o seu digito verIficador.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTeCHVAC(cUF, cAAMM, cCNPJ, cMod, cSerie, nCT, cCT)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cUF...: Codigo da UF                                       ³±±
±±³          ³ cAAMM.: Ano (2 Digitos) + Mes da Emissao do CTe            ³±±
±±³          ³ cCNPJ.: CNPJ do Emitente do CTe                            ³±±
±±³          ³ cMod..: Modelo (57 = CTe)                                  ³±±
±±³          ³ cSerie: Serie do CTe                                       ³±±
±±³          ³ nCT...: Numero do CTe                                      ³±±
±±³          ³ cCT...: Numero do Lote de Envio a SEFAZ                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Explicacao do Calculo se encontra no manual do CT-e        ³±±
±±³          ³ disponibilizado pela SEFAZ na versao atual 1.02,           ³±±
±±³          ³ pag: 77 e 78                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CTeCHVAC(cUF, cAAMM, cCNPJ, cMod, cSerie, nCT, cCT)
Local nCount      := 0
Local nSequenc    := 2
Local nPonderacao := 0
Local cResult     := ''
Local cChvAcesso  := cUF +  cAAMM + cCNPJ + cMod + cSerie + nCT + cCT

// A partir da versão 1.04 do leiaute do CT-e, o campo tpEmis (forma de emissão da CT-e) passou
// a compor a chave de acesso da seguinte forma:
// O tamanho do campo cCT – código numérico do CT-e –foi reduzido para oito posiçõespara não
// alterar o tamanho da chave de acesso do CT-e de 44 posições que passa sercomposta pelos
// seguintes campos que se encontram dispersos no CT-e :
// cUF    - Codigo da UF do emitente do Documento Fiscal
// AAMM   - Ano (2 Digitos) e Mes de emissão do CT-e
// CNPJ   - CNPJ do emitente
// mod    - Modelo do Documento Fiscal (57 = CTe)
// serie  - Serie do Documento Fiscal
// nCT    - Numero do Documento Fiscal
// tpEmis - Forma de emissão do CT-e
// cCT    - Codigo Numurico que compoe a Chave de Acesso
// cDV    - Digito Verificador da Chave de Acesso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SEQUENCIA DE MULTIPLICADORES (nSequenc), SEGUE A SEGUINTE        ³
//³ORDENACAO NA SEQUENCIA: 2,3,4,5,6,7,8,9,2,3,4... E PRECISA SER   ³
//³GERADO DA DIREITA PARA ESQUERDA, SEGUINDO OS CARACTERES          ³
//³EXISTENTES NA CHAVE DE ACESSO INFORMADA (cChvAcesso)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := Len( AllTrim(cChvAcesso) ) To 1 Step -1
	nPonderacao += ( Val( SubStr( AllTrim(cChvAcesso), nCount, 1) ) * nSequenc )
	nSequenc += 1
	If (nSequenc == 10)
		nSequenc := 2
	EndIf
Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando o resto da divisão for 0 (zero) ou 1 (um), o DV devera   ³
//³ ser igual a 0 (zero).                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( mod(nPonderacao,11) > 1)
	cResult := (cChvAcesso + cValToChar( (11 - mod(nPonderacao,11) ) ) )
Else
	cResult := (cChvAcesso + '0')
EndIf

Return(cResult)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NoPontos  ºAutor  ³Andre Godoi         º Data ³  20/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retira caracteres dIferentes de numero, como, ponto,       º±±
±±º          ³virgula, barra, traco                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NoPontos(cString)
Local cChar     := ""
Local nX        := 0
Local cPonto    := "."
Local cBarra    := "/"
Local cTraco    := "-"
Local cVirgula  := ","
Local cBarraInv := "\"
Local cPVirgula := ";"
Local cUnderline:= "_"
Local cParent   := "()"

For nX:= 1 To Len(cString)
	cChar := SubStr(cString, nX, 1)
	If cChar$cPonto+cVirgula+cBarra+cTraco+cBarraInv+cPVirgula+cUnderline+cParent
		cString := StrTran(cString,cChar,"")
		nX := nX - 1
	EndIf
Next
cString := AllTrim(_NoTags(cString))

Return cString
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTeCHCTG ³Autor  ³ JfsBarreto            ³ Data ³19.03.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel em montar a Chave de Acesso auxiliar    ³±±
±±³          ³ a SEFAZ e calcular o seu digito verIficador.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTeCHCTG(cUF, tpEmis,CNPJ,VCT,ICMSp,ICMSs,DD)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³- cUF    - 02 = Código da UF                                ³±±
±±³          ³- tpEmis - 01 = Forma de Emissão                            ³±±
±±³          ³- CNPJ   - 14 = CNPJ do destinatário                        ³±±
±±³          ³- vCT    - 14 = Valor Total do Serviço                      ³±±
±±³          ³- ICMSp  - 01 = Destaque de ICMS próprio                    ³±±
±±³          ³- ICMSs  - 01 = Destaque de ICMS por substituição tributária³±±
±±³          ³- DD     - 02 = Dia da emissão                              ³±±
±±³          ³- DV     - 01 = Dígito Verificador                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Explicacao do Calculo se encontra no manual do CT-e        ³±±
±±³          ³ disponibilizado pela SEFAZ na versao atual 1.02,           ³±±
±±³          ³ pag: 77 e 78                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CTeCHCTG(cUF,tpEmis,cCNPJ, cvCT, cICMSp, cICMSs, cDD)
Local nCount      := 0
Local nSequenc    := 2
Local nPonderacao := 0
Local cResult     := ''
Local cChvCTG  := cUF +  tpEmis + cCNPJ + cvCT + cICMSp + cICMSs + cDD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SEQUENCIA DE MULTIPLICADORES (nSequenc), SEGUE A SEGUINTE        ³
//³ORDENACAO NA SEQUENCIA: 2,3,4,5,6,7,8,9,2,3,4... E PRECISA SER   ³
//³GERADO DA DIREITA PARA ESQUERDA, SEGUINDO OS CARACTERES          ³
//³EXISTENTES NA CHAVE DE ACESSO INFORMADA (cChvAcesso)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := Len( AllTrim(cChvCTG) ) To 1 Step -1
	nPonderacao += ( Val( SubStr( AllTrim(cChvCTG), nCount, 1) ) * nSequenc )
	nSequenc += 1
	If (nSequenc == 10)
		nSequenc := 2
	EndIf

Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando o resto da divisão for 0 (zero) ou 1 (um), o DV devera   ³
//³ ser igual a 0 (zero).                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( mod(nPonderacao,11) > 1)
	cResult := (cChvCTG + cValToChar( (11 - mod(nPonderacao,11) ) ) )
Else
	cResult := (cChvCTG + '0')
EndIf

Return(cResult)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UsaColaboracao  ºAutor ³Felipe Barbiereº Data ³  07/01/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se é TOTVS Colaboraçao                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
Return (lUsa)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTESEFAZ3  ºAutor  ³Felipe Barbiere     º Data ³  20/12/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³    Retorna o Tomador do CT-e                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTeToma(cAliasDT6, nRet, cCodUFRem,cCodUFDes,cCodUFRec,cCodUFExp,cCodUFCon,cCodUFDpc,cCodUFDUL)

Local cRet 			:= ""
Local cPessoaToma	:= ""
Local cCNPJToma 	:= ""
Local cTomador   	:= ""
Local cIEToma		:= ""
Local aAreaSA1		:= SA1->(GetArea())

Default nRet 		:= 1
Default cCodUFRem 	:= ""
Default cCodUFDes 	:= ""
Default cCodUFRec 	:= ""
Default cCodUFExp 	:= ""
Default cCodUFCon 	:= ""
Default cCodUFDpc 	:= ""
Default cCodUFDUL 	:= ""

If( Empty((cAliasDT6)->DT6_CLICON) .And. Empty((cAliasDT6)->DT6_CLIDPC) ) .Or. ;
	((IIf(!Empty((cAliasDT6)->DT6_CLICON),((cAliasDT6)->DT6_CLICON+(cAliasDT6)->DT6_LOJCON <> (cAliasDT6)->DT6_CLIDEV+(cAliasDT6)->DT6_LOJDEV),.T.)) .And. ;
	 (IIf(!Empty((cAliasDT6)->DT6_CLIDPC) ,((cAliasDT6)->DT6_CLIDPC+(cAliasDT6)->DT6_LOJDPC <> (cAliasDT6)->DT6_CLIDEV+(cAliasDT6)->DT6_LOJDEV),.T.)))

	//+-------------------------------------------------------------------------------------------------------+\\
	//| Tomador = 0-Remetente                                                                                 |\\
	//| DTC/DT6_DEVFRE : 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante;6=Expedidor;7=Recebedor     |\\ 
	//+-------------------------------------------------------------------------------------------------------+\\ 

	//+---------------------------------------------------------------------------
	//| Tomador = 0-Remetente
	//+---------------------------------------------------------------------------
	If ((cAliasDT6)->DT6_CLIREM = (cAliasDT6)->DT6_CLIDEV) .And.;
		((cAliasDT6)->DT6_LOJREM = (cAliasDT6)->DT6_LOJDEV) 
		cCNPJToma 		:= AllTrim((cAliasDT6)->REM_CNPJ)
		cPessoaToma 	:= AllTrim((cAliasDT6)->REM_TPPESSOA)
		cTomador   	    := '0'

		If (cAliasDT6)->REM_CONTRIB <> "2" .And. !Empty((cAliasDT6)->REM_INSC)
			If "ISENT" $ Upper(AllTrim((cAliasDT6)->REM_INSC))
				cIEToma := "2" //-- Contribuinte isento de inscricao
			Else
				cIEToma := "1" //-- Contribuinte ICMS
			EndIf
		Else
			cIEToma  := "9"
		EndIf		
		cRet += '<toma>'
		cRet += '<toma>'+cTomador+'</toma>'
		cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
		If (AllTrim((cAliasDT6)->REM_TPPESSOA) == "J")
			cRet += '<CNPJ>' + NoAcentoCte( (cAliasDT6)->REM_CNPJ ) + '</CNPJ>'
		Else
			cRet += '<CPF>'  + NoAcentoCte( (cAliasDT6)->REM_CNPJ ) + '</CPF>'
		EndIf
			
		tagAutXML( NoAcentoCte(AllTrim(((cAliasDT6)->REM_CNPJ))))  
		
		//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
		If (cAliasDT6)->REM_CONTRIB =='1' 
			If Empty((cAliasDT6)->REM_INSC) .Or. 'ISENT' $ Upper(AllTrim((cAliasDT6)->REM_INSC)) .Or. ((cAliasDT6)->REM_CONTRIB =='1' .And. 'ISENT' $ Upper(AllTrim((cAliasDT6)->REM_INSC)))
				cRet += '<IE>ISENTO</IE>'
			Else
				cRet += '<IE>' + NoPontos((cAliasDT6)->REM_INSC) + '</IE>'
			EndIf
		EndIf

		cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->REM_NOME,1,60)) + '</xNome>'
		cRet += '<enderToma>'
		cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->REM_END)[1]) + '</xLgr>'
		cRet += '<nro>' + Iif(FisGetEnd((cAliasDT6)->REM_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->REM_END)[2])),"S/N") + '</nro>'
		If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->REM_CPL)[4]))
			cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->REM_CPL)[4]) + '</xCpl>'
		EndIf
		If Empty(AllTrim((cAliasDT6)->REM_BAIRRO))
			cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
		Else
			cRet += '<xBairro>' + NoAcentoCte( (cAliasDT6)->REM_BAIRRO ) + '</xBairro>'
		EndIf
		cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFRem) + Alltrim((cAliasDT6)->REM_COD_MUN) ) + '</cMun>'
		cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->REM_MUNICI ) + '</xMun>'
		cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->REM_CEP )    + '</CEP>'
		cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->REM_UF )     + '</UF>'
		cRet += '</enderToma>'
		If !Empty((cAliasDT6)->REM_EMAIL)
			cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->REM_EMAIL),1,60)) + '</email>'
		EndIf
		cRet += '</toma>'	
	//+---------------------------------------------------------------------------
	//| Tomador = 1-Expedidor
	//+---------------------------------------------------------------------------
	ElseIf ((cAliasDT6)->DT6_CLIEXP == (cAliasDT6)->DT6_CLIDEV) .And.;
		   ((cAliasDT6)->DT6_LOJEXP == (cAliasDT6)->DT6_LOJDEV) .And. (cAliasDT6)->DT6_DEVFRE $ "6"
			cCNPJToma     := AllTrim((cAliasDT6)->EXP_CNPJ)
			cPessoaToma   := AllTrim((cAliasDT6)->EXP_TPPESSOA)
			cTomador      := '1'
			If (cAliasDT6)->EXP_CONTRIB <> "2" .And. !Empty((cAliasDT6)->EXP_INSC)
				If "ISENT" $ Upper(AllTrim((cAliasDT6)->EXP_INSC))
					cIEToma := "2" //-- Contribuinte isento de inscricao
				Else
					cIEToma := "1" //-- Contribuinte ICMS
				EndIf
			Else
				cIEToma  := "9"
			EndIf
			cRet += '<toma>'
			cRet += '<toma>'+cTomador+'</toma>'
			cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
			If (AllTrim((cAliasDT6)->EXP_TPPESSOA) == "J")
				cRet += '<CNPJ>' + NoAcentoCte( (cAliasDT6)->EXP_CNPJ ) + '</CNPJ>'
			Else
				cRet += '<CPF>'  + NoAcentoCte( (cAliasDT6)->EXP_CNPJ ) + '</CPF>'
			EndIf
				
			tagAutXML( NoAcentoCte(AllTrim(((cAliasDT6)->EXP_CNPJ))))  
			
			//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
			If (cAliasDT6)->EXP_CONTRIB =='1' 
				If Empty((cAliasDT6)->EXP_INSC) .Or. 'ISENT' $ Upper(AllTrim((cAliasDT6)->EXP_INSC)) .Or. ((cAliasDT6)->EXP_CONTRIB =='1' .And. 'ISENT' $ Upper(AllTrim((cAliasDT6)->EXP_INSC)))
					cRet += '<IE>ISENTO</IE>'
				Else
					cRet += '<IE>' + NoPontos((cAliasDT6)->EXP_INSC) + '</IE>'
				EndIf
			EndIf

			cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->EXP_NOME,1,60)) + '</xNome>'
			cRet += '<enderToma>'
			cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->EXP_END)[1]) + '</xLgr>'
			cRet += '<nro>' + Iif(FisGetEnd((cAliasDT6)->EXP_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->EXP_END)[2])),"S/N") + '</nro>'
			If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->EXP_CPL)[4]))
				cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->EXP_CPL)[4]) + '</xCpl>'
			EndIf
			If Empty(AllTrim((cAliasDT6)->EXP_BAIRRO))
				cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
			Else
				cRet += '<xBairro>' + NoAcentoCte( (cAliasDT6)->EXP_BAIRRO ) + '</xBairro>'
			EndIf
			cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFExp) + Alltrim((cAliasDT6)->EXP_COD_MUN) ) + '</cMun>'
			cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->EXP_MUNICI ) + '</xMun>'
			cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->EXP_CEP )    + '</CEP>'
			cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->EXP_UF )     + '</UF>'
			cRet += '</enderToma>'
			If !Empty((cAliasDT6)->EXP_EMAIL)
				cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->EXP_EMAIL),1,60)) + '</email>'
			EndIf
			cRet += '</toma>'	


	//+---------------------------------------------------------------------------
	//| Tomador = 2-Recebedor
	//+---------------------------------------------------------------------------
	ElseIf ((cAliasDT6)->DT6_CLIREC == (cAliasDT6)->DT6_CLIDEV) .And.;
		   ((cAliasDT6)->DT6_LOJREC == (cAliasDT6)->DT6_LOJDEV)  .And. (cAliasDT6)->DT6_DEVFRE $ "7"
			cCNPJToma     := AllTrim((cAliasDT6)->REC_CNPJ)
			cPessoaToma   := AllTrim((cAliasDT6)->REC_TPPESSOA)
			cTomador      := '2'
			
			If (cAliasDT6)->REC_CONTRIB <> "2" .And. !Empty((cAliasDT6)->REC_INSC)
				If "ISENT" $ Upper(AllTrim((cAliasDT6)->REC_INSC))
					cIEToma := "2" //-- Contribuinte isento de inscricao
				Else
					cIEToma := "1" //-- Contribuinte ICMS
				EndIf
			Else
				cIEToma  := "9"
			EndIf

			cRet += '<toma>'
			cRet += '<toma>'+cTomador+'</toma>'
			cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
			If (AllTrim((cAliasDT6)->REC_TPPESSOA) == "J")
				cRet += '<CNPJ>' + NoAcentoCte( (cAliasDT6)->REC_CNPJ ) + '</CNPJ>'
			Else
				cRet += '<CPF>'  + NoAcentoCte( (cAliasDT6)->REC_CNPJ ) + '</CPF>'
			EndIf
				
			tagAutXML( NoAcentoCte(AllTrim(((cAliasDT6)->REC_CNPJ))))  
			
			//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
			If (cAliasDT6)->REC_CONTRIB =='1' 
				If Empty((cAliasDT6)->REC_INSC) .Or. 'ISENT' $ Upper(AllTrim((cAliasDT6)->REC_INSC)) .Or. ((cAliasDT6)->REC_CONTRIB =='1' .And. 'ISENT' $ Upper(AllTrim((cAliasDT6)->REC_INSC)))
					cRet += '<IE>ISENTO</IE>'
				Else
					cRet += '<IE>' + NoPontos((cAliasDT6)->REC_INSC) + '</IE>'
				EndIf
			EndIf

			cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->REC_NOME,1,60)) + '</xNome>'
			cRet += '<enderToma>'
			cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->REC_END)[1]) + '</xLgr>'
			cRet += '<nro>' + Iif(FisGetEnd((cAliasDT6)->REC_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->REC_END)[2])),"S/N") + '</nro>'
			If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->REC_CPL)[4]))
				cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->REC_CPL)[4]) + '</xCpl>'
			EndIf
			If Empty(AllTrim((cAliasDT6)->REC_BAIRRO))
				cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
			Else
				cRet += '<xBairro>' + NoAcentoCte( (cAliasDT6)->REC_BAIRRO ) + '</xBairro>'
			EndIf
			cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFRec) + Alltrim((cAliasDT6)->REC_COD_MUN) ) + '</cMun>'
			cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->REC_MUNICI ) + '</xMun>'
			cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->REC_CEP )    + '</CEP>'
			cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->REC_UF )     + '</UF>'
			cRet += '</enderToma>'
			If !Empty((cAliasDT6)->REC_EMAIL)
				cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->REC_EMAIL),1,60)) + '</email>'
			EndIf
			cRet += '</toma>'	


	//+---------------------------------------------------------------------------
	//| Tomador = 3-Destinatario
	//+---------------------------------------------------------------------------
	ElseIf ((cAliasDT6)->DT6_CLIDES = (cAliasDT6)->DT6_CLIDEV) .And.;
		   ((cAliasDT6)->DT6_LOJDES = (cAliasDT6)->DT6_LOJDEV)
		                                    
		cCNPJToma 		:= AllTrim((cAliasDT6)->DES_CNPJ)
		cPessoaToma 	:= AllTrim((cAliasDT6)->DES_TPPESSOA)
		cTomador		:= '3'
		If (cAliasDT6)->DES_CONTRIB <> "2" .and. !Empty((cAliasDT6)->DES_INSC)
			 If "ISENT" $ Upper(Alltrim((cAliasDT6)->DES_INSC))
			  cIEToma := "2" //2-Contribuinte isento de inscrição;
			 Else
			  cIEToma := "1" //1-Contribuinte ICMS;
			 EndIf
		Else
		 	cIEToma := "9" //9-Não Contribuinte		 	
		EndIf

		cRet += '<toma>'
		cRet += '<toma>'+cTomador+'</toma>'
		cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
		If (AllTrim((cAliasDT6)->DES_TPPESSOA) == "J")
			cRet += '<CNPJ>' + NoAcentoCte( (cAliasDT6)->DES_CNPJ ) + '</CNPJ>'
		Else
			cRet += '<CPF>'  + NoAcentoCte( (cAliasDT6)->DES_CNPJ ) + '</CPF>'
		EndIf
			
		tagAutXML( NoAcentoCte(AllTrim(((cAliasDT6)->DES_CNPJ))))  
		
		//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
		If (cAliasDT6)->DES_CONTRIB =='1' 
			If Empty((cAliasDT6)->DES_INSC) .Or. 'ISENT' $ Upper(AllTrim((cAliasDT6)->DES_INSC)) .Or. ((cAliasDT6)->DES_CONTRIB =='1' .And. 'ISENT' $ Upper(AllTrim((cAliasDT6)->DES_INSC)))
				cRet += '<IE>ISENTO</IE>'
			Else
				cRet += '<IE>' + NoPontos((cAliasDT6)->DES_INSC) + '</IE>'
			EndIf
		EndIf

		cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->DES_NOME,1,60)) + '</xNome>'
		cRet += '<enderToma>'
		cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->DES_END)[1]) + '</xLgr>'
		cRet += '<nro>' + Iif(FisGetEnd((cAliasDT6)->DES_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->DES_END)[2])),"S/N") + '</nro>'
		If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->DES_CPL)[4]))
			cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->DES_CPL)[4]) + '</xCpl>'
		EndIf
		If Empty(AllTrim((cAliasDT6)->DES_BAIRRO))
			cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
		Else
			cRet += '<xBairro>' + NoAcentoCte( (cAliasDT6)->DES_BAIRRO ) + '</xBairro>'
		EndIf
		cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFDes) + Alltrim((cAliasDT6)->DES_COD_MUN) ) + '</cMun>'
		cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->DES_MUNICI ) + '</xMun>'
		cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->DES_CEP )    + '</CEP>'
		cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->DES_UF )     + '</UF>'
		cRet += '</enderToma>'
		If !Empty((cAliasDT6)->DES_EMAIL)
			cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->DES_EMAIL),1,60)) + '</email>'
		EndIf
		cRet += '</toma>'	


	Else
		cTomador   	:= '1'
		cIEToma 		:= IIf((cAliasDT6)->REM_CONTRIB = '1', '1', '9')	
	EndIf


ElseIf !(Empty((cAliasDT6)->DT6_CLICON)) .And. (cAliasDT6)->DT6_DEVFRE $ "2"   	
	//+---------------------------------------------------------------------------
	//| Tomador = 3-Destinatario
	//+---------------------------------------------------------------------------
	If ((cAliasDT6)->DT6_CLIDES = (cAliasDT6)->DT6_CLIDEV) .And.;
		   ((cAliasDT6)->DT6_LOJDES = (cAliasDT6)->DT6_LOJDEV) .And. (cAliasDT6)->DT6_DEVFRE $ "2"
		                                    
		cCNPJToma 		:= AllTrim((cAliasDT6)->DES_CNPJ)
		cPessoaToma 	:= AllTrim((cAliasDT6)->DES_TPPESSOA)
		cTomador		:= '3'
		If (cAliasDT6)->DES_CONTRIB <> "2" .and. !Empty((cAliasDT6)->DES_INSC)
			 If "ISENT" $ Upper(Alltrim((cAliasDT6)->DES_INSC))
			  cIEToma := "2" //2-Contribuinte isento de inscrição;
			 Else
			  cIEToma := "1" //1-Contribuinte ICMS;
			 EndIf
		Else
		 	cIEToma := "9" //9-Não Contribuinte		 	
		EndIf
	Else
		cTomador   	:= '1'
		cIEToma 		:= IIf((cAliasDT6)->REM_CONTRIB = '1', '1', '9')	
	EndIf

	cRet += '<toma>'
	cRet += '<toma>'+cTomador+'</toma>'
	cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
	If (AllTrim((cAliasDT6)->DES_TPPESSOA) == "J")
		cRet += '<CNPJ>' + NoAcentoCte( (cAliasDT6)->DES_CNPJ ) + '</CNPJ>'
	Else
		cRet += '<CPF>'  + NoAcentoCte( (cAliasDT6)->DES_CNPJ ) + '</CPF>'
	EndIf
		
	tagAutXML( NoAcentoCte(AllTrim(((cAliasDT6)->DES_CNPJ))))  
	
	//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
	If (cAliasDT6)->DES_CONTRIB =='1' 
		If Empty((cAliasDT6)->DES_INSC) .Or. 'ISENT' $ Upper(AllTrim((cAliasDT6)->DES_INSC)) .Or. ((cAliasDT6)->DES_CONTRIB =='1' .And. 'ISENT' $ Upper(AllTrim((cAliasDT6)->DES_INSC)))
			cRet += '<IE>ISENTO</IE>'
		Else
			cRet += '<IE>' + NoPontos((cAliasDT6)->DES_INSC) + '</IE>'
		EndIf
	EndIf

	cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->DES_NOME,1,60)) + '</xNome>'
	cRet += '<enderToma>'
	cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->DES_END)[1]) + '</xLgr>'
	cRet += '<nro>' + Iif(FisGetEnd((cAliasDT6)->DES_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->DES_END)[2])),"S/N") + '</nro>'
	If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->DES_CPL)[4]))
		cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->DES_CPL)[4]) + '</xCpl>'
	EndIf
	If Empty(AllTrim((cAliasDT6)->DES_BAIRRO))
		cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
	Else
		cRet += '<xBairro>' + NoAcentoCte( (cAliasDT6)->DES_BAIRRO ) + '</xBairro>'
	EndIf
	cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFDes) + Alltrim((cAliasDT6)->DES_COD_MUN) ) + '</cMun>'
	cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->DES_MUNICI ) + '</xMun>'
	cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->DES_CEP )    + '</CEP>'
	cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->DES_UF )     + '</UF>'
	cRet += '</enderToma>'
	If !Empty((cAliasDT6)->DES_EMAIL)
		cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->DES_EMAIL),1,60)) + '</email>'
	EndIf
	cRet += '</toma>'	

ElseIf (((cAliasDT6)->DT6_CLICON = (cAliasDT6)->DT6_CLIDEV) .And.;
		((cAliasDT6)->DT6_LOJCON = (cAliasDT6)->DT6_LOJDEV))
		
	cCNPJToma 		:= AllTrim((cAliasDT6)->CON_CNPJ)
	cPessoaToma 	:= AllTrim((cAliasDT6)->CON_TPPESSOA)	
	If (cAliasDT6)->CON_CONTRIB <> "2" .and. !Empty((cAliasDT6)->CON_INSC)
		 If "ISENT" $ Upper(Alltrim((cAliasDT6)->CON_INSC))
		  cIEToma := "2" //2-Contribuinte isento de inscrição; 
		 Else
		  cIEToma := "1" //1-Contribuinte ICMS;  
		 EndIf
	Else 		
	 	cIEToma := "9" //9-Não Contribuinte	 	
	EndIf		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tomador do Servico Consignatario     ³
	//³ 4 - Outros;                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet += '<toma>'
	cRet += '<toma>4</toma>'
	cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
	
	If (AllTrim((cAliasDT6)->CON_TPPESSOA) == "J")
		cRet += '<CNPJ>' + AllTrim((cAliasDT6)->CON_CNPJ) + '</CNPJ>'
	Else
		cRet += '<CPF>'  + AllTrim((cAliasDT6)->CON_CNPJ) + '</CPF>'
	EndIf
	 
	tagAutXML( NoAcentoCte(AllTrim((cAliasDT6)->CON_CNPJ))) 
	
	//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
	If (cAliasDT6)->CON_CONTRIB =='1' 
		If Empty((cAliasDT6)->CON_INSC) .Or. "ISENT" $ Upper(AllTrim((cAliasDT6)->CON_INSC))
			cRet += '<IE>ISENTO</IE>'
		Else
			cRet += '<IE>' + NoPontos((cAliasDT6)->CON_INSC) + '</IE>'
		EndIf
	EndIf

	cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->CON_NOME,1,60)) + '</xNome>'
	If  !Empty(NoPontos((cAliasDT6)->CON_TEL))
		cRet += '<fone>'  +  cValtoChar(NoPontos((cAliasDT6)->CON_DDDTEL)) +;
		cValtoChar(NoPontos((cAliasDT6)->CON_TEL)) + '</fone>'
	EndIf
	cRet += '<enderToma>'
	cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->CON_END)[1]) + '</xLgr>'
	cRet += '<nro>'  + Iif(FisGetEnd((cAliasDT6)->CON_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->CON_END)[2])),"S/N") + '</nro>'
	
	If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->CON_CPL)[4]))
		cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->CON_CPL)[4]) + '</xCpl>'
	EndIf
	
	If Empty(AllTrim((cAliasDT6)->CON_BAIRRO))
		cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
	Else
		cRet += '<xBairro>' +NoAcentoCte( (cAliasDT6)->CON_BAIRRO ) + '</xBairro>'
	EndIf
	
	//-- Confere se Uf do Consignatario esta OK
	If !Empty((cAliasDT6)->CON_UF)
		If (aScan(aUF,{|x| x[1] == (cAliasDT6)->CON_UF }) != 0)
			cCodUFCon  := aUF[ aScan(aUF,{|x| x[1] == (cAliasDT6)->CON_UF }), 2]
		Else
			cCodUFCon := ''
		EndIf
	EndIf
					
	cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFCon)         + AllTrim((cAliasDT6)->CON_COD_MUN) ) + '</cMun>'
	cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->CON_MUNICI ) + '</xMun>'
	cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->CON_CEP )    + '</CEP>'
	cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->CON_UF )     + '</UF>'
	If !Empty(AllTrim((cAliasDT6)->CON_PAIS))
		cRet +=  '<cPais>'+ NoAcentoCte( (cAliasDT6)->CON_PAIS ) + '</cPais>'
		cRet +=  '<xPais>'+ NoAcentoCte( Posicione("SYA",1,xFilial("SYA")+(cAliasDT6)->CON_PAIS,"YA_DESCR") ) + '</xPais>'
	EndIf
	
	cRet += '</enderToma>'
	If !Empty((cAliasDT6)->CON_EMAIL)
		cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->CON_EMAIL),1,60)) + '</email>'
	EndIf
	cRet += '</toma>'
		
ElseIf (((cAliasDT6)->DT6_CLIDPC = (cAliasDT6)->DT6_CLIDEV) .And.;
		((cAliasDT6)->DT6_LOJDPC = (cAliasDT6)->DT6_LOJDEV))
		
	cCNPJToma 	:= AllTrim((cAliasDT6)->DPC_CNPJ)
	cPessoaToma := AllTrim((cAliasDT6)->DPC_TPPESSOA)  		
	If (cAliasDT6)->DPC_CONTRIB <> "2" .and. !Empty((cAliasDT6)->DPC_INSC)
		If "ISENT" $ Upper(Alltrim((cAliasDT6)->CON_INSC))
			cIEToma := "2" //2-Contribuinte isento de inscrição; 
		Else
			cIEToma := "1" //1-Contribuinte ICMS;  
		EndIf
	Else		 	
	 	cIEToma := "9" //9-Não Contribuinte		 	
	EndIf		
	
	cRet += '<toma>'
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tomador do Servico Despachante       ³
	//³ 4 - Outros;                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet += '<toma>4</toma>'
	cRet += '<indIEToma>' + cIEToma + '</indIEToma>'
	If (AllTrim((cAliasDT6)->DPC_TPPESSOA) == "J")
		cRet += '<CNPJ>' + NoAcentoCte( (cAliasDT6)->DPC_CNPJ ) + '</CNPJ>'
	Else
		cRet += '<CPF>'  + NoAcentoCte( (cAliasDT6)->DPC_CNPJ ) + '</CPF>'
	EndIf
		
	tagAutXML( NoAcentoCte(AllTrim(((cAliasDT6)->DPC_CNPJ))))  
	
	//-- Conf. MOC 3.00a, tag IE: Caso o tomador não seja contribuinte do ICMS não informar o conteúdo. 
	If (cAliasDT6)->DPC_CONTRIB =='1' 
		If Empty((cAliasDT6)->DPC_INSC) .Or. 'ISENT' $ Upper(AllTrim((cAliasDT6)->DPC_INSC)) .Or. ((cAliasDT6)->DPC_CONTRIB =='1' .And. 'ISENT' $ Upper(AllTrim((cAliasDT6)->DPC_INSC)))
			cRet += '<IE>ISENTO</IE>'
		Else
			cRet += '<IE>' + NoPontos((cAliasDT6)->DPC_INSC) + '</IE>'
		EndIf
	EndIf

	cRet += '<xNome>' + NoAcentoCte(SubStr((cAliasDT6)->DPC_NOME,1,60)) + '</xNome>'
	cRet += '<enderToma>'
	cRet += '<xLgr>' + NoAcentoCte(FisGetEnd((cAliasDT6)->DPC_END)[1]) + '</xLgr>'
	cRet += '<nro>' + Iif(FisGetEnd((cAliasDT6)->DPC_END)[2]<>0, AllTrim(cValtoChar( FisGetEnd((cAliasDT6)->DPC_END)[2])),"S/N") + '</nro>'
	If !Empty(NoAcentoCte(FisGetEnd((cAliasDT6)->DPC_CPL)[4]))
		cRet += '<xCpl>' + NoAcentoCte(FisGetEnd((cAliasDT6)->DPC_CPL)[4]) + '</xCpl>'
	EndIf
	If Empty(AllTrim((cAliasDT6)->DPC_BAIRRO))
		cRet += '<xBairro>BAIRRO NAO CADASTRADO</xBairro>'
	Else
		cRet += '<xBairro>' + NoAcentoCte( (cAliasDT6)->DPC_BAIRRO ) + '</xBairro>'
	EndIf
	cRet += '<cMun>' + NoAcentoCte( AllTrim(cCodUFDpc) + Alltrim((cAliasDT6)->DPC_COD_MUN) ) + '</cMun>'
	cRet += '<xMun>' + NoAcentoCte( (cAliasDT6)->DPC_MUNICI ) + '</xMun>'
	cRet += '<CEP>'  + NoAcentoCte( (cAliasDT6)->DPC_CEP )    + '</CEP>'
	cRet += '<UF>'   + NoAcentoCte( (cAliasDT6)->DPC_UF )     + '</UF>'
	cRet += '</enderToma>'
	If !Empty((cAliasDT6)->DPC_EMAIL)
		cRet += '<email>' + NoAcentoCte(SubStr(AllTrim((cAliasDT6)->DPC_EMAIL),1,60)) + '</email>'
	EndIf
	cRet += '</toma>'	
EndIf
	
If (nRet == 2)
	If (AllTrim(cPessoaToma) == "J")
		cRet = '<CNPJ>' + AllTrim(cCNPJToma) + '</CNPJ>'
	Else
		cRet = '<CPF>'  + AllTrim(cCNPJToma) + '</CPF>'
	EndIf
EndIf 	

RestArea(aAreaSA1)

Return(cRet)

/*/{Protheus.doc} TrocaToma
// Verifica se o tomador de serviços foi alterado na substituição
@author caio.y
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cFilDoc, characters, Filial Doc
@param cDoc, characters, Documento
@param cSerie, characters, Serie
@param cCliDev, characters, Devedor
@param cLojDev, characters, Loja Devedor
@type function
/*/
Static Function TrocaToma(cFilDoc, cDoc , cSerie ,  cCliDev , cLojDev )
Local lRet		:= .F. 
Local aAreaDT6	:= DT6->(GetArea())

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cCliDev		:= ""
Default cLojDev		:= ""

DT6->(dbSetOrder(1)) //-- FILIAL+FILDOC+DOC+SERIE
If DT6->(dbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie ))
	If cCliDev + cLojDev <> DT6->(DT6_CLIDEV+DT6_LOJDEV)
		lRet	:= .T. 
	EndIf
EndIf

RestArea(aAreaDT6)
Return lRet


/*/{Protheus.doc} tagAutXML()
	Monta a TAG aAutXML do CTe para envio a SEFAZ
	@type  Static Function
	@author Felipe M. Barbiere
	@since 10/01/2024
	@version 1.0	
	/*/
Static Function tagAutXML( cCNPJ_CPF )
Local nPos := 0

Default cCNPJ_CPF := ""

If !Empty(cCNPJ_CPF) .And. !Empty(aCNPJAntt)
	nPos := AScan(aCNPJAntt, cCNPJ_CPF) 

	If nPos > 0
		aDel(aCNPJAntt, nPos)	
		aSize(aCNPJAntt, Len(aCNPJAntt)-1)
	EndIf
	
EndIf

Return

/*/{Protheus.doc} tagcBenef()
	Monta a TAG cBenef do CTe para envio a SEFAZ
	@type  Static Function
	@author Fabio Marchiori Sampaio
	@since 09/07/2024
	@version 1.0	
	/*/
Static Function tagcBenef(cFildoc, cDoc,cSerie,cCliDev,cLojDev)

Local cRet        := ''
Local cQuery      := ''
Local cAliasQry   := ''

Default cFildoc   := ''
Default cDoc      := ''
Default cSerie    := ''
Default cCliDev   := ''
Default cLojDev   := ''

	cQuery := "SELECT CDV_CODAJU "
	cQuery += "FROM " + RetSqlName("CDV") + " "
	cQuery += "WHERE CDV_FILIAL = '" + xFilial("CDV") + "' "
	cQuery += "AND CDV_TPMOVI = '" + 'S' + "' "
	cQuery += "AND CDV_ESPECI = '" + 'CTE' + "' "
	cQuery += "AND CDV_FORMUL = '" + 'S' + "' "
	cQuery += "AND CDV_DOC    = '" + cDoc + "' "
	cQuery += "AND CDV_SERIE  = '" + cSerie + "' "
	cQuery += "AND CDV_CLIFOR = '" + cCliDev + "' "
	cQuery += "AND CDV_LOJA   = '" + cLojDev + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof())
		cRet := (cAliasQry)->CDV_CODAJU 
	EndIf
	(cAliasQry)->(DbCloseArea())

Return cRet

/*/{Protheus.doc} RetObsSub
Monta a observação de subcontratação conforme 
definido no AJUSTE SINIEF 14/89, art 1, § VII e CONVÊNIO/SINIEF 06/89
@type  Static Function
@author Felipe M. Barbiere
@since 10/01/2024
@version 1.0	
/*/
Static Function RetObsSub( cCODFOR, cLOJFOR, cPLACA, cESTPLA, cMARVEI )

Local aAreaSA2	:= SA2->(GetArea())
Local cRet		:= ""

Default cCODFOR := ""
Default cLOJFOR := ""
Default cPLACA	:= ""
Default cESTPLA	:= ""
Default cMARVEI	:= ""

If !Empty(cCODFOR) .And. !Empty(cLOJFOR)
	cNReduz := Posicione( 'SA2', 1, xFilial('SA2') + cCODFOR + cLOJFOR, 'A2_NREDUZ')
	cDescMar:= Tabela( "M6", cMARVEI, .F. )
	cRet := " Transporte subcontratado com " + AllTrim(cNReduz) + ", proprietario do veiculo marca " + AllTrim(cDescMar) + ", placa num." + AllTrim(cPLACA) + ", UF " + AllTrim(cESTPLA)
EndIf

RestArea(aAreaSA2)

Return cRet
