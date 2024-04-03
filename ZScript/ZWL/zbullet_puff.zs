class ZBulletPuff : BulletPuff
{
    Default
    {
        Decal "BulletChip";
        Height 8;
    }

	States
	{
	Spawn:
		PUFF A 4 Bright;
		PUFF B 4;
        // Fallthrough
    Melee:
		PUFF CD 4;
		Stop;
    Crash:
		PUFF A 4 Bright A_SpawnItemEx("ZBulletChip");
        PUFF BCD 4;
        Stop;
	}
}

class ZDefaultBulletPuff : ZBulletPuff
{
    Default
    {
        Decal "DefaultBulletChip";
    }
}

class ZFlatDecal : Actor
{
    const epsilon = 4;

    bool onCeiling;
    bool randomFlipX,
         randomFlipY;

    Property RandomFlip : randomFlipX, randomFlipY;

    Default
    {
        Height 0;
        Radius 0;

        RenderStyle "Shaded";

        +NoTeleport
        +FlatSprite
        +NoBlockMap
        +NoGravity
        +MoveWithSector
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Random flip
        scale.x *= randomFlipX ? RandomPick(1, -1) : 1;
        scale.y *= randomFlipY ? RandomPick(1, -1) : 1;

        // Stick to floor/ceiling
        SecPlane plane;
        if (Abs(pos.z - GetZAt()) <= epsilon)
        {
            SetZ(GetZAt());
            plane = curSector.floorPlane;
            onCeiling = false;
        }
        else if (Abs(pos.z - GetZAt(flags:GZF_Ceiling)) <= epsilon)
        {
            SetZ(GetZAt(flags:GZF_Ceiling));
            plane = curSector.ceilingPlane;
            onCeiling = true;
        }
        else
        {
            Destroy();
            return;
        }

        // Tilt to match slopes
        let normal = plane.normal;
        angle = VectorAngle(normal.x, normal.y);

        normal.xy = RotateVector(normal.xy, -angle);
        pitch = -VectorAngle(normal.x, normal.z) + 90;
    }

    override void Tick()
    {
        Super.Tick();

        // MoveWithSector isn't good enough to stick to a rising ceiling
        if (onCeiling)
            SetZ(GetZAt(flags:GZF_Ceiling));
    }
}

class ZBulletChip : ZFlatDecal
{
    Default
    {
        Scale 0.5;
        Alpha 0.85;
        StencilColor "black";
        ZFlatDecal.RandomFlip true, true;
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay
        {
            return curState + Random(1, 5);
        }
        CHIP ABCDE -1;
        Stop;
    }
}


class ZFlatDecalKiller : EventHandler
{
    Array<ZFlatDecal> flatDecals;
    int back;

    override void WorldThingSpawned(WorldEvent e)
    {
        if (!ZFlatDecal(e.thing)) return;

        int maxFlatDecals = CVar.FindCVar('zwl_maxflatdecals').GetInt();
        if (flatDecals.Size() < maxFlatDecals)
        {
            flatDecals.Push(ZFlatDecal(e.thing));
        }
        else
        {
            if (flatDecals[back])
                flatDecals[back].Destroy();

            flatDecals[back] = ZFlatDecal(e.thing);
        }

        back = (back + 1) % maxFlatDecals;
    }

    override void WorldTick()
    {
        int maxFlatDecals = CVar.FindCVar('zwl_maxflatdecals').GetInt();
        if (flatDecals.Size() > maxFlatDecals)
        {
            Array<ZFlatDecal> newFlatDecals;

            int excess = flatDecals.Size() - maxFlatDecals;

            for (int i = 0; i < flatDecals.Size(); ++i)
            {
                if (i < excess)
                    flatDecals[back].Destroy();
                else
                    newFlatDecals.Push(flatDecals[back]);

                // Back is just a convenient counter; it isn't being used as the back of the queue, here
                back = (back + 1) % flatDecals.Size();
            }

            back = 0;
            flatDecals.Move(newFlatDecals);
        }
    }
}