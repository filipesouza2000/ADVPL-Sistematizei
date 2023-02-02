#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
/*���������������������������������������������������������������������
MVC Modelo 1 com a tabela ZZ1
*/

User Function MVCZZ1()
    Local   aArea := GetArea()
    Local   oBrowseZZ1 

oBrowseZZ1:= FwmBrowse():New()

//passo como par�metro a tabela a mostrar no Browse    
oBrowseZZ1:SetAlias("ZZ1")
oBrowseZZ1:SetDescription('ZZ1-Protheuzeiro')

oBrowseZZ1:AddLegend("ZZ1->ZZ1_STATUS=='2'","RED","Desativado(a)")
oBrowseZZ1:AddLegend("ZZ1->ZZ1_STATUS=='1'","GREEN","Ativo(a)")

//retira a barra de detalhes na base do browse
//oBrowseZZ1:DisableDetails()

//Filtrando os dados
//oBrowseZZ1:SetFilterDefault("ZZ1->ZZ1_STATUS == '1'")

//Exibir determinados campos na tabela, SetOnlyFields, ou RemoveField()  no View
//oBrowseZZ1:SetOnlyFields({"ZZ1_COD","ZZ1_NOME","ZZ1_NOMERE","ZZ1_CPF","ZZ1_BAIRRO","ZZ1_CIDADE"})
oBrowseZZ1:ACTIVATE()
RestArea(aArea)
Return

/*���������������������������������������������������������������������*/
Static Function MenuDef()
    Local aRotina:={}
    ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'ViewDef.MVCZZ1' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'      ACTION 'ViewDef.MVCZZ1' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'      ACTION 'ViewDef.MVCZZ1' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'ViewDef.MVCZZ1' OPERATION 5 ACCESS 0

    /* OPERATION
    1 pesquisar
    2 visualizar
    3 incluir
    4 alterar
    5 excluir
    6 copiar
    */
Return aRotina    

Return 
/*���������������������������������������������������������������������*/
Static Function ModelDef()
    Local oModel := NIL
    Local oStructZZ1 := FWFormStruct(1,'ZZ1')//traz a estrutura da ZZ1
    
    //criando um modelo de dados, com id 'MVCZZ1M'
    oModel:=MPFormModel():New("MVCZZ1M")
    //stribuindo Formul�rio para o modelo
    oModel:AddFields("FormZZ1",/*n�o tem owner pois � modelo 1*/,oStructZZ1)

    oModel:SetPrimaryKey({"ZZ1_FILIAL","ZZ1_CPF"})
    oModel:SetDescription("Modelo de Dados ZZ1")
    oModel:GetModel("FormZZ1")
Return oModel

/*���������������������������������������������������������������������*/
Static Function ViewDef()
    Local oView:= NIL
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel:= FWLoadModel("MVCZZ1")
    //traz a estrutura da ZZ1- (1 model - 2 View)
    Local oStructZZ1 := FWFormStruct(2,"ZZ1")
     //Remover espec�fico campo no View , Remove um campo da estrutura. No lugar de SetOnlyFields    
    oStructZZ1:RemoveField("ZZ1_STATUS")    
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView:=FWFormView():New()    
    oView:SetModel(oModel)
   
    //no view add field (singular)
    oView:AddField("ViewZZ1",oStructZZ1,"FormZZ1")
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("Formul�rio-ZZ1", 100)
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView("ViewZZ1"," Visualiza��o dos registros")
     //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("ViewZZ1","Formul�rio-ZZ1")

Return oView

//API UF
User Function xApiUf()
    Local nX
    Local cRet          := ''        
    Local aHeader       := {}  
    Local cHeaderRet    := ''  
    Local cResult       := ''  
    Local oResult       := {}  
    Begin Sequence        
        cResult := HTTPQuote('https://servicodados.ibge.gov.br/api/v1/localidades/estados/', "GET", "", , , aHeader, @cHeaderRet)
            If !("200 OK" $ cHeaderRet )
            FwAlertError('Erro na Consulta: ' + cResult,'Valida��o')
            Break
        Endif
        If !FWJsonDeserialize( cResult, @oResult )
            FwAlertError('Erro no jSon: ' + cResult,'Valida��o')
            Break
        Endif 
        For nX:= 1 to Len(oResult)
            cRet +=oResult[nX]:sigla +';'
        Next                
        
        RECOVER
    End Sequence
Return cRet
