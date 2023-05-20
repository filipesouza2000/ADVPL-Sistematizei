#INCLUDE 'Protheus.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  01/04/2023  | Filipe Souza |  Ponto de entrada 'Bancos' 
                                Neste caso o IdModel tem o mesmo nome da Function, por isso tem o nome MATA070_PE
                                Escopo:Campos de d�gito da agencia e do banco n�o podem estar vazios.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
User Function MATA070()
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
    // captura a opera��o da aplica��o
    Local nOperation    := oObject:GetOperation()
   
    // verificar se est� null, quer dizer que algumas a��o est� sendo feita nomodelo
    if aParam[2] <> NIL
        //se estiver na p�s valida��o
        if cIdPonto =='MODELPOS'
            //verifica se campo D�gito da agencia e d�gito da conta est�o vazios
            If Empty(M->A6_DVAGE)
                HELP(Nil,Nil,'MATA070' ,Nil,'Conte�do n�o permitido',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'Campo D�gito da Agencia pode estar vazio, ou somente com espa�o!'+cL+;
                 'Insira conte�dos v�lidos.'})
                xRet:=.F.            
            elseif Empty(M->A6_DVCTA)
                HELP(Nil,Nil,'MATA070' ,Nil,'Conte�do n�o permitido',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'Campo D�gito da Conta pode estar vazio, ou somente com espa�o!'+cL+;
                 'Insira conte�dos v�lidos.'})
                xRet:=.F.            
            EndIf
        endif            
    endif


RETURN xRet
