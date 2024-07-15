#INCLUDE 'protheus.ch'
#INCLUDE "TopConn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE 'totvs.ch'

/*++++DATA++++|++++AUTOR+++++|++++++++++++++++DESCRI��O+++++++++++++
  22/06/2023  | Filipe Souza |  Exerc�cio Conex�oNF-e:
                                Desenvolver um programa que tenha a fun��o de processar um arquivo XML e 
                                retornar para o usu�rio se o documento de entrada est� ou n�o lan�ado no Protheus.  
    Requisitos
    -O programa deve solicitar o arquivo XML para o usu�rio por meio da fun��o cGetFile (utilizar como exemplo o arquivo: 99221704876700009490006008031800463126653400-nfe.xml). 
    -Ap�s capturar o arquivo, processar o conte�do do XML utilizando a classe TXmlManager. 
    -Capturar n�mero, s�rie e CNPJ do emissor do XML. 
    -Utilizar o CNPJ para procurar o cadastro do fornecedor (SA2). 
    -Com o c�digo e loja do fornecedor, procurar no documento de entrada (SF1) se existe um registro com o mesmo n�mero, s�rie, fornecedor e loja (utilizar TCGenQry ou BeginSql nas buscas de fornecedor e documento de entrada). 
    -No final, apresentar um alerta indicando se foi ou n�o encontrado o documento de entrada.
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  22/06/2023  | Filipe Souza |  Nova estrutura de leitura do xml, formando json
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function procXML()
    Local oXml,oJson
    Local lRead     :=.F.
    Local lNode     :=.F.
    Local cL        :=Chr(10)+Chr(13)
    Local aIde      :={}
    Local aEmit     :={}
    Local aArea     := GetArea()
    Local cXMl,cCodF, cLojaF,cCNPJ,cNota ,cSerie ,ckey, cQuery,cWhere,cTp,cJson,cError,cMessage

    cXMl := cGetFile('*.xml','Buscar arquivo XML',0,'C:\TOTVS12133\Protheus\protheus_data\xmlnfe\new',.F.,GETF_LOCALHARD + GETF_NOCHANGEDIR,.T.)
    If cXMl == '' .OR. cXMl == nil
        FWAlertError("Xml n�o selecionado ","XMl Info erro")
    else
        oXml := TXmlManager():New()
        lRead := oXml:Parse(MemoRead(cXml))
        If lRead == .F.
            FWAlertError('Erro na leitura'+cL+oXML:Error(),'Error')
            return
        EndIf
        oXML :DOMChildNode()//<NFe
        oXML :DOMChildNode()//<infNFe
        ckey := oXml:DOMGetAtt('Id')//chave da nfe
        oXML :DOMChildNode()//<ide
        //verifica se existe o n�
        If oXml:CNAME == "ide"            
            aIde    := oXML:DOMGetChildArray()
            cJson   :=arrToJson(aIde)
            oJson   := JsonObject():New()
            cError  := oJson:FromJson(cJson)
            lNode   :=.T.
        else 
            cMessage:="-Estrutura XML incompleta, <ide> inexistente."+cL
            lNode     :=.F.
        endif 
        
        IF lNode .and. Empty(cError)
            if oJson:hasProperty('serie')
                cSerie := oJson:GetJsonObject('serie')
            else
                cMessage:="-Estrutura XML incompleta, <serie> inexistente."+cL
                lNode     :=.F.
            endif 
            if lNode .and.  oJson:hasProperty('nnf')
                cNota := oJson:GetJsonObject('nnf')
            else
                cMessage:="-Estrutura XML incompleta, <nnf> inexistente."+cL
                lNode     :=.F.
            endif     
            if lNode .and.  oJson:hasProperty('nnf')
                cTp := oJson:GetJsonObject('tpnf')
            else
                cMessage:="-Estrutura XML incompleta, <tpnf> inexistente."+cL
                lNode     :=.F.
            endif           
        else
            FWAlertError(cError)
        endif
    /*
        For nX:= 1 to Len(aIde)
            If UPPER(aIde[nX][1])=='SERIE'
                cSerie := aIde[nX][2]
            ELSEIF UPPER(aIde[nX][1])=='NNF'
                cNota  := aIde[nX][2]
            ELSEIF UPPER(aIde[nX][1])=='TPNF'
                cTp    := aIde[nX][2]
            EndIf            
        Next
    */

        oXML:DOMPrevNode()
        oXML:DOMNextNode()//<emit
        aEmit := oXML:DOMGetChildArray()

        cJson:=arrToJson(aEmit)
        oJson:= JsonObject():New()
        cError  := oJson:FromJson(cJson)

        IF Empty(cError)
            cCNPJ := oJson:GetJsonObject('CNPJ')
        else
            FWAlertError(cError)
        endif
    /*
        For nX:= 1 to Len(aEmit)
            If UPPER(aEmit[nX][1])=='CNPJ'
                cCNPJ := aEmit[nX][2]            
            EndIf            
        Next
    */
        //-Utilizar o CNPJ para procurar o cadastro do fornecedor (SA2). A2_CGC 14   A2_COD  6    
        /*DBSelectArea("SA2")
        SA2->(DbSetOrder(3))// A2_FILIAL + A2_CGC
        If !SA2->(DBSEEK(xFilial('SA2')+cCNPJ))
            MSGALERT( "Fornecedor n�o econtrado com CGC:"+cCNPJ +cL+;
                    "Ser� preciso efetuar seu registro.", "Erro na importa��o XML" )
        EndIf*/
        cQuery := "SELECT A2_COD,A2_LOJA "
        cQuery += " FROM "+RetSqlName("SA2")
        cQuery += " WHERE D_E_L_E_T_ = '' AND A2_FILIAl ='"+ FwXFilial('SA2')+ "' AND A2_CGC = '"+cCNPJ+"'"
        
        cQuery:= ChangeQuery(cQuery)   
        DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'A2',.F.,.T.)
        cCodF :=''
        cLojaF:=''
        If A2->(!EOF())
            cCodF := Alltrim(A2->A2_COD)
            cLojaF:= Alltrim(A2->A2_LOJA)
            A2->(DBSKIP())
        EndIf
        If Alltrim(cCodF)=='' .AND. Alltrim(cLojaF)==''
            FWAlertWarning( "Fornecedor n�o econtrado com CGC:"+cCNPJ +cL+;
                    "Ser� preciso efetuar seu registro.", "Erro na importa��o XML" )
            A2->(DBCloseArea())
            return
        EndIf    
        A2->(DBCloseArea())
        //procurar no documento de entrada (SF1)
        //F1 order 1 Filial+Doc+Serie+Fornece+Loja+Tipo
        cWhere :=" AND F1_FILIAL = '"+ FwXFilial("SF1")+"' AND F1_DOC='"+cNota+"' AND F1_SERIE = '"+cSerie+"'"+cL+;
                " AND F1_FORNECE = '"+cCodF+"' AND F1_LOJA='"+cLojaF+"' AND F1_TIPO='"+cTp+"' "
        cWhere := "%"+cWhere+"%"
        
        cF1 := GetNextAlias()
        BeginSql Alias cF1
            SELECT  F1_DOC
            FROM	%table:SF1%  F1
            WHERE   F1.%NOTDEL%
            %exp:cwhere%
        EndSql 

        IF Alltrim(F1_DOC) != ''
            FWAlertWarning( "J� existe documento de entrada com o n�mero "+cNota, "Importa��o de XML" )
        else
            FWAlertSuccess( "Documento de entrada "+cNota+cL+"registrado com sucesso.", "Importa��o de XML" )
        endif    
        (cF1)->(DBCloseArea())
         
    EndIf  
    FreeObj(oJson)
    RestArea(aArea)
return 
