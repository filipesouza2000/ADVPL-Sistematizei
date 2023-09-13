#INCLUDE 'Protheus.ch'
#INCLUDE "TOTVS.CH"
/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  13/09/2023  | Filipe Souza | PE, valida��o na grid "ZD3Detail" para vverificar se j� havia valor

@see https://tdn.totvs.com/display/public/framework/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC
*/  

User Function xContrM()
    Local aparam    := PARAMIXB
    Local xRet      :=.T.
    //Local oObject   := aparam[1] //objeto do formul�rio ou do modelo
    Local cIdPonto  := aparam[2] // id do local de execu��o do ponto de entrada
    Local cIdModel  := aparam[3] //id do formulario
    Local oModel, oModelG
    
    If aparam[2] <> Nil
        If cIdModel=='ZD3Detail' .and. cIdPonto == "FORMLINEPRE"
            oModel  :=FwModelActive()
            oModelG :=oModel:GetModel(cIdModel)
            If !Empty(M->ZD3_DURAC)
                xRet := U_xValTime(M->ZD3_DURAC)//valida tempo digitado 
                If xRet
                    If M->ZD3_DURAC <> nOldT .and. nOldT >0//valor editado
                        xRet := U_xTotDur(nOldT)                
                        elseif M->ZD3_DURAC == nOldT    
                            nOldT  := M->ZD3_DURAC
                    EndIf
                else
                 Help(NIL, NIL, "Valida��o!", NIL, "N�mero incoreto para o campo de dura��o", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Digite n�meros dentro do formato da hora."})
                    
                EndIf
            else  //recebe valor anterior da edi��o
                nOldT:= omodelg:GetValue('ZD3_DURAC')
            EndIf    
        EndIf
    EndIf
    

return xRet
