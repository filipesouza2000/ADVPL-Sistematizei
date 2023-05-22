#INCLUDE 'Protheus.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  10/03/2023  | Filipe Souza |  PE, valida��o na grid limitar para 10 qtd
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function MVCSZ7m()
//parametro PE em MVC contendo informa��es sobre o estado e ponto de execu��o da rotina
    Local aParam        := PARAMIXB
    Local cL        :=CHR( 19 )+Chr(13)
/* Retorno do array
1   O  Objeto do formul�rio ou do modelo, conforme o caso
2   C  ID do local de execu��o do ponto de entrada
3   C  ID do formul�rio */
    //vari�vel poder� retornar L�gico ou Array, por isso usa nota��o H�ngaradefinida com X
    Local xRet      := .T.
    Local oObject   := aParam[1]
    Local cIdPonto  := aParam[2]
    Local cIdModel  := aParam[3]
   
    // verificar se est� null, quer dizer que algumas a��o est� sendo feita nomodelo
    if aParam[2] <> NIL
        //se estiver na valida��o da linha na grid de itens
        if cIdPonto =='FORMLINEPOS'
            //Fun��o que busca o valor do campo na linha do grid
            If FwFldGet('Z7_QUANT') > 10 
                HELP(Nil,Nil,'Valida��o' ,Nil,'<b>Aten��o</b>!'+cL+'Quantidade n�o permitida',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'Quantidade limitada at� 10'})
            xRet    := .F.        
            EndIf
        endif            
    endif


RETURN xRet

