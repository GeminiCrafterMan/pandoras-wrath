// Emits lightning bolt when fired
class ZLightningSeg : Object
{
    Vector3 aPos, bPos;
    double size;
}

class ZLightning : ZTrail
{
    Array<ZLightningSeg> segs;

    Color colour;
    int lifetime;
    double range;
    double size;
    double spacing;
    int generations;
    double maxOffset;
    double forkChance;
    double offsetFactor;
    double forkOffsetFactor;
    double forkSizeFactor;

    Property Color : colour;
    Property Alpha : alpha;
    Property Lifetime : lifetime;
    Property Range : range;
    Property Size : size;
    Property Spacing : spacing;
    Property Generations : generations;
    Property MaxOffset : maxOffset;
    Property ForkChance : forkChance;
    Property OffsetFactor : offsetFactor;
    Property ForkOffsetFactor : forkOffsetFactor;
    Property ForkSizeFactor : forkSizeFactor;

    Default
    {
        Speed 0.001;  // This is a hack to find the pitch

        ZLightning.Color 0xddddff;
        ZLightning.Alpha 0.8;
        ZLightning.Lifetime 8;
        ZLightning.Range 8192;
        ZLightning.Size 4;
        ZLightning.Spacing 1;
        ZLightning.Generations 4;
        ZLightning.MaxOffset 32;
        ZLightning.ForkChance 0.25;
        ZLightning.ForkOffsetFactor 4;
        ZLightning.OffsetFactor 0.5;
        ZLightning.ForkSizeFactor 0.33;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Find lightning endpoint
        // Projectiles are fired w/ pitch = 0, but we can find the real pitch from our velocity
        if (target && pitch == 0) pitch = -ATan2(vel.z, vel.xy.Length());

        Actor mo = target ? target : Actor(self);
        FLineTraceData traceData;
        mo.LineTrace(angle, range, pitch, data: traceData);

        // These will be used to offset points along the bolt
        Vector3 right = (Cos(angle-90.0), Sin(angle-90.0), 0.0);
        Vector3 up = (Cos(pitch-90.0) * Cos(angle), Cos(pitch-90.0) * Sin(angle), -Sin(pitch-90.0));

        // Create line segment spanning entire lightning bolt
        segs.Push(New("ZLightningSeg"));
        segs[0].aPos = pos;
        segs[0].bPos = traceData.hitLocation;
        segs[0].size = size;

        double rMax = maxOffset;
        for (int i = 0; i < generations; ++i)
        {
            int segCount = segs.Size();
            for (int j = 0; j < segCount; ++j)  // For each seg that already exists
            {
                // Split seg in half
                let aSeg = segs[j];  // No need to delete a perfectly good seg
                let bSeg = New("ZLightningSeg");
                segs.Push(bSeg);

                // Offset the midpoint perpendicular to bolt's direction
                let midPoint = 0.5 * (aSeg.aPos + aSeg.bPos);
                let r = FRandom(0, rMax);
                let t = FRandom(0, 360);
                midPoint += r * Cos(t) * right;
                midPoint += r * Sin(t) * up;

                // Set attributes for both new segs
                bSeg.aPos = midPoint;
                bSeg.bPos = aSeg.bPos;
                bSeg.size = aSeg.size;

                aSeg.bPos = midPoint;

                // Randomly create new seg branching off from midpoint
                if (FRandom(0, 1) < forkChance)
                {
                    let cSeg = New("ZLightningSeg");
                    segs.Push(cSeg);

                    let endPoint = bSeg.bPos;
                    let r = FRandom(0, forkOffsetFactor * rMax);
                    let t = FRandom(0, 360);
                    endPoint += r * Cos(t) * right;
                    endPoint += r * Sin(t) * up;

                    cSeg.aPos = bSeg.aPos;
                    cSeg.bPos = endPoint;
                    cSeg.size = forkSizeFactor * bSeg.size;  // It should be thinner than the main bolt
                }
            }

            rMax *= offsetFactor;  // Each generation is offset less than the one before
        }

        for (int i = 0; i < segs.Size(); ++i)
        {
            DrawSegment(segs[i].aPos, segs[i].bPos, colour, colour, segs[i].size, -1, alpha, -1, spacing, lifetime, flags: PF_FullBright);
        }

        Destroy();
    }
}