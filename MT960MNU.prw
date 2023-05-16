 #INCLUDE 'TOTVS.ch'
 
 /*/{Protheus.doc} MT960MNU
Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
@type  Function
@author Pedro Carvalho Gonçalves
@since 18/01/2023
@version 12.1.33
@see https://tdn.totvs.com/pages/releaseview.action?pageId=655873508
/*/

User Function MT960MNU()
    
    aAdd(aRotina,{'Gerar Guias','U_CTLF001P', 0, 3, 0, NIL})
    aAdd(aRotina,{'Gerar Titulo Cts. Pagar','U_CTLF002P', 0, 3, 0, NIL})

Return 
