#INCLUDE 'Protheus.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  27/03/2023  | Filipe Souza | Escopo: Pedido de venda n�o aceitar quantidade > 10 unidades por item de produto, C6_QTDVEN
                               Validar para n�o inserir produto igual j� existende 
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function M410LIOK()
    Local lRet      := .T.
    Local cL        :=CHR( 19 )+Chr(13)
    Local nAcolsQtd := ASCAN( aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})
    Local nQuant    := aCols[n,nAcolsQtd]
    Local nAcolsProd:= ASCAN( aHeader, {|x| Alltrim(x[2]) == "C6_PRODUTO"} )
    Local cCodProd  := aCols[n,nAcolsProd]
    Local nColItem  := ASCAN( aHeader, {|x| AllTrim(x[2]) == "C6_ITEM"})
    Local cItem     := aCols[n,nColItem]
    Local nCount    :=0
    Local nIguais   :=0

    For nCount:= 1 to Len(aCols)
      if aCols[nCount,nAcolsProd] = cCodProd
        nIguais ++      
      endif  
    Next

    if nIguais > 1
      lRet:=.F.
      FWAlertWarning('N�o � permitido colocar produtos iguais no mesmo pedido.'+cL+;
      'Item : '+cItem +'  '+ cCodProd ,'Opera��o n�o permitida.')
    elseif nQuant > 10
      FWAlertWarning('N�o � permitido item do pedido maior que 10 unidades!'+cL+;
      'Item : '+cItem +'  '+ cCodProd +'  '+ Str(nQuant)  ,'Opera��o n�o permitida.')
      lRet:=.F.
  endif
return lRet
