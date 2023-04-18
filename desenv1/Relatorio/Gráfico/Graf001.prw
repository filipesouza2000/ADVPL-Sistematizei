#INCLUDE 'Protheus.CH'

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---Data---|-----Autor-------|-------Descri��o------------
17/02/2023| Filipe Souza    | Gr�fico com a ferramenta FWChartBar
@see https://tdn.totvs.com.br/display/public/framework/FWChartBar
@see https://terminaldeinformacao.com/2016/09/06/criando-graficos-advpl-fwchartbar/
    � FWChartBar    � Gr�ficos de Barra
    � FWChartBarComp� Gr�ficos de Barra (Compara��o)
    � FWChartLine   � Gr�ficos de Linha
    � FWChartPie    � Gr�ficos de Pizza
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
User Function Graf001()
    Local oChart
    Local oDlg
    Local aRand :={}

    //criar janela para exii��o do gr�fico
    DEFINE MSDIALOG oDlg PIXEL FROM 0,0 TO 500,700
        oChart := FWChartBar():New()
                //oOwner,lSerieLabel,lShadow
        oChart:Init(oDlg,.T.,.T.)
        oChart:SetTitle("Vendas por M�s",CONTROL_ALIGN_CENTER)
        //Adiciona as s�ries, com as descri��es e valores
        oChart:addSerie("Ano 2019", 20044453.50)
        oChart:addSerie("Ano 2020", 21044453.35)
        oChart:addSerie("Ano 2021", 22044453.15)
        oChart:addSerie("Ano 2022", 23044453.10)
        oChart:addSerie("Ano 2023", 25544453.01)
         
        //Define que a legenda ser� mostrada na esquerda
        oChart:setLegend( CONTROL_ALIGN_LEFT )
         
        //Seta a m�scara mostrada na r�gua
        oChart:cPicture := "@E 999,999,999,999,999.99"
         
        //Define as cores que ser�o utilizadas no gr�fico
        aAdd(aRand, {"084,120,164", "007,013,017"})
        aAdd(aRand, {"171,225,108", "017,019,010"})
        aAdd(aRand, {"207,136,077", "020,020,006"})
        aAdd(aRand, {"166,085,082", "017,007,007"})
        aAdd(aRand, {"130,130,130", "008,008,008"})
         
        //Seta as cores utilizadas
        oChart:oFWChartColor:aRandom := aRand
        oChart:oFWChartColor:SetColor("Random")
         
        //Constr�i o gr�fico
        oChart:Build()
    ACTIVATE MSDIALOG oDlg CENTERED

return
