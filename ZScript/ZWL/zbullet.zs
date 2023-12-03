class ZBullet : FastProjectile
{
    // These constants can be used to convert to Doom's natural units.
    // Assumes that 35 map units = 1 meter
    // e.g. 1*mps = 1 unit/tic
    const mps = 1;
    const fps = 0.3048;

    double airFriction;
    class<Actor> puffType;

    Property AirFriction : airFriction;
    Property PuffType : puffType;

    Default
    {
        Radius 1;
        Height 1;
        Decal "BulletChip";
        ZBullet.AirFriction 0.97;
        ZBullet.PuffType "ZBulletPuff";

        -NoGravity;
    }

    States
    {
    Death:  // Wall
    Crash:  // Non-bleeding actor
        TNT1 A 0 SpawnPuff(puffType, pos, angle, 0, 0);
        Stop;
    XDeath: // Bleeding actor
        TNT1 A 0;
        Stop;
    }

    override void Tick()
    {
        Super.Tick();

        vel *= airFriction;
        if (!bNoGravity)
            vel.z -= gravity * curSector.gravity;
    }
}