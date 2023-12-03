class ZTrail : Actor
{
    enum EParticleFlags
    {
        PF_FullBright = SPF_FullBright,
        PF_NoTimeFreeze = SPF_NoTimeFreeze
    }


    Default
    {
        +NoGravity
        +NoClip
    }


    void DrawSegment(Vector3 aPos, Vector3 bPos, Color aCol, Color bCol, double aSize = 1, double bSize = -1,
                     double aAlpha = 1, double bAlpha = -1, double spacing = 1, int lifetime = TicRate,
                     Vector3 vel = (0, 0, 0), Vector3 accel = (0, 0, 0), double fadeStep = -1, double sizeStep = 0,
                     int flags = 0)
    {
        let realPos = pos;
        SetXyz(aPos);

        if (bSize < 0)
            bSize = aSize;
        if (bAlpha < 0)
            bAlpha = aAlpha;

        let dis = bPos - aPos;
        let step = dis.Length() > 1 ? spacing / dis.Length() : 1;
        for (double t = 0; t < 1; t += step)
        {
            Color col = int(Lerp(aCol.r, bCol.r, t)) << 16
                      | int(Lerp(aCol.g, bCol.g, t)) << 8
                      | int(Lerp(aCol.b, bCol.b, t));
            double size = Lerp(aSize, bSize, t);
            Vector3 ofs = (Lerp(0, dis.x, t), Lerp(0, dis.y, t), Lerp(0, dis.z, t));
            double alpha = Lerp(aAlpha, bAlpha, t);

            A_SpawnParticle(col,
                            flags,
                            lifetime,
                            size,
                            0,
                            ofs.x, ofs.y, ofs.z,
                            vel.x, vel.y, vel.z,
                            accel.x, accel.y, accel.z,
                            alpha, fadeStep,
                            sizeStep);
        }

        SetXyz(realPos);
    }


	double lerp(float v0, float v1, double t)
    {
		return (1 - t) * v0 + t * v1;
	}
}