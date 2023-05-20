#INCLUDE 'Protheus.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  01/04/2023  | Filipe Souza |  Escopo: Ponto de entrada 'Fornecedor' Na confirma��o do cadastro, 
                                validar campo Raz�o Social para conter m�nimo de 20 caracteres,
                                e Validar campo nome de fantasia conter m�nimo de 10 caracteres.
                                Adicionar bot�o para acessar m�dulo ProdutoXFornecedor
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
User Function CUSTOMERVENDOR()
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
            //verifica se raz�o social contem a partir de 20 caracteres
            If Len(Alltrim(M->A2_NOME)) < 20
                HELP(Nil,Nil,'RAZ�O SOCIAL' ,Nil,'Conte�do n�o permitido',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'A Raz�o Social <b>'+Alltrim(M->A2_NOME)+'</b><br> deve conter a partir de 20 caracteres.'})
                xRet:=.F.
            //verifica se nome de fantasia contem a partir de 10 caracteres
            elseif Len(Alltrim(M->A2_NREDUZ)) < 10//
                HELP(Nil,Nil,'NOME DE FANTASIA' ,Nil,'Conte�do n�o permitido',1,0,Nil,Nil,Nil,Nil,Nil,;
                {'Nome de Fantasia <b>'+Alltrim(M->A2_NREDUZ)+'</b><br> deve conter a partir de 10 caracteres.'})                
                xRet:=.F.
            EndIf
        //adicionar bot�o para acessar m�dulo ProdutoXFornecedor    
        elseif cIdPonto =='BUTTONBAR'
                xRet:= {{"ProdXForn","ProdXForn",{|| MATA061()},"Abre o m�dulo de amarra��o Produto X Fornecedor"}}
        endif
    endif


RETURN xRet
