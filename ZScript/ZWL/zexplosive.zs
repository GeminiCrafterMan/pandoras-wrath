// Base class for explosives (e.g. rockets, grenades, mines)
class ZExplosive : Actor
{
    enum EExplosionFlags
    {
        ZXF_HurtSource  = XF_HurtSource,    // Most of these replicate A_Explode's flags.
        ZXF_NotMissile  = XF_NotMissile,
        ZXF_NoSplash    = XF_NoSplash,
        ZXF_ThrustZ     = XF_ThrustZ,
        ZXF_NoAlert     = XF_ThrustZ << 1   // Replaces the alert param from A_Explode.
    }

    enum EShrapnelFlags
    {
        ZSF_Horizontal      = 1 << 0,   // Shrapnel will only be fired horizontally, like nails in A_Explode.
        ZSF_NotMissile      = 1 << 1,   // See A_Explosive's flags.
        ZSF_AddParentVel    = 1 << 2    // Add explosive's velocity to shrapnel. Only for ZWL_ProjectileShrapnel.
    }

    enum EProximityFlags
    {
        ZPF_DetectEnemies = 1 << 0, // Explode when enemies are nearby
        ZPF_DetectFriends = 1 << 1  // Same but for friends
    }


    bool bWillHitOwner;
    int explosiveFlags;
    Actor stuckActor;
    Vector3 stuckActorOffset;


    Flagdef AutoCountdown: explosiveFlags, 0;   // Explosive will enter death state after ReactionTime tics.
    Flagdef StickToFloors: explosiveFlags, 1;   // These allow explosive to stick to different surfaces.
    Flagdef StickToWalls: explosiveFlags, 2;
    Flagdef StickToCeilings: explosiveFlags, 3;
    Flagdef StickToActors: explosiveFlags, 4;


    Default
    {
        Projectile;
        +NoBlood
    }


    // NOTE: You can't define a bounce and stick state for the same surface type.
    States
    {
    Bounce.Floor:
        TNT1 A 0
        {
            vel = (0, 0, 0);
            bMoveWithSector = true;

            return ResolveState("Stick.Floor");
        }
    Bounce.Ceiling:
        TNT1 A 0
        {
            vel = (0, 0, 0);
            bNoGravity = true;

            return ResolveState("Stick.Ceiling");
        }
    Bounce.Wall:
        TNT1 A 0
        {
            vel = (0, 0, 0);
            bNoGravity = true;

            return ResolveState("Stick.Wall");
        }
    Bounce.Actor:
        TNT1 A 0
        {
            vel = (0, 0, 0);
            bNoGravity = true;
            stuckActor = blockingMobj;
            stuckActorOffset = pos - stuckActor.pos;
            stuckActorOffset.xy = RotateVector(stuckActorOffset.xy, -stuckActor.angle);

            return ResolveState("Stick.Actor");
        }
    }


    // This is more or less just A_Explosive, at the moment,
    // It removes the ability to fire nails; you should use ZWL_HitscanShrapnel for that,
    void ZWL_Explode(int damage,    // How much damage is inflicted at the center of the explosion.
        int distance,               // The area covered by the damage (damage inflicted drop linearly with distance).
        int fullDamageDistance = 0, // The area within which full damage is inflicted.
        Name damageType = 'None',   // The damage type to use. 'None' defaults to this actor's DamageType
        int flags = ZXF_HurtSource) // See EExplosionFlags
    {
        bool alert = !(flags & ZXF_NoAlert);
        flags &= ~ZXF_NoAlert;
        flags |= XF_ExplicitDamageType;

        if (damageType == 'None') damageType = self.damageType;
        A_Explode(damage, distance, flags, alert, fullDamageDistance, 0, 0, "", damageType);
    }

    // Fires hitscan attacks in random directions
    void ZWL_HitscanShrapnel(
        int damage,                             // Damage done per fragment.
        int fragCount,                          // Number of fragments.
        double spread = 180,                    // Shrapnel spread, in degrees. Defaults to full sphere.
        int range = 8192,                       // Maximum distance at which fragments can do damage.
        Name damageType = 'None',               // Fragment damage type.
        Class<Actor> puffType = "ZBulletPuff",  // Bullet puff class.
        Vector3 offset = (0, 0, 0),             // Offset from which shrapnel is released.
        double angleOfs = 0,                    // Angle offset for center of spread.
        double pitchOfs = 0,                    // Pitch offset for center of spread.
        int flags = 0)                          // See EShrapnelFlags
    {
        for (int i = 0; i < fragCount; ++i)
        {
            double fragAngle, fragPitch;
            [fragAngle, fragPitch] = BulletAngle(spread, angle + angleOfs, pitch + pitchOfs);
            LineAttack(
                fragAngle,
                range,
                fragPitch,
                damage,
                damageType,
                puffType,
                LAF_NoRandomPuffZ,
                null,
                offset.z,
                offset.x,
                offset.y);
        }
    }

    // Fires projectiles in random directions
    void ZWL_ProjectileShrapnel(
        Class<Actor> fragType,      // Type of fragments.
        int fragCount,              // Number of fragments.
        double spread = 180,        // Shrapnel spread, in degrees. Defaults to full sphere.
        Vector3 offset = (0, 0, 0), // Offset from which shrapnel is released.
        double angleOfs = 0,        // Angle offset for center of spread.
        double pitchOfs = 0,        // Pitch offset for center of spread.
        int flags = 0)              // See EShrapnelFlags
    {
        for (int i = 0; i < fragCount; ++i)
        {
            double fragAngle, fragPitch;
            [fragAngle, fragPitch] = BulletAngle(spread, angle + angleOfs, pitch + pitchOfs);

            A_SpawnProjectile(fragType,
                height / 2,
                0,
                fragAngle,
                CMF_TrackOwner | CMF_AimDirection | CMF_AbsoluteAngle | CMF_SavePitch,
                fragPitch);
        }
    }

    // TODO: flags
    // Sets off explosive if anything crosses beam.
    State ZWL_Tripwire(
        StateLabel st = "Death",        // State to jump to
        Class<Actor> trailType = null,  // Type of trail to show for beam
        Vector3 offset = (0, 0, 0),     // Offset for beam
        double angleOfs = 0,            // Angle to fire beam at
        double pitchOfs = 0,            // Pitch to fire beam at
        int range = 8192)               // Maximum detection range
    {
        FLineTraceData trace;
        LineTrace(angle + angleOfs, range, pitch + pitchOfs, 0, offset.z, offset.x, offset.y, trace);

        if (trace.hitType == Trace_HitActor)
        {
            A_PlaySound(deathSound);
            return ResolveState(st);
        }

        if (trailType)
        {
            let spot = Spawn("Actor", trace.hitLocation);
            SpawnMissileXYZ(pos + offset, spot, trailType);
            spot.Destroy();
        }

        return ResolveState(null);
    }

    // Sets off explosive if anything enters radius.
    State ZWL_Proximity(
        int range,                      // Radius in which to set off explosive
        StateLabel st = "Death",        // State to jump to
        int flags = ZPF_DetectEnemies)  // See EProximityFlags
    {
        let it = BlockThingsIterator.Create(self, range);
        while (it.Next())
        {

            if (Distance3D(it.thing) < range && CheckSight(it.thing))
            {
                let src = target ? target : Actor(self);
                if (flags & ZPF_DetectEnemies && src.isHostile(it.thing)
                    || flags & ZPF_DetectFriends && src.isFriend(it.thing))
                {
                    A_PlaySound(deathSound);
                    return ResolveState(st);
                }
            }
        }

        return ResolveState(null);
    }

    // Turns explosive toward the spot its source is looking at.
    void ZWL_LaserGuidedMissile(double maxTurnAngle)
    {
        if (!target) return;

        // Init pitch, since ZWL_FireProjectile doesn't set pitch, yet.
        // Honestly, I've put much more work into working around this than it would take to change it. Come 1.0, though.
        if (pitch == 0) pitch = -VectorAngle(vel.xy.Length(), vel.z);

        double zOffset = target.height / 2;
        if (PlayerPawn(target) && target.player)
        {
            zOffset += PlayerPawn(target).attackZOffset;
            zOffset *= target.player.crouchFactor;
        }

        FLineTraceData trace;
        target.LineTrace(target.angle, 8192, target.pitch, 0, zOffset, data: trace);

        Vector3 v = trace.hitLocation - pos;

        double targetAngle = VectorAngle(v.x, v.y);
        double targetPitch = -VectorAngle(v.xy.Length(), v.z);

        // Note: missile can turn faster, diagonally
        angle += Clamp(DeltaAngle(angle, targetAngle), -maxTurnAngle, maxTurnAngle);
        pitch += Clamp(DeltaAngle(pitch, targetPitch), -maxTurnAngle, maxTurnAngle);

        Vel3DFromAngle(vel.Length(), angle, pitch);
    }


    override void BeginPlay()
    {
        Super.BeginPlay();

        if (bStickToFloors)
        {
            bBounceOnFloors = true;
            bUseBounceState = true;
            bounceFactor = 0;
        }

        if (bStickToCeilings)
        {
            bBounceOnCeilings = true;
            bUseBounceState = true;
            bounceFactor = 0;
        }

        if (bStickToWalls)
        {
            bBounceOnWalls = true;
            bUseBounceState = true;
            wallBounceFactor = 0;
        }

        if (bStickToActors)
        {
            bAllowBounceOnActors = true;
            bBounceOnActors = true;
            bUseBounceState = true;
            bounceFactor = 0;
        }

        bWillHitOwner = bHitOwner;
        bHitOwner = false;
    }

    override void Tick()
    {
        Super.Tick();

        if (bAutoCountdown && reactionTime > 0) A_Countdown();

        if (bWillHitOwner)
        {
            // Can't use CheckBlock, since it damages player like a ripper
            Vector3 v = pos - target.pos;

            if (Abs(v.x) > radius + target.radius
                || Abs(v.y) > radius + target.radius
                || v.z < -height
                || v.z > target.height)
            {
                bWillHitOwner = false;
                bHitOwner = true;
            }
        }

        if (stuckActor)
        {
            Vector3 newPos = stuckActorOffset;
            newPos.xy = RotateVector(newPos.xy, stuckActor.angle);
            newPos += stuckActor.pos;
            SetOrigin(newPos, true);
        }
    }


    // Returns random angle and pitch within cone
    // I have no idea if there's a better way of doing this ¯\_(ツ)_/¯
    // Params:
    //  - accuracy: maximum angle b/w cone's axis, and bullet trajectory
    //  - angle: angle of axis
    //  - pitch: pitch of axis
    double, double BulletAngle(double accuracy, double angle, double pitch)
    {
        Vector3 v = (0, 0, 0);

        if (accuracy > 10)
        {
            // Generate random vector in sphere section
            Vector3 axis = (Cos(pitch) * Cos(angle), Cos(pitch) * Sin(angle), -Sin(pitch));
            while (v == (0, 0, 0) || v.Length() > 1 || ACos(axis dot v.Unit()) > accuracy)
            {
                v = (FRandom(-1, 1), FRandom(-1, 1), FRandom(-1, 1));
            }

            // Extract angle and pitch from trajectory
            angle = VectorAngle(v.x, v.y);
            pitch = -ASin(v.z / v.Length());
        }
        else if (accuracy > 0)
        {
            // Generate random vector in sphere around end of axis
            double r = Sin(accuracy);
            while (v == (0, 0, 0) || v.Length() > r)
            {
                v = (FRandom(-r, r), FRandom(-r, r), FRandom(-r, r));
            }

            Vector3 axis = (Cos(pitch) * Cos(angle), Cos(pitch) * Sin(angle), -Sin(pitch));
            v += axis;

            // Extract angle and pitch from trajectory
            angle = VectorAngle(v.x, v.y);
            pitch = -ASin(v.z / v.Length());
        }

        return angle, pitch;
    }
}