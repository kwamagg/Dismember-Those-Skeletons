Scriptname DismemberThoseSkeletons extends ReferenceAlias

Actor Property DTS_PlayerRef Auto

Keyword Property DTS_SkeletonHuman Auto
Keyword Property DTS_SkeletonElf Auto
Keyword Property DTS_SkeletonOrc Auto
Keyword Property DTS_SkeletonKhajiit Auto
Keyword Property DTS_SkeletonArgonian Auto
Keyword Property DTS_SkeletonBloody Auto

Keyword Property DTS_SkeletonHeadless Auto
Keyword Property DTS_SkeletonJawless Auto
Keyword Property DTS_SkeletonArmless Auto
Keyword Property DTS_SkeletonHeadlessArmless Auto
Keyword Property DTS_SkeletonJawlessArmless Auto
Keyword Property DTS_SkeletonOneArm Auto
Keyword Property DTS_SkeletonHeadlessOneArm Auto
Keyword Property DTS_SkeletonJawlessOneArm Auto
Keyword Property DTS_SkeletonOneLeg Auto
Keyword Property DTS_SkeletonHeadlessOneLeg Auto
Keyword Property DTS_SkeletonJawlessOneLeg Auto
Keyword Property DTS_SkeletonDeer Auto
Keyword Property DTS_SkeletonDeerHorned Auto

Keyword[] DTS_SkeletonVariantKeywords

FormList Property DTS_SkeletonRemainsMasterlist Auto

Actor killedSkeleton
Bool OnActorKilledStarted = False
Int akFormList = 100

Event OnInit()
	DTS_Register()
EndEvent

Event OnPlayerLoadGame()
	DTS_Register()
EndEvent

Event OnActorKilled(Actor akSkeleton, Actor akKiller)
    OnActorKilledStarted = True
    If !akSkeleton.IsDead() && (akSkeleton != killedSkeleton)
        If DTS_DetermineSkeleton(akSkeleton)
            DTS_SkeletonDropItems(akSkeleton)
            DTS_DismemberSkeleton(akSkeleton)
            killedSkeleton = akSkeleton
        EndIf
    EndIf
EndEvent

Event OnMagicHit(ObjectReference akTarget, Form akSource, Projectile akProjectile)
    Actor akSkeleton = akTarget as Actor
    If akSkeleton == killedSkeleton
        OnActorKilledStarted = False
    EndIf
    If (akSkeleton != killedSkeleton) && akSkeleton.IsDead()
        If DTS_DetermineSkeleton(akSkeleton)
            GoToState("Busy")
            DTS_SkeletonDropItems(akSkeleton)
            DTS_DismemberSkeleton(akSkeleton)
            GoToState("")
        EndIf
    EndIf
EndEvent

Event OnProjectileHit(ObjectReference akTarget, Form akSource, Projectile akProjectile)
    Actor akSkeleton = akTarget as Actor
    If akSkeleton == killedSkeleton
        OnActorKilledStarted = False
    EndIf
    If (akSkeleton != killedSkeleton) && akSkeleton.IsDead()
        If DTS_DetermineSkeleton(akSkeleton)
            GoToState("Busy")
            DTS_SkeletonDropItems(akSkeleton)
            DTS_DismemberSkeleton(akSkeleton)
            GoToState("")
        EndIf
    EndIf
EndEvent

Event OnWeaponHit(ObjectReference akTarget, Form akSource, Projectile akProjectile, Int aiHitFlagMask)
    Actor akSkeleton = akTarget as Actor
    If akSkeleton == killedSkeleton
        OnActorKilledStarted = False
    EndIf
    If (akSkeleton != killedSkeleton) && akSkeleton.IsDead()
        If DTS_DetermineSkeleton(akSkeleton)
            GoToState("Busy")
            DTS_SkeletonDropItems(akSkeleton)
            DTS_DismemberSkeleton(akSkeleton)
            GoToState("")
        EndIf
    EndIf
EndEvent

State Busy
    Event OnWeaponHit(ObjectReference akTarget, Form akSource, Projectile akProjectile, Int aiHitFlagMask)
    EndEvent

    Event OnMagicHit(ObjectReference akTarget, Form akSource, Projectile akProjectile)
    EndEvent
    
    Event OnProjectileHit(ObjectReference akTarget, Form akSource, Projectile akProjectile)
    EndEvent
EndState

Function DTS_Register()
    PO3_Events_Alias.RegisterForActorKilled(self)
    PO3_Events_Alias.RegisterForWeaponHit(self)
    PO3_Events_Alias.RegisterForMagicHit(self)
    PO3_Events_Alias.RegisterForProjectileHit(self)

    DTS_SkeletonVariantKeywords = new Keyword[13]
    DTS_SkeletonVariantKeywords[0] = DTS_SkeletonHeadless
    DTS_SkeletonVariantKeywords[1] = DTS_SkeletonJawless
    DTS_SkeletonVariantKeywords[2] = DTS_SkeletonOneArm
    DTS_SkeletonVariantKeywords[3] = DTS_SkeletonJawlessOneArm
    DTS_SkeletonVariantKeywords[4] = DTS_SkeletonArmless
    DTS_SkeletonVariantKeywords[5] = DTS_SkeletonHeadlessArmless
    DTS_SkeletonVariantKeywords[6] = DTS_SkeletonJawlessArmless
    DTS_SkeletonVariantKeywords[7] = DTS_SkeletonOneLeg
    DTS_SkeletonVariantKeywords[8] = DTS_SkeletonHeadlessOneLeg
    DTS_SkeletonVariantKeywords[9] = DTS_SkeletonJawlessOneLeg
    DTS_SkeletonVariantKeywords[10] = DTS_SkeletonHeadlessOneArm
    DTS_SkeletonVariantKeywords[11] = DTS_SkeletonDeer
    DTS_SkeletonVariantKeywords[12] = DTS_SkeletonDeerHorned
EndFunction

Bool Function DTS_DetermineSkeleton(Actor akSkeleton)
    Bool isHuman = akSkeleton.HasKeyword(DTS_SkeletonHuman)
    Bool isElf = akSkeleton.HasKeyword(DTS_SkeletonElf)
    Bool isKhajiit = akSkeleton.HasKeyword(DTS_SkeletonKhajiit)
    Bool isArgonian = akSkeleton.HasKeyword(DTS_SkeletonArgonian)
    Bool isOrc = akSkeleton.HasKeyword(DTS_SkeletonOrc)
    Bool isBloody = akSkeleton.HasKeyword(DTS_SkeletonBloody)

    If !isHuman && !isElf && !isKhajiit && !isArgonian && !isOrc && !isBloody
        Int count = DTS_SkeletonVariantKeywords.Length
        Int i = 0
        Bool bFound = False
        While i < count && !bFound
            If akSkeleton.HasKeyword(DTS_SkeletonVariantKeywords[i])
                bFound = True
            EndIf
            i += 1
        EndWhile

        If !bFound
            Return False
        EndIf

        Int j = DTS_SkeletonRemainsMasterlist.GetSize()
        While j > 0
            j -= 1
            FormList currentList = DTS_SkeletonRemainsMasterlist.GetAt(j) as FormList
            Keyword akKeyword = currentList.GetAt(0) as Keyword
            If akSkeleton.HasKeyword(akKeyword)
                akFormList = DTS_SkeletonRemainsMasterlist.Find(currentList)
                Return True
            EndIf
        EndWhile

        Return False
    EndIf

    If isHuman && !isElf && !isKhajiit && !isArgonian && !isOrc && !isBloody
        akFormList = 1
        Return True
    EndIf

    If isElf
        akFormList = 2
        Return True
    ElseIf isOrc
        akFormList = 3
        Return True
    ElseIf isKhajiit
        akFormList = 4
        Return True
    ElseIf isArgonian
        akFormList = 5
        Return True
    ElseIf isBloody
        akFormList = 6
        Return True
    EndIf

    Return False
EndFunction

Function DTS_SkeletonDropItems(Actor akSkeleton)
    Int i = akSkeleton.GetNumItems()
    While i > 0
        i -= 1
        Form akObject = akSkeleton.GetNthForm(i)
        Int akCount = akSkeleton.GetItemCount(akObject)
        akSkeleton.DropObject(akObject, akCount)
    EndWhile
EndFunction

Function DTS_DismemberSkeleton(Actor akSkeleton)
    If akFormlist != 100
        FormList akSkeletonRemainsList = DTS_SkeletonRemainsMasterlist.GetAt(akFormList) as FormList
        Int i = akSkeletonRemainsList.GetSize()
        While i > 0
            i -= 1
            Form akRemain = akSkeletonRemainsList.GetAt(i) as Form
            If i == 1
                akSkeleton.SetAlpha(0.0)
                akSkeleton.PlaceAtMe(akRemain, 1)
            ElseIf i != 1
                akSkeleton.PlaceAtMe(akRemain, 1)
            EndIf
        EndWhile
    EndIf
    akSkeleton.Disable()
    akSkeleton.Delete()
EndFunction
