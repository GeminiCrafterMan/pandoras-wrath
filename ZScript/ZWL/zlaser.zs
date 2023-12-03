// Emits line of particles when fired
// Useful for Unmaker-style weapons, laser tripwires, etc.
class ZLaser : ZTrail
{
    Color colour;
    double spacing;
    double lifetime;
    double fadeStep;
    double sizeStep;
    double range;
    Name style;

    Property Color : colour;
    Property Spacing : spacing;
    Property Lifetime : lifetime;
    Property Range : range;
    Property FadeStep : fadeStep;
    Property SizeStep : sizeStep;
    Property Style : style;

    Default
    {
        Speed 0.001;  // This is a hack to find the pitch
        Scale 4;

        ZLaser.Color "red";
        ZLaser.Spacing 1;
        ZLaser.Lifetime 1;
        ZLaser.Range 8192;
        ZLaser.FadeStep -1;
        ZLaser.SizeStep 0;
        ZLaser.Style 'Line';
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Find beam endpoint
        // Projectiles are fired w/ pitch = 0, but we can find the real pitch from our velocity
        if (target && pitch == 0) pitch = -ATan2(vel.z, vel.xy.Length());

        Actor mo = target ? target : Actor(self);
        FLineTraceData traceData;
        mo.LineTrace(angle, range, pitch, data: traceData);

        if (style == 'Fuzzy')
        {
            Vector3 dis = traceData.hitLocation - pos;
            for (int i = 0; i < dis.Length() / spacing; ++i)
            {
                double t = FRandom(0, 1);
                Vector3 ofs = (Lerp(0, dis.x, t), Lerp(0, dis.y, t), Lerp(0, dis.z, t));
                A_SpawnParticle(
                    colour,
                    PF_FullBright,
                    lifetime,
                    scale.x,
                    0,
                    ofs.x,
                    ofs.y,
                    ofs.z,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    alpha,
                    fadeStep,
                    sizeStep);
            }
        }
        else
        {
            DrawSegment(
                pos,
                traceData.hitLocation,
                colour,
                colour,
                scale.x,
                -1,
                alpha,
                -1,
                spacing,
                lifetime,
                (0, 0, 0),
                (0, 0, 0),
                fadeStep,
                sizeStep,
                PF_FullBright);
        }

        Destroy();
    }
}