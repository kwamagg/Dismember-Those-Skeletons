Scriptname DismemberThoseSkeletons extends ReferenceAlias

Actor Property DTS_PlayerRef Auto

Keyword Property DTS_SkeletonHuman Auto
Keyword Property DTS_SkeletonElf Auto
Keyword Property DTS_SkeletonOrc Auto
Keyword Property DTS_SkeletonKhajiit Auto
Keyword Property DTS_SkeletonArgonian Auto
Keyword Property DTS_SkeletonBloody Auto

FormList Property DTS_SkeletonRemainsMasterlist Auto

Actor killedSkeleton
Bool OnActorKilledStarted = False
Int akFormList = 9

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
EndFunction

Bool Function DTS_DetermineSkeleton(Actor akSkeleton)
    ; A workaround to ensure the accidentally distributed identical keywords don't screw everything up (Immersive Creatures).
    If !akSkeleton.HasKeyword(DTS_SkeletonHuman) && !akSkeleton.HasKeyword(DTS_SkeletonElf) && \
        !akSkeleton.HasKeyword(DTS_SkeletonKhajiit) && !akSkeleton.HasKeyword(DTS_SkeletonArgonian) && \
        !akSkeleton.HasKeyword(DTS_SkeletonOrc) && !akSkeleton.HasKeyword(DTS_SkeletonBloody)
        Return False
    ElseIf akSkeleton.HasKeyword(DTS_SkeletonHuman) && !akSkeleton.HasKeyword(DTS_SkeletonElf) && \
        !akSkeleton.HasKeyword(DTS_SkeletonKhajiit) && !akSkeleton.HasKeyword(DTS_SkeletonArgonian) && \
        !akSkeleton.HasKeyword(DTS_SkeletonOrc) && !akSkeleton.HasKeyword(DTS_SkeletonBloody)
        akFormList = 0
        Return True
    ElseIf (akSkeleton.HasKeyword(DTS_SkeletonElf) && !akSkeleton.HasKeyword(DTS_SkeletonHuman)) || \
        (akSkeleton.HasKeyword(DTS_SkeletonElf) && akSkeleton.HasKeyword(DTS_SkeletonHuman))
        akFormList = 1
        Return True
    ElseIf (akSkeleton.HasKeyword(DTS_SkeletonOrc) && !akSkeleton.HasKeyword(DTS_SkeletonHuman)) || \
        (akSkeleton.HasKeyword(DTS_SkeletonOrc) && akSkeleton.HasKeyword(DTS_SkeletonHuman))
        akFormList = 2
        Return True
    ElseIf (akSkeleton.HasKeyword(DTS_SkeletonKhajiit) && !akSkeleton.HasKeyword(DTS_SkeletonHuman)) || \
        (akSkeleton.HasKeyword(DTS_SkeletonKhajiit) && akSkeleton.HasKeyword(DTS_SkeletonHuman))
        akFormList = 3
        Return True
    ElseIf (akSkeleton.HasKeyword(DTS_SkeletonArgonian) && !akSkeleton.HasKeyword(DTS_SkeletonHuman)) || \
        (akSkeleton.HasKeyword(DTS_SkeletonArgonian) && akSkeleton.HasKeyword(DTS_SkeletonHuman))
        akFormList = 4
        Return True
    ElseIf (akSkeleton.HasKeyword(DTS_SkeletonBloody) && !akSkeleton.HasKeyword(DTS_SkeletonHuman)) || \
        (akSkeleton.HasKeyword(DTS_SkeletonBloody) && akSkeleton.HasKeyword(DTS_SkeletonHuman))
        akFormList = 5
        Return True
    EndIf
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
    If akFormlist != 9
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
