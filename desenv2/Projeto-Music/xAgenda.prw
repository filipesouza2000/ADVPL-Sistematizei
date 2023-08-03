#INCLUDE "TOTVS.CH"
#INCLUDE "FwMVCDef.ch"
#INCLUDE "TOPCONN.CH"

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  08/07/2023  | Filipe Souza |  Projeto Music, com Scrum-Kanban
                                Cadastro de Artistas x Cds x M�sicas no Modelo X em MVC, tabelas, SA1 SB1
                                Onde produto tem tipo CD, MUSICA
  09/07/2023  | Filipe Souza |  MODELO1-SA1                                
  10/07/2023  | Filipe Souza |  ModeloX-SA1-SB1-ZD3
                                Criar campo B1_XART para relacionar com ZD1_COD
                                Criar campo B1_XEST para receber codigo de estudio
                                Alterar Layout de horinzontal para vertical
                                Remover campo B1_XART da estrutura a n�o exibir.
                                Remover campo B1_AFAMAD da estrutura a n�o exibir.
                                Desabiliar campo ZD1_COD, iniciar com GETXENUM
                                Desabiliar campo A2_COD, iniciar com GETXENUM
                                Desabilitar e retirar autoincrement do B1_COD, utilizar gatilho a fun��o xCodProd 
                                    -mudar gatilho para chamar s� B1_TIPO
                                    -resolvido a sequencia B1_COD que parava em �nico registro.
                                    -no evento cancelar, zerar a vari�vel Private que lega o cod do registro.
                                Totalizadores para CD e Musicas
  11/07/2023  | Filipe Souza |  Rean�lise dos cen�rios para Agendamento de ensaio e grava��o.   
  17/07/2023  | Filipe Souza |  Atualizado estrutra das tabela conforme UMl_classe
  18/07/2023  | Filipe Souza |  Prototipa��o,novo modelo para agendamento-ZD1. renomeada fun��o e arquivo.
                                Falta otimizar a numera��o autom�tica para ZD1_COD
  20/07/2023  | Filipe Souza |  Usar no MPFormModel bCancel FWFORMCANCEL(SELF) passando o objeto model 
                                   para cancelar numera��o autom�tica, igual RollBackSX8 
                                Retirar campos no browse e nas grids, campos do relacionamento. 
  21/07/2023  | Filipe Souza |  An�lise cen�rio contrato de grava��o
                                O layout inicial da agenda passa ser de contrato.
                                O layout da agenda atual � modelo 1, ao selecionar servi�o de grava��o
                                habilita ou exibe campos para buscar cd e m�sica para a grava��o.
  02/08/2023  | Filipe Souza |  criar consultas padr�es para ZD0
                                formular tamanhos de campo c�digo de 15 para 9
                                Criar campo B1_XCONTR  para relacionamento de CD - Cod Contrato
                                gerar SX5 para Instrumentos para grava��o. Pois n�o s�o produtos do estudio a venda.
                                pesquisa padr�o no campo ZD1_INSTR para tabela 'IM - Instrumento musical na gava��o'
                                mudar campos de Status nas tabelas ZD1 ZD3 para 1-OFF 2-ON 3-OK
                                Retirar da grid Musica o campo codigo.
                                habilitar e boquear campos referente ao servi�o selecionado ZD1_SERV
                                criar pesquisas padr�o para auto preencher campos da ZD0-Contrato                               


    Planejamento @see https://docs.google.com/document/d/1V0EWr04f5LLvjhhBhYQbz8MrneLWxDtVqTkCJIA9kTA/edit?usp=drive_link
    UML          @see https://drive.google.com/file/d/1wFO2CKqSrvzxg5RZDYTfGayHrAUcCcfL/view?usp=drive_link 
    Scrum-kanban @see https://trello.com/w/protheusadvplmusicbusiness       
    GitHug       @see https://github.com/filipesouza2000/Advpl-Sistematizei/tree/main/desenv2/Projeto-Music                                  
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
Static cTitulo  := "Agendamento de Servi�o- Ensaio e Grava��o"
Static cAge     := "ZD1"
Static cCli     := "SA1"
Static cCD      := "SB1"
Static cMusica  := "ZD3"

User Function xAgenda()
    Local aArea     := GetArea()
    Local oBrowse   
    Local cArtist
    Private aRotina :={}
    Private cRegCd  :=''

    aRotina := MenuDef()
    //cArtist := U_xArtXcd()
    oBrowse:= FwMBrowse():New()
    oBrowse:SetAlias(cAge)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
    //recebe filtro da lista de artistas a serem listados no bowse
    //oBrowse:SetFilterDefault(cCli+"->A1_COD $"+"'"+cArtist+"'")
    oBrowse:ACTIVATE()
    RestArea(aArea)
return NIL

Static Function MenuDef()
    //Local aRotina   := FwMvcmenu("xAgenda")
    Local aRotina:={}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.xAgenda" OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD Option aRotina TITLE "Incluir"    ACTION "VIEWDEF.xAgenda" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD Option aRotina TITLE "Alterar"    ACTION "VIEWDEF.xAgenda" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD Option aRotina TITLE "Excluir"    ACTION "VIEWDEF.xAgenda" OPERATION MODEL_OPERATION_DELETE ACCESS 0
    
return aRotina


Static Function ModelDef()
    Local oStruAge      :=FWFormStruct(1,cAge)   //remover campo , pois j� exibir� na strutura Pai
    Local oStruCD       :=FWFormStruct(1,cCD)//, {|x| !AllTrim(x) $ "B1_XART"})
    Local oStruMu       :=FWFormStruct(1,cMusica)
    Local aRelCD        :={}
    Local aRelMusic     :={}    
    Local oModel
    Local bPre          :=NIL
    Local bPos          :=NIL
    Local bCommit       :=NIL
    Local bCancel       :={|| FWFORMCANCEL(SELF)}  

    oModel:=MPFormModel():New("xAgendaM",bPre,bPos,bCommit,bCancel)
    oModel:addFields("ZD1Master",/*cOwner*/,oStruAge)
    oModel:AddGrid("SB1Detail","ZD1Master",oStruCD,/*bLinePre*/,/*bLinePos*/,/*bPre-Grid Full*/,/*bLoad-Carga do modelo manual*/,)
    oModel:AddGrid("ZD3Detail","SB1Detail",oStruMu,/*bLinePre*/,/*bLinePos*/,/*bPre-Grid Full*/,/*bLoad-Carga do modelo manual*/,)
    oModel:SetPrimaryKey({"ZD1_FILIAL","ZD1_COD"})//,"A1_CGC"
   
       //CD- relacionamento B1-CD com A1-Cli 
    //propriedade do cod do artista � obrigat�rio na tabela, mas seta como n�o obrigat�rio para n�o exibir
    oStruCD:SetProperty("B1_XART", MODEL_FIELD_OBRIGAT, .F.)
    aAdd(aRelCD, {"B1_FILIAL","FwxFilial('ZD1')"})
    aAdd(aRelCD, {"B1_COD","ZD1_CODCD"})
    oModel:SetRelation("SB1Detail", aRelCD, SB1->(IndexKey(1)))
    
    //Musica- relacionamento B1-CD com ZD3-Musica
    aAdd(aRelMusic,{"ZD3_FILIAL","FwxFilial('SB1')"})
    aAdd(aRelMusic,{"ZD3_CODCD", "B1_COD"})
    oModel:SetRelation("SB1Detail", aRelMusic,SB1->(IndexKey(1)))

    oModel:GetModel("SB1Detail"):SetUniqueLine({"B1_COD"})
    oModel:GetModel("ZD3Detail"):SetUniqueLine({"ZD3_MUSICA"})
    //totalizador-  titulo,     relacionamento, camo a calcular,visrtual,opera��o,,,display    
    oModel:AddCalc('Totais','ZD1Master','SB1Detail','B1_COD','XX_TOTCD','COUNT',,,'Total CDs')
    oModel:AddCalc('Totais','SB1Detail','ZD3Detail','ZD3_MUSICA','XX_TOTM','COUNT',,,'Total Musicas')

return oModel

Static Function ViewDef()
    Local oModel    :=FwLoadModel("xAgenda")
    Local oStruAge  :=FWFormStruct(2,cAge)
    Local oStruCD:=FWFormStruct(2,cCD,      {|x| !AllTrim(x) $ 'B1_AFAMAD'})
    Local oStruMu :=FWFormStruct(2,cMusica, {|x| !AllTrim(x) $ 'ZD3_COD'})
    Local oStruTot  :=FWCalcStruct(oModel:GetModel('Totais'))
    Local oView

    oView:= FwFormView():New()
    oView:SetModel(oModel)
    
    oView:addField("VIEW_ZD1",oStruAge  ,"ZD1Master")
    oView:addGrid("VIEW_SB1",oStruCD,"SB1Detail")
    oView:addGrid("VIEW_ZD3",oStruMu ,"ZD3Detail")
    oView:addField("VIEW_TOT",oStruTot,"Totais")

    oView:CreateHorizontalBox("AGE_BOX",50)
    oView:CreateHorizontalBox("MEIO_BOX",40)
        oView:CreateVerticalBox("MEIOLEFT",50,"MEIO_BOX")// Vertical BOX
        oView:CreateVerticalBox("MEIORIGHT",50,"MEIO_BOX")// Vertical BOX
    oView:CreateHorizontalBox("ENCH_TOT",10)
    
     oView:SetOwnerView("VIEW_ZD1","AGE_BOX")
        oView:SetOwnerView("VIEW_SB1","MEIOLEFT")
        oView:SetOwnerView("VIEW_ZD3","MEIORIGHT")
    oView:SetOwnerView("VIEW_TOT","ENCH_TOT")

    oView:EnableTitleView("VIEW_ZD1", "Agendamento")
    oView:EnableTitleView("VIEW_SB1", "CDs")
    oView:EnableTitleView("VIEW_ZD3", "M�sicas")

    //oStruCD:RemoveField("B1_NOME")
    oStruAge:RemoveField("ZD1_CODCD")
    oStruMu:RemoveField("ZD3_CODCD")
    oStruCD:RemoveField("B1_XART")
    
    //oView:AddIncrementField("SB1Detail","B1_COD")// gatilho xCodProd()
    oView:AddIncrementField("ZD3Detail","ZD3_COD")
    oView:AddIncrementField("ZD3Detail","ZD3_ITEM")
    oView:SetCloseOnOk({||.T.})
return oView

// Fun��o para verificar o servi�o selecionado para exibir ou ocultar campos necess�rios 
User Function xServ()
    Local lRet :=.F.
        
    lRet := FwAlertYesNo('Selecionou servi�o'+M->ZD1_SERV,'Warning')
    
    //oModel:GetStruct():SetProperty("ZD1_INSTR",MVC_VIEW_CANCHANGE, lRet)
    //oModel:GetStruct():SetProperty("ZD1_CODCA",MVC_VIEW_CANCHANGE, lRet)
    //oModel:GetStruct():SetProperty("ZD1_CONTR",MVC_VIEW_CANCHANGE, lRet)
    

return lRet


/* fun��o chamada no evento CENCELAR, para zerar a vari�vel Private cRegCd que guarda o c�digo que ainda n�o foi gravado.
User Function xCDMcan(cRegCd)
    cRegCd :=NIL
    //FwFreeVar(cRegCd)
return .T.

User Function xArtXcd()
        Local cQuery
        Local cRet :=''
        
        cQuery := " SELECT DISTINCT(B1_XART) as art"
        cQuery += " FROM "+RetSqlName("SB1")
        cQuery += " WHERE D_E_L_E_T_ = '' AND B1_FILIAl ='"+ FwXFilial('SB1')+"'
        
        cQuery:= ChangeQuery(cQuery)   
        DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'xArt',.F.,.T.)
        While xArt->(!EOF())
            cRet+= "|"+xArt->art
            xArt->(DBSKIP())
        EndDo
        IIF(Alltrim(cRet)=='|',cRet:='',cRet)
        xArt->(DBCloseArea())
    
Return cRet
*/
