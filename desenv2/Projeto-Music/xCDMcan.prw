#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  18/07/2023  | Filipe Souza | fun��o chamada no evento CENCELAR, 
                               para zerar a vari�vel Private cRegCd que guarda o c�digo que ainda n�o foi gravado.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function xCDMcan(cRegCd)
    cRegCd :=NIL
    //FwFreeVar(cRegCd)
return .T.
