class GWM_StatusBar : BaseStatusBar
{
	HUDFont mHUDFont;
	HUDFont mIndexFont;
	HUDFont mAmountFont;
	InventoryBarState diparms;
	

	override void Init()
	{
		Super.Init();
		SetSize(32, 320, 200);

		// Create the font used for the fullscreen HUD
		Font fnt = "BigUpper";
		mHUDFont = HUDFont.Create(fnt, 2, false, 2, 2);
		fnt = "INDEXFONT_DOOM";
		mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
		mAmountFont = HUDFont.Create("INDEXFONT");
		diparms = InventoryBarState.Create();
	}

	override void Draw (int state, double TicFrac)
	{
		Super.Draw (state, TicFrac);

		if (state == HUD_StatusBar)
		{
			BeginStatusBar();
			DrawMainBar (TicFrac);
		}
		else if (state == HUD_Fullscreen)
		{
			BeginHUD();
			DrawFullScreenStuff ();
		}
	}

	protected void DrawMainBar (double TicFrac)
	{
		DrawImage("STBAR", (0, 168), DI_ITEM_OFFSETS);
		DrawString(mHUDFont, "%", (90, 171), DI_ITEM_OFFSETS, translation: Font.CR_Sapphire);
		DrawString(mHUDFont, "%", (221, 171), DI_ITEM_OFFSETS, translation: Font.CR_Sapphire);
		
		Inventory a1 = GetCurrentAmmo();
		if (a1 != null) DrawString(mHUDFont, FormatNumber(a1.Amount, 3), (44, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, translation: Font.CR_Sapphire);
		DrawString(mHUDFont, FormatNumber(CPlayer.health, 3), (90, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, translation: Font.CR_Sapphire);
		DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3), (221, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, translation: Font.CR_Sapphire);

		DrawBarKeys();
		DrawBarAmmo();
		
		if (deathmatch || teamplay)
		{
			DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (138, 171), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
		}
		else
		{
			DrawBarWeapons();
		}
		
		if (multiplayer)
		{
			DrawImage("STFBANY", (143, 168), DI_ITEM_OFFSETS|DI_TRANSLATABLE);
		}
		
		if (CPlayer.mo.InvSel != null && !Level.NoInventoryBar)
		{
			DrawInventoryIcon(CPlayer.mo.InvSel, (160, 198), DI_DIMDEPLETED);
			if (CPlayer.mo.InvSel.Amount > 1)
			{
				DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount), (175, 198-mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_GOLD);
			}
		}
		else
		{
			DrawTexture(GetMugShot(5), (143, 168), DI_ITEM_OFFSETS);
		}
		if (isInventoryBarVisible())
		{
			DrawInventoryBar(diparms, (48, 169), 7, DI_ITEM_LEFT_TOP);
		}
		
	}
	
	protected virtual void DrawBarKeys()
	{
		bool locks[6];
		String image;
		for(int i = 0; i < 6; i++) locks[i] = CPlayer.mo.CheckKeys(i + 1, false, true);
		// key 1
		if (locks[1] && locks[4]) image = "STKEYS6";
		else if (locks[1]) image = "STKEYS0";
		else if (locks[4]) image = "STKEYS3";
		DrawImage(image, (239, 171), DI_ITEM_OFFSETS);
		// key 2
		if (locks[2] && locks[5]) image = "STKEYS7";
		else if (locks[2]) image = "STKEYS1";
		else if (locks[5]) image = "STKEYS4";
		else image = "";
		DrawImage(image, (239, 181), DI_ITEM_OFFSETS);
		// key 3
		if (locks[0] && locks[3]) image = "STKEYS8";
		else if (locks[0]) image = "STKEYS2";
		else if (locks[3]) image = "STKEYS5";
		else image = "";
		DrawImage(image, (239, 191), DI_ITEM_OFFSETS);
	}
	
	protected virtual void DrawBarAmmo()
	{
		int amt1, maxamt;
		[amt1, maxamt] = GetAmount("GWM_LowCaliberMagazine");
		DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 173), DI_TEXT_ALIGN_RIGHT);
		DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 173), DI_TEXT_ALIGN_RIGHT);
		
		[amt1, maxamt] = GetAmount("GWM_Shell");
		DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 179), DI_TEXT_ALIGN_RIGHT);
		DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 179), DI_TEXT_ALIGN_RIGHT);
		
		[amt1, maxamt] = GetAmount("GWM_RocketAmmo");
		DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 185), DI_TEXT_ALIGN_RIGHT);
		DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 185), DI_TEXT_ALIGN_RIGHT);
		
		[amt1, maxamt] = GetAmount("GWM_Cell");
		DrawString(mIndexFont, FormatNumber(amt1, 3), (288, 191), DI_TEXT_ALIGN_RIGHT);
		DrawString(mIndexFont, FormatNumber(maxamt, 3), (314, 191), DI_TEXT_ALIGN_RIGHT);
	}
	
	protected virtual void DrawBarWeapons()
	{
		DrawImage("STARMS", (104, 168), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(2)? "STYSNUM2" : "STGNUM2", (111, 172), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(3)? "STYSNUM3" : "STGNUM3", (123, 172), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(4)? "STYSNUM4" : "STGNUM4", (135, 172), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(5)? "STYSNUM5" : "STGNUM5", (111, 182), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(6)? "STYSNUM6" : "STGNUM6", (123, 182), DI_ITEM_OFFSETS);
		DrawImage(CPlayer.HasWeaponsInSlot(7)? "STYSNUM7" : "STGNUM7", (135, 182), DI_ITEM_OFFSETS);
	}

	protected void DrawFullScreenStuff ()
	{
		Vector2 iconbox = (40, 20);
		// Draw health
		let berserk = CPlayer.mo.FindInventory("PowerStrength");
		DrawImage(berserk? "PSTRA0" : "MEDIA0", (20, -2));
/*		if (CPlayer.Health == 0)
			DrawBar("STBAROFF", "STBAROFF", CPlayer.Health, 0, (44, -20), 0, 0);
		else if (CPlayer.Health > 0 && CPlayer.Health <= 100)
			DrawBar("STBARON", "STBAROFF", CPlayer.Health, 100, (44, -20), 0, 0);
		else if (CPlayer.Health > 100 && CPlayer.Health <= 200)
			DrawBar("STBAR200", "STBARON", CPlayer.Health-100, 100, (44, -20), 0, 0);
		else if (CPlayer.Health > 200)
			DrawBar("STBAR300", "STBAR200", CPlayer.Health-200, 100, (44, -20), 0, 0);
*/
		DrawString(mHUDFont, FormatNumber(CPlayer.health, 3), (44, -20), translation: Font.CR_Sapphire);
		
		let armor = CPlayer.mo.FindInventory("BasicArmor");
		if (armor != null && armor.Amount > 0)
		{
			DrawInventoryIcon(armor, (20, -22));
			DrawString(mHUDFont, FormatNumber(armor.Amount, 3), (44, -40), translation: Font.CR_Sapphire);
		}
		
		int amt1, amt2;
		
		amt1 = GetAmount("GWM_ChargedRockets");
		DrawString(mHUDFont, FormatNumber(amt1,3), (-44, -90), translation: Font.CR_Red);
		
		amt1 = GetAmount("GWM_PandoraPoints");
		amt2 = GetAmount("GWM_PandoraPointsCap");
		
		DrawString(mHUDFont, StringStruct.Format("%d/%d", amt1, amt2), (-10, -74), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Purple);
//		DrawString(mHUDFont, FormatNumber(amt1,8), (-94, -74), translation: Font.CR_Purple);
//		DrawString(mHUDFont, FormatNumber(amt2,8), (-94, -54), translation: Font.CR_Purple);
		
		
		TextureID mtex2 = GetMugShot(5); // get a texture
		String mtexname2 = TexMan.Getname(mtex2); // conver to string
		if (armor != null && armor.Amount > 0)
		{
			mtexname2.Replace("STF", "STX");
			DrawImage(mtexname2, (90, -36), DI_ITEM_OFFSETS|DI_SCREEN_LEFT_BOTTOM);
		}
		else
		{
			DrawTexture(GetMugShot(5,MugShot.STANDARD,"STF"), (90, -36), DI_ITEM_OFFSETS|DI_SCREEN_LEFT_BOTTOM);
		}
		
			 
		
		
		
		//THANK YOU ASH, YOU'RE MY HERO!!! -Mengo
		TextureID mtex = GetMugShot(1); // get a texture
		String mtexname = TexMan.Getname(mtex); // convert to string
		let arm = BasicArmor(CPlayer.mo.FindInventory('BasicArmor'));
		
		if(armor != null && armor.Amount > 0)
		{
			if (arm.armortype == "GWM_CombatArmor" ||arm.armortype == "GreenArmor")
			{
				if (armor.Amount > 75)
					mtexname.Replace("STF", "CA1");
				else if (armor.Amount > 50)
					mtexname.Replace("STF", "CA2");
				else if (armor.Amount > 25)
					mtexname.Replace("STF", "CA3");
				else if (armor.Amount > 0)
					mtexname.Replace("STF", "CA4");
					DrawImage(mtexname, (90, -36), DI_ITEM_OFFSETS|DI_SCREEN_LEFT_BOTTOM);
			}
			else
			if (arm.armortype == "GWM_AssaultArmor" ||arm.armortype == "BlueArmor")
			{
				if (armor.Amount > 150)
					mtexname.Replace("STF", "XA1");
				else if (armor.Amount > 100)
					mtexname.Replace("STF", "XA2");
				else if (armor.Amount > 50)
					mtexname.Replace("STF", "XA3");
				else if (armor.Amount > 0)
					mtexname.Replace("STF", "XA4");
					DrawImage(mtexname, (90, -36), DI_ITEM_OFFSETS|DI_SCREEN_LEFT_BOTTOM);
			}
			else
			{
				if (armor.Amount > 75)
					mtexname.Replace("STF", "CA1");
				else if (armor.Amount > 50)
					mtexname.Replace("STF", "CA2");
				else if (armor.Amount > 25)
					mtexname.Replace("STF", "CA3");
				else if (armor.Amount > 0)
					mtexname.Replace("STF", "CA4");
					DrawImage(mtexname, (90, -36), DI_ITEM_OFFSETS|DI_SCREEN_LEFT_BOTTOM);
			}
		}
		
		Inventory ammotype1, ammotype2;
		[ammotype1, ammotype2] = GetCurrentAmmo();
		let weapon = ZWeapon(cplayer.readyWeapon);
		int invY = -20;
		if (ammotype1 != null)
		{
			if (ammotype1 && weapon && weapon.magazineSize > 0)
			{
				DrawInventoryIcon(ammotype1, (-14, -4));
				DrawString(mHUDFont, StringStruct.Format("%d/%d", weapon.ammoCount, ammoType1.amount), (-30, -20),
						   DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
				invY -= 20;
			}
			else
			{
				DrawInventoryIcon(ammotype1, (-14, -4));
				DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3), (-30, -20), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
				invY -= 20;
			}
		}
		if (ammotype2 != null && ammotype2 != ammotype1)
		{
			DrawInventoryIcon(ammotype2, (-14, invY + 17));
			DrawString(mHUDFont, FormatNumber(ammotype2.Amount, 3), (-30, invY), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
			invY -= 20;
		}
		if (weapon && weapon.maxCharge > 0)
		{
			DrawString(mHUDFont, StringStruct.Format("%d/%d", weapon.chargeLevel, weapon.maxCharge), (-30, invY),
					   DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
			invY -= 20;
		}
		if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel != null)
		{
			DrawInventoryIcon(CPlayer.mo.InvSel, (-14, invY + 17), DI_DIMDEPLETED);
			DrawString(mHUDFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (-30, invY), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
		}
		if (deathmatch)
		{
			DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (-3, 1), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_GOLD);
		}
		else
		{
			DrawFullscreenKeys();
		}
		
		if (isInventoryBarVisible())
		{
			DrawInventoryBar(diparms, (0, 0), 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW);
		}
		
		DrawImage("IceHUDFX", (0, 0), DI_ITEM_OFFSETS|DI_SCREEN_CENTER,GetAmount("IceSlowCount")*0.002);
		
		if (GetAmount("FireburnCount")) 
		{
		DrawImage("FirHUDFX", (0, 0), DI_ITEM_OFFSETS|DI_SCREEN_CENTER_BOTTOM,0.25+frandom(0.03, 0.09)+GetAmount("FireburnCount")*0.002);
		}
		
		if (GetAmount("AcidWeakCount"))
		{
		DrawImage("AciHUDFX", (0, 0), DI_ITEM_OFFSETS|DI_SCREEN_CENTER,0.1+GetAmount("AcidWeakCount")*0.003);
		}
		
	}
	
	protected virtual void DrawFullscreenKeys()
	{
		// Draw the keys. This does not use a special draw function like SBARINFO because the specifics will be different for each mod
		// so it's easier to copy or reimplement the following piece of code instead of trying to write a complicated all-encompassing solution.
		Vector2 keypos = (-10, 2);
		int rowc = 0;
		double roww = 0;
		for(let i = CPlayer.mo.Inv; i != null; i = i.Inv)
		{
			if (i is "Key" && i.Icon.IsValid())
			{
				DrawTexture(i.Icon, keypos, DI_SCREEN_RIGHT_TOP|DI_ITEM_LEFT_TOP);
				Vector2 size = TexMan.GetScaledSize(i.Icon);
				keypos.Y += size.Y + 2;
				roww = max(roww, size.X);
				if (++rowc == 3)
				{
					keypos.Y = 2;
					keypos.X -= roww + 2;
					roww = 0;
					rowc = 0;
				}
			}
		}
	}
}
