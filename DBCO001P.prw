#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} DBCO001P
Monta uma tela trazendo a grid da spw
@type  Function
@author Pedro Carvalho Gonçalves
@since 21/12/2022
@version 12.1.33
/*/
User Function DBCO001P()

    Local aSX5        := FWGetSX5('Z0')
    Local aCab        := {}

    Private _dDataEnt := Date()
    Private _nHrVisit := 0
    Private _oGrid    := Nil
    Private _cGrp     := Nil
    Private _cTpVisit := Nil
    Private _cClassif := Nil
    Private _aCols    := {}
    Private _lMarkAll := .T.


    aEval(aSX5, {|x| aAdd(aCab, x[3] + '-' + x[4])})

    _cGrp := aCab[1]

    LoadGrid(.T.)
    SetPrvt("oJanela,oPainel,oCbBox","oCbBox1","oCbBox2","oOk","oNo","oBtn1","oBtn2","oGet1","oGet2","oSay1","oSay2","oSay3","oSay4")

    oJanela    := MSDialog():New( 023,005,585,1024,"Selecione a visita",,,.F.,,,,,,.T.,,,.T. )
    oPainel    := TPanel():New( 055,000,"",oJanela,,.F.,.F.,,,526,400,.T.,.F. )
    oBtn1      := TButton():New( 027,445,"Confirmar"    ,oJanela,{||fInclSPY()}      ,037,012,,,,.T.,,"",,,,.F. )
    oBtn2      := TButton():New( 027,398,"Cancelar"     ,oJanela,{||oJanela:End()}    ,037,012,,,,.T.,,"",,,,.F. )
    oGet1      := TGet():New(027, 120, {| u | If( PCount() == 0, _dDataEnt, _dDataEnt := u ) }, oJanela, 060 , 010 , "99/99/9999", , CLR_BLACK , CLR_WHITE, , .f. , , .T.,, .F.,, .F., .F., , .F., .F. ,, "_dDataEnt",,,, .F.)
    oGet2      := TGet():New(027, 185, {| u | If( PCount() == 0, _nHrVisit, _nHrVisit := u ) }, oJanela, 060 , 010 , "@E 999.99", , CLR_BLACK , CLR_WHITE, , .f. , , .T.,, .F.,, .F., .F., , .F., .F. ,, "_nHrVisit",,,, .F.)
    oSay1      := TSay():New(013,011,{||'Selecione o grupo'},oJanela,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
    oSay2      := TSay():New(020,122,{||'Data de visita'},oJanela,,,,,,.T.,CLR_BLACK,CLR_WHITE,220,30)
    oSay3      := TSay():New(020,187,{||'Hr Visita'},oJanela,,,,,,.T.,CLR_BLACK,CLR_WHITE,220,30)

    oOk        := LoadBitmap(GetResources(), "LBOK")
    oNo        := LoadBitmap(GetResources(), "LBNO")  
    _oGrid     := TCBrowse():New(0, 0, 10, 10,,,, oPainel,,,,,,,,,,,,,, .F.,,,, .T., .T.)      

    _oGrid:Align := CONTROL_ALIGN_ALLCLIENT
    _oGrid:SetArray(_aCols)
    _oGrid:AddColumn(TCColumn():New('   ', {|| Iif(_aCols[_oGrid:nAt, 08],oOk,oNo)},,,,, 15, .T., .F.))
    _oGrid:AddColumn(TCColumn():New('Filial', {|| _aCols[_oGrid:nAt, 01]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('N° Visitante', {|| _aCols[_oGrid:nAt, 02]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('Nome Completo', {|| _aCols[_oGrid:nAt, 03]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('CPF', {|| _aCols[_oGrid:nAt, 04]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('N° Matricula', {|| _aCols[_oGrid:nAt, 05]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('C. Custo', {|| _aCols[_oGrid:nAt, 06]},,,,, 40))
    _oGrid:AddColumn(TCColumn():New('N° Crachá', {|| _aCols[_oGrid:nAt, 07]},,,,, 40))


    _oGrid:bHeaderClick   := {|| fMarkItem(.T.)}
    _oGrid:bLDblClick     := {|| fMarkItem()}

    oCbBox    := TComboBox():New( 025,010,{|u| If(PCount()>0,_cGrp:=u,_cGrp)}, aCab, 100,050,oJanela,,{|| LoadGrid() },,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,_cGrp )
    oCbBox1   := TComboBox():New( 023,257,{|u| If(PCount()>0,_cTpVisit:=u,_cTpVisit)}, {"1 - Negócios", "2 - Particular"}, 058,014,oJanela,,{|| LoadGrid() },,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,_cTpVisit )
    oCbBox2   := TComboBox():New( 023,322,{|u| If(PCount()>0,_cClassif:=u,_cClassif)}, {"1 - Agendada", "2 - Não Agendada"}, 058,014,oJanela,,{|| LoadGrid() },,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,_cClassif )



    oJanela:Activate(,,,.T.)

Return 


/*/{Protheus.doc} LoadGrid
Atualiza a grid
@type  Function
@author Pedro Carvalho Gonçalves
@since 21/12/2022
@version 12.1.33
/*/
Static Function LoadGrid(p_lPrm)

    Local cALTMP := GetNextAlias()
    Local cSQL  := ''
    Local aArea :=  GetArea()

    Default p_lPrm := .F.
    
    _aCols      := {}
    cSQL := "PW_XAGRUP = '" + SubStr(_cGrp, 1, 6) + "'"
    cSQL := '%' + cSQL + '%'

    BeginSQL Alias cALTMP

        SELECT 
            PW_FILIAL,
            PW_VISITA,
            PW_NOMFULL,
            PW_CPF,
            PW_XMATRIC,
            PW_XCC,
            PW_XCRACHA
        FROM %Table:SPW% SPW
        WHERE %Exp:cSQL%
        AND NOT EXISTS (
            SELECT 
               2
            FROM %Table:SPY% SPY
            WHERE
                SPY.PY_VISITA = SPW.PW_VISITA
            AND SPY.PY_DTVISIT = %Exp:DtoS(_dDataEnt)%
            AND SPY.PY_DTBAIXA  = ' '
            AND SPY.%NotDel%
            )
        AND SPW.%NotDel%

        // A grid não trará os visitantes que possuem alguma visita em aberto.

    ENDSQL

    While !(cALTMP)->(Eof())

        aAdd(_aCols, {;
            (cALTMP)->PW_FILIAL,;
            (cALTMP)->PW_VISITA,;
            (cALTMP)->PW_NOMFULL,;
            (cALTMP)->PW_CPF,;
            (cALTMP)->PW_XMATRIC,;
            (cALTMP)->PW_XCC,;
            (cALTMP)->PW_XCRACHA,;
            .F.})

        (cALTMP)->(DbSkip())

    End

    If !p_lPrm
        _oGrid:SetArray(_aCols)
        _oGrid:Refresh()
    EndIf

    RestArea(aArea)

Return 


/*/{Protheus.doc} fMarkItem
Marca os itens da grid
@type  Function
@author Pedro Carvalho Gonçalves
@since 21/12/2022
@version 12.1.33
/*/
Static Function fMarkItem(lAll)

    Local nI := 0
    Default lRet := .F.

    If lAll
        For nI := 1 to Len(_aCols)
            _aCols[nI, 8] := !_aCols[nI, 8]
        Next
    Else
        nI := _oGrid:nAt
        _aCols[nI, 8] := !_aCols[nI, 8]
    EndIf
    _oGrid:Refresh()

Return


/*/{Protheus.doc} fInclSPY
Insere/altera os registros na tabela 
@type  Function
@author Pedro Carvalho Gonçalves
@since 21/12/2022
@version 12.1.33
/*/
Static Function fInclSPY()

    Local nI := 0
    Local lAlt := .F.
    Local lAdd := .F. //Gera a próx numeração do índice
    Local cNum := ""

    If Select('SPY') = 0
        DbSelectArea('SPY')
    Endif

    SPY->(DbSetOrder(1)) //PY_FILIAL+PY_VISITA+DTOS(PY_DTVISIT)+PY_CRACHA+PY_NUMERO                                                                                                      
    SPY->(DbGoTop())

    If !Empty(_dDataEnt)  // Verifica se o usuário preencheu os campos de data da visita e Hr. Visita
        Begin Transaction

            cNum := GetSXENum('SPY','PY_NUMERO')

            For nI := 1 to Len(_aCols)
                If _aCols[nI, 8]
                    lAdd := !SPY->(MsSeek(xFilial('SPY') + _aCols[nI, 2] + DtoS(_dDataEnt)))

                    If lAdd .or. (!lAdd .and. Empty(SPY->PY_DTBAIXA)) // Caso haja alguma visita ainda em aberto, não deixará incluir um novo
                        RecLock('SPY', lAdd)

                            SPY->PY_NUMERO  := cNum
                            SPY->PY_FILIAL  := xFilial('SPY')
                            SPY->PY_DTVISIT := _dDataEnt
                            SPY->PY_DATAE   := _dDataEnt
                            SPY->PY_ENTRADA := _nHrVisit
                            SPY->PY_TIPOVIS := _cTpVisit
                            SPY->PY_CLASSIF := _cClassif
                            SPY->PY_VISITA  := _aCols[nI,2]        
                            SPY->PY_MAT     := _aCols[nI,5]
                            SPY->PY_CC      := _aCols[nI,6] 
                            SPY->PY_CRACHA  := _aCols[nI,7]

                        SPY->(MsUnlock())

                        lAlt := .T.
                    Endif
                Endif
            Next
        End Transaction

        If lAlt 
            MsgAlert("Inclusão realizada com sucesso!")
            SPY->(ConfirmSX8())
            oJanela:End()
        Else
            MsgAlert("Favor selecione algum registro!")
            SPY->(RollBackSx8())
        Endif
    Else
        MsgAlert("Há campos obrigatórios não preenchidos!", "Atenção - DBCO001P")
        SPY->(RollBackSx8())
        _oGrid:Refresh()
    Endif

Return
