class ZWeapon : Weapon
{
	// These constants can be used to convert to Doom's natural units.
	// e.g. 35*rps = 1 round/tic
	const sec = ticRate;
	const rpm = 1.0 / (ticRate * 60);
	const rps = 1.0 / ticRate;

	enum EWeaponReadyFlags
	{
		ZRF_NoBob           = 1 << 0,
		ZRF_NoSwitch        = 1 << 1,
		ZRF_DisableSwitch   = 1 << 2,
		ZRF_NoPrimary       = 1 << 3,
		ZRF_NoSecondary     = 1 << 4,
		ZRF_NoZoom          = 1 << 5,   // Changed from WRF_AllowZoom.
		ZRF_NoReload        = 1 << 6,   // Changed from WRF_AllowReload.
		ZRF_NoPartialReload = 1 << 7,   // Weapon can't reload, until completely empty (like Marathon).
		ZRF_ExtraRound      = 1 << 8,   // Weapon can reload when full.
		ZRF_AllowUser1		= 1 << 9,	// Weapon allows USER1 key
		ZRF_AllowUser2		= 1 << 10,	// Weapon allows USER2 key
		ZRF_AllowUser3		= 1 << 11,	// Weapon allows USER3 key
		ZRF_AllowUser4		= 1 << 12,	// Weapon allows USER4 key

		ZRF_NoFire = ZRF_NoPrimary | ZRF_NoSecondary
	}

	enum EFireHitscanFlags
	{
		ZHF_DontUseAmmo = 1 << 0,
		ZHF_NoSound     = 1 << 1
	}

	enum EFireProjectileFlags
	{
		ZPF_DontUseAmmo     = 1 << 0,
		ZPF_NoSound         = 1 << 1,
		ZPF_AddPlayerVel    = 1 << 2
	}

	enum EAttackSoundState
	{
		ALS_Attack,
		ALS_Sustain,
		ALS_ReadyRelease,
		ALS_Release
	}


	double deficit;
	int lastShotTic;
	int pressed;
	int attackSoundState;
	int attackSoundStartTic;
	int chargeLevel;

	int ammoCount;
	int magazineSize;
	Sound reloadSound;
	Sound clickSound;
	Sound attackAttack;
	Sound attackRelease;
	double attackAttackTics;
	double attackLoopTics;
	int maxCharge;


	Property MagazineSize: magazineSize;                    // # of rounds weapon magazine can hold
	Property ReloadSound: reloadSound;                      // Sound weapon makes when reloading
	Property ClickSound: clickSound;                        // Sound weapon makes when empty and trigger is pulled

	/*
	AttackSound can be divided into up to 3 parts. Any part can be omitted. AttackSustain and AttackSound are the same;
	the only difference is that AttackSound won't loop if attackLoopTics isn't given (or is 0).
	 - Attack plays when trigger is first pulled, and lasts given # of tics.
	 - Sustain loops as long as weapon is firing. attackLoopTics doesn't actually affect length of loop.
	 - Release plays when trigger is relased or ammo runs out. It always waits for current loop to end (this is where
	   attackLoopTics comes into play).
	*/
	Property AttackAttack: attackAttack, attackAttackTics;
	Property AttackSustain: attackSound, attackLoopTics;
	Property AttackRelease: attackRelease;

	Property MaxCharge: maxCharge;


	// Does the same thing as A_WeaponReady. It has similar flags (see above).
	action void ZWL_WeaponReady(int flags = 0)
	{
		invoker.lastShotTic = 0;
		invoker.deficit = 0.0;

		ZWL_StopAttackLoop();

		invoker.CheckMagazine(true);

		// Empty weapon click
		if (!invoker.CheckMagazine(false) && invoker.JustPressed(BT_Attack)                     // Primary
				|| invoker.GetAltAtkState(false) && !invoker.CheckAmmo(AltFire, false, true)    // Alt
				&& invoker.JustPressed(BT_AltAttack))
			A_PlaySound(invoker.clickSound, CHAN_Auto);

		// Weapon ready flags
		int wrf = 0;
		wrf |= flags & ZRF_NoSwitch ? WRF_NoSwitch : 0;
		wrf |= flags & ZRF_DisableSwitch ? WRF_DisableSwitch : 0;
		wrf |= flags & ZRF_AllowUser1 ? WRF_AllowUser1 : 0;
		wrf |= flags & ZRF_AllowUser2 ? WRF_AllowUser2 : 0;
		wrf |= flags & ZRF_AllowUser3 ? WRF_AllowUser3 : 0;
		wrf |= flags & ZRF_AllowUser4 ? WRF_AllowUser4 : 0;

		// If NoAutofire
		wrf |= flags & ZRF_NoPrimary || !invoker.CheckMagazine(false) && !invoker.Default.bAmmo_Optional || !invoker.JustPressed(BT_Attack) && !invoker.bNoAutofire ? WRF_NoPrimary : 0;

		wrf |= flags & ZRF_NoSecondary || !invoker.JustPressed(BT_AltAttack) ? WRF_NoSecondary : 0;

		wrf |= flags & ZRF_NoBob ? WRF_NoBob : 0;

		wrf |= !(flags & ZRF_NoZoom) && invoker.JustPressed(BT_Zoom) ? WRF_AllowZoom : 0;

		// WasPressed is because we have to reset the reload button in order for reload cancelling to work.
		// We have to reset it before allowing reload, or we'll enter reload state before this function runs.
		wrf |= !(flags & ZRF_NoReload) && !invoker.IsFull(flags & ZRF_ExtraRound)
			&& (invoker.CheckMagazine(false) || !(flags & ZRF_NoPartialReload))
			&& invoker.WasPressed(BT_Reload) ? WRF_AllowReload : 0;
// G: look at this further later, it's 1:33 am somehow
		A_WeaponReady(wrf);
	}


	/*
	Same as A_ReFire.
	Params:
	 - fullAuto: If false, weapon only fires if Attack was released and pressed again.
	*/
	action void ZWL_ReFire(StateLabel holdState = null, bool fullAuto = true)
	{
		if (invoker.bAltFire)
		{
			if (!invoker.CheckAmmo(AltFire, false, true))
				ZWL_StopAttackLoop();
		}
		else if (!invoker.CheckMagazine(false))
		{
			ZWL_StopAttackLoop();
		}

		invoker.CheckMagazine(true);

		if (fullAuto || invoker.JustPressed(BT_Attack) || invoker.JustPressed(BT_AltAttack))
		{
			A_ReFire(holdState);
		}
		else
		{
			A_CheckReload();
			player.refire = 0;  // Prevent weapon from going to Hold state next time it fires
		}
	}


	/*
	Jumps to given state if weapon is finished reloading.
	Params:
	 - allowCancel: If true, reload can be cancelled by pressing Reload again (meaning this function will jump).
	 - extraRound: If true, weapon can hold one extra round (presumably in the chamber).
	 */
	action State ZWL_JumpIfReloaded(StateLabel st, bool allowCancel = true, bool extraRound = false)
	{
		if (!invoker.CheckAmmo(PrimaryFire, false, true) || invoker.IsFull(extraRound)
				|| allowCancel && invoker.WasPressed(BT_Reload))
			return ResolveState(st);

		return ResolveState(null);
	}


	// Jumps if either magazine is empty, or no ammo remains.
	action State ZWL_JumpIfEmpty(StateLabel st)
	{
		if (!invoker.CheckMagazine(false))
			return ResolveState(st);

		return ResolveState(null);
	}


	// Auto-reloads weapon, if empty. Auto-switches if player has no ammo left.
	action void ZWL_CheckReload(bool autoReload = true, bool autoSwitch = true)
	{
		invoker.CheckMagazine(autoReload);
		invoker.CheckAmmo(invoker.bAltFire ? AltFire : PrimaryFire, autoSwitch);
	}


	/*
	Fires one or more hitscan shots.
	Params:
	 - accuracy: Random bullet spread, in degrees.
	 - damage: Damage done. Unlike A_FireBullets, this is never multiplied by Random(1, 3).
	 - fireRate: Rate of fire in rounds-per-tic. You can convert from rounds-per-minute using the rpm constant.
	 - pellets: Number of shotgun pellets to fire per shot.
	 - spread: Random pellet spread. Pellets fire in a cone. Accuracy controls its center. Spread controls its size.
	 - range: The maximum distance at which the bullets can do damage.
	 - damageType: Type of damage to do.
	 - puffType: Actor to spawn if shot hits a wall.
	 - tracerType: The actor projectile to spawn. This actor faces the bullet puff and travels directly towards it.
	 - tracerFreq: Tracers are only fired once in this many shots.
	 - offset: Offset from which hitscan attacks are fired, relative to player. X is forward, Y is right, Z is up.
	 - flags: Customizes behavior.
		- ZHF_DontUseAmmo: Weapon won't use ammo.
		- ZHF_NoSound: Weapon won't play attack sound.
	*/
	action void ZWL_FireHitscan(double accuracy, int damage, double fireRate = -1, int pellets = 1, double spread = 0,
								double range = 8192, Name damageType = 'Normal', class<Actor> puffType = "ZBulletPuff",
								class<Actor> tracerType = null, int tracerFreq = 1, Vector3 offset = (0, 0, 0),
								int flags = 0)
	{
		int rounds = fireRate > 0 ? invoker.RoundCount(fireRate) : 1;

		if (rounds > 0)
			ZWL_StartAttackLoop();

		FTranslatedLineTarget lineTarget;
		double aimPitch = AimLineAttack(angle, range, lineTarget);
		double aimAngle = lineTarget.lineTarget ? lineTarget.attackAngleFromSource : angle; // TODO: actually use aimAngle

		for (int i = 0; i < rounds; ++i)
		{
			if (!(flags & ZHF_DontUseAmmo) && !invoker.DepleteAmmo(invoker.bAltFire))
				break;

			double shotAngle, shotPitch;
			[shotAngle, shotPitch] = invoker.BulletAngle(accuracy, aimAngle, aimPitch);

			for (int j = 0; j < pellets; ++j)
			{
				double pelAngle, pelPitch;
				[pelAngle, pelPitch] = invoker.BulletAngle(spread, shotAngle, shotPitch);

				Actor puff;
				puff = LineAttack(pelAngle, range, pelPitch, damage, damageType, puffType, LAF_NoRandomPuffZ,
								  offsetZ: offset.z, offsetForward: offset.x, offsetSide: offset.y);

				if (tracerType && invoker.AmmoLeft(invoker.bAltFire) % tracerFreq == 0)
				{
					let xy = RotateVector(offset.xy, angle);

					double playerPitch = pitch;
					pitch = pelPitch;
					SpawnPlayerMissile(tracerType, pelAngle, xy.x, xy.y, offset.z);
					pitch = playerPitch;
				}
			}
		}
	}


	/*
	Fires one or more projectiles.
	Params:
	 - missileType: Type of projectile to fire.
	 - accuracy: Random bullet spread, in degrees.
	 - fireRate: Rate of fire in rounds-per-tic. You can convert from rounds-per-minute using the rpm constant.
	 - tracerType: The actor projectile to spawn. This actor faces the bullet puff and travels directly towards it.
	 - tracerFreq: Tracers are only fired once in this many shots.
	 - offset: Offset from which hitscan attacks are fired, relative to player. X is forward, Y is right, Z is up.
	 - angleOfs: Angle at which projectile fires (relative to straight ahead).
	 - pitchOfs: Pitch at which projectile fires (relative to straight ahead).
	 - flags: Customizes behavior.
		- ZPF_DontUseAmmo: Weapon won't use ammo.
		- ZPF_NoSound: Weapon won't play attack sound.
	*/
	action void ZWL_FireProjectile(class<Actor> missileType, double accuracy, double fireRate = -1,
								   class<Actor> tracerType = null, int tracerFreq = 1, Vector3 offset = (0, 0, 0),
								   double angleOfs = 0, double pitchOfs = 0, double speed = -1, double damage = -1, int flags = 0)
	{
		int rounds = fireRate > 0 ? invoker.RoundCount(fireRate) : 1;

		if (!(flags & ZPF_NoSound) && rounds > 0)
			ZWL_StartAttackLoop();

		// Rotate base direction by angle and pitch offsets
		Vector3 baseDirection = (Cos(pitch) * Cos(angle), Cos(pitch) * Sin(angle), -Sin(pitch));
		Vector3 right = (Cos(angle-90.0), Sin(angle-90.0), 0.0);
		Vector3 up = (Cos(pitch-90.0) * Cos(angle), Cos(pitch-90.0) * Sin(angle), -Sin(pitch-90.0));

		baseDirection += Sin(angleOfs) * right;
		baseDirection += Sin(-pitchOfs) * up;

		double baseAngle = VectorAngle(baseDirection.x, baseDirection.y);
		baseDirection.xy = RotateVector(baseDirection.xy, -baseAngle);
		double basePitch = -VectorAngle(baseDirection.x, baseDirection.z);

		for (int i = 0; i < rounds; ++i)
		{
			if (!(flags & ZPF_DontUseAmmo) && !invoker.DepleteAmmo(invoker.bAltFire))
				break;

			class<Actor> type = missileType;
			if (tracerType && invoker.AmmoLeft(invoker.bAltFire) % tracerFreq == 0)
				type = tracerType;

			double misAngle, misPitch;
			[misAngle, misPitch] = invoker.BulletAngle(accuracy, baseAngle, basePitch);

			// Rotate offset
			offset.y *= -1;  // The +y axis is to the right, for offsets
			let xz = RotateVector((offset.x, offset.z), -basePitch);
			offset.x = xz.x;
			offset.z = xz.y;
			offset.xy = RotateVector(offset.xy, baseAngle);

			double playerPitch = pitch;
			pitch = misPitch;
			Actor missile = SpawnPlayerMissile(type, misAngle, offset.x, offset.y, offset.z);
			pitch = playerPitch;

			if (missile)
			{
				if (speed >= 0)
					missile.Vel3dFromAngle(speed, misAngle, misPitch);

				if (damage >= 0)
					missile.SetDamage(damage);

				if (missile && flags & ZPF_AddPlayerVel)
					missile.vel += vel;
			}
		}
	}


	/*
	Ejects a bullet casing to the side.
	Params:
	 - casingType: Type of actor to eject.
	 - left: If true, casing ejects to the left. Otherwise it ejects to the right.
	 - ejectPitch: Pitch at which casing ejects, relative to view direction.
	 - speed: Speed at which casing ejects.
	 - accuracy: Random spread, in degrees.
	 - offset: Offset from which casing is ejected, relative to center of view.
	*/
	action void ZWL_EjectCasing(class<Actor> casingType, bool left = false, double ejectPitch = -45, double speed = 4,
								double accuracy = 8, Vector3 offset = (24, 0, -10))
	{
		// Find offset vector
		// +y axis is to the right for offsets
		offset.y *= -1;

		// Rotate offset by pitch
		Vector2 xz = RotateVector((offset.x, offset.z), -pitch);
		offset.x = xz.x;
		offset.z = xz.y;

		// Rotate vector by angle
		offset.xy = RotateVector(offset.xy, angle);

		// Move to player camera
		offset.xy += pos.xy;
		offset.z += player.viewZ;

		// Find velocity vector
		Vector3 side = (Cos(angle + (left ? 90 : -90)), Sin(angle + (left ? 90 : -90)), 0);
		Vector3 up = (Cos(pitch-90) * Cos(angle), Cos(pitch-90) * Sin(angle), -Sin(pitch-90));
		Vector3 baseDirection = Cos(-ejectPitch) * side + Sin(-ejectPitch) * up;

		double baseAngle = VectorAngle(baseDirection.x, baseDirection.y);
		baseDirection.xy = RotateVector(baseDirection.xy, -baseAngle);
		double basePitch = -VectorAngle(baseDirection.x, baseDirection.z);

		double casAngle, casPitch;
		[casAngle, casPitch] = invoker.BulletAngle(accuracy, baseAngle, basePitch);

		let casing = Spawn(casingType, offset);
		casing.Vel3dFromAngle(speed, casAngle, casPitch);
		casing.vel += vel;
	}


	/*
	Removes rounds from weapon.
	Params:
	 - Rounds: Number of rounds to remove. 0 means a full magazine. < 0 means to leave -rounds in the weapon.
	 - toInventory: If true, rounds go back to player's inventory.
	*/
	action void ZWL_Unload(int rounds = 0, bool toInventory = false)
	{
		if (rounds <= 0)
		{
			rounds = Max(invoker.ammoCount + rounds, 0);
		}

		int tradeAmt = Min(rounds, invoker.ammoCount);

		invoker.ammoCount -= tradeAmt;

		Inventory playerAmmo = FindInventory(invoker.ammoType1);
		if (toInventory && playerAmmo)
		{
			playerAmmo.amount += tradeAmt;
		}
	}


	/*
	Reloads weapon.
	Params:
	 - rounds: # of rounds to reload. If rounds is 0, reload full magazine, or more, if < 0.
	 - wasteRemaining: If true, remaining ammo is discarded.
	*/
	action void ZWL_Reload(int rounds = 0, bool wasteRemaining = false)
	{
		if (wasteRemaining)
		{
			invoker.ammoCount = 0;
		}

		Inventory playerAmmo = FindInventory(invoker.ammoType1);
		if (playerAmmo)
		{
			if (rounds <= 0)
			{
				rounds = invoker.magazineSize - invoker.ammoCount - rounds;
			}

			A_PlaySound(invoker.reloadSound, CHAN_Weapon);

			int tradeAmt = Min(rounds, playerAmmo.amount);

			invoker.ammoCount += tradeAmt;
			playerAmmo.amount -= tradeAmt;
		}
	}


	// Raises weapon all the way, but doesn't jump to Ready state. Use before custom select animation.
	action void ZWL_QuickRaise()
	{
		A_OverlayOffset(PSP_WEAPON, 0, 32);
	}

	// Lowers weapon and switches to next one immediately. Use after custom deselect animation.
	action void ZWL_QuickLower()
	{
		A_Lower(256);
	}


	// Plays looping attack sound. Automatically called by ZWL_FireHitscan.
	action void ZWL_StartAttackLoop(bool interrupt = false)
	{
		if (invoker.attackSoundState == ALS_Release || invoker.attackSoundState == ALS_ReadyRelease || interrupt)
		{
			if (invoker.attackLoopTics > 0)
			{
				if (invoker.attackAttack)
				{
					// Loop w/ attack
					A_PlaySound(invoker.attackAttack, CHAN_Weapon);
					invoker.attackSoundState = ALS_Attack;
					invoker.attackSoundStartTic = gameTic;
				}
				else
				{
					// Loop w/o attack
					A_PlaySound(invoker.attackSound, CHAN_Weapon, 1.0, true);
					invoker.attackSoundState = ALS_Sustain;
					invoker.attackSoundStartTic = gameTic;
				}
			}
			else
			{
				// Non-looping attack sound
				A_PlaySound(invoker.attackSound, CHAN_Weapon);
				invoker.attackSoundState = ALS_Release;
			}
		}
	}


	// Ends looping attack sound. Automatically called by ZWL_WeaponReady.
	action void ZWL_StopAttackLoop()
	{
		if (invoker.attackSoundState != ALS_Release)
			invoker.attackSoundState = ALS_ReadyRelease;
	}

	action void ZWL_ResetCharge()
	{
		invoker.chargeLevel = 0;
	}

	action void ZWL_Charge(StateLabel overchargeState = null)
	{
		if (++invoker.chargeLevel > invoker.maxCharge)
		{
			if (overchargeState) invoker.owner.player.GetPSprite(PSP_Weapon).SetState(ResolveState(overchargeState));
			else invoker.chargeLevel = invoker.maxCharge;
		}
	}


	override void BeginPlay()
	{
		Super.BeginPlay();

		bAmmo_Optional = magazineSize > 0;
		attackSoundState = ALS_Release;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		// If player spawns w/ weapon, make sure it's loaded
		if (owner && magazineSize > 0)
		{
			int tradeAmt = Min(Default.ammoGive1, ammo1.amount);
			ammo1.amount -= tradeAmt;
			ammoCount += tradeAmt;
		}
	}

	override void Tick()
	{
		if (owner && owner.player && owner.player.readyWeapon == self)
			pressed |= owner.player.cmd.buttons & ~owner.player.oldbuttons;

		Super.Tick();

		// Advance attack loop
		if (attackSoundState != ALS_Release)
		{
			int ticsSinceStart = gameTic - attackSoundStartTic;
			bool onBeat = ticsSinceStart % attackLoopTics < 1;
			if (attackSoundState == ALS_Attack && ticsSinceStart >= attackAttackTics)
			{
				// Attack is over
				owner.A_PlaySound(attackSound, CHAN_Weapon, 1.0, true);
				attackSoundState = ALS_Sustain;
				attackSoundStartTic = gameTic;
			}
			else if (attackSoundState == ALS_ReadyRelease && onBeat)
			{
				// Time to end loop
				owner.A_PlaySound(attackRelease, CHAN_Weapon);
				attackSoundState = ALS_Release;
			}
		}
	}


	/*
	Removes ammo from magazine or inventory.
	Params:
	 - altFire: Whether to deplete primary or secondary ammo. Note: [Primary|Alt]_Uses_Both flags modify behavior.
	 - checkEnough: If true, will return false w/o depleting ammo, if not enough remains.
	 - ammoUse: How much ammo to deplete. Defaults to AmmoUse[1|2] if < 0.
	*/
	override bool DepleteAmmo(bool altFire, bool checkEnough, int ammoUse)
	{
		if (altFire || magazineSize <= 0)
			return Super.DepleteAmmo(altFire, checkEnough, ammoUse);

		// TODO: Check infinite ammo

		if (checkEnough && !CheckMagazine(false, false, ammoUse))
			return false;

		ammoCount -= ammoUse < 0 ? ammoUse1 : ammoUse;

		if (bPrimary_Uses_Both)
			ammo2.amount -= ammoUse2;

		ammoCount = Max(ammoCount, 0);

		if (ammo2)
			ammo2.amount = Max(ammo2.amount, 0);

		return true;
	}


	override void AttachToOwner (Actor other)
	{
		Super.AttachToOwner(other);

		// AmmoGive places ammo in magazine
		if (magazineSize > 0)
		{
			int tradeAmt = Min(ammoGive1, ammo1.amount);
			ammo1.amount -= tradeAmt;
			ammoCount += tradeAmt;
		}
	}


	/*
	Returns true if weapon has enough ammo in its magazine to fire.
	Params:
	 - autoReload: Reload weapon if it doesn't have enough ammo.
	 - requireAmmo: If true, overrides Ammo_Optional flag.
	 - ammoCount: How much ammo is required. Defaults to AmmoUse1 if < 0.
	*/
	virtual bool CheckMagazine(bool autoReload, bool requireAmmo = false, int ammoCount = -1)
	{
		if (magazineSize <= 0)
			return CheckAmmo(PrimaryFire, false, true);  // Magazine is all ammo in inventory

		if (!requireAmmo && Default.bAmmo_Optional)
			return true;

		if (self.ammoCount < (ammoCount < 0 ? ammoUse1 : ammoCount))
		{
			bAmmo_Optional = Default.bAmmo_Optional;

			if (autoReload && CheckAmmo(PrimaryFire, false, true) && owner && owner.player)
				owner.player.GetPSprite(PSP_Weapon).SetState(GetReloadState());

			return false;
		}

		bAmmo_Optional = true;

		return true;
	}


	virtual State GetReloadState()
	{
		return ResolveState("Reload");
	}


	// Everything below here is just helper functions. I'll document them later.

	bool IsFull(bool extraRound)
	{
		return ammoCount >= magazineSize + extraRound;
	}

	bool JustPressed(int button)
	{
		if (!owner || !owner.player) return false;

		return owner.player.cmd.buttons & button && !(owner.player.oldButtons & button);
	}

	bool WasPressed(int button, bool reset = true)
	{
		if (pressed & button)
		{
			pressed &= reset ? ~button : -1;
			return true;
		}

		return false;
	}


	// Returns amount of ammo remaining (in magazine)
	int AmmoLeft(bool altFire)
	{
		if (altFire)
		{
			Inventory ammo = owner.FindInventory(ammoType2);
			return ammo ? ammo.amount : 0;
		}
		else
		{
			if (magazineSize > 0)
			{
				return ammoCount;
			}
			else
			{
				Inventory ammo = owner.FindInventory(ammoType1);
				return ammo ? ammo.amount : 0;
			}
		}
	}


	// Returns # of bullets to fire to match rate-of-fire
	int RoundCount(double fireRate)
	{
		int interval;
		if (lastShotTic == 0)
			interval = fireRate < 1 ? 1/fireRate : 1;  // Ensure weapon fires immediately on trigger pull
		else
			interval = gameTic - lastShotTic;

		lastShotTic = gameTic;

		int rounds = interval * fireRate;

		// Fire extra bullet occasionally to keep up w/ rate-of-fire
		deficit += (interval * fireRate) % 1;
		if (deficit >= 1)
		{
			++rounds;
			--deficit;
		}

		return rounds;
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