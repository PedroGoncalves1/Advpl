#INCLUDE 'TOTVS.CH'

 /*/{Protheus.doc} DBCO002P
Gera saída dos visitantes de forma agrupada
@type  Function
@author Pedro Carvalho Gonçalves    
@since 23/12/2022
@version 12.1.33
@Param
mv_par01 Visitante de?
mv_par02 Visitante ate?
mv_par03 Data de entrada de?
mv_par04 Data de entrada ate?
mv_par05 Grupo de?
mv_par06 Grupo ate?
/*/

User Function DBCO002P()

    Local   aGrid := {}
    Private _nHora  := 0
    Private _dDataBx  := date()

    SetPrvt("_oGrid","oJanela,oPainel,oCbBox","oOk","oNo","oBtn1","oBtn2","oGet1","oGet2","oGet3","oSay1","oSay2","oSay3","oSay4")

    If Pergunte('DBCO002P') 
    Endif

    aGrid := fConsulta()

    oJanela      := MSDialog():New( 052,033,520,938,"Selecione a visita",,,.F.,,,,,,.T.,,,.T. )
    oPainel      := TPanel():New( 045,000,"",oJanela,,.F.,.F.,,,526,400,.T.,.F. )
    oOk          := LoadBitmap(GetResources(), "LBOK")
    oNo          := LoadBitmap(GetResources(), "LBNO") 
    oGet1        := TGet():New(027, 210, {| u | If( PCount() == 0, _dDataBx, _dDataBx := u ) }, oJanela, 060 , 010 , "99/99/9999", , CLR_BLACK , CLR_WHITE, , .f. , , .T.,, .F.,, .F., .F., , .F., .F. ,, "_dDataBx",,,, .F.)
    oGet2        := TGet():New(027, 275, {| u | If( PCount() == 0, _nHora, _nHora := u ) }, oJanela, 060 , 010 , "@E 999.99", , CLR_BLACK , CLR_WHITE, , .f. , , .T.,, .F.,, .F., .F., , .F., .F. ,, "_nHora",,,, .F.)
    oSay1        := TSay():New(020,211,{||'Data de saída'},oJanela,,,,,,.T.,CLR_BLACK,CLR_WHITE,220,30)
    oSay2        := TSay():New(020,276,{||'Saída'},oJanela,,,,,,.T.,CLR_BLACK,CLR_WHITE,220,30) 
    _oGrid       := TCBrowse():New(0, 0, 10, 10,,,, oPainel,,,,,,,,,,,,,, .F.,,,, .T., .T.)      
    _oGrid:Align := CONTROL_ALIGN_ALLCLIENT

    oBtn1      := TButton():New( 027,122,"Confirmar"    ,oJanela,{||fInclSPY(aGrid)}      ,037,012,,,,.T.,,"",,,,.F. )
    oBtn2      := TButton():New( 027,165,"Cancelar"     ,oJanela,{||oJanela:End()}    ,037,012,,,,.T.,,"",,,,.F. )

    _oGrid:SetArray(aGrid)
    _oGrid:AddColumn(TCColumn():New('   ', {|| Iif(aGrid[_oGrid:nAt, 10],oOk,oNo)},,,,, 15, .T., .F.))
    _oGrid:AddColumn(TCColumn():New('Filial', {|| aGrid[_oGrid:nAt, 01]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('N° Visita', {|| aGrid[_oGrid:nAt, 02]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Cod. Visitante', {|| aGrid[_oGrid:nAt, 03]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Nome ', {|| aGrid[_oGrid:nAt, 04]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('CPF', {|| aGrid[_oGrid:nAt, 05]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Data entrada ', {|| SToD(aGrid[_oGrid:nAt, 06])},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Hr. Entrada ', {|| aGrid[_oGrid:nAt, 07]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Centro Custo ', {|| aGrid[_oGrid:nAt, 08]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Grupo ', {|| aGrid[_oGrid:nAt, 09]},,,,, 40))

    _oGrid:bHeaderClick   := {|| fMarkItem(.T.,aGrid)}
    _oGrid:bLDblClick     := {|| fMarkItem(.F.,aGrid)}

    oJanela:Activate(,,,.T.)


Return 

 /*/{Protheus.doc} fConsulta
Atualiza os dados da grid
@type  Function
@author Pedro Carvalho Gonçalves    
@since 23/12/2022
@version 12.1.33
/*/

Static Function fConsulta()

    Local aArea  := GetArea()
    Local cAlTMP := GetNextAlias()
    Local aGrid  := {}

    BEGINSQL Alias cALTMP

        SELECT 
            PY.PY_FILIAL,
            PY.PY_NUMERO,
            PY.PY_VISITA,
            PW.PW_NOME,
            PW.PW_CPF,
            PY.PY_DATAE,
            PY.PY_ENTRADA,
            PY.PY_CC,
            PW.PW_XAGRUP
        FROM %Table:SPY% PY
        INNER JOIN %Table:SPW% PW
        ON 
                PY.PY_VISITA = PW.PW_VISITA
          AND   PW.PW_FILIAL = %Exp:xFilial('SPW')%
          AND   PW.%NotDel%

        WHERE   PY.PY_DTBAIXA  = ' '
          AND   PY.PY_FILIAL = %Exp:xFilial('SPY')% 
          AND   PY.%NotDel%
          AND   PY.PY_VISITA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
          AND   PY.PY_DATAE  BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
          AND   PW.PW_XAGRUP  BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%

        // Filtra as visitas que estão em aberto e dentro dos parametros

    ENDSQL

    While !(cALTMP)->(Eof())

        aAdd(aGrid, {;
        (cALTMP)->PY_FILIAL,;
        (cALTMP)->PY_NUMERO,;
        (cALTMP)->PY_VISITA,;
        (cALTMP)->PW_NOME  ,; 
        (cALTMP)->PW_CPF,;
        (cALTMP)->PY_DATAE,;
        (cALTMP)->PY_ENTRADA,;
        (cALTMP)->PY_CC,;
        (cALTMP)->Pw_XAGRUP,;
        .F.})

        (cALTMP)->(DbSkip())

    End

    (cALTMP)->(DbCloseArea())
    RestArea(aArea)

Return aGrid

/*/{Protheus.doc} fMarkItem
@type  Function
Marca os itens da grid
@author Pedro Carvalho Gonçalves
@since 21/12/2022
@version 12.1.33
/*/

Static Function fMarkItem(lAll,aGrid)

    Local nI := 0
    Default lRet := .F.

    If lAll
        For nI := 1 to Len(aGrid)
            aGrid[nI, 10] := !aGrid[nI, 10]
        Next
    Else
        nI := _oGrid:nAt
        aGrid[nI, 10] := !aGrid[nI, 10]
    EndIf
    _oGrid:Refresh()

Return

/*/{Protheus.doc} fInclSPY
@type  Function
Marca a data e a hora da saída da visita
@author Pedro Carvalho Gonçalves
@since 23/12/2022
@version 12.1.33
/*/

Static Function fInclSPY(aGrid)

    Local nI := 0
    Local lAlt := .F.

    If Select('SPY') = 0
        DbSelectArea('SPY')
    Endif

    SPY->(DbSetOrder(4)) // PY_FILIAL+PY_NUMERO                                                                                                    
    SPY->(DbGoTop())

    If !Empty(_dDataBx) // Verifica se o usuário preencheu os campos de data da visita e Hr. Visita

        For nI := 1 to Len(aGrid)

            If aGrid[nI, 10]

                If SPY->(MsSeek(xFilial('SPY') + aGrid[nI, 2]))

                    RecLock('SPY',.F.)
                        SPY->PY_DATAS   := _dDataBx
                        SPY->PY_DTBAIXA := _dDataBx
                        SPY->PY_SAIDA    := _nHora
                        SPY->(MsUnlock())
                        lAlt := .T.
                Endif
            Endif
        Next

        If lAlt 
            MsgAlert("Saída realizada com sucesso!")
            oJanela:End()
        Else
            MsgAlert("Favor selecione algum registro!")
        Endif
    Else
        MsgAlert("Preencha a data da saída!", "Atenção - DBCO001P")
        _oGrid:Refresh()
    Endif
             


Return
