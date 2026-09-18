#Include "totvs.ch"
#Include "protheus.ch"
  
/*/{Protheus.doc} MT410TOK
    Validação da tela toda no Pedido de Venda (Ao clicar em Salvar)
    @author Miqueias Coelho
    @since Fev/2026
    @version 2.0
    @type function
/*/
User Function MT410TOK()
    
    Local aArea     := GetArea()
    Local aAreaSB1  := SB1->(GetArea())
    Local aAreaSC2  := SC2->(GetArea())
    Local aAreaSGA  := SGA->(GetArea())
    
    Local aOpc      := {}
    Local nI        := 0
    Local nX        := 0
    Local cDescOpc  := ""
    
    // Busca dinamica das posicoes no aHeader
    Local nCodPrd   := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
    Local nNumOP    := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_NUMOP"})
    Local nItemOP   := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEMOP"})
    Local nDescri   := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_DESCRI"})

    // BLINDAGEM: Se faltar algum campo no aHeader, sai silenciosamente para nao dar Array Out of Bounds
    If nCodPrd == 0 .Or. nNumOP == 0 .Or. nItemOP == 0 .Or. nDescri == 0
        Return .T.
    EndIf

    SB1->(DbSetOrder(1))
    SC2->(DbSetOrder(1))
    SGA->(DbSetOrder(1)) // Indice 1: GA_FILIAL + GA_OPC

    For nI := 1 To Len(aCols)
        
        // BLINDAGEM: Ignora as linhas que o usuario deletou no Grid
        If !aCols[nI][Len(aHeader) + 1] 
            
            If !Empty(aCols[nI][nNumOP])
                // Posiciona na Ordem de Producao
                If SC2->(DbSeek(xFilial("SC2") + aCols[nI][nNumOP] + aCols[nI][nItemOP])) .And. !Empty(SC2->C2_OPC)
                    
                    aOpc := StrTokArr2(SC2->C2_OPC, "/")
                    cDescOpc := "" // Zera o acumulador para a linha atual

                    // Laco das opcoes: Acumula todas as descricoes em uma variavel
                    For nX := 1 To Len(aOpc)
                        If SGA->(DbSeek(xFilial("SGA") + Alltrim(aOpc[nX]))) .And. SGA->GA_XIMPPV == "S"
                            cDescOpc += Alltrim(SGA->GA_DESCOPC) + " "
                        EndIf
                    Next
                    
                    // Se encontrou validou opcoes, atualiza a descricao concatenando
                    If !Empty(cDescOpc) .And. SB1->(DbSeek(xFilial("SB1") + aCols[nI][nCodPrd]))
                        // Usa o TamSX3 do proprio campo de destino (C6_DESCRI) para evitar estourar o limite da celula
                        aCols[nI][nDescri] := Substr(Alltrim(SB1->B1_DESC) + " - " + Alltrim(cDescOpc), 1, TamSX3("C6_DESCRI")[1])
                    else
                        // Se nao encontrou opcoes, apenas coloca a descricao do produto
                        If SB1->(DbSeek(xFilial("SB1") + aCols[nI][nCodPrd]))
                            aCols[nI][nDescri] := Substr(Alltrim(SB1->B1_DESC), 1, TamSX3("C6_DESCRI")[1])
                        EndIf
                    EndIf
                    
                EndIf
            EndIf
            
        EndIf
    Next

    // Restaura as areas na ordem inversa
    RestArea(aAreaSGA)
    RestArea(aAreaSC2)
    RestArea(aAreaSB1)
    RestArea(aArea)

Return .T.
