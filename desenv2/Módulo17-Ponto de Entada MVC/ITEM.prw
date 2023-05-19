#INCLUDE 'Protheus.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  27/03/2023  | Filipe Souza |  Escopo: codigo do produto deve conter nom�nimo 10 caracteres
                                descri��o deve conter 15 caracteres obrigat�rios.
  30/03/2023  | Filipe Souza |  Bloquear a opera��o de excluir. 
                                Confirma��o para cancelamento.                               
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
User Function ITEM()
    //parametro PE em MVC contendo informa��es sobre o estado e ponto de execu��o da rotina
    Local aParam        := PARAMIXB
    
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
        //verifica se o cod do produto a partir de 10 caracteres
            If Len(Alltrim(M->B1_COD)) < 10
                HELP(Nil,Nil,'COD PRODUTO' ,Nil,'C�digo n�o permitido',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'O C�digo <b>'+Alltrim(M->B1_COD)+'</b> deve ter a partir de 10 caracteres.'})
                xRet:=.F.
            elseif Len(Alltrim(M->B1_DESC)) < 15
                HELP(Nil,Nil,'DESC PRODUTO' ,Nil,'Descri��o n�o permitida',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'A descri��o <b>'+Alltrim(M->B1_DESC)+'</b> deve ter a partir de 15 caracteres.'})                
                xRet:=.F.
            EndIf  
        elseif cIdPonto == 'MODELCANCEL'
                xRet:= FwAlertNoYes('Certeza de cancelar opera��o?','Confirma��o')                      
        elseif nOperation == 5 //exclus�o    
            HELP(Nil,Nil,'Exclus�o de Produto' ,Nil,'Exclus�o n�o permitida',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'Produtos n�o podem ser exclu�dos!<br>Consulte departamento de TI'})                
                xRet:=.F.
        endif
    endif


RETURN xRet
