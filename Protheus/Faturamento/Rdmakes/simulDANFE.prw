#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rptdef.ch"
#include "fwprintsetup.ch"

#define ESPLIN		2
#define IMP_SPOOL	2
#define MAXMSG		80												// Máximo de dados adicionais por página
#define MAXITEM		22												// Máximo de produtos para a primeira página
#define MAXITEMP2	49												// Máximo de produtos para a pagina 2 em diante
#define MAXITEMC	38												// Máxima de caracteres por linha de produtos/serviços
#define _MAXIMP		62												// Máximo de impostos calculados pela função FIMPOSTOS

user function PREDANFE(cMod,cPV,cNF,cSE,cCLI)

	local aArea := GetArea()
	local lOk   := .F.

	//--------------------------------------------------------------------------
	// Se chamado pelo menu, solicita os dados ao usuário
	//--------------------------------------------------------------------------

	If ValType(cPV)  != "C" .Or. ValType(cNF)  != "C" .Or. ;
			ValType(cSE)  != "C" .Or. ValType(cCLI) != "C" .Or. ;
			ValType(cMod) != "C"

		cMod := "S"
		cPV  := Space(06)
		lOk  := .F.

		Define Dialog oDlg Title "PRE-DANFE" From 100,100 To 300,500 Pixel

		// Label e campo do pedido
		@ 020,010 Say "Número do Pedido de Venda:" Size 150,010 Of oDlg Pixel
		@ 035,010 Get oGetPV Var cPV Picture "@!" Size 120,012 Of oDlg Pixel

		// Botões centralizados
		@ 065,040 Button "&Confirmar" Size 070,016 Of oDlg Pixel Action ;
			(;
			cPV := AllTrim(cPV),;
			IIf(Empty(cPV), ;
			MsgAlert("Informe o Número do Pedido de Venda!"), ;
			IIf(!SC5->(DbSeek(xFilial("SC5")+cPV,.F.)), ;
			MsgAlert("Pedido '"+cPV+"' não encontrado!"), ;
			(lOk := .T., oDlg:End()) ;
			) ;
			) ;
			) Pixel
		@ 065,120 Button "&Cancelar" Size 070,016 Of oDlg Pixel Action (lOk := .F., oDlg:End()) Pixel

		Activate Dialog oDlg Centered


		If !lOk
			RestArea(aArea)
			Return
		EndIf

		//-- Pedido encontrado, busca cliente automaticamente -----------------
		DbSelectArea("SC5")
		DbSetOrder(1)
		SC5->(MsSeek(xFilial("SC5")+cPV,.F.))

		cCLI := SC5->C5_CLIENTE + SC5->C5_LOJACLI
		cMod := "S"
		cNF  := ""
		cSE  := ""

	EndIf

	//--------------------------------------------------------------------------
	// Inicialização das variáveis privadas
	//--------------------------------------------------------------------------

	private nConsTex := 0.5
	private nFolha := 1
	private nFolhas := 1
	private lExistNfe := .T.

	private aEmpresa := {}
	private aDestinat := {}
	private aTotais := {}
	private aTransp := {}
	private aISSQN := {}
	private aNotaF := {}
	private aItens := {}
	private aFaturas := {}
	private aTabImposto := {}
	private cMensagem := {}
	private cResFisco := {}
	private aTot := {}
	private nModImp := IIf(Empty(cNF),1,0)

	private oPrinter := FWMSPrinter():New(IIf(nModImp <> 1,"PREDANFE_"+AllTrim(cNF),"PRENOTA_"+AllTrim(cPV)),IMP_PDF,.F.,,.T.,,@oPrinter,,,.F.,,.T.)
	private oFont07  := TFont():New("Times New Roman",,-06,,.F.,,,,,,.F.)
	private oFont07N := TFont():New("Times New Roman",,-06,,.T.,,,,,,.F.)
	private oFont08  := TFont():New("Times New Roman",,-07,,.F.,,,,,,.F.)
	private oFont08N := TFont():New("Times New Roman",,-06,,.T.,,,,,,.F.)
	private oFont09  := TFont():New("Times New Roman",,-08,,.F.,,,,,,.F.)
	private oFont09N := TFont():New("Times New Roman",,-08,,.T.,,,,,,.F.)
	private oFont10  := TFont():New("Times New Roman",,-09,,.F.,,,,,,.F.)
	private oFont10N := TFont():New("Times New Roman",,-08,,.T.,,,,,,.F.)
	private oFont11  := TFont():New("Times New Roman",,-10,,.F.,,,,,,.F.)
	private oFont11N := TFont():New("Times New Roman",,-10,,.T.,,,,,,.F.)
	private oFont12  := TFont():New("Times New Roman",,-11,,.F.,,,,,,.F.)
	private oFont12N := TFont():New("Times New Roman",,-11,,.T.,,,,,,.F.)
	private oFont18N := TFont():New("Times New Roman",,-17,,.T.,,,,,,.F.)
	private oFont19N := TFont():New("Times New Roman",,-07,,.T.,,,,,,.F.)

	oPrinter:cPathPDF := GetTempPath()
	oPrinter:lServer  := .F.

	oPrinter:SetResolution(78)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60)

	if !Empty(cNF)
		RptStatus({|| DPreDanfeNF(IIf(cMod == "S","1","0"),cNF,cSE,cCLI)},"Gravando o dados da "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+" de saida...")
	else
		RptStatus({|| DPreDanfePV(IIf(cMod == "S","1","0"),cPV,cCLI)},"Gravando o dados da "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+" de saida...")
	endif

	if lExistNfe
		RptStatus({|| PreDanfeProc(cMod)},"Imprimindo "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+"...")

		oPrinter:Preview()

	endif

	FreeObj(oPrinter)

	oPrinter := nil

	RestArea(aArea)
return

user function ConvData(cData)
	local cRetorno := ""

	if ValType(cData) == "D"
		cData := DToS(cData)
	endif

	if !Empty(AllTrim(cData)) .and. Len(AllTrim(cData)) == 8
		cRetorno := SubStr(cData,7,2)+"/"+SubStr(cData,5,2)+"/"+SubStr(cData,1,4)
	endif

return cRetorno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERANDO DADOS DA PRE-DANFE PELA NOTA FISCAL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function DPreDanfeNF(cModNF,cNota,cSerie,cCliFor)
	local aCampo := {}
	local aTes := {}
	local nTotServico := 0

	DbSelectArea("SM0")
	SM0->(MsSeek(cEmpAnt+cFilAnt,.F.))

	AAdd(aEmpresa,AllTrim(SM0->M0_NOMECOM))
	AAdd(aEmpresa,AllTrim(SM0->M0_ENDCOB))
	AAdd(aEmpresa,AllTrim(SM0->M0_BAIRCOB)+" - CEP: "+Transf(SM0->M0_CEPCOB,"@R 99999-999"))
	AAdd(aEmpresa,AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB)
	AAdd(aEmpresa,"Fone: 31 "+Transf(Right(AllTrim(SM0->M0_TEL),8),"@R 9999-9999"))
	AAdd(aEmpresa,GetSrvProfString("Startpath","")+"DANFE"+cEmpAnt+cFilAnt+".BMP")
	AAdd(aEmpresa,AllTrim(SM0->M0_CGC))
	AAdd(aEmpresa,AllTrim(SM0->M0_INSC))
	AAdd(aEmpresa,AllTrim(SM0->M0_INSCM))

	if cModNF == "1"
		cAliasNF := "SF2"
		nIndice := 2
	else
		cAliasNF := "SF1"
		nIndice := 1
	endif

	aCampo := {{"F1_TIPO","F1_EMISSAO","F1_HORA","F1_SAIDA","F1_TRANSP"},;
		{"F2_TIPO","F2_EMISSAO","F2_HORA","F2_SAIDA","F2_TRANSP"}}

	DbSelectArea(cAliasNF)
	(cAliasNF)->(MsSeek(xFilial(cAliasNF)+cNota+cSerie+cCliFor,.F.))

	AAdd(aNotaF,cModNF)
	AAdd(aNotaF,cNota)
	AAdd(aNotaF,cSerie)
	AAdd(aNotaF,cCliFor)
	AAdd(aNotaF,(cAliasNF)->&(aCampo[nIndice][1]))
	AAdd(aNotaF,DToS((cAliasNF)->&(aCampo[nIndice][2])))

	if Empty((cAliasNF)->&(aCampo[nIndice][4]))
		AAdd(aNotaF,DToS((cAliasNF)->&(aCampo[nIndice][2])))
	else
		AAdd(aNotaF,DToS((cAliasNF)->&(aCampo[nIndice][4])))
	endif

	AAdd(aNotaF,(cAliasNF)->&(aCampo[nIndice][3])+":00")
	AAdd(aNotaF,(cAliasNF)->&(aCampo[nIndice][5]))
	AAdd(aNotaF,"")

	if cModNF == "1"
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA2"
			nIndice1 := 2
		else
			cAliasCF := "SA1"
			nIndice1 := 1
		endif
	else
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA1"
			nIndice1 := 1
		else
			cAliasCF := "SA2"
			nIndice1 := 2
		endif
	endif

	aCampo := {{"A1_PESSOA","A1_NOME","A1_CGC","A1_END","A1_NR_END","A1_BAIRRO","A1_CEP","A1_MUN","A1_DDD","A1_TEL","A1_EST","A1_INSCR","A1_INSCRM"},;
		{"A2_TIPO","A2_NOME","A2_CGC","A2_END","A2_NR_END","A2_BAIRRO","A2_CEP","A2_MUN","A2_DDD","A2_TEL","A2_EST","A2_INSCR","A2_INSCRM"}}

	DbSelectArea(cAliasCF)
	(cAliasCF)->(MsSeek(xFilial(cAliasCF)+cCliFor,.F.))

	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][1]))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][2])))
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][3]))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][4])))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][6])))
	AAdd(aDestinat,Transf((cAliasCF)->&(aCampo[nIndice1][7]),"@R 99999-999"))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][8])))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][9]))+AllTrim((cAliasCF)->&(aCampo[nIndice1][10])))
	AAdd(aDestinat,(cAliasCF)->&(aCampo[nIndice1][11]))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][12])))
	AAdd(aDestinat,AllTrim((cAliasCF)->&(aCampo[nIndice1][13])))

	if cModNF == "1"
		cAliasFT := "SE1"
		nIndice := 2
		nIndOrd := 2
	else
		cAliasFT := "SE2"
		nIndice := 1
		nIndOrd := 6
	endif

	aCampo := {{"E2_NUM","E2_PREFIXO","E2_VALOR","E2_VENCTO","E2_FORNECE","E2_LOJA"},;
		{"E1_NUM","E1_PREFIXO","E1_VALOR","E1_VENCTO","E1_CLIENTE","E1_LOJA"}}

	DbSelectArea(cAliasFT)
	(cAliasFT)->(DbSetOrder(nIndOrd))

	if (cAliasFT)->(MsSeek(xFilial(cAliasFT)+aNotaF[4]+aNotaF[3]+aNotaF[2],.F.))
		while !(cAliasFT)->(Eof()) .and. (cAliasFT)->&(aCampo[nIndice][2])+(cAliasFT)->&(aCampo[nIndice][1]) == aNotaF[3]+aNotaF[2] .and. (cAliasFT)->&(aCampo[nIndice][5])+(cAliasFT)->&(aCampo[nIndice][6]) == aNotaF[4]
			AAdd(aFaturas,{(cAliasFT)->&(aCampo[nIndice][2]),;
				(cAliasFT)->&(aCampo[nIndice][1]),;
				U_ConvData(DToS((cAliasFT)->&(aCampo[nIndice][4]))),;
				AllTrim(Transf((cAliasFT)->&(aCampo[nIndice][3]),"@E 9,999,999,999,999.99"))})

			(cAliasFT)->(DbSkip())
		enddo
	endif

	aCampo := {{"F1_BASEICM","F1_VALICM","F1_VALMERC","F1_FRETE","F1_SEGURO","F1_DESCONT","F1_DESPESA","F1_VALIPI","F1_VALBRUT","F1_BRICMS","F1_ICMSRET","F1_VALIMP6","F1_VALIMP5"},;
		{"F2_BASEICM","F2_VALICM","F2_VALMERC","F2_FRETE","F2_SEGURO","F2_DESCONT","F2_DESPESA","F2_VALIPI","F2_VALBRUT","F2_BRICMS","F2_ICMSRET","F2_VALIMP6","F2_VALIMP5"}}

	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][1]),"@E 9,999,999,999,999.99"))   // [01] BASE ICMS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][2]),"@E 9,999,999,999,999.99"))   // [02] VALOR ICMS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][10]),"@E 9,999,999,999,999.99"))  // [03] BASE ICMS ST
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][11]),"@E 9,999,999,999,999.99"))  // [04] VALOR ICMS ST
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][3]),"@E 9,999,999,999,999.99"))   // [05] VALOR MERCADORIA
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][4]),"@E 9,999,999,999,999.99"))   // [06] FRETE
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][5]),"@E 9,999,999,999,999.99"))   // [07] SEGURO
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][6]),"@E 9,999,999,999,999.99"))   // [08] DESCONTO
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][7]),"@E 9,999,999,999,999.99"))   // [09] OUTRAS DESPESAS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][12]),"@E 9,999,999,999,999.99"))  // [10] VALOR PIS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][13]),"@E 9,999,999,999,999.99"))  // [11] VALOR COFINS
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][8]),"@E 9,999,999,999,999.99"))   // [12] VALOR IPI
	AAdd(aTotais,Transf((cAliasNF)->&(aCampo[nIndice][9]),"@E 9,999,999,999,999.99"))   // [13] VALOR TOTAL

	DbSelectArea("SA4")

	if SA4->(MsSeek(xFilial("SA4")+aNotaF[9],.F.))
		AAdd(aTransp,AllTrim(SA4->A4_NOME))

		if Len(AllTrim(SA4->A4_CGC)) == 14
			cAux := Transf(SA4->A4_CGC,"@R 99.999.999/9999-99")
		else
			cAux := Transf(SA4->A4_CGC,"@R 999.999.999-99")
		endif

		AAdd(aTransp,cAux)
		AAdd(aTransp,AllTrim(SA4->A4_END))
		AAdd(aTransp,AllTrim(SA4->A4_MUN))
		AAdd(aTransp,SA4->A4_EST)
		AAdd(aTransp,IIf(Empty(SA4->A4_INSEST),"ISENTO",AllTrim(SA4->A4_INSEST)))
	else
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
	endif

	DbSelectArea("SC5")
	DbSetOrder(8)
	MsSeek(xFilial("SC5")+aNotaF[2]+aNotaF[3]+aNotaF[4],.F.)

	do case
	case SC5->C5_TPFRETE == "C"
		AAdd(aTransp,"0")
	case SC5->C5_TPFRETE == "F"
		AAdd(aTransp,"1")
	case SC5->C5_TPFRETE == "T"
		AAdd(aTransp,"2")
	case SC5->C5_TPFRETE == "S"
		AAdd(aTransp,"9")
	otherwise
		AAdd(aTransp,"1")
	endcase

	AAdd(aTransp,"")
	AAdd(aTransp,SC5->C5_PLACA1)

	if !Empty(SC5->C5_VOLUME1)
		AAdd(aTransp,AllTrim(Str(Round(SC5->C5_VOLUME1,0))))
	else
		AAdd(aTransp,"")
	endif

	AAdd(aTransp,AllTrim(SC5->C5_ESPECI1))
	AAdd(aTransp,"")
	AAdd(aTransp,"")

	if !Empty(SC5->C5_PBRUTO)
		AAdd(aTransp,Transf(SC5->C5_PBRUTO,"@E 999999.999"))
	else
		AAdd(aTransp,"")
	endif

	if !Empty(SC5->C5_PESOL)
		AAdd(aTransp,Transf(SC5->C5_PESOL,"@E 999999.999"))
	else
		AAdd(aTransp,"")
	endif

	aCampo := {{"F1_VALMERC","F1_ISS"},;
		{"F2_BASEISS","F2_VALISS"}}

	if !Empty((cAliasNF)->&(aCampo[nIndice][2]))
		AAdd(aISSQN,aEmpresa[09])
		AAdd(aISSQN,"")
		AAdd(aISSQN,Transf((cAliasNF)->&(aCampo[nIndice][1]),"@E 99,999,999,999.99"))
		AAdd(aISSQN,Transf((cAliasNF)->&(aCampo[nIndice][2]),"@E 99,999,999,999.99"))
	else
		AAdd(aISSQN,"")
		AAdd(aISSQN,"")
		AAdd(aISSQN,"")
		AAdd(aISSQN,"")
	endif

	if cModNF == "1"
		cAliasIT := "SD2"
		nIndice := 2
		nIndOrd := 3
	else
		cAliasIT := "SD1"
		nIndice := 1
		nIndOrd := 1
	endif

	aCampo := {{"D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA","D1_DESCPRO","D1_COD","D1_TES","D1_CF","D1_CLASFIS","D1_UM","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_BASEICM","D1_VALICM","D1_VALIPI","D1_PICM","D1_IPI","D1_VALISS","D1_VALIMP6","D1_VALIMP5"},;
		{"D2_DOC","D2_SERIE","D2_CLIENTE","D2_LOJA","C6_DESCRI","D2_COD","D2_TES","D2_CF","D2_CLASFIS","D2_UM","D2_QUANT","D2_PRCVEN","D2_TOTAL","D2_BASEICM","D2_VALICM","D2_VALIPI","D2_PICM","D2_IPI","D2_VALISS","D2_VALIMP6","D2_VALIMP5"}}

	DbSelectArea(cAliasIT)
	(cAliasIT)->(DbSetOrder(nIndOrd))
	(cAliasIT)->(MsSeek(xFilial(cAliasIT)+aNotaF[2]+aNotaF[3]+aNotaF[4],.F.))

	nItem := 0

	while !(cAliasIT)->(Eof()) .and. (cAliasIT)->&(aCampo[nIndice][1]) == aNotaF[2] .and. (cAliasIT)->&(aCampo[nIndice][2]) == aNotaF[3] .and. (cAliasIT)->&(aCampo[nIndice][3])+(cAliasIT)->&(aCampo[nIndice][4]) == aNotaF[4]
		if cAliasIT == "SD2"
			DbSelectArea("SC6")
			DbSetOrder(12)
			MsSeek(xFilial("SC6")+aNotaF[2]+aNotaF[3]+SD2->D2_ITEMPV,.F.)
		endif

		cDescri := AllTrim(&(aCampo[nIndice][5]))

		DbSelectArea(cAliasIT)

		cNcm := IIf(SB1->(MsSeek(xFilial("SB1")+(cAliasIT)->&(aCampo[nIndice][6]),.F.)),AllTrim(SB1->B1_POSIPI),"")
		cTes := (cAliasIT)->&(aCampo[nIndice][7])

		if (nInd := AScan(aTes,{|x| x[1] == cTes})) == 0
			AAdd(aTes,{cTes,IIf(SF4->(MsSeek(xFilial("SF4")+cTes,.F.)),AllTrim(SF4->F4_TEXTO),""),AllTrim((cAliasIT)->&(aCampo[nIndice][8]))})

			aNotaF[10] := AllTrim(SF4->F4_TEXTO)+"/"
		endif

		AAdd(aItens,{Left(&(aCampo[nIndice][6]),6),;
			MemoLine(cDescri,MAXITEMC,1),;
			cNcm,;
			&(aCampo[nIndice][9]),;
			&(aCampo[nIndice][8]),;
			&(aCampo[nIndice][10]),;
			AllTrim(Transf(&(aCampo[nIndice][11]),PesqPict(cAliasIT,aCampo[nIndice][11]))),;
			AllTrim(Transf(&(aCampo[nIndice][12]),PesqPict(cAliasIT,aCampo[nIndice][12]))),;
			AllTrim(Transf(&(aCampo[nIndice][13]),PesqPict(cAliasIT,aCampo[nIndice][13]))),;
			AllTrim(Transf(&(aCampo[nIndice][14]),PesqPict(cAliasIT,aCampo[nIndice][14]))),;
			AllTrim(Transf(&(aCampo[nIndice][15]),PesqPict(cAliasIT,aCampo[nIndice][15]))),;
			AllTrim(Transf(&(aCampo[nIndice][16]),PesqPict(cAliasIT,aCampo[nIndice][16]))),;
			AllTrim(Transf(&(aCampo[nIndice][17]),"@E 99.99%")),;
			AllTrim(Transf(&(aCampo[nIndice][18]),"@E 99.99%")),;
			AllTrim(Transf(&(aCampo[nIndice][20]),PesqPict(cAliasIT,aCampo[nIndice][20]))),;
			AllTrim(Transf(&(aCampo[nIndice][21]),PesqPict(cAliasIT,aCampo[nIndice][21])))})

		nItem++

		if MLCount(cDescri,MAXITEMC) > 1
			for k := 2 to MLCount(cDescri,MAXITEMC)
				AAdd(aItens,{"",MemoLine(cDescri,MAXITEMC,k),"","","","","","","","","","","","","",""})

				nItem++
			next
		endif

		if !Empty((cAliasIT)->&(aCampo[nIndice][19]))
			nTotServico += (cAliasIT)->&(aCampo[nIndice][13])
		endif

		(cAliasIT)->(DbSkip())
	enddo

	if !Empty(nTotServico)
		aISSQN[2] := Transf(nTotServico,"@E 99,999,999,999.99")
	endif

	nItem -= MAXITEM
	lFlag := .T.

	while lFlag
		if nItem > 0
			nFolhas++
			nItem -= MAXITEMP2
		else
			lFlag := .F.
		endif
	enddo

	cProjetos := "Projeto(s): "+Projetos(aNotaF[2],aNotaF[3],Left(aNotaF[4],6),Right(aNotaF[4],2),cAliasNF)
	cMensagem := AllTrim(SC5->C5_MENNOTA)+Chr(13)+Chr(10)+cProjetos
	cResFisco := ""

	TabImpostos(cModNF)
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERANDO DADOS DA PRE-DANFE PELO PEDIDO DE VENDA                        ³
//³ Com simulação fiscal via MaFisIni/MaFisAdd/MaFisRet/MaFisEnd          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function DPreDanfePV(cModNF, cPedVen, cCliFor)
	local aCampo         := {}
	local aTes           := {}
	local aAreaBkp       := {}
	local aImpostoItem   := {}   // impostos por item: {baseICM,valICM,valIPI,alqICM,alqIPI,valPIS,valCOF}
	local nItAtu         := 0
	local nItem          := 0
	local nTotNota       := 0
	local nTotServico    := 0
	// Totalizadores fiscais
	local nTotBaseICM    := 0
	local nTotValICM     := 0
	local nTotBaseST     := 0
	local nTotValST      := 0
	local nTotIPI        := 0
	local nTotPIS        := 0
	local nTotCOFINS     := 0
	local nTotFrete      := 0
	local nTotGeral      := 0

	cModNF  := IIf(ValType(cModNF)  == "C", cModNF,  "1")
	cPedVen := IIf(ValType(cPedVen) == "C", cPedVen, "")
	cCliFor := IIf(ValType(cCliFor) == "C", cCliFor, "")

	If Empty(cPedVen)
		MsgAlert("Número do pedido de venda não informado!")
		lExistNfe := .F.
		Return
	EndIf

	If Empty(cCliFor)
		MsgAlert("Código do cliente não informado!")
		lExistNfe := .F.
		Return
	EndIf

	//----------------------------------------------------------------------
	// Empresa (SM0)
	//----------------------------------------------------------------------
	DbSelectArea("SM0")
	SM0->(MsSeek(cEmpAnt+cFilAnt,.F.))
	AAdd(aEmpresa, AllTrim(SM0->M0_NOMECOM))
	AAdd(aEmpresa, AllTrim(SM0->M0_ENDCOB))
	AAdd(aEmpresa, AllTrim(SM0->M0_BAIRCOB)+" - CEP: "+Transf(SM0->M0_CEPCOB,"@R 99999-999"))
	AAdd(aEmpresa, AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB)
	AAdd(aEmpresa, "Fone: 31 "+Transf(Right(AllTrim(SM0->M0_TEL),8),"@R 9999-9999"))
	AAdd(aEmpresa, GetSrvProfString("Startpath","")+"DANFE"+cEmpAnt+cFilAnt+".BMP")
	AAdd(aEmpresa, AllTrim(SM0->M0_CGC))
	AAdd(aEmpresa, AllTrim(SM0->M0_INSC))
	AAdd(aEmpresa, AllTrim(SM0->M0_INSCM))

	//----------------------------------------------------------------------
	// Cabeçalho do pedido (SC5)
	//----------------------------------------------------------------------
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(MsSeek(xFilial("SC5")+cPedVen,.F.))

	AAdd(aNotaF, cModNF)                         // [01] Mod NF
	AAdd(aNotaF, cPedVen)                         // [02] Número
	AAdd(aNotaF, "")                              // [03] Série
	AAdd(aNotaF, cCliFor)                         // [04] Cliente+Loja
	AAdd(aNotaF, SC5->C5_TIPO)                    // [05] Tipo NF
	AAdd(aNotaF, DToS(SC5->C5_EMISSAO))          // [06] Emissão
	AAdd(aNotaF, "")                              // [07] Data Saída
	AAdd(aNotaF, "")                              // [08] Hora Saída
	AAdd(aNotaF, SC5->C5_TRANSP)                  // [09] Transportadora
	AAdd(aNotaF, "")                              // [10] Natureza Operação
	AAdd(aNotaF, AllTrim(SC5->C5_TPFRETE))       // [11] Tipo Frete
	AAdd(aNotaF, SC5->C5_PLACA1)                  // [12] Placa
	AAdd(aNotaF, Str(SC5->C5_VOLUME1))            // [13] Volume
	AAdd(aNotaF, AllTrim(SC5->C5_ESPECI1))        // [14] Espécie
	AAdd(aNotaF, Str(SC5->C5_PBRUTO))             // [15] Peso Bruto
	AAdd(aNotaF, Str(SC5->C5_PESOL))              // [16] Peso Líquido
	AAdd(aNotaF, AllTrim(SC5->C5_MENNOTA))        // [17] Mensagem

	//----------------------------------------------------------------------
	// Destinatário
	//----------------------------------------------------------------------
	if cModNF == "1"
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA2"
			nIndice1 := 2
		else
			cAliasCF := "SA1"
			nIndice1 := 1
		endif
	else
		if aNotaF[5] $ "B/D"
			cAliasCF := "SA1"
			nIndice1 := 1
		else
			cAliasCF := "SA2"
			nIndice1 := 2
		endif
	endif

	aCampo := {{"A1_PESSOA","A1_NOME","A1_CGC","A1_END","A1_NR_END","A1_BAIRRO","A1_CEP","A1_MUN","A1_DDD","A1_TEL","A1_EST","A1_INSCR","A1_INSCRM"},;
		{"A2_TIPO","A2_NOME","A2_CGC","A2_END","A2_NR_END","A2_BAIRRO","A2_CEP","A2_MUN","A2_DDD","A2_TEL","A2_EST","A2_INSCR","A2_INSCRM"}}

	DbSelectArea(cAliasCF)
	(cAliasCF)->(MsSeek(xFilial(cAliasCF)+cCliFor,.F.))

	AAdd(aDestinat, (cAliasCF)->&(aCampo[nIndice1][1]))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][2])))
	AAdd(aDestinat, (cAliasCF)->&(aCampo[nIndice1][3]))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][4])))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][6])))
	AAdd(aDestinat, Transf((cAliasCF)->&(aCampo[nIndice1][7]),"@R 99999-999"))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][8])))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][9]))+AllTrim((cAliasCF)->&(aCampo[nIndice1][10])))
	AAdd(aDestinat, (cAliasCF)->&(aCampo[nIndice1][11]))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][12])))
	AAdd(aDestinat, AllTrim((cAliasCF)->&(aCampo[nIndice1][13])))

	//----------------------------------------------------------------------
	// aTotais — inicializado vazio, preenchido após MaFis*
	//----------------------------------------------------------------------
	AAdd(aTotais,"")   // [01] BASE ICMS
	AAdd(aTotais,"")   // [02] VALOR ICMS
	AAdd(aTotais,"")   // [03] BASE ICMS ST
	AAdd(aTotais,"")   // [04] VALOR ICMS ST
	AAdd(aTotais,"")   // [05] VALOR MERCADORIA
	AAdd(aTotais,"")   // [06] FRETE
	AAdd(aTotais,"")   // [07] SEGURO
	AAdd(aTotais,"")   // [08] DESCONTO
	AAdd(aTotais,"")   // [09] OUTRAS DESPESAS
	AAdd(aTotais,"")   // [10] VALOR PIS
	AAdd(aTotais,"")   // [11] VALOR COFINS
	AAdd(aTotais,"")   // [12] VALOR IPI
	AAdd(aTotais,"")   // [13] VALOR TOTAL

	for m := 1 to _MAXIMP
		AAdd(aTot,0)
	next

	//----------------------------------------------------------------------
	// Transportadora (SA4)
	//----------------------------------------------------------------------
	DbSelectArea("SA4")
	if SA4->(MsSeek(xFilial("SA4")+aNotaF[9],.F.))
		AAdd(aTransp, AllTrim(SA4->A4_NOME))
		if Len(AllTrim(SA4->A4_CGC)) == 14
			cAux := Transf(SA4->A4_CGC,"@R 99.999.999/9999-99")
		else
			cAux := Transf(SA4->A4_CGC,"@R 999.999.999-99")
		endif
		AAdd(aTransp, cAux)
		AAdd(aTransp, AllTrim(SA4->A4_END))
		AAdd(aTransp, AllTrim(SA4->A4_MUN))
		AAdd(aTransp, SA4->A4_EST)
		AAdd(aTransp, IIf(Empty(SA4->A4_INSEST),"ISENTO",AllTrim(SA4->A4_INSEST)))
	else
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
		AAdd(aTransp,"")
	endif

	do case
	case aNotaF[11] == "F" ; AAdd(aTransp,"0")
	case aNotaF[11] == "C" ; AAdd(aTransp,"1")
	case aNotaF[11] == "T" ; AAdd(aTransp,"2")
	case aNotaF[11] == "S" ; AAdd(aTransp,"9")
	otherwise              ; AAdd(aTransp,"1")
	endcase

	AAdd(aTransp,"")
	AAdd(aTransp, aNotaF[12])
	AAdd(aTransp,"")

	if !Empty(AllTrim(aNotaF[13])) .and. Val(aNotaF[13]) > 0
		AAdd(aTransp, AllTrim(Str(Round(Val(aNotaF[13]),0))))
	else
		AAdd(aTransp,"")
	endif

	AAdd(aTransp, aNotaF[14])
	AAdd(aTransp,"")
	AAdd(aTransp,"")

	if !Empty(AllTrim(aNotaF[15])) .and. Val(aNotaF[15]) > 0
		AAdd(aTransp, Transf(Val(aNotaF[15]),"@E 999999.999"))
	else
		AAdd(aTransp,"")
	endif

	if !Empty(AllTrim(aNotaF[16])) .and. Val(aNotaF[16]) > 0
		AAdd(aTransp, Transf(Val(aNotaF[16]),"@E 999999.999"))
	else
		AAdd(aTransp,"")
	endif

	AAdd(aISSQN,"")
	AAdd(aISSQN,"")
	AAdd(aISSQN,"")
	AAdd(aISSQN,"")

	//======================================================================
	// CÁLCULO FISCAL SIMULADO — MaFisIni / MaFisAdd / MaFisRet / MaFisEnd
	//======================================================================

	// Garante posicionamento correto nas tabelas usadas pelo MaFis*
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(MsSeek(xFilial("SC5")+cPedVen,.F.))
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	//-- Inicializa engine fiscal com dados do cabeçalho do pedido ----------
	MaFisIni(;
		SC5->C5_CLIENTE,;                           // 01 - Código do cliente
	SC5->C5_LOJACLI,;                           // 02 - Loja do cliente
	IIf(SC5->C5_TIPO $ "D;B","F","C"),;         // 03 - C=Cliente / F=Fornecedor
	SC5->C5_TIPO,;                              // 04 - Tipo da NF
	SC5->C5_TIPOCLI,;                           // 05 - Tipo do cliente
	MaFisRelImp("MT100",{"SF2","SD2"}),;        // 06 - Relação de impostos suportados
	,;                                          // 07 - Tipo de complemento (padrão)
	,;                                          // 08 - Permite impostos no rodapé (padrão)
	"SB1",;                                     // 09 - Alias do cadastro de produtos
	"MATA461";                                  // 10 - Nome da rotina
	)

	//-- Primeira passagem: adiciona itens à engine fiscal ------------------
	SC6->(MsSeek(xFilial("SC6")+cPedVen,.F.))
	aAreaBkp := SC6->(GetArea())
	nItAtu   := 0

	while !SC6->(Eof()) .and. SC6->C6_NUM == cPedVen
		nItAtu++
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))

		MaFisAdd(;
			SC6->C6_PRODUTO,;    // 01 - Código do produto         (obrigatório)
		SC6->C6_TES,;        // 02 - Código do TES             (obrigatório)
		SC6->C6_QTDVEN,;     // 03 - Quantidade                (obrigatório)
		SC6->C6_PRCVEN,;     // 04 - Preço unitário            (obrigatório)
		SC6->C6_VALDESC,;    // 05 - Desconto do item
		SC6->C6_NFORI,;      // 06 - NF original (devolução)
		SC6->C6_SERIORI,;    // 07 - Série NF original
		0,;                  // 08 - RecNo NF original SD1/SD2
		0,;                  // 09 - Valor frete do item
		0,;                  // 10 - Valor despesa do item
		0,;                  // 11 - Valor seguro do item
		0,;                  // 12 - Valor frete autônomo
		SC6->C6_VALOR,;      // 13 - Valor da mercadoria       (obrigatório)
		0,;                  // 14 - Valor da embalagem
		SB1->(RecNo()),;     // 15 - RecNo do SB1
		0;                   // 16 - RecNo do SF4
		)

		// Informa o valor da mercadoria à engine
		MaFisLoad("IT_VALMERC", SC6->C6_VALOR, nItAtu)

		SC6->(DbSkip())
	enddo

	//-- Aplica totais do cabeçalho (frete, seguro, desconto, despesa) ------
	MaFisAlt("NF_FRETE",    SC5->C5_FRETE)
	MaFisAlt("NF_SEGURO",   SC5->C5_SEGURO)
	MaFisAlt("NF_DESPESA",  SC5->C5_DESPESA)
	MaFisAlt("NF_AUTONOMO", SC5->C5_FRETAUT)

	if SC5->C5_DESCONT > 0
		MaFisAlt("NF_DESCONTO", Min(MaFisRet(,"NF_VALMERC") - 0.01, SC5->C5_DESCONT + MaFisRet(,"NF_DESCONTO")))
	endif
	if SC5->C5_PDESCAB > 0
		MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(,"NF_VALMERC") * SC5->C5_PDESCAB / 100, "C6_VALOR") + MaFisRet(,"NF_DESCONTO"))
	endif

	//-- Segunda passagem: coleta impostos por item ANTES de MaFisEnd() ----
	// IMPORTANTE: MaFisRet() só funciona antes de MaFisEnd().
	// Aqui salvamos todos os valores por item em aImpostoItem.
	RestArea(aAreaBkp)
	nItAtu := 0

	while !SC6->(Eof()) .and. SC6->C6_NUM == cPedVen
		nItAtu++

		AAdd(aImpostoItem,{;
		MaFisRet(nItAtu,"IT_BASEICM"),;   // [1] Base ICMS
		MaFisRet(nItAtu,"IT_VALICM"),;    // [2] Valor ICMS
		MaFisRet(nItAtu,"IT_VALIPI"),;    // [3] Valor IPI
		MaFisRet(nItAtu,"IT_ALIQICM"),;   // [4] Alíquota ICMS
		MaFisRet(nItAtu,"IT_ALIQIPI"),;   // [5] Alíquota IPI
		MaFisRet(nItAtu,"IT_PIS252"),;    // [6] Valor PIS
		MaFisRet(nItAtu,"IT_COF252")})    // [7] Valor COFINS

		// Acumula totalizadores	
		nTotBaseICM += MaFisRet(nItAtu,"IT_BASEICM")
		nTotValICM  += MaFisRet(nItAtu,"IT_VALICM")
		nTotBaseST  += MaFisRet(nItAtu,"IT_BASESOL")
		nTotValST   += MaFisRet(nItAtu,"IT_VALSOL")
		nTotIPI     += MaFisRet(nItAtu,"IT_VALIPI")
		nTotPIS     += MaFisRet(nItAtu,"IT_PIS252")
		nTotCOFINS  += MaFisRet(nItAtu,"IT_COF252")
		nTotNota    += SC6->C6_VALOR

		SC6->(DbSkip())
	enddo

	// Totais do documento
	nTotFrete := MaFisRet(,"NF_FRETE")
	nTotGeral := MaFisRet(,"NF_TOTAL")

	// Encerra a engine fiscal — após isso MaFisRet() não funciona mais
	MaFisEnd()

	//-- Preenche aTotais com os valores simulados --------------------------
	aTotais[01] := Transf(nTotBaseICM,"@E 9,999,999,999,999.99")  // BASE ICMS
	aTotais[02] := Transf(nTotValICM, "@E 9,999,999,999,999.99")  // VALOR ICMS
	aTotais[03] := Transf(nTotBaseST, "@E 9,999,999,999,999.99")  // BASE ICMS ST
	aTotais[04] := Transf(nTotValST,  "@E 9,999,999,999,999.99")  // VALOR ICMS ST
	aTotais[05] := Transf(nTotNota,   "@E 9,999,999,999,999.99")  // VALOR MERCADORIA
	aTotais[06] := Transf(nTotFrete,  "@E 9,999,999,999,999.99")  // FRETE
	aTotais[07] := Transf(SC5->C5_SEGURO,  "@E 9,999,999,999,999.99")  // SEGURO
	aTotais[08] := Transf(SC5->C5_DESCONT, "@E 9,999,999,999,999.99")  // DESCONTO
	aTotais[09] := Transf(SC5->C5_DESPESA, "@E 9,999,999,999,999.99")  // OUTRAS DESPESAS
	aTotais[10] := Transf(nTotPIS,    "@E 9,999,999,999,999.99")  // VALOR PIS
	aTotais[11] := Transf(nTotCOFINS, "@E 9,999,999,999,999.99")  // VALOR COFINS
	aTotais[12] := Transf(nTotIPI,    "@E 9,999,999,999,999.99")  // VALOR IPI
	aTotais[13] := Transf(nTotGeral,  "@E 9,999,999,999,999.99")  // VALOR TOTAL

	//======================================================================
	// FIM DO CÁLCULO FISCAL
	//======================================================================

	//----------------------------------------------------------------------
	// Monta aItens (terceira passagem na SC6) usando aImpostoItem
	//----------------------------------------------------------------------
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6")+cPedVen,.F.))

	nItem  := 0
	nItAtu := 0

	while !SC6->(Eof()) .and. SC6->C6_NUM == cPedVen
		nItAtu++
		cDescri := AllTrim(SC6->C6_DESCRI)
		cNcm    := IIf(SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)),AllTrim(SB1->B1_POSIPI),"")
		cTes    := SC6->C6_TES

		if (nInd := AScan(aTes,{|x| x[1] == cTes})) == 0
			AAdd(aTes,{cTes,IIf(SF4->(MsSeek(xFilial("SF4")+cTes,.F.)),AllTrim(SF4->F4_TEXTO),""),AllTrim(SC6->C6_CF)})
			aNotaF[10] := AllTrim(SF4->F4_TEXTO)+"/"
		endif

		// Recupera impostos calculados pelo MaFis* para este item
		// aImpostoItem[nItAtu] = {baseICM,valICM,valIPI,alqICM,alqIPI,valPIS,valCOF}
		AAdd(aItens,{;
			Left(SC6->C6_PRODUTO,6),;                                                            // [01] Código
		MemoLine(cDescri,MAXITEMC,1),;                                                        // [02] Descrição linha 1
		cNcm,;                                                                                // [03] NCM
		SC6->C6_CLASFIS,;                                                                     // [04] CST
		SC6->C6_CF,;                                                                          // [05] CFOP
		SC6->C6_UM,;                                                                          // [06] Unidade
		AllTrim(Transf(SC6->C6_QTDVEN,PesqPict("SC6","C6_QTDVEN"))),;                       // [07] Quantidade
		AllTrim(Transf(SC6->C6_PRCVEN,PesqPict("SC6","C6_PRCVEN"))),;                       // [08] Valor Unitário
		AllTrim(Transf(SC6->C6_VALOR, PesqPict("SC6","C6_VALOR"))),;                        // [09] Valor Total
		AllTrim(Transf(aImpostoItem[nItAtu][1],PesqPict("SC6","C6_VALOR"))),;               // [10] Base ICMS
		AllTrim(Transf(aImpostoItem[nItAtu][2],PesqPict("SC6","C6_VALOR"))),;               // [11] Valor ICMS
		AllTrim(Transf(aImpostoItem[nItAtu][3],PesqPict("SC6","C6_VALOR"))),;               // [12] Valor IPI
		AllTrim(Transf(aImpostoItem[nItAtu][4],"@E 99.99%")),;                              // [13] Alíquota ICMS
		AllTrim(Transf(aImpostoItem[nItAtu][5],"@E 99.99%")),;                              // [14] Alíquota IPI
		AllTrim(Transf(aImpostoItem[nItAtu][6],PesqPict("SC6","C6_VALOR"))),;               // [15] Valor PIS
		AllTrim(Transf(aImpostoItem[nItAtu][7],PesqPict("SC6","C6_VALOR")))})               // [16] Valor COFINS

		nItem++

		// Linhas de continuação da descrição (quebra de texto)
		if MLCount(cDescri,MAXITEMC) > 1
			for k := 2 to MLCount(cDescri,MAXITEMC)
				AAdd(aItens,{"",MemoLine(cDescri,MAXITEMC,k),"","","","","","","","","","","","","",""})
				nItem++
			next
		endif

		SC6->(DbSkip())
	enddo

	//----------------------------------------------------------------------
	// Cálculo do número de folhas
	//----------------------------------------------------------------------
	nItem -= MAXITEM
	lFlag := .T.

	while lFlag
		if nItem > 0
			nFolhas++
			nItem -= MAXITEMP2
		else
			lFlag := .F.
		endif
	enddo

	cProjetos := "Projeto(s): "+Projetos(aNotaF[2],"",Left(aNotaF[4],6),Right(aNotaF[4],2),"SC6")
	cMensagem := aNotaF[17]
	cResFisco := ""
return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRESSAO DA PRE-DANFE                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function PreDanfeProc(cModNF)

	local lConverte := GetNewPar("MV_CONVERT",.F.)

	private nLinCalc := 0
	private nFolImp := IIf(!Empty(aTabImposto),1,0)

	oPrinter:StartPage()
	Cabecalho(42,.T.)

	oPrinter:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N)
	oPrinter:Line(197,000,197,500,ESPLIN)
	oPrinter:Line(197,000,257,000,ESPLIN)
	oPrinter:Line(197,500,257,500,ESPLIN)
	oPrinter:Line(257,000,257,500,ESPLIN)
	oPrinter:Say(205,002,"NOME/RAZÃO SOCIAL",oFont08N)
	oPrinter:Say(215,002,aDestinat[2],oFont08)
	oPrinter:Line(197,280,217,280,ESPLIN)

	do case
	case aDestinat[1] == "J"
		cAux := Transf(aDestinat[3],"@R 99.999.999/9999-99")
	case aDestinat[1] == "F"
		cAux := Transf(aDestinat[3],"@R 999.999.999-99")
	otherwise
		cAux := Space(14)
	endcase

	oPrinter:Say(205,283,"CNPJ/CPF",oFont08N)
	oPrinter:Say(215,283,cAux,oFont08)
	oPrinter:Line(217,000,217,500,ESPLIN)
	oPrinter:Say(224,002,"ENDEREÇO",oFont08N)
	oPrinter:Say(234,002,aDestinat[4],oFont08)
	oPrinter:Line(217,230,237,230,ESPLIN)
	oPrinter:Say(224,232,"BAIRRO/DISTRITO",oFont08N)
	oPrinter:Say(234,232,aDestinat[5],oFont08)
	oPrinter:Line(217,380,237,380,ESPLIN)
	oPrinter:Say(224,382,"CEP",oFont08N)
	oPrinter:Say(234,382,aDestinat[6],oFont08)
	oPrinter:Line(237,000,237,500,ESPLIN)
	oPrinter:Say(245,002,"MUNICIPIO",oFont08N)
	oPrinter:Say(255,002,aDestinat[7],oFont08)
	oPrinter:Line(237,150,257,150,ESPLIN)
	oPrinter:Say(245,152,"FONE/FAX",oFont08N)
	oPrinter:Say(255,152,aDestinat[8],oFont08)
	oPrinter:Line(237,255,257,255,ESPLIN)
	oPrinter:Say(245,257,"UF",oFont08N)
	oPrinter:Say(255,257,aDestinat[9],oFont08)
	oPrinter:Line(237,340,257,340,ESPLIN)
	oPrinter:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N)
	oPrinter:Say(255,342,aDestinat[10],oFont08)

	oPrinter:Line(197,502,197,603,ESPLIN)
	oPrinter:Line(197,502,257,502,ESPLIN)
	oPrinter:Line(197,603,257,603,ESPLIN)
	oPrinter:Line(257,502,257,603,ESPLIN)
	oPrinter:Say(205,504,"DATA DE EMISSÃO",oFont08N)
	oPrinter:Say(215,504,U_ConvData(aNotaF[6]),oFont08)
	oPrinter:Line(217,502,217,603,ESPLIN)
	oPrinter:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N)
	oPrinter:Say(233,504,U_ConvData(aNotaF[7]),oFont08)
	oPrinter:Line(237,502,237,603,ESPLIN)
	oPrinter:Say(245,505,"HORA ENTRADA/SAÍDA",oFont08N)
	oPrinter:Say(255,505,aNotaF[8],oFont08)

	oPrinter:Say(263,002,"FATURA",oFont08N)
	oPrinter:Line(265,000,265,603,ESPLIN)
	oPrinter:Line(265,000,296,000,ESPLIN)

	nCol := 067

	for i := 1 to 8
		oPrinter:Line(265,nCol,296,nCol,ESPLIN)
		nCol += 67
	next i

	oPrinter:Line(265,603,296,603,ESPLIN)
	oPrinter:Line(296,000,296,603,ESPLIN)

	nColuna := 002

	if Len(aFaturas) > 0
		for n := 1 to Len(aFaturas)
			oPrinter:Say(273,nColuna,aFaturas[n][1]+" "+aFaturas[n][2],oFont08)
			oPrinter:Say(281,nColuna,aFaturas[n][3],oFont08)
			oPrinter:Say(289,nColuna,aFaturas[n][4],oFont08)
			nColuna += 67
		next n
	endif

	oPrinter:Say(305,002,"CALCULO DO IMPOSTO",oFont08N)
	oPrinter:Line(307,000,307,603,ESPLIN)
	oPrinter:Line(307,000,353,000,ESPLIN)
	oPrinter:Line(307,603,353,603,ESPLIN)
	oPrinter:Line(353,000,353,603,ESPLIN)
	oPrinter:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N)
	oPrinter:Say(326,002,aTotais[1],oFont08)
	oPrinter:Line(307,120,330,120,ESPLIN)
	oPrinter:Say(316,125,"VALOR DO ICMS",oFont08N)
	oPrinter:Say(326,125,aTotais[2],oFont08)
	oPrinter:Line(307,199,330,199,ESPLIN)
	oPrinter:Say(316,201,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N)
	oPrinter:Say(326,202,aTotais[3],oFont08)
	oPrinter:Line(307,360,330,360,ESPLIN)
	oPrinter:Say(316,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N)
	oPrinter:Say(326,363,aTotais[4],oFont08)
	oPrinter:Line(307,490,330,490,ESPLIN)
	oPrinter:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N)
	oPrinter:Say(327,491,aTotais[5],oFont08)
	oPrinter:Line(330,000,330,603,ESPLIN)
	oPrinter:Say(339,002,"VALOR DO FRETE",oFont08N)
	oPrinter:Say(349,002,aTotais[6],oFont08)
	oPrinter:Line(330,075,353,075,ESPLIN)
	oPrinter:Say(339,077,"VALOR DO SEGURO",oFont08N)
	oPrinter:Say(349,077,aTotais[7],oFont08)
	oPrinter:Line(330,150,353,150,ESPLIN)
	oPrinter:Say(339,152,"DESCONTO",oFont08N)
	oPrinter:Say(349,152,aTotais[8],oFont08)
	oPrinter:Line(330,210,353,210,ESPLIN)
	oPrinter:Say(339,212,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N)
	oPrinter:Say(349,212,aTotais[9],oFont08)
	oPrinter:Line(330,330,353,330,ESPLIN)
	oPrinter:Say(339,332,"VALOR DO PIS",oFont08N)
	oPrinter:Say(349,332,aTotais[10],oFont08)
	oPrinter:Line(330,390,353,390,ESPLIN)
	oPrinter:Say(339,392,"VALOR DO COFINS",oFont08N)
	oPrinter:Say(349,392,aTotais[11],oFont08)
	oPrinter:Line(330,455,353,455,ESPLIN)
	oPrinter:Say(339,457,"VALOR DO IPI",oFont08N)
	oPrinter:Say(349,457,aTotais[12],oFont08)
	oPrinter:Line(330,510,353,510,ESPLIN)
	oPrinter:Say(339,512,"VALOR TOTAL DA NOTA",oFont08N)
	oPrinter:Say(349,512,aTotais[13],oFont08)

	oPrinter:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N)
	oPrinter:Line(363,000,363,603,ESPLIN)
	oPrinter:Line(363,000,432,000,ESPLIN)
	oPrinter:Line(363,603,432,603,ESPLIN)
	oPrinter:Line(432,000,432,603,ESPLIN)
	oPrinter:Say(372,002,"RAZÃO SOCIAL",oFont08N)
	oPrinter:Say(382,002,aTransp[1],oFont08)
	oPrinter:Line(363,245,385,245,ESPLIN)
	oPrinter:Say(372,247,"FRETE POR CONTA",oFont08N)

	if aTransp[7] == "0"
		oPrinter:Say(382,247,"0-EMITENTE",oFont08)
	elseif aTransp[7] == "1"
		oPrinter:Say(382,247,"1-DESTINATARIO",oFont08)
	elseif aTransp[7] == "2"
		oPrinter:Say(382,247,"2-TERCEIROS",oFont08)
	elseif aTransp[7] == "9"
		oPrinter:Say(382,247,"9-SEM FRETE",oFont08)
	else
		oPrinter:Say(382,247,"",oFont08)
	endif

	oPrinter:Line(363,315,385,315,ESPLIN)
	oPrinter:Say(372,317,"CÓDIGO ANTT",oFont08N)
	oPrinter:Say(382,319,aTransp[8],oFont08)
	oPrinter:Line(363,370,385,370,ESPLIN)
	oPrinter:Say(372,375,"PLACA DO VEÍCULO",oFont08N)
	oPrinter:Say(382,375,IIf(Empty(aTransp[1]),"",aTransp[9]),oFont08)
	oPrinter:Line(363,450,385,450,ESPLIN)
	oPrinter:Say(372,452,"UF",oFont08N)
	oPrinter:Say(382,452,IIf(Empty(aTransp[1]),"",aTransp[10]),oFont08)
	oPrinter:Line(363,510,385,510,ESPLIN)
	oPrinter:Say(372,512,"CNPJ/CPF",oFont08N)
	oPrinter:Say(382,512,aTransp[2],oFont08)
	oPrinter:Line(385,000,385,603,ESPLIN)
	oPrinter:Say(393,002,"ENDEREÇO",oFont08N)
	oPrinter:Say(404,002,aTransp[3],oFont08)
	oPrinter:Line(385,240,408,240,ESPLIN)
	oPrinter:Say(393,242,"MUNICIPIO",oFont08N)
	oPrinter:Say(404,242,aTransp[4],oFont08)
	oPrinter:Line(385,340,408,340,ESPLIN)
	oPrinter:Say(393,342,"UF",oFont08N)
	oPrinter:Say(404,342,aTransp[5],oFont08)
	oPrinter:Line(385,440,408,440,ESPLIN)
	oPrinter:Say(393,442,"INSCRIÇÃO ESTADUAL",oFont08N)
	oPrinter:Say(404,442,aTransp[6],oFont08)
	oPrinter:Line(408,000,408,603,ESPLIN)
	oPrinter:Say(418,002,"QUANTIDADE",oFont08N)
	oPrinter:Say(428,002,aTransp[11],oFont08)
	oPrinter:Line(408,100,432,100,ESPLIN)
	oPrinter:Say(418,102,"ESPECIE",oFont08N)
	oPrinter:Say(428,102,aTransp[12],oFont08)
	oPrinter:Line(408,200,432,200,ESPLIN)
	oPrinter:Say(418,202,"MARCA",oFont08N)
	oPrinter:Say(428,202,aTransp[13],oFont08)
	oPrinter:Line(408,300,432,300,ESPLIN)
	oPrinter:Say(418,302,"NUMERAÇÃO",oFont08N)
	oPrinter:Say(428,302,aTransp[14],oFont08)
	oPrinter:Line(408,400,432,400,ESPLIN)
	oPrinter:Say(418,402,"PESO BRUTO",oFont08N)
	oPrinter:Say(428,402,aTransp[15],oFont08)
	oPrinter:Line(408,500,432,500,ESPLIN)
	oPrinter:Say(418,502,"PESO LIQUIDO",oFont08N)
	oPrinter:Say(428,502,aTransp[16],oFont08)

	oPrinter:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N)
	oPrinter:Line(442,000,442,603,ESPLIN)
	oPrinter:Line(442,000,678,000,ESPLIN)
	oPrinter:Line(442,603,678,603,ESPLIN)
	oPrinter:Line(678,000,678,603,ESPLIN)

	aAuxCabec := {"COD. PROD","DESCRIÇÃO DO PROD./SERV.","NCM/SH","CST","CFOP","UN","QUANT.","V.UNITARIO","V.TOTAL","BC.ICMS","V.ICMS","V.IPI","A.ICMS","A.IPI"}

	aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
	nY := 0
	nLenItens := Len(aItens)

	for nX := 1 to nLenItens
		AAdd(ATail(aAux)[01],aItens[nX][01])
		AAdd(ATail(aAux)[02],NoChar(aItens[nX][02],lConverte))
		AAdd(ATail(aAux)[03],aItens[nX][03])
		AAdd(ATail(aAux)[04],aItens[nX][04])
		AAdd(ATail(aAux)[05],aItens[nX][05])
		AAdd(ATail(aAux)[06],aItens[nX][06])
		AAdd(ATail(aAux)[07],aItens[nX][07])
		AAdd(ATail(aAux)[08],aItens[nX][08])
		AAdd(ATail(aAux)[09],aItens[nX][09])
		AAdd(ATail(aAux)[10],aItens[nX][10])
		AAdd(ATail(aAux)[11],aItens[nX][11])
		AAdd(ATail(aAux)[12],aItens[nX][12])
		AAdd(ATail(aAux)[13],aItens[nX][13])
		AAdd(ATail(aAux)[14],aItens[nX][14])
	next nX

	for nK := 1 to nLenItens
		AAdd(ATail(aAux)[01],"")
		AAdd(ATail(aAux)[02],"")
		AAdd(ATail(aAux)[03],"")
		AAdd(ATail(aAux)[04],"")
		AAdd(ATail(aAux)[05],"")
		AAdd(ATail(aAux)[06],"")
		AAdd(ATail(aAux)[07],"")
		AAdd(ATail(aAux)[08],"")
		AAdd(ATail(aAux)[09],"")
		AAdd(ATail(aAux)[10],"")
		AAdd(ATail(aAux)[11],"")
		AAdd(ATail(aAux)[12],"")
		AAdd(ATail(aAux)[13],"")
		AAdd(ATail(aAux)[14],"")
	next nK

	aTamCol := RetTamCol(aAuxCabec,aAux,oPrinter,oFont08,oFont08N)

	nAuxH := 0

	for nK := 1 to Len(aAuxCabec)
		oPrinter:Line(442,nAuxH,678,nAuxH,2)
		oPrinter:Say(450,nAuxH + 2,aAuxCabec[nK],oFont08N)
		nAuxH += aTamCol[nK]
	next nK

	nLinha := 460
	nK     := 1

	while nK <= Len(aItens) .and. nK <= MAXITEM
		nAuxH     := 0
		aDescLin  := {}
		nAltLinha := 10

		if !Empty(AllTrim(aItens[nK][2]))
			aDescLin := ImpQuebraTexto(AllTrim(aItens[nK][2]), aTamCol[2] - 4, oPrinter, oFont08)
		else
			AAdd(aDescLin, "")
		endif

		nAltLinha := 10 * Len(aDescLin)

		nAuxH := 0
		for nJ := 1 to 14
			if nJ != 2
				oPrinter:Say(nLinha + 2, nAuxH + 2, aItens[nK][nJ], oFont08)
			endif
			nAuxH += aTamCol[nJ]
		next nJ

		nColDesc := aTamCol[1]
		for nLinDesc := 1 to Len(aDescLin)
			oPrinter:Say(nLinha + 2 + ((nLinDesc - 1) * 10), nColDesc + 2, aDescLin[nLinDesc], oFont08)
		next nLinDesc

		nLinha += nAltLinha
		nK++
	enddo

	oPrinter:Say(686,000,"CALCULO DO ISSQN",oFont08N)
	oPrinter:Line(688,000,688,603,ESPLIN)
	oPrinter:Line(688,000,711,000,ESPLIN)
	oPrinter:Line(688,603,711,603,ESPLIN)
	oPrinter:Line(711,000,711,603,ESPLIN)
	oPrinter:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N)
	oPrinter:Say(706,002,aISSQN[1],oFont08)
	oPrinter:Line(688,150,711,150,ESPLIN)
	oPrinter:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N)
	oPrinter:Say(706,152,aISSQN[2],oFont08)
	oPrinter:Line(688,300,711,300,ESPLIN)
	oPrinter:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N)
	oPrinter:Say(706,302,aISSQN[3],oFont08)
	oPrinter:Line(688,450,711,450,ESPLIN)
	oPrinter:Say(696,452,"VALOR DO ISSQN",oFont08N)
	oPrinter:Say(706,452,aISSQN[4],oFont08)

	oPrinter:Say(719,000,"DADOS ADICIONAIS",oFont08N)
	oPrinter:Line(721,000,721,603,ESPLIN)
	oPrinter:Line(721,000,865,000,ESPLIN)
	oPrinter:Line(721,603,865,603,ESPLIN)
	oPrinter:Line(865,000,865,603,ESPLIN)
	oPrinter:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N)

	nLin := 741

	oPrinter:Say(nLin,002,MemoLine(cMensagem,MAXMSG,1),oFont08)
	nLin := nLin + 10

	if MLCount(cMensagem,MAXMSG) > 1
		for k := 2 to MLCount(cMensagem,MAXMSG)
			oPrinter:Say(nLin,002,MemoLine(cMensagem,MAXMSG,k),oFont08)
			nLin := nLin + 10
		next
	endif

	oPrinter:Line(721,350,865,350,ESPLIN)
	oPrinter:Say(729,352,"RESERVADO AO FISCO",oFont08N)

	nLin := 741

	oPrinter:Say(nLin,351,MemoLine(cResFisco,MAXMSG,1),oFont08)
	nLin := nLin + 10

	if MLCount(cResFisco,MAXMSG) > 1
		for k := 2 to MLCount(cResFisco,MAXMSG)
			oPrinter:Say(nLin,351,MemoLine(cResFisco,MAXMSG,k),oFont08)
			nLin := nLin + 10
		next
	endif

	oPrinter:EndPage()

	nFolha := 2
	nItens := MAXITEM + 1

	while nFolha <= nFolhas
		oPrinter:StartPage()
		Cabecalho(0,.F.)

		oPrinter:Say(161,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N)
		oPrinter:Line(163,000,163,603,ESPLIN)
		oPrinter:Line(163,000,865,000,ESPLIN)
		oPrinter:Line(163,603,865,603,ESPLIN)
		oPrinter:Line(865,000,865,603,ESPLIN)

		nAuxH := 0

		for nK := 1 to Len(aAuxCabec)
			oPrinter:Line(163,nAuxH,865,nAuxH,2)
			oPrinter:Say(171,nAuxH + 2,aAuxCabec[nK],oFont08N)
			nAuxH += aTamCol[nK]
		next nK

		nLinha := 181

		while nItens <= Len(aItens) .and. nItens <= (MAXITEM + ((nFolha - 1) * MAXITEMP2))
			nAuxH     := 0
			aDescLin  := {}
			nAltLinha := 10

			if !Empty(AllTrim(aItens[nItens][2]))
				aDescLin := ImpQuebraTexto(AllTrim(aItens[nItens][2]), aTamCol[2] - 4, oPrinter, oFont08)
			else
				AAdd(aDescLin, "")
			endif

			nAltLinha := 10 * Len(aDescLin)

			nAuxH := 0
			for nJ := 1 to 14
				if nJ != 2
					oPrinter:Say(nLinha + 2, nAuxH + 2, aItens[nItens][nJ], oFont08)
				endif
				nAuxH += aTamCol[nJ]
			next nJ

			nColDesc := aTamCol[1]
			for nLinDesc := 1 to Len(aDescLin)
				oPrinter:Say(nLinha + 2 + ((nLinDesc - 1) * 10), nColDesc + 2, aDescLin[nLinDesc], oFont08)
			next nLinDesc

			nLinha += nAltLinha
			nItens++
		enddo

		nFolha++
		oPrinter:EndPage()
	enddo

	ASort(aTabImposto,,,{|x,y| x[1] < y[1]})

	if Len(aTabImposto) > 0
		oPrinter:StartPage()
		Cabecalho(0,.F.)

		oPrinter:Say(161,002,"TABELA DE IMPOSTOS",oFont08N)
		oPrinter:Line(163,000,163,603,ESPLIN)
		oPrinter:Line(163,000,865,000,ESPLIN)
		oPrinter:Line(163,603,865,603,ESPLIN)
		oPrinter:Line(865,000,865,603,ESPLIN)
		oPrinter:Say(171,002,"IMPOSTO",oFont08N)
		oPrinter:Say(171,160,"ALIQUOTA",oFont08N)
		oPrinter:Say(171,270,"BASE CALCULO",oFont08N)
		oPrinter:Say(171,380,"VALOR IMPOSTO",oFont08N)

		nLinha := 181
		nTotal := 0

		for nI := 1 to Len(aTabImposto)
			oPrinter:Say(nLinha,002,aTabImposto[nI][1],oFont08)
			oPrinter:Say(nLinha,025,U_MPREDANF(Left(aTabImposto[nI][1],3)),oFont08)
			oPrinter:Say(nLinha,160,AllTrim(aTabImposto[nI][2]),oFont08)
			oPrinter:Say(nLinha,270,AllTrim(aTabImposto[nI][3]),oFont08)
			oPrinter:Say(nLinha,380,AllTrim(aTabImposto[nI][4]),oFont08)

			nTotal += aTabImposto[nI][5]
			nLinha += 10
		next nI

		oPrinter:Line(nLinha,370,nLinha,450,2)
		oPrinter:Say(nLinha + 10,380,AllTrim(Transf(nTotal,"@E 999,999,999,999.99")),oFont19N)

		oPrinter:EndPage()
	endif
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RETORNA OS PROJETOS UTILIZADO                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function Projetos(cNota,cSerie,cCliFor,cLoja,cTab)
	local cQry := ""
	local cProj := ""
	local cCampo := ""

	do case
	case cTab == "SF2"
		cQry := "select distinct C6_CLVL from "+RetSqlName("SC6")+" where C6_NOTA = '"+cNota+"' and C6_SERIE = '"+cSerie+"' and C6_CLI = '"+cCliFor+"' and C6_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*'"
		cCampo := "C6_CLVL"
	case cTab == "SF1"
		cQry := "select distinct D1_CLVL from "+RetSqlName("SD1")+" where D1_DOC = '"+cNota+"' and D1_SERIE = '"+cSerie+"' and D1_FORNECE = '"+cCliFor+"' and D1_LOJA = '"+cLoja+"' and D_E_L_E_T_ <> '*'"
		cCampo := "D1_CLVL"
	case cTab == "SC6"
		cQry := "select distinct C6_CLVL from "+RetSqlName("SC6")+" where C6_NUM = '"+cNota+"' and D_E_L_E_T_ <> '*'"
		cCampo := "C6_CLVL"
	endcase

	tcquery cQry new alias "TMP"
	DbSelectArea("TMP")

	while !TMP->(Eof())
		if AllTrim(TMP->&(cCampo)) <> "000000000"
			cProj += AllTrim(TMP->&(cCampo))+" / "
		endif

		TMP->(DbSkip())
	enddo

	TMP->(DbCloseArea())
return (SubStr(cProj,1,Len(cProj) - 3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RETORNA OS IMPOSTOS UTILIZADO                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function TabImpostos(cModNF)
	if cModNF == "1"
		cCondicao := "and CD2_CODCLI = '"+Left(aNotaF[4],6)+"' and CD2_LOJCLI = '"+Right(aNotaF[4],2)+"' "
	else
		cCondicao := "and CD2_CODFOR = '"+Left(aNotaF[4],6)+"' and CD2_LOJFOR = '"+Right(aNotaF[4],2)+"' "
	endif

	if Select("QRY") <> 0
		QRY->(DbCloseArea())
	endif

	cQry := "select CD2_IMP, CD2_ALIQ, sum(CD2_BC) as CD2_BC, sum(CD2_VLTRIB) as CD2_VLTRIB "
	cQry += "from "+RetSqlName("CD2")+" "
	cQry += "where CD2_TPMOV = '"+IIf(cModNF == "1","S","E")+"' and CD2_DOC = '"+aNotaF[2]+"' and CD2_SERIE = '"+aNotaF[3]+"' "+cCondicao+"and D_E_L_E_T_ <> '*' "
	cQry += "group by CD2_IMP, CD2_ALIQ "
	cQry += "order by CD2_IMP, CD2_ALIQ"

	tcquery cQry new alias "QRY"

	DbSelectArea("QRY")
	QRY->(DbGoTop())

	while !QRY->(Eof())
		AAdd(aTabImposto,{QRY->CD2_IMP,Transf(QRY->CD2_ALIQ,"@E 99.99")+"%",Transf(QRY->CD2_BC,"@E 999,999,999,999.99"),Transf(QRY->CD2_VLTRIB,"@E 999,999,999,999.99"),QRY->CD2_VLTRIB,QRY->CD2_BC})

		QRY->(DbSkip())
	enddo
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONVERTER CARACTERES ESPECIAIS                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function NoChar(cString,lConverte)
	default lConverte := .F.

	if lConverte
		cString := (StrTran(cString,"&lt;","<"))
		cString := (StrTran(cString,"&gt;",">"))
		cString := (StrTran(cString,"&amp;","&"))
		cString := (StrTran(cString,"&quot;",'"'))
		cString := (StrTran(cString,"&#39;","'"))
	endif
return cString

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QUEBRAR TEXTO EM LINHAS                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function QbraTexto(cStrAux,nTam,oFont)
	nForTo := Len(cStrAux) / nTam
	nForTo += IIf(nForTo > Round(nForTo,0),Round(nForTo,0) + 1 - nForTo,nForTo)

	for nX := 1 to nForTo
		oPrinter:Say(nLinCalc,098,SubStr(cStrAux,IIf(nX == 1,1,((nX - 1) * nTam) + 1),nTam),oFont)

		nLinCalc += 10
	next nX
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CALCULA TAMANHO DE CADA COLUNA DOS ITENS                               ³
//³                                                                        ³
//³ Colunas (14 no total, total disponível = 603 pts):                     ³
//³  [01] COD.PROD   [02] DESCRIÇÃO  [03] NCM/SH   [04] CST               ³
//³  [05] CFOP       [06] UN         [07] QUANT.    [08] V.UNITARIO        ³
//³  [09] V.TOTAL    [10] BC.ICMS    [11] V.ICMS    [12] V.IPI             ³
//³  [13] A.ICMS     [14] A.IPI                                            ³
//³                                                                        ³
//³ Estratégia:                                                            ³
//³  - Colunas fixas recebem tamanho mínimo justo para o conteúdo          ³
//³  - Coluna DESCRIÇÃO (col 2) recebe toda a sobra (mín 80 garantido)     ³
//³  - Ajuste dinâmico: cada coluna cresce até o MAX conforme conteúdo     ³
//³  - Ao crescer uma coluna fixa, desconta da DESCRIÇÃO                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function RetTamCol(aCabec, aValores, oPrinter, oFontCabec, oFont)
	local aTamCol := {}
	local aTamMin := {}
	local aTamMax := {}
	local nAux    := 0
	local nX      := 0
	local nY      := 0
	local nTxtW   := 0
	local nTotal  := 0
	local nSobra  := 0

	// -----------------------------------------------------------------
	// Mínimos por coluna — soma exata de 603 (descrição recebe a sobra)
	// Col:  01   02    03   04   05   06   07   08   09   10   11   12   13   14
	aTamMin := { 32,  221,  38,  18,  22,  14,  30,  38,  38,  36,  32,  30,  28,  26 }

	// Máximos por coluna — limita o crescimento dinâmico de cada coluna
	// A descrição (col 2) recebe o que sobrar (mín 80 garantido)
	// Col:  01   02   03   04   05   06   07   08   09   10   11   12   13   14
	aTamMax := { 45,   0,  50,  24,  30,  20,  42,  50,  50,  48,  44,  42,  36,  34 }

	// Inicializa todas as colunas com seus mínimos
	for nX := 1 to Len(aCabec)
		AAdd(aTamCol, aTamMin[nX])
	next nX

	// -----------------------------------------------------------------
	// Ajuste dinâmico: mede o conteúdo real de cada coluna fixa
	// e expande até o MAX se necessário
	// (Descrição col 2 é ignorada aqui — ela recebe a sobra no final)
	// -----------------------------------------------------------------
	for nX := 1 to Len(aValores[1])
		if nX == 2
			loop  // descrição calculada depois
		endif

		nAux := aTamMin[nX]

		// Mede o cabeçalho da coluna
		nTxtW := oPrinter:GetTextWidth(aCabec[nX], oFontCabec) + 6
		if nTxtW > nAux
			nAux := nTxtW
		endif

		// Mede cada valor de conteúdo da coluna
		for nY := 1 to Len(aValores[1][nX])
			if !Empty(AllTrim(aValores[1][nX][nY]))
				nTxtW := oPrinter:GetTextWidth(AllTrim(aValores[1][nX][nY]), oFont) + 6
				if nTxtW > nAux
					nAux := nTxtW
				endif
			endif
		next nY

		// Limita ao máximo definido para a coluna
		aTamCol[nX] := IIf(nAux > aTamMax[nX], aTamMax[nX], nAux)
	next nX

	// -----------------------------------------------------------------
	// Descrição (col 2) recebe toda a sobra após somar as colunas fixas
	// Mínimo garantido de 80 pontos para não colapsar a coluna
	// -----------------------------------------------------------------
	nTotal := 0
	for nX := 1 to Len(aTamCol)
		if nX != 2
			nTotal += aTamCol[nX]
		endif
	next nX

	nSobra     := 603 - nTotal
	aTamCol[2] := IIf(nSobra >= 80, nSobra, 80)

return aTamCol


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IMPRIMIR CABECALHO                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
static function Cabecalho(nLinha,lPrincipal)
	oPrinter:SayBitmap(150,030,GetSrvProfString("Startpath","")+IIf(nModImp <> 1,"mdpredanfe.bmp","mdprenota.bmp"),495,496)

	if lPrincipal
		oPrinter:Line(000,000,000,603,ESPLIN)
		oPrinter:Line(000,000,037,000,ESPLIN)
		oPrinter:Line(000,603,037,603,ESPLIN)
		oPrinter:Line(037,000,037,603,ESPLIN)
		oPrinter:Say(008,003,"A "+IIf(nModImp == 1,"PRE-NOTA","PRE-DANFE")+" É UM DOCUMENTO NÃO FISCAL, COM O INTUITO DE FACILITAR A VISUALIZAÇÃO DA DANFE ANTES QUE A MESMA SEJA TRANSMITIDA, EVITANDO ASSIM",oFont07)
		oPrinter:Say(017,003,"O SEU CANCELAMENTO. MESMO COM ESSA PRATICIDADE, É DE EXTREMA IMPORTÂNCIA A VERIFICAÇÃO DA DANFE ORIGINAL IMPRESSA.",oFont07)
		oPrinter:Line(000,500,037,500,ESPLIN)

		if nModImp <> 1
			oPrinter:Say(007,542,"NF-e",oFont08N)
		else
			oPrinter:Say(007,538,"Pre-Nota",oFont08N)
		endif

		oPrinter:Say(017,510,"N. "+aNotaF[2],oFont08)

		if nModImp <> 1
			oPrinter:Say(027,510,"SÉRIE "+IIf(AllTrim(aNotaF[3]) == "U","0",aNotaF[3]),oFont08)
		endif
	endif

	oPrinter:Line(nLinha,000,nLinha,603,ESPLIN)
	oPrinter:Line(nLinha,000,nLinha + 95,000,ESPLIN)
	oPrinter:Line(nLinha,603,nLinha + 95,603,ESPLIN)
	oPrinter:Line(nLinha + 95,000,nLinha + 95,603,ESPLIN)

	// Logomarca da empresa — arquivo BMP deve estar na pasta Startpath
	// Nome do arquivo: DANFE + cEmpAnt + cFilAnt + .BMP  (ex: DANFE0101.BMP)

	// ROGRIGO - IMAGEM TOTVS
	if File(aEmpresa[6])
		oPrinter:SayBitmap(nLinha+ 008, 005, aEmpresa[6], 080, 080)
	endif

	oPrinter:Say(nLinha + 10,098,"Identificação do emitente",oFont12N)

	nLinCalc := nLinha + 23

	QbraTexto(aEmpresa[1],25,oFont12N)
	oPrinter:Say(nLinCalc,098,aEmpresa[2],oFont08N)

	nLinCalc += 10

	oPrinter:Say(nLinCalc,098,aEmpresa[3],oFont08N)

	nLinCalc += 10

	oPrinter:Say(nLinCalc,098,aEmpresa[4],oFont08N)

	nLinCalc += 10

	oPrinter:Say(nLinCalc,098,aEmpresa[5],oFont08N)
	oPrinter:Line(nLinha,248,nLinha + 95,248,ESPLIN)

	if nModImp <> 1
		oPrinter:Say(nLinha + 13,258,"PRE-DANFE",oFont18N)
		oPrinter:Say(nLinha + 23,261,"DOCUMENTO AUXILIAR DA",oFont07)
	else
		oPrinter:Say(nLinha + 13,261,"PRE-NOTA",oFont18N)
		oPrinter:Say(nLinha + 23,262,"DOCUMENTO MODELO DA",oFont07)
	endif

	oPrinter:Say(nLinha + 33,261,"NOTA FISCAL ELETRÔNICA",oFont07)
	oPrinter:Say(nLinha + 43,266,"0-ENTRADA",oFont08)
	oPrinter:Say(nLinha + 53,266,"1-SAÍDA",oFont08)
	oPrinter:Say(nLinha + 47,318,aNotaF[1],oFont08N)
	oPrinter:Line(nLinha + 36,315,nLinha + 36,325,ESPLIN)
	oPrinter:Line(nLinha + 36,315,nLinha + 53,315,ESPLIN)
	oPrinter:Line(nLinha + 36,325,nLinha + 53,325,ESPLIN)
	oPrinter:Line(nLinha + 53,315,nLinha + 53,325,ESPLIN)
	oPrinter:Say(nLinha + 68,255,"N. "+aNotaF[2],oFont10N)

	if nModImp <> 1
		oPrinter:Say(nLinha + 78,255,"SÉRIE "+IIf(AllTrim(aNotaF[3]) == "U","0",aNotaF[3]),oFont10N)
	endif

	oPrinter:Say(nLinha + 88,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas + nFolImp,2),oFont10N)
	oPrinter:Line(nLinha,351,nLinha + 95,351,ESPLIN)
	oPrinter:Line(nLinha + 33,351,nLinha + 33,603,ESPLIN)
	oPrinter:Say(nLinha + 43,355,"CHAVE DE ACESSO DA NF-E",oFont12N)
	oPrinter:Line(nLinha + 63,351,nLinha + 63,603,ESPLIN)
	oPrinter:Say(nLinha + 75,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12)
	oPrinter:Say(nLinha + 85,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12)

	nTamNatureza := Len(AllTrim(aNotaF[10])) - 1

	oPrinter:Line(nLinha + 97,000,nLinha + 97,603,ESPLIN)
	oPrinter:Line(nLinha + 97,000,nLinha + 120,000,ESPLIN)
	oPrinter:Line(nLinha + 97,603,nLinha + 120,603,ESPLIN)
	oPrinter:Line(nLinha + 120,000,nLinha + 120,603,ESPLIN)
	oPrinter:Say(nLinha + 106,002,"NATUREZA DA OPERAÇÃO",oFont08N)
	oPrinter:Say(nLinha + 116,002,Left(aNotaF[10],nTamNatureza),oFont08)
	oPrinter:Line(nLinha + 97,350,nLinha + 120,350,ESPLIN)
	oPrinter:Say(nLinha + 106,352,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N)

	oPrinter:Line(nLinha + 122,000,nLinha + 122,603,ESPLIN)
	oPrinter:Line(nLinha + 122,000,nLinha + 145,000,ESPLIN)
	oPrinter:Line(nLinha + 122,603,nLinha + 145,603,ESPLIN)
	oPrinter:Line(nLinha + 145,000,nLinha + 145,603,ESPLIN)
	oPrinter:Say(nLinha + 130,002,"INSCRIÇÃO ESTADUAL",oFont08N)
	oPrinter:Say(nLinha + 138,002,aEmpresa[8],oFont08)
	oPrinter:Line(nLinha + 122,200,nLinha + 145,200,ESPLIN)
	oPrinter:Say(nLinha + 130,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N)
	oPrinter:Line(nLinha + 122,400,nLinha + 145,400,ESPLIN)
	oPrinter:Say(nLinha + 130,405,"CNPJ",oFont08N)
	oPrinter:Say(nLinha + 138,405,Transf(aEmpresa[7],IIf(Len(aEmpresa[7]) <> 14,"@R 999.999-99","@R 99.999.999/9999-99")),oFont08)
return

static function ImpQuebraTexto(cTexto, nLargura, oPrinter, oFont)
	local aLinhas   := {}
	local aPalavras := {}
	local cLinha    := ""
	local cTeste    := ""
	local nI        := 0
	local nFator    := 0

	nFator := 0.30

	cTexto    := AllTrim(cTexto)
	aPalavras := StrTokArr(cTexto, " ")

	for nI := 1 to Len(aPalavras)
		cTeste := IIf(Empty(cLinha), aPalavras[nI], cLinha + " " + aPalavras[nI])

		if (oPrinter:GetTextWidth(cTeste, oFont) * nFator) <= nLargura
			cLinha := cTeste
		else
			if !Empty(cLinha)
				AAdd(aLinhas, cLinha)
			endif
			cLinha := aPalavras[nI]
		endif
	next nI

	if !Empty(cLinha)
		AAdd(aLinhas, cLinha)
	endif

	if Len(aLinhas) == 0
		AAdd(aLinhas, "")
	endif

return aLinhas
