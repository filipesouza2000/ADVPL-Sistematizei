#INCLUDE 'Protheus.ch'
#INCLUDE "TOTVS.CH"
/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  13/09/2023  | Filipe Souza | PE, valida��o na grid "ZD3Detail" para vverificar se j� havia valor
  19/09/2023  | Filipe Souza | Evento aparam[5]=="DELETE" seta para cima que remove linha vazia,
                                totalizador incrementa e � preciso decrementar total de m�sicas.
  20/09/2023  | Filipe Souza | otimiza��o do ponto de entrada, estava sendo chamado U_xTotMus(2) nos 2 eventos
                                de 'Deletar' e 'seta apra cima' que tamb�m deleta. 
                                adicionei condi��o para verificar se campos est�o vazios, assim n�o foi confirmada linha.                                
@see https://tdn.totvs.com/display/public/framework/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC
@see https://tdn.totvs.com/display/public/PROT/DT+PE+MNTA080+Ponto+de+entrada+padrao+MVC
*/  

User Function xContrM()
/* PARAMIXB FORMLINEPRE
    1     O        Objeto do formul�rio ou do modelo, conforme o caso
    2     C        ID do local de execu��o do ponto de entrada
    3     C        ID do formul�rio
    4     N        N�mero da Linha da FWFORMGRID
    5     C        A��o da FWFORMGRID
    6     C        Id do campo
*/
    Local aparam    := PARAMIXB
    Local xRet      :=.T.
    //Local oObject   := aparam[1] //objeto do formul�rio ou do modelo
    Local cIdPonto  := aparam[2] // id do local de execu��o do ponto de entrada
    Local cIdModel  := aparam[3] //id do formulario
    Local oModel, oModelG
    Local nModel    :=0
    Local aCampos   :={}
    
    If aparam[2] <> Nil
        //nOpt, cTotalM, cXX_TOT
        //verifica qual m�dulo foi chamado, qual Grid        
        If cIdModel=='SB1Detail'
            nModel:=1
            aAdd(aCampos,'B1_COD')
            aAdd(aCampos,'B1_DESC')
        elseif cIdModel=='ZD3Detail'
            nModel:=2            
            aAdd(aCampos,'ZD3_MUSICA')            
            aAdd(aCampos,'ZD3_DURAC')
        EndIf
        
        If (nModel==1 .or. nModel==2) .and. cIdPonto == "FORMLINEPRE"
            oModel  :=FwModelActive()
            oModelG :=oModel:GetModel(cIdModel)
            //evento de seta para cima                          campos vazios
            If  Len(aparam) >4 .and. aparam[5]=="DELETE" .and. Empty(AllTrim(oModelG:GetValue(aCampos[1]))) .and. Empty(AllTrim(oModelG:GetValue(aCampos[2])))
                //xTotQtd(modulo master,2=decrementar qtd,1=cd 2=musica,)
                U_xTotQtd("ZD5Master",2,nModel)                
            EndIf
            //tratar dura��o da m�sica e totalizador
            If nModel==2  .and. !Empty(M->ZD3_DURAC) .and. M->ZD3_DURAC > 0
                xRet := U_xValTime(M->ZD3_DURAC)//valida tempo digitado                 
            elseif nModel==2 .and.  M->ZD3_DURAC <= 0
               xRet:=.F.   
            elseif nModel==2  // recebe valor dura��o anterior da edi��o
                nOldT:= omodelg:GetValue(aCampos[2])
            EndIf

            If xRet
                If M->ZD3_DURAC <> nOldT .and. nOldT >0//valor editado
                    xRet := U_xTotDur(nOldT)//decrementa antes de adicionar
                    elseif M->ZD3_DURAC == nOldT    
                        nOldT  := M->ZD3_DURAC 
                        xRet := U_xTotDur(nOldT)//mesmo igual, deve decrementar para adicionar automaticamente pelo totalizador.
                EndIf
            else
                Help(NIL, NIL, "Valida��o!", NIL, "N�mero incoreto para o campo de dura��o", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Digite n�meros dentro do formato da hora."})
                
            EndIf    
        /*��������������������������������������������������������������������������������������������������������
        totalizador de tempo usa NEGATIVO
        ����������������������������������������������������������������������������������������������������������*/
        EndIf
    EndIf    
    aCampos   :={}
return xRet
