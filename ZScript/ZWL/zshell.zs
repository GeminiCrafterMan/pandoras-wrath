// Explodes into several pellets when spawned.
// Useful for non-hitscan shotguns.
class ZShell : ZExplosive
{
    class<Actor> pelletType;
    int pelletCount;
    double spread;

    Property PelletType: pelletType;    // Type of pellets
    Property PelletCount: pelletCount;  // Number of pellets
    Property Spread: spread;            // Cone in which to fire pellets

    Default
    {
        Radius 1;
        Height 1;
        Speed 0.001;
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay
        {
            // Projectiles are fired w/ pitch = 0, but we can find the real pitch from our velocity
            if (target && pitch == 0) pitch = -ATan2(vel.z, vel.xy.Length());
            ZWL_ProjectileShrapnel(pelletType, pelletCount, spread);
        }
        Stop;
    }
}