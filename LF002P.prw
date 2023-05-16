#INCLUDE 'TOTVS.ch'

/*/{Protheus.doc} LF002P
Faz a relacao das guias e gera titulos no contas a pagar
@type Function
@author Pedro Carvalho Goncalves
@since 23/01/2023
@version 12.1.33
/*/

User Function LF002P()
    
    If !Pergunte('LF002P')
        Return
    Endif

    If !fRetGuias()
        MsgAlert('Nenhum dado a exibir dentre os parametros informados!', "Atencao")
    Endif

Return 

/*/{Protheus.doc} fRetGuias
Faz a relacao das guias e gera titulos no contas a pagar
@type Function
@author Pedro Carvalho Goncalves
@since 23/01/2023
@version 12.1.33
/*/

Static Function fRetGuias()

    Local cALTMP := GetNextAlias()
    Local aArea  := GetArea()
    Local lRet   := .T.
    Private _aCols := {}

    BEGINSQL Alias cALTMP

        SELECT 
            F6_FILIAL,
            F6_NUMERO,
            F6_EST,
            F6_DTARREC,
            F6_VALOR,
            F6_DTPAGTO,
            F6_JUROS,
            F6_MULTA,
            F6_ATMON,
            F6_CDBARRA
        FROM %Table:SF6%
        WHERE 
                F6_FILIAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
            AND F6_DTARREC BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
            AND F6_EST = %Exp:mv_par05%
            AND F6_GNREWS = 'S'
            AND F6_SE2TIT = ' '
            AND %NotDel%
        ORDER BY 
            F6_EST,
            F6_NUMERO

    ENDSQL

    If (cALTMP)->(Eof())
        lRet := .F.
    Else
        While !(cALTMP)->(Eof())
            aAdd(_aCols, {;
                (cALTMP)->F6_FILIAL,; 
                (cALTMP)->F6_NUMERO,;
                (cALTMP)->F6_EST,;
                (cALTMP)->F6_DTARREC,; 
                (cALTMP)->F6_VALOR,;
                (cALTMP)->F6_DTPAGTO,; 
                (cALTMP)->F6_JUROS,; 
                (cALTMP)->F6_MULTA,; 
                (cALTMP)->F6_ATMON,;
                (cALTMP)->F6_CDBARRA,; 
                .F.})
            (cALTMP)->(DbSkip())
        End
            fMontaTela()
    Endif


    (cALTMP)->(DbCloseArea())
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} fMontaTela
Monta a tela do browse
@type Function
@author Pedro Carvalho Goncalves
@since 23/01/2023
@version 12.1.33
/*/

Static Function fMontaTela()

    Local oOk        := LoadBitmap(GetResources(), "LBOK")
    Local oNo        := LoadBitmap(GetResources(), "LBNO")  
    Private _oGrid   := Nil
    Private nMark    := 0

    SetPrvt("_oJanela","oPainel","oBtn1","oBtn2")

    _oJanela := MSDialog():New( 085,235,788,1303,"_oJanela",,,.F.,,,,,,.T.,,,.T. )
    oPainel  := TPanel():New( 036,000,"oPainel",_oJanela,,.F.,.F.,,,528,308,.T.,.F. )
    oBtn1    := TButton():New( 008,348,"Gerar",_oJanela,{||Iif(MsgYesNo('Deseja gerar titulos das guias selecionadas?','Atencao'),fGeraTit(),)},072,020,,,,.T.,,"",,,,.F. )
    oBtn2    := TButton():New( 008,431,"Cancelar",_oJanela,{||_oJanela:End()},072,020,,,,.T.,,"",,,,.F. )

    _oGrid   := TCBrowse():New(0, 0, 10, 10,,,, oPainel,,,,,,,,,,,,,, .F.,,,, .T., .T.)   

    _oGrid:Align := CONTROL_ALIGN_ALLCLIENT
    _oGrid:SetArray(_aCols)

    _oGrid:AddColumn(TCColumn():New('   ', {|| Iif(_aCols[_oGrid:nAt, 11],oOk,oNo)},,,,, 15, .T., .F.))
    _oGrid:AddColumn(TCColumn():New('Filial', {|| _aCols[_oGrid:nAt, 01]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('N° Guia', {|| _aCols[_oGrid:nAt, 02]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Estado.', {|| _aCols[_oGrid:nAt, 03]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Dt. Recebto', {|| _aCols[_oGrid:nAt, 04]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Valor', {|| _aCols[_oGrid:nAt, 05]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Dt. Pagto', {|| _aCols[_oGrid:nAt, 06]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Juros', {|| _aCols[_oGrid:nAt, 07]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Multa', {|| _aCols[_oGrid:nAt, 08]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('At. Monet.', {|| _aCols[_oGrid:nAt, 09]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Cod. Barras', {|| _aCols[_oGrid:nAt, 10]},,,,, 40))

    _oGrid:bHeaderClick   := {|| fMarkItem(.T.)}
    _oGrid:bLDblClick     := {|| fMarkItem()}
    _oJanela:Activate(,,,.T.)

Return


/*/{Protheus.doc} fMarkItem
Marca e desmarca a caixinha do grid
@type  Function
@author Pedro Carvalho Goncalves
@since 23/01/2023
@version 12.1.33
/*/

Static Function fMarkItem(lAll)

    Local nI := 0
    Default lAll := .F.

    If lAll
        For nI := 1 to Len(_aCols)
            Iif(_aCols[nI,11],nMark--,nMark++)
            _aCols[nI, 11] := !_aCols[nI, 11]
        Next
    Else
        nI := _oGrid:nAt
        Iif(_aCols[nI,11],nMark--,nMark++)
        _aCols[nI, 11] := !_aCols[nI, 11]
    EndIf
    _oGrid:Refresh()

Return

/*/{Protheus.doc} fGeraTit
Marca e desmarca a caixinha do grid
@type  Function
@author Pedro Carvalho Goncalves
@since 23/01/2023
@version 12.1.33
/*/

Static Function fGeraTit()

    Local nI         := 0
    Local aDadosAuto := {}
    Local aTitSF6    := {}
    Local dVcto      := LastDay(dDataBase,2)
    Local nCont      := 0
    Local nOpc       := 0
    Local nErro      := 0
    Local lBreak     := .F.
    Local nReg       := nMark    
    Private lMsErroAuto := .F.
    
        For nI := 1 to Len(_aCols)
        
            If _aCols[nI,11]

                aDadosAuto := {}
                nReg--

                aAdd(aDadosAuto, {"E2_FORNECE",         mv_par06,                                     Nil})
                aAdd(aDadosAuto, {"E2_LOJA",            mv_par07,                                     Nil})
                aAdd(aDadosAuto, {"E2_EMISSAO",         dDataBase,                                    Nil})
                aAdd(aDadosAuto, {"E2_VENCTO",          dVcto,                                        Nil})
                aAdd(aDadosAuto, {"E2_VENCREA",         dVcto,                                        Nil})
                aAdd(aDadosAuto, {"E2_NUM",             GetSxeNum('SE2','E2_NUM'),                    Nil})
                aAdd(aDadosAuto, {"E2_TIPO",            'GUI',                                        Nil})
                aAdd(aDadosAuto, {"E2_PREFIXO",         '000',                                        Nil})
                aAdd(aDadosAuto, {"E2_NATUREZ",         '2010102022',                                 Nil})
                aAdd(aDadosAuto, {"E2_JUROS",           _aCols[nI,07],                                Nil})
                aAdd(aDadosAuto, {"E2_MULTA",           _aCols[nI,08],                                Nil})
                aAdd(aDadosAuto, {"E2_CORREC",          _aCols[nI,09],                                Nil})
                aAdd(aDadosAuto, {"E2_VALOR",           (_aCols[nI,05]+_aCols[nI,07]+_aCols[nI,08]+_aCols[nI,09]),                                Nil})
                aAdd(aDadosAuto, {"E2_CODBAR",          _aCols[nI,10],                                Nil})
                aAdd(aDadosAuto, {"E2_DATALIB",         dDataBase,                                    Nil})
                aAdd(aDadosAuto, {"E2_USUALIB",         cUserName,                                    Nil})
                aAdd(aDadosAuto, {"E2_STATLIB",         '03',                                         Nil})

                Begin Transaction

                    FWMsgRun(,{||MSExecAuto({|x,y| FINA050(x,y)}, aDadosAuto, 3)},"Incluindo titulo da guia " +_aCols[nI,02] ,"Incluindo...")
                    
                    If lMsErroAuto
                        DisarmTransaction()
                        RollBackSX8()
                        nOpc := Aviso('Erro ao gerar a guia '+_aCols[nI,02],MostraErro(), {'Continuar','Cancelar Operacao'},3)

                        If nOpc = 2
                            lBreak := .T.
                            nI := Len(_aCols)+1 
                        Else
                            nErro++
                        Endif
                    Else
                        ConfirmSX8()
                        nCont++
                        aAdd(aTitSF6, {aDadosAuto[6,2], _aCols[nI,01],_aCols[nI,02],_aCols[nI,03]})
                    Endif
                    
                End Transaction

            Endif

        Next 

        If (lBreak .and. nCont > 0) .or. (!lBreak .and. nCont > 0 .and. nErro > 0)
            MsgAlert('Titulos Gerados: '+cValToChar(nCont) + CRLF + 'Titulos com erro:' + cValtoChar(nErro) + CRLF + 'Titulos restantes: '+CValToChar(nMark), 'Titulos gerados parcialmente!')
            fVincSF6(aTitSF6)
            _oJanela:End()
        Endif

        If !lBreak .and. nCont = 0 .and. nErro = 0
            MsgAlert('Favor selecione algum registro!', 'Atencao')
        Endif

        If !lBreak .and. nCont > 0 .and. nErro = 0
            MsgInfo('Titulos gerados com sucesso!', 'Atencao')
            fVincSF6(aTitSF6)
            _oJanela:End()
        Endif
Return

/*/{Protheus.doc} fVincSF6
Vincula o n° do titulo gerado na SF6
@type  Function
@author Pedro Carvalho Gonçalves
@since 24/01/2023
@version 12.1.33
/*/

Static Function fVincSF6(aTitSF6)
    
    Local nI := 0

        If Select('SF6') = 0
            DbSelectArea('SF6')
        Endif

        SF6->(DbSetOrder(1)) //  F6_FILIAL+F6_EST+F6_NUMERO
        SF6->(DbGoTop())

        For nI := 1 to Len(aTitSF6)

            If SF6->(MsSeek(aTitSF6[nI,02] + aTitSF6[nI,04] + aTitSF6[nI,03]))

                RecLock('SF6',.F.)
                    SF6->F6_SE2TIT := aTitSF6[nI,01]
                SF6->(MsUnlock())

            Endif

        Next

Return 
