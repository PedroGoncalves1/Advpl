#INCLUDE 'TOTVS.ch'
 
/*/{Protheus.doc} LF001P
Gera as guias para transmissão do pagamento do DIFAL ao GNRE
@type  Function
@author Pedro Carvalho Gonçalves
@since 18/01/2023
@version 12.1.33
/*/

User Function LF001P()
    
    If !Pergunte('FSR087', .T.)
        Return
    Endif

    If !fRetGuias()
        MsgAlert("Nenhum dado a ser exibido de acordo com os parametros informados!", "Atencao")
    Endif

Return 

/*/{Protheus.doc} fRetGuias
Executa a query e traz a tela com as informações
@type  Function
@author Pedro Carvalho Gonçalves
@since 18/01/2023
@version 12.1.33
/*/

Static Function fRetGuias()

    Local cALTMP  := GetNextAlias()
    Local aArea   := GetArea()
    Local cUFIE   := '%' + FormatIn(GetMV('CT_UFIEAT',.F.,'SP|PR'),'|') + '%'
    Local lRet    := .T.
    Local aFils   := {}
    Local aFilial := {}
    Local cFils   := ''
    Local nI     := 1
    Private _aCols := {}


    If mv_par03 = 1

        aFils := MatFilCalc( .T. )

        For nI := 1 to Len(aFils)

            If aFils[nI,1]
                aAdd(aFilial,aFils[nI,2])
                cFils := cFils + aFils[nI,2] + '|'
            Endif
            
        Next

        cFils := '%' + FormatIn(SubStr(cFils, 1, (Len(cFils)-1)),'|') + '%'
    Else
        cFils := cFilAnt
    Endif

    BeginSql Alias cALTMP

       SELECT
		    SF2.F2_GNRDIF, 
            SUBSTRING(SF2.F2_GNRDIF, 4, 9) AS F2_NUMTIT, 
            SUBSTRING(SF2.F2_GNRDIF, 1, 3) AS F2_PREFIXO,
            SF2.F2_GNRFECP, 
		    SF3.F3_FILIAL, 
            SF3.F3_CFO, 
            SF3.F3_NFISCAL, 
            SF3.F3_SERIE, 
            SF3.F3_DIFAL,
            SF3.F3_ICMSCOM, 
            SF3.F3_VFCPDIF, 
            SF3.F3_ESTADO,
		    SF3.F3_EMISSAO, 
            SF3.F3_CLIEFOR, 
            SF3.F3_LOJA, 
            SF3.F3_TIPO,  
            SF3.F3_VALCONT,
            SF3.F3_BASEICM
        FROM %Table:SF2% SF2
        INNER JOIN %Table:SF3% SF3 ON
            SF3.F3_FILIAL		= SF2.F2_FILIAL AND 
            SF3.F3_NFISCAL 		= SF2.F2_DOC AND 
            SF3.F3_SERIE 		= SF2.F2_SERIE AND 
            SF3.F3_CLIEFOR 		= SF2.F2_CLIENTE AND 
            SF3.F3_LOJA 		= SF2.F2_LOJA AND 
            SF3.F3_ENTRADA		= SF2.F2_EMISSAO AND
            SF3.F3_ENTRADA		>= %Exp:DToS (mv_par01)%  AND
            SF3.F3_ENTRADA		<= %Exp:DToS (mv_par02)%  AND
            (SF3.F3_DIFAL 		> 0 OR (SF3.F3_BASEDES 	> 0 AND  SUBSTRING(SF3.F3_CFO,1,1)>='5')) AND
            SF3.F3_DTCANC       = ' ' AND
            SF3.F3_ESTADO       NOT IN %Exp:cUFIE% AND
            SF3.%NotDel%
        WHERE
            SF2.F2_FILIAL IN %Exp:cFils% AND
            SF2.%NotDel% AND
            NOT EXISTS (
                SELECT
                    SF6.F6_FILIAL,
                    SF6.F6_DOC,
                    SF6.F6_SERIE, 
                    SF6.F6_CLIFOR, 
                    SF6.F6_LOJA 
                FROM %Table:SF6% SF6
                WHERE
                    SF3.F3_FILIAL	= SF6.F6_FILIAL AND 
                    SF3.F3_NFISCAL 	= SF6.F6_DOC    AND
                    SF3.F3_SERIE 	= SF6.F6_SERIE  AND
                    SF3.F3_CLIEFOR 	= SF6.F6_CLIFOR AND
                    SF3.F3_LOJA 	= SF6.F6_LOJA   AND
                    SF6.%NotDel%
                )
        ORDER BY
            SF3.F3_ESTADO
    ENDSQL


    If !(cALTMP)->(Eof())
        While !(cALTMP)->(Eof())

             aAdd(_aCols, {;
                (cALTMP)->F3_FILIAL,; 
                (cALTMP)->F2_NUMTIT,;
                (cALTMP)->F2_PREFIXO,;
                (cALTMP)->F2_GNRFECP,; 
                (cALTMP)->F2_GNRDIF,;
                (cALTMP)->F3_CFO,; 
                (cALTMP)->F3_NFISCAL,; 
                (cALTMP)->F3_SERIE,; 
                (cALTMP)->F3_DIFAL,;
                (cALTMP)->F3_ICMSCOM,; 
                (cALTMP)->F3_VFCPDIF,; 
                (cALTMP)->F3_ESTADO,;
                (cALTMP)->F3_EMISSAO,; 
                (cALTMP)->F3_CLIEFOR,; 
                (cALTMP)->F3_LOJA,; 
                (cALTMP)->F3_TIPO,;  
                (cALTMP)->F3_VALCONT,;
                (cALTMP)->F3_BASEICM,;
                .F.})

            (cALTMP)->(DbSkip())

        End
        fMontaTela()
    Else
        lRet := .F.
    Endif

    (cALTMP)->(DbCloseArea())
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} fMontaTela
Monta a tela com as informações trazidas
@type  Function
@author Pedro Carvalho Gonçalves
@since 18/01/2023
@version 12.1.33
/*/

Static Function fMontaTela()

    SetPrvt("_oJanela","oPainel","oBtn1","oBtn2")

    Local oOk        := LoadBitmap(GetResources(), "LBOK")
    Local oNo        := LoadBitmap(GetResources(), "LBNO")  
    Private _oGrid := Nil

    _oJanela    := MSDialog():New( 094,000,842,1595,"Selecione os registros que deseja gerar",,,.F.,,,,,,.T.,,,.T. )
    oPainel    := TPanel():New( 028,000,"",_oJanela,,.F.,.F.,,,780,326,.T.,.F. )
    oBtn1      := TButton():New( 008,592,"Confirmar"    ,_oJanela,{||fGeraGuia()}      ,052,016,,,,.T.,,"",,,,.F. )
    oBtn2      := TButton():New( 008,701,"Cancelar"     ,_oJanela,{||_oJanela:End()}    ,052,016,,,,.T.,,"",,,,.F. )
    _oGrid     := TCBrowse():New(0, 0, 10, 10,,,, oPainel,,,,,,,,,,,,,, .F.,,,, .T., .T.)   

    _oGrid:Align := CONTROL_ALIGN_ALLCLIENT
    _oGrid:SetArray(_aCols)

    _oGrid:AddColumn(TCColumn():New('   ', {|| Iif(_aCols[_oGrid:nAt, 19],oOk,oNo)},,,,, 15, .T., .F.))
    _oGrid:AddColumn(TCColumn():New('Filial', {|| _aCols[_oGrid:nAt, 01]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Tit. Difal', {|| _aCols[_oGrid:nAt, 02]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Prefixo', {|| _aCols[_oGrid:nAt, 03]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('GNRFECP', {|| _aCols[_oGrid:nAt, 04]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Diferenca GNR', {|| _aCols[_oGrid:nAt, 05]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('CFO', {|| _aCols[_oGrid:nAt, 06]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Documento', {|| _aCols[_oGrid:nAt, 07]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Serie', {|| _aCols[_oGrid:nAt, 08]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Difal', {|| _aCols[_oGrid:nAt, 09]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('ICMSCOM', {|| _aCols[_oGrid:nAt, 10]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('VFCPDIF', {|| _aCols[_oGrid:nAt, 11]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Estado', {|| _aCols[_oGrid:nAt, 12]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Emissao', {|| _aCols[_oGrid:nAt, 13]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Cli/For', {|| _aCols[_oGrid:nAt, 14]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Loja', {|| _aCols[_oGrid:nAt, 15]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Tipo', {|| _aCols[_oGrid:nAt, 16]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('ValorCont', {|| _aCols[_oGrid:nAt, 17]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Base ICMS', {|| _aCols[_oGrid:nAt, 18]},,,,, 40))

    _oGrid:bHeaderClick   := {|| fMarkItem(.T.)}
    _oGrid:bLDblClick     := {|| fMarkItem()}
    _oJanela:Activate(,,,.T.)


Return

/*/{Protheus.doc} fGeraGuia
Monta a tela com as informacoes trazidas
@type  Function
@author Pedro Carvalho Goncalves
@since 18/01/2023
@version 12.1.33
/*/

Static Function fGeraGuia()

   Local nI         := 0 
   Local oModel     := FwLoadModel('MATA960') 
   Local aDadosAuto := {}
   Local cFilBkp    := cFilAnt

   Private aRotina  := {}
   Private lMsErroAuto := .F.
 
   For nI := 1 to Len(_aCols)

        If (_aCols[nI,19])

            lMsErroAuto := .F.
            aDadosAuto  := {}
            cFilant := _aCols[nI,01]
            aAdd(aDadosAuto, {"F6_EST",            _aCols[nI,12],                                 Nil})
            aAdd(aDadosAuto, {"F6_TIPOIMP",        'B',                                           Nil})
            aAdd(aDadosAuto, {"F6_VALOR",          _aCols[nI,09],                                 Nil})
            aAdd(aDadosAuto, {"F6_DTARREC",        StoD(_aCols[nI,13]),                           Nil})
            aAdd(aDadosAuto, {"F6_DTVENC",         StoD(_aCols[nI,13]),                           Nil})
            aAdd(aDadosAuto, {"F6_MESREF",         Month(StoD(_aCols[nI,13])),                    Nil})
            aAdd(aDadosAuto, {"F6_ANOREF",         Year(StoD(_aCols[nI,13])),                     Nil})
            aAdd(aDadosAuto, {"F6_CODREC",         GetMV('MV_DIFNAT',.F.,'100102'),               Nil})
            aAdd(aDadosAuto, {"F6_DOC",            _aCols[nI,07],                                 Nil})
            aAdd(aDadosAuto, {"F6_SERIE",          _aCols[nI,08],                                 Nil})
            aAdd(aDadosAuto, {"F6_CLIFOR",         _aCols[nI,14],                                 Nil})
            aAdd(aDadosAuto, {"F6_LOJA",           _aCols[nI,15],                                 Nil})
            aAdd(aDadosAuto, {"F6_OPERNF",         '2',                                           Nil})
            aAdd(aDadosAuto, {"F6_DTPAGTO",        LastDay(dDataBase,2),                          Nil})
            aAdd(aDadosAuto, {"F6_REF",            '1',                                           Nil})
            aAdd(aDadosAuto, {"F6_COBREC",         '000',                                         Nil}) 
            aAdd(aDadosAuto, {"F6_TIPOGNU",        fRetDocOri(_aCols[nI,12]),                     Nil})
            aAdd(aDadosAuto, {"F6_DOCORIG",        Iif(aDadosAuto[17,2] $ '22|24','2','1'),       Nil})

            FwMsgRun(,{||FwMVCRotAuto(oModel, 'SF6', 3, {{'MATA960MOD', aDadosAuto}})},"Incluindo registros...","Incluindo guia "+aDadosAuto[9,2]+"-"+_aCols[nI,08]+"...")

        Endif

        If lMsErroAuto
            MostraErro()
            Break
        Endif

   Next

   If Len(aDadosAuto) > 0 .and. !lMsErroAuto
       MsgInfo("Registros Incluidos com sucesso!", "Atencao")
       _oJanela:End()
   ElseIf Len(aDadosAuto) = 0 
       MsgInfo("Selecione algum registro!")
   Endif

   cFilAnt := cFilBkp                                                                                                                      

Return


/*/{Protheus.doc} fMarkItem
Marca e desmarca a caixinha do grid
@type  Function
@author Pedro Carvalho Goncalves
@since 18/01/2023
@version 12.1.33
/*/

Static Function fMarkItem(lAll)

    Local nI := 0
    Default lAll := .F.

    If lAll
        For nI := 1 to Len(_aCols)
            _aCols[nI, 19] := !_aCols[nI, 19]
        Next
    Else
        nI := _oGrid:nAt
        _aCols[nI, 19] := !_aCols[nI, 19]
    EndIf
    _oGrid:Refresh()

Return


/*/{Protheus.doc} fRetDocOri
Retorna o Doc. de Origem do estado informado
@type  Static Function
@author Pedro Carvalho Goncalves
@since 18/01/2023
@version 12.1.33
/*/

Static Function fRetDocOri(p_cEstado)

    Local cDocOri := ''

    If p_cEstado $ 'AM|MT|RN|RS|TO'
        cDocOri := '22'
    ElseIf p_cEstado $ 'PE|RJ|SC'
        cDocOri := '24'
    Else 
        cDocOri := '10'
    Endif

Return cDocOri

