#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} ITTRELLO
API para integração com Trello
@type class
@version 12.1.33
@author Pedro Carvalho Gonçalves
@since 27/04/2023
/*/

Class ITTRELLO From CTINTEGWS

    Data cToken
    Data cKey
    Data nTimeOut
    Data cUrlBoard
    Data aHeader

    Method New() Constructor
    Method SetHeader()
    Method CriaCard()
    Method RetErr()
    Method GetLista()
    Method GetBoard()
    Method SetToken()

EndClass

/*/{Protheus.doc} New
Construtor
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method New() Class ITTRELLO

    _Super:New('TRELLO')

    Self:cToken    := Self:RetParam('001', 'URL_TOKEN') 
    Self:cKey      := Self:RetParam('001', 'URL_KEY')
    Self:cUrlBoard := Self:RetParam('001', 'URL_BOARD')
    Self:aHeader   := {}
    Self:nTimeOut  := 120

Return


/*/{Protheus.doc} CriaCard
Cria o cartão
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method CriaCard(cIdLista,cTitulo,cDesc) Class ITTRELLO

    Local cUrl      := 'https://api.trello.com/1/cards?'
    Local cRet      := ''
    Local cMsgErr   := ''
    Local lRet      := .T.
    Local cHttpStat := ''
    Local oJson     := JsonObject():New()

    cDesc := cDesc + CRLF + CRLF + 'Solicitante: ' + ZA1->ZA1_NOMSOL

    oJson['name']    := EncodeUTF8(cTitulo)
    oJson['desc']    := EncodeUTF8(cDesc)
    oJson['pos']     := 'top'

    cUrl += Self:SetToken()
    cUrl += '&idList='+cIdLista

    cRet := HttpQuote(cUrl, 'POST', , oJson:ToJson() ,Self:nTimeOut, Self:SetHeader(), @cMsgErr)
    nHttpCode := HTTPGetStatus(@cHttpStat)

    If Self:RetErr() .or. Empty(cRet)
       MsgAlert('Erro ao criar o cartão!','Atenção - ITTRELLO')
       lRet := .F.
    Else
       MsgInfo('Cartão criado com sucesso!', 'Atenção - ITTRELLO')
    Endif

Return lRet

/*/{Protheus.doc} SetHeader
Cria cabeçalho
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method SetHeader() Class ITTRELLO

    Local aHeader := {}

    aAdd(aHeader,'Content-Type: application/json')
    aAdd(aHeader,'Authorization: Bearer '+Self:cToken)    

Return aHeader


/*/{Protheus.doc} RetErr
Retorna erro
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method RetErr() Class ITTRELLO

    Local nHttpCode := 0
    Local cHttpStat := ''
    Local lRet      := .T.

    nHttpCode := HTTPGetStatus(@cHttpStat)

    lRet := !(nHttpCode =  201 .or.  nHttpCode =  200)

Return lRet


/*/{Protheus.doc} GetLista
Retorna array com as listas do board
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method GetLista() Class ITTRELLO

    Local cIdBoard := ''
    Local aListas  := {}
    Local aRet     := {}
    Local cUrl     := 'https://api.trello.com/1/boards/'
    Local cMsgErr  := ''
    Local jRet     := JsonObject():New()
    Local cRet     := ''
    Local nI       := 0

    cIdBoard := Self:GetBoard()

    If !Empty(cIdBoard)
        cUrl += cIdBoard+'?'
        cUrl += Self:SetToken()
        cUrl += '&lists=all'

        cRet := HttpQuote(cUrl, 'GET', , ,Self:nTimeOut, Self:SetHeader(), @cMsgErr)

        If Self:RetErr() .or. Empty(cRet)
            MsgAlert('Erro ao encontrar as listas do quadro do trello! Verifique!','Atenção - ITTRELLO')
        Else
            jRet:FromJson(cRet)
            aListas := jRet['lists']

            For nI := 1 to Len(aListas)
                If !aListas[nI]['closed']
                    aAdd(aRet, {aListas[nI]['id'], aListas[nI]['name']})
                Endif
            Next
        Endif
        
    Else
        MsgAlert('Erro ao acessar o quadro do Trello. Verifique!','Atenção - ITTRELLO')
    Endif

Return aRet


/*/{Protheus.doc} GetBoard
Retorna ID do board
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method GetBoard() Class ITTRELLO

    Local cRet      := ''
    Local cUrl      := Self:cUrlBoard + '.json?'
    Local cMsgErr   := ''
    Local jRet      := JsonObject():New()
    Local cIdBoard  := ''
    Local cHttpStat := ''

    cUrl += Self:SetToken()

    cRet := HttpQuote(cUrl, 'GET', , ,Self:nTimeOut, Self:SetHeader(), @cMsgErr)

    nHttpCode := HTTPGetStatus(@cHttpStat)

    If !Self:RetErr() .and. !Empty(cRet)
        jRet:FromJson(cRet)
        cIdBoard := jRet['id']
    Endif

Return cIdBoard


/*/{Protheus.doc} SetToken
Imputa informações de token e key na url
@type Method
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Method SetToken() Class ITTRELLO

    Local cUrl := ''

    cUrl := 'key='+Self:cKey
    cUrl += '&token='+Self:cToken

Return cUrl
