//Bibliotecas
#Include "totvs.ch"
#Include "protheus.ch"
  
/*/{Protheus.doc} MA410MNU
    Ponto de Entrada na adição de funções no Pedido de Venda
    @author Miqueias Coelho
    @since Fev/2026
    @version 1.0
    @type function
    @see https://tdn.totvs.com/display/public/PROT/MA410MNU
/*/
User Function MA415MNU()
    
    aAdd(aRotina, {"*Imprimir Orcamento", "u_RFAT100()",  0, 4, 0, Nil})

Return
