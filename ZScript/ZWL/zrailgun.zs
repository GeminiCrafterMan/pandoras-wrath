// Fires damageless railgun effect when spawned
// Maybe useful as a tracer?
class ZRailgun : ZTrail
{
    Color ringColor;
    Color coreColor;
    double maxDiff;
    double range;
    double lifetime;
    double spacing;
    double driftSpeed;
    int spiralOffset;

    Property Colors : ringColor, coreColor;
    Property MaxDiff : maxDiff;
    Property Range : range;
    Property Lifetime : lifetime;
    Property Spacing : spacing;
    Property DriftSpeed : driftSpeed;
    Property spiralOffset : spiralOffset;

    Default
    {
        ZRailgun.Colors "", "";
        ZRailgun.MaxDiff 0;
        ZRailgun.Range 8192;
        ZRailgun.Lifetime ticRate;
        ZRailgun.Spacing 1;
        ZRailgun.DriftSpeed 0;
        ZRailgun.SpiralOffset 270;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        // Find rail endpoint
        // Projectiles are fired w/ pitch = 0, but we can find the real pitch from our velocity
        if (target) pitch = -ATan2(vel.z, vel.xy.Length());

        Actor mo = target ? target : Actor(self);
        mo.A_CustomRailgun(0,0, ringColor, coreColor, RGF_Silent | RGF_NoPiercing | RGF_ExplicitAngle | RGF_FullBright | RGF_CenterZ, 0, maxDiff, null, 0, 0, range, lifetime, spacing, driftSpeed, null, 0, spiralOffset);
    }
}