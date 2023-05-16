#INCLUDE 'restful.ch'
#include 'totvs.ch'

/*/{Protheus.doc} REST
API básica do tipo GET que retorna a relação de clientes passadas de acordo com os parâmetros informados.
@author Pedro Carvalho Gonçalves
@since 27/03/2023
@version 12.2.1220
/*/

WSRESTFUL APICLI DESCRIPTION "REST" FORMAT APPLICATION_JSON
WSDATA cgc  as  CHARACTER OPTIONAL
WSDATA cod  as  CHARACTER OPTIONAL
WSDATA loja as  CHARACTER OPTIONAL

WSMETHOD GET ConsultaCliente;
    DESCRIPTION "API criada por Pedro Carvalho que retorna informações do cliente";
    WSSYNTAX "/consultacli/?{cgc}&{cod}&{loja}";
    PATH "/consultacli/";
    TTALK "Consultaclientes";
    PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD GET ConsultaCliente HEADERPARAM cgc, cod, loja WSSERVICE REIDOAPI

    Local oResponse := Nil
    Local cWhere    := ''
    Local cAlTMP    := GetNextAlias()
    Local lRet      := .T. 
    Local oSend     := Nil
    Local oConstr   := Nil
    Local aResp     := {}
    Local cMsg      := ''
    Local cCgc      := Iif(Valtype(Self:cgc)  = "U" .or. Len(Self:cgc) < 11, "", Self:cgc)
    Local cCod      := Iif(Valtype(Self:cod)  = "U" .or. Len(Self:cod) != 6, "", Self:cod)
    Local cLoja     := Iif(Valtype(Self:loja) = "U" .or. Len(Self:loja)!= 2, "", Self:loja)

    If !Empty(cCgc)
        cWhere := "A1_CGC = '"+cCgc+"' AND "
    Endif
    If !Empty(cCod)
        cWhere += "A1_COD = '"+cCod+"' AND "
    Endif
    If !Empty(cLoja)
        cWhere += "A1_LOJA = '"+cLoja+"' AND "
    Endif

    If Empty(cLoja) .and. Empty(cCod) .and. Empty(cCgc)
        cWhere := '1=1 AND'
    Endif

    If lRet 
        cWhere := "%" + cWhere + "%"

        BEGINSQL Alias cAlTMP
            SELECT 
                A1_COD,
                A1_LOJA,
                A1_CGC,
                A1_NOME,
                A1_NREDUZ,
                A1_END,
                A1_EMAIL
            FROM %Table:SA1%
            WHERE
                %Exp:cWhere% 
                A1_FILIAL = %Exp:xFilial('SA1')% AND
                A1_MSBLQL = '2' AND
                %NotDel% 
         ENDSQL

        If (cALTMP)->(Eof())
            cMsg := 'Não encontramos registros com estes filtros. Verifique se os parametros foram digitados corretamente ou se o cliente está bloqueado!'
            lRet := .F.
        Else
            While !(cALTMP)->(Eof())
                oConstr := JsonObject():New()
                oConstr['Codigo']    := (cALTMP)->A1_COD
                oConstr['Loja']      := (cALTMP)->A1_LOJA
                oConstr['CPFCNPJ']   := (cALTMP)->A1_CGC
                oConstr['Nome']      := (cALTMP)->A1_NOME
                oConstr['NomeReduz'] := (cALTMP)->A1_NREDUZ
                oConstr['Endereço']  := (cALTMP)->A1_END
                oConstr['Email']     := (cALTMP)->A1_EMAIL       

                aAdd(aResp,oConstr)         

                (cALTMP)->(DbSkip())
            End
            oSend := JsonObject():New()
            oSend['Resposta'] := aResp
            Self:SetResponse(EncodeUtf8(oSend:ToJson()))

            oConstr   := Nil
            oSend     := Nil
            oResponse := Nil
            FreeObj(oConstr)
            FreeObj(oSend)
            FreeObj(oResponse)

        Endif

    Endif
    If !lRet
        oResponse := JsonObject():New()
        oResponse['Erro'] := cMsg
        Self:SetResponse(EncodeUtf8(oResponse:ToJson()))
        Freeobj(oResponse)
    Endif

Return lRet 
