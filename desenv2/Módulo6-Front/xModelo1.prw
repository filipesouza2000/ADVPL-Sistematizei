#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'parmtype.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  10/10/2022  | Filipe Souza | Modelo 1 convencional
                              O AxCadastro() � uma funcionalidade de cadastro simples, com poucas op��es de
                              customiza��o, a qual � composta de:
                              -Browse padr�o para visualiza��o das informa��es da base de dados, de acordo com as
                              configura��es do SX3 � Dicion�rio de Dados (campo browse).
                              -Fun��es de pesquisa, visualiza��o, inclus�o, altera��o e exclus�o padr�es para
                              visualiza��o de registros simples, sem a op��o de cabe�alho e itens.
                              -Sintaxe: AxCadastro(cAlias, cTitulo, cVldExc, cVldAlt)
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function xModelo1()
       
    AxCadastro("SB1", "Produtos - Modelo 1",".T.",".T.")
RETURN

