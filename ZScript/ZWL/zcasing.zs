class ZCasing : Actor
{
    Default
    {
        Height 4;
        Radius 2;

        BounceType "Doom";
        BounceFactor 0.5;
        WallBounceFactor 0.5;

        +Missile
        +Dropoff
        +NoBlockMap
        +MoveWithSector
        +ThruActors
    }
}

class ZCasingKiller : EventHandler
{
    Array<ZCasing> casings;
    int back;

    override void WorldThingSpawned(WorldEvent e)
    {
        if (!ZCasing(e.thing)) return;

        int maxCasings = CVar.FindCVar('zwl_maxcasings').GetInt();
        if (casings.Size() <= back)
        {
            casings.Push(ZCasing(e.thing));
        }
        else
        {
            if (casings[back])
                casings[back].Destroy();

            casings[back] = ZCasing(e.thing);
        }

        back = (back + 1) % maxCasings;
    }

    override void WorldTick()
    {
        int maxCasings = CVar.FindCVar('zwl_maxcasings').GetInt();
        if (casings.Size() > maxCasings)
        {
            Array<ZCasing> newCasings;

            int excess = casings.Size() - maxCasings;

            for (int i = 0; i < casings.Size(); ++i)
            {
                if (i < excess)
                    casings[back].Destroy();
                else
                    newCasings.Push(casings[back]);

                // Back is just a convenient counter; it isn't being used as the back of the queue, here
                back = (back + 1) % casings.Size();
            }

            back = 0;
            casings.Move(newCasings);
        }
    }
}