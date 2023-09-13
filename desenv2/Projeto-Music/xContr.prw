#INCLUDE "TOTVS.CH"
#INCLUDE "FwMVCDef.ch"

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  21/07/2023  | Filipe Souza |  An�lise cen�rio contrato de grava��o
                                O layout inicial da agenda passa ser de contrato.
                                O layout da agenda atual � modelo 1, ao selecionar servi�o de grava��o
                                habilita ou exibe campos para buscar cd e m�sica para a grava��o.
  05/08/2023  | Filipe Souza |Gatilho via codigo para campo ZD1_SERV quando muda, para 1, apaga campos ZD1_INSTR ,ZD1_NINSTR , ZD1_CODA , ZD1_ART j� preenchidos
                              Gerar Browse de registro para tabela ZD4-ARTISTA, com rela��o com SA1-Cliente
                                    N�o foi poss�vel pelo protheus n�o ter relacionamentos integrados, formei somente ZD4
                              Na View retirar da oStrArt o campo ZD4_CLI
                              GetSxEnum no ZD4_COD
                              Criar tabela gen�rica para G�nero Musical, consulta padr�o para campo ZD4_GENERO	
                              testados registros com integridade de dados
  11/08/2023  | Filipe Souza |gerar prot�tipo do layout- xContr modelo1 ZD5
	                          criar gatilho no campo cod cliente, para filtrar somente os que existem em ZD4
  28/08/2023  | Filipe Souza |
                            gerar campo ZD5_DATA para iniciar com data do sistema.
                            atualizar para modelo 2 e 3	
                            Gatilho B1_TIPO, campo B1_COD recebe U_xCodProd()
                            Gerar auto preenchimento de ZD5_QCD,ZD5_FAIXAS e ZD5_TEMPO relativo a totalizadores. 
                            U_xTotCd()  no campo B1_TIPO   ,valida��o do usu�rio, para chamar fun��o ao editar. Preenche ZD5_QCD
                            U_xTotMus() no campo ZD3_MUSICA,valida��o do usu�rio, para chamar fun��o ao editar. Preenche ZD5_FAIXAS
                            U_xTotDur() no campo ZD3_DURAC, valida��o do usu�rio, para chamar fun��o ao editar. Preenche ZD5_TEMPO
  12/09/2023  | Filipe Souza |  
                            Alterar tabelaSB1 como Compartilhada de filial em SX2
                            atualizar pesquisa padr�o ZD5 do campo cod artista para retornar ZD4_CLI==M->ZD5_CLI
                            gatilho para zerar campos de artista ao alterar o campo cod cliente.
                            criar campo ZD3_XCONT  para o relacionamento com m�sica.
                            atualizar relacionamento Musica com Contrato adicionando campo ZD3_XCONT
                            validar digitos do tempo , xTotDur().   
                            somar tempo formatado e atribuir ao totalizador e campo, IncTime('10:50:40',20,15,25 ) 

    Planejamento @see https://docs.google.com/document/d/1V0EWr04f5LLvjhhBhYQbz8MrneLWxDtVqTkCJIA9kTA/edit?usp=drive_link
    UML          @see https://drive.google.com/file/d/1wFO2CKqSrvzxg5RZDYTfGayHrAUcCcfL/view?usp=drive_link 
    Scrum-kanban @see https://trello.com/w/protheusadvplmusicbusiness       
    GitHug       @see https://github.com/filipesouza2000/Advpl-Sistematizei/tree/main/desenv2/Projeto-Music                                  
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
Static cTitulo  := "Contrato de Servi�o-Grava��o"
Static cCont     := "ZD5"
//Static cCli     := "SA1"
Static cCD      := "SB1"
Static cMusica  := "ZD3"

User Function xContr()
    Local aArea     := GetArea()
    Local oBrowse   
//    Local cArtist
    Private aRotina :={}
    Private cRegCd  :=''
    Private cTempo  := '00:00:00'

    aRotina := MenuDef()
    oBrowse:= FwMBrowse():New()
    oBrowse:SetAlias(cCont)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
    //recebe filtro da lista de artistas a serem listados no bowse
    //oBrowse:SetFilterDefault(cCli+"->A1_COD $"+"'"+cArtist+"'")
    oBrowse:ACTIVATE()
    RestArea(aArea)
return NIL

Static Function MenuDef()
    //Local aRotina   := FwMvcmenu("xContr")
    Local aRotina:={}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.xContr" OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD Option aRotina TITLE "Incluir"    ACTION "VIEWDEF.xContr" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD Option aRotina TITLE "Alterar"    ACTION "VIEWDEF.xContr" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD Option aRotina TITLE "Excluir"    ACTION "VIEWDEF.xContr" OPERATION MODEL_OPERATION_DELETE ACCESS 0
    
return aRotina


Static Function ModelDef()
    Local oStruCon      :=FWFormStruct(1,cCont)   //remover campo , pois j� exibir� na strutura Pai
    Local oStruCD       :=FWFormStruct(1,cCD)//, {|x| !AllTrim(x) $ "B1_XART"})
    Local oStruMu       :=FWFormStruct(1,cMusica)
    Local aRelCD        :={}
    Local aRelMusic     :={}    
    Local oModel
    Local bPre          :=NIL
    Local bPos          :=NIL
    Local bCommit       :=NIL
    Local bCancel       :={|| FWFORMCANCEL(SELF)}

    oModel:=MPFormModel():New("xContrM",bPre,bPos,bCommit,bCancel)
    oModel:addFields("ZD5Master",/*cOwner*/,oStruCon)
    oModel:AddGrid("SB1Detail","ZD5Master",oStruCD,/*bLinePre*/,/*bPos*/,/*bPre-Grid Full*/,/*bLoad-Carga do modelo manual*/,)
    oModel:AddGrid("ZD3Detail","SB1Detail",oStruMu,/*bLinePre*/,/*bLinePos*/,/*bPre-Grid Full*/,/*bLoad-Carga do modelo manual*/,)
    oModel:SetPrimaryKey({"ZD5_FILIAL","ZD5_COD"})//,"A1_CGC"
    
    //CD- relacionamento B1-CD com ZD5-Contrato 
    //propriedade do cod do artista � obrigat�rio na tabela, mas seta como n�o obrigat�rio para n�o exibir
    oStruCD:SetProperty("B1_XART", MODEL_FIELD_OBRIGAT, .F.)
                  
    aAdd(aRelCD, {"B1_FILIAL","FWxFilial('SB1')"})
    aAdd(aRelCD, {"B1_XCONTR","ZD5_COD"})
    oModel:SetRelation("SB1Detail", aRelCD, SB1->(IndexKey(1)))
    
    //Musica- relacionamento ZD3-Musica com ZD5-Contrato
    aAdd(aRelMusic,{"ZD3_FILIAL","FWxFilial('ZD5')"})    
    AAdd(aRelMusic,{"ZD3_XCONT","ZD5_COD"})
    oModel:SetRelation("ZD3Detail", aRelMusic,ZD3->(IndexKey(3)))

    oModel:GetModel("SB1Detail"):SetUniqueLine({"B1_DESC"})
    oModel:GetModel("ZD3Detail"):SetUniqueLine({"ZD3_MUSICA"})
    //totalizador-  titulo,     relacionamento, campo a calcular,virtual,opera��o,,,display    
    oModel:AddCalc('TotaisCd','ZD5Master','SB1Detail','B1_COD'    ,'XX_TOTCD' ,'COUNT',,,'Total CDs')
    oModel:AddCalc('TotaisM','ZD5Master','ZD3Detail','ZD3_MUSICA','XX_TOTM'  ,'COUNT',,,'Total Musicas')
    oModel:AddCalc('TotaisM','ZD5Master','ZD3Detail','ZD3_DURAC' ,'XX_TOTDUR','SUM',,,'Total Dura��o')
    
return oModel

Static Function ViewDef()
    Local oModel    :=FwLoadModel("xContr")
    Local oStruCon  :=FWFormStruct(2,cCont)
    Local oStruCD   :=FWFormStruct(2,cCD, {|x| !AllTrim(x) $ 'B1_AFAMAD'})
    Local oStruMu   :=FWFormStruct(2,cMusica)
    Local oStruTotCd:=FWCalcStruct(oModel:GetModel('TotaisCd'))
    Local oStruTotM :=FWCalcStruct(oModel:GetModel('TotaisM'))
    Local oView
    
    oView:= FwFormView():New()
    oView:SetModel(oModel)
    
    oView:addField("VIEW_ZD5",oStruCon  ,"ZD5Master")
    oView:addGrid("VIEW_SB1",oStruCD,"SB1Detail")
    oView:addGrid("VIEW_ZD3",oStruMu ,"ZD3Detail")
    oView:addField("VIEW_TOTCD",oStruTotCd,"TotaisCd")
    oView:addField("VIEW_TOTM",oStruTotM,"TotaisM")

    oView:CreateHorizontalBox("CONT_BOX",50)
    
    oView:CreateHorizontalBox("MEIO_BOX",40)
    oView:CreateVerticalBox("MEIOLEFT",50,"MEIO_BOX")// Vertical BOX
    oView:CreateVerticalBox("MEIORIGHT",50,"MEIO_BOX")// Vertical BOX    
    
    oView:CreateHorizontalBox("BARTOT",10)   
    oView:CreateVerticalBox("TOTLEFT",50,"BARTOT")// Vertical BOX
    oView:CreateVerticalBox("TOTRIGHT",50,"BARTOT")// Vertical BOX
    
    oView:SetOwnerView("VIEW_SB1","MEIOLEFT")
    oView:SetOwnerView("VIEW_ZD3","MEIORIGHT")
    oView:SetOwnerView("VIEW_TOTCD","TOTLEFT")
    oView:SetOwnerView("VIEW_TOTM","TOTRIGHT")

    oView:EnableTitleView("VIEW_SB1", "CDs")
    oView:EnableTitleView("VIEW_ZD3", "M�sicas")

    oView:SetOwnerView("VIEW_ZD5","CONT_BOX")
    oView:EnableTitleView("VIEW_ZD5", "Contrato")
    

    //oStruCD:RemoveField("B1_NOME")
    oStruMu:RemoveField("ZD3_CODCD")
    oStruMu:RemoveField("ZD3_COD")
    oStruMu:RemoveField("ZD3_XCONT")
    oStruCD:RemoveField("B1_XART")
   
    //refresh para tentar atualziar Totalizadores
/*    oView:AddUserButton('Refresh','MAGIC.BMP',{|| oView:Refresh()},,,,.T.)
    oView:SetViewAction('REFRESH',      {|| oView:Refresh()})
    oView:SetViewAction('DELETELINE',   {|| oView:Refresh()})
    oView:SetViewAction('UNDELETELINE', {|| oView:Refresh()})
*/   
    //oView:AddIncrementField("SB1Detail","B1_COD")// gatilho xCodProd()
    oView:AddIncrementField("ZD3Detail","ZD3_COD")
    oView:AddIncrementField("ZD3Detail","ZD3_ITEM")
    oView:SetCloseOnOk({||.T.})
return oView

User Function xTotCd()
    Local oModel
    Local oModelTot := FwModelActive()
    Local oModelCd       

    If oModelTot:Adependency[1][1] == "ZD5Master"
        oModelCd  := oModelTot:GetModel("TotaisCd")        
        nCd       := oModelCd:GetValue("XX_TOTCD")        
        oModel:= oModelTot:GetModel("ZD5Master")
        oModel:SetValue("ZD5_QCD",nCd)         
    EndIf
    
return .T.

User Function xTotMus()
    Local oModel
    Local oModelTot := FwModelActive()
    Local oModelMu 
    Local nMus       

    If oModelTot:Adependency[1][1] == "ZD5Master"
        oModelMu  := oModelTot:GetModel("TotaisM")
        nMus      := oModelMu:GetValue("XX_TOTM")
        oModel:= oModelTot:GetModel("ZD5Master")
        oModel:SetValue("ZD5_FAIXAS",nMus) 
    EndIf
    
return .T.

User Function xTotDur()
    Local oModel
    Local oModelTot := FwModelActive()
    Local oModelDur 
    //Local nDur
    Local xRet := .T.    
    Local cDur := alltrim(str(M->ZD3_DURAC))
    Local cS   := IIF(Len(cDur)>=2,right( cDur ,2), '')
    Local cM   := ''    
    Local cH   := ''
    Local nT   
    //atribuir Min Hora
    If Len(cDur)==3 
        cM := Left(cDur, 1)  // 1 30
        elseif Len(cDur)==4
            cM :=  Left(cDur, 2)  //11 30
            elseif Len(cDur)==5
                cM := SubStr(cDur,2,2)//1 11 30
                cH := Left(cDur,1)
                elseif Len(cDur)==6
                    cM := SubStr(cDur,3,2) //10 11 30            
                    cH := Left(cDur,2)
    EndIf
                                                 
    If  cS=='' .OR. val(cS)>59 //validar segundos       
        xRet  :=.F.
        elseif val(cM)>59 //validar minutos
            xRet  :=.F.
            elseIf val(cH)>23 //validar hora
                xRet  :=.F.
    EndIf
    cTempo  := IncTime(cTempo,val(cH),+val(cM),+val(cS))
    nT      := strtran(cTempo,':','')
    //somahoras(28.55,5.10)          
    //IncTime('10:50:40',20,15,25 )   
    If xRet .and. oModelTot:Adependency[1][1] == "ZD5Master"
        oModelDur := oModelTot:GetModel("TotaisM")
        //nDur      := oModelDur:GetValue("XX_TOTDUR")
        oModelDur:SetValue("XX_TOTDUR",val(nT))
        oModel:= oModelTot:GetModel("ZD5Master")
        oModel:SetValue("ZD5_TEMPO",val(nT)) 
    EndIf
    
return xRet


