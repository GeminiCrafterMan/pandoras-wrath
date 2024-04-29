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
		[amt1, maxamt] = GetAmount("GWM_HollowPointMagazine");
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
		let berserk = CPlayer.mo.FindInventory("GWM_PowerStrength");
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

		amt1 = GetAmount("GWM_PandoraPoints");
		amt2 = GetAmount("GWM_PandoraPointsCap");
		DrawString(mHUDFont, StringStruct.Format("%d/%d", amt1, amt2), (-10, -74), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Purple);
		
		
		
		if (GWM_Player(CPlayer.mo))
		{
			amt1 = GWM_PLAYER(Cplayer.mo).chargedrockets;
			DrawString(mHUDFont, FormatNumber(amt1,3), (-44, -90), translation: Font.CR_Red);
			amt1 = GWM_PLAYER(Cplayer.mo).chargedgrenades;
			DrawString(mHUDFont, FormatNumber(amt1,3), (-44, -106), translation: Font.CR_Green);
			amt1 = GWM_PLAYER(Cplayer.mo).VulcanRage;
			DrawString(mHUDFont, FormatNumber(amt1,3), (-84, -106), translation: Font.CR_ORANGE);
			
			amt1 = GWM_PLAYER(Cplayer.mo).WeddingCharges;
			DrawString(mHUDFont, FormatNumber(amt1,3), (-84, -90), translation: Font.CR_WHITE);
			
		}
		amt1 = GetAmount("GWM_KahunaSpread");
		DrawString(mHUDFont, FormatNumber(amt1,3), (-44, -122), translation: Font.CR_Gold);
		

		
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
		
		if (weapon.magazineSize == 18)
		{
		if (weapon.ammocount > 0){DrawImage("2MAG1",(-30,-5));} else {DrawImage("2MAG0",(-30,-5));}
		if (weapon.ammocount > 3){DrawImage("2MAG1",(-40,-5));} else {DrawImage("2MAG0",(-40,-5));}
		if (weapon.ammocount > 6){DrawImage("2MAG1",(-50,-5));} else {DrawImage("2MAG0",(-50,-5));}
		if (weapon.ammocount > 9){DrawImage("2MAG1",(-60,-5));} else {DrawImage("2MAG0",(-60,-5));}
		if (weapon.ammocount > 12){DrawImage("2MAG1",(-70,-5));} else {DrawImage("2MAG0",(-70,-5));}
		if (weapon.ammocount > 15){DrawImage("2MAG1",(-80,-5));} else {DrawImage("2MAG0",(-80,-5));}
		}
		else
		if (weapon.magazineSize < 20)
		{
		if (weapon.magazineSize > 0) {if (weapon.ammocount > 0){DrawImage("MAG1",(-30,-5));} else {DrawImage("MAG0",(-30,-5));}}
		if (weapon.magazineSize > 1) {if (weapon.ammocount > 1){DrawImage("MAG1",(-35,-5));} else {DrawImage("MAG0",(-35,-5));}}
		if (weapon.magazineSize > 2) {if (weapon.ammocount > 2){DrawImage("MAG1",(-40,-5));} else {DrawImage("MAG0",(-40,-5));}}
		if (weapon.magazineSize > 3) {if (weapon.ammocount > 3){DrawImage("MAG1",(-45,-5));} else {DrawImage("MAG0",(-45,-5));}}
		if (weapon.magazineSize > 4) {if (weapon.ammocount > 4){DrawImage("MAG1",(-50,-5));} else {DrawImage("MAG0",(-50,-5));}}
		if (weapon.magazineSize > 5) {if (weapon.ammocount > 5){DrawImage("MAG1",(-55,-5));} else {DrawImage("MAG0",(-55,-5));}}
		if (weapon.magazineSize > 6) {if (weapon.ammocount > 6){DrawImage("MAG1",(-60,-5));} else {DrawImage("MAG0",(-60,-5));}}
		if (weapon.magazineSize > 7) {if (weapon.ammocount > 7){DrawImage("MAG1",(-65,-5));} else {DrawImage("MAG0",(-65,-5));}}
		if (weapon.magazineSize > 8) {if (weapon.ammocount > 8){DrawImage("MAG1",(-70,-5));} else {DrawImage("MAG0",(-70,-5));}}
		if (weapon.magazineSize > 9) {if (weapon.ammocount > 9){DrawImage("MAG1",(-75,-5));} else {DrawImage("MAG0",(-75,-5));}}
		if (weapon.magazineSize > 10) {if (weapon.ammocount > 10){DrawImage("MAG1",(-80,-5));} else {DrawImage("MAG0",(-80,-5));}}
		if (weapon.magazineSize > 11) {if (weapon.ammocount > 11){DrawImage("MAG1",(-85,-5));} else {DrawImage("MAG0",(-85,-5));}}
		if (weapon.magazineSize > 12) {if (weapon.ammocount > 12){DrawImage("MAG1",(-90,-5));} else {DrawImage("MAG0",(-90,-5));}}
		if (weapon.magazineSize > 13) {if (weapon.ammocount > 13){DrawImage("MAG1",(-95,-5));} else {DrawImage("MAG0",(-95,-5));}}
		if (weapon.magazineSize > 14) {if (weapon.ammocount > 14){DrawImage("MAG1",(-100,-5));} else {DrawImage("MAG0",(-100,-5));}}
		if (weapon.magazineSize > 15) {if (weapon.ammocount > 15){DrawImage("MAG1",(-105,-5));} else {DrawImage("MAG0",(-105,-5));}}
		if (weapon.magazineSize > 16) {if (weapon.ammocount > 16){DrawImage("MAG1",(-110,-5));} else {DrawImage("MAG0",(-110,-5));}}
		if (weapon.magazineSize > 17) {if (weapon.ammocount > 17){DrawImage("MAG1",(-115,-5));} else {DrawImage("MAG0",(-115,-5));}}
		if (weapon.magazineSize > 18) {if (weapon.ammocount > 18){DrawImage("MAG1",(-120,-5));} else {DrawImage("MAG0",(-120,-5));}}
		if (weapon.magazineSize > 19) {if (weapon.ammocount > 19){DrawImage("MAG1",(-125,-5));} else {DrawImage("MAG0",(-125,-5));}}
		}
		
		if (weapon.magazineSize < 10)
		{
		if (weapon.magazineSize > 0) {if (weapon.ammocount > 0){DrawImage("2MAG1",(-30,-5));} else {DrawImage("2MAG0",(-30,-5));}}
		if (weapon.magazineSize > 1) {if (weapon.ammocount > 1){DrawImage("2MAG1",(-40,-5));} else {DrawImage("2MAG0",(-40,-5));}}
		if (weapon.magazineSize > 2) {if (weapon.ammocount > 2){DrawImage("2MAG1",(-50,-5));} else {DrawImage("2MAG0",(-50,-5));}}
		if (weapon.magazineSize > 3) {if (weapon.ammocount > 3){DrawImage("2MAG1",(-60,-5));} else {DrawImage("2MAG0",(-60,-5));}}
		if (weapon.magazineSize > 4) {if (weapon.ammocount > 4){DrawImage("2MAG1",(-70,-5));} else {DrawImage("2MAG0",(-70,-5));}}
		if (weapon.magazineSize > 5) {if (weapon.ammocount > 5){DrawImage("2MAG1",(-80,-5));} else {DrawImage("2MAG0",(-80,-5));}}
		if (weapon.magazineSize > 6) {if (weapon.ammocount > 6){DrawImage("2MAG1",(-90,-5));} else {DrawImage("2MAG0",(-90,-5));}}
		if (weapon.magazineSize > 7) {if (weapon.ammocount > 7){DrawImage("2MAG1",(-100,-5));} else {DrawImage("2MAG0",(-100,-5));}}
		if (weapon.magazineSize > 8) {if (weapon.ammocount > 8){DrawImage("2MAG1",(-110,-5));} else {DrawImage("2MAG0",(-110,-5));}}
		if (weapon.magazineSize > 9) {if (weapon.ammocount > 9){DrawImage("2MAG1",(-120,-5));} else {DrawImage("2MAG0",(-120,-5));}}
		}
		
		if (weapon.magazineSize > 20)
		{
		if (weapon.magazineSize > 0) {if (weapon.ammocount > 0){DrawImage("3MAG1",(-30,-5));} else {DrawImage("3MAG0",(-30,-5));}}
		if (weapon.magazineSize > 1) {if (weapon.ammocount > 1){DrawImage("3MAG1",(-32,-5));} else {DrawImage("3MAG0",(-32,-5));}}
		if (weapon.magazineSize > 2) {if (weapon.ammocount > 2){DrawImage("3MAG1",(-34,-5));} else {DrawImage("3MAG0",(-34,-5));}}
		if (weapon.magazineSize > 3) {if (weapon.ammocount > 3){DrawImage("3MAG1",(-36,-5));} else {DrawImage("3MAG0",(-36,-5));}}
		if (weapon.magazineSize > 4) {if (weapon.ammocount > 4){DrawImage("3MAG1",(-38,-5));} else {DrawImage("3MAG0",(-38,-5));}}
		if (weapon.magazineSize > 5) {if (weapon.ammocount > 5){DrawImage("3MAG1",(-40,-5));} else {DrawImage("3MAG0",(-40,-5));}}
		if (weapon.magazineSize > 6) {if (weapon.ammocount > 6){DrawImage("3MAG1",(-42,-5));} else {DrawImage("3MAG0",(-42,-5));}}
		if (weapon.magazineSize > 7) {if (weapon.ammocount > 7){DrawImage("3MAG1",(-44,-5));} else {DrawImage("3MAG0",(-44,-5));}}
		if (weapon.magazineSize > 8) {if (weapon.ammocount > 8){DrawImage("3MAG1",(-46,-5));} else {DrawImage("3MAG0",(-46,-5));}}
		if (weapon.magazineSize > 9) {if (weapon.ammocount > 9){DrawImage("3MAG1",(-48,-5));} else {DrawImage("3MAG0",(-48,-5));}}
		if (weapon.magazineSize > 10) {if (weapon.ammocount > 10){DrawImage("3MAG1",(-50,-5));} else {DrawImage("3MAG0",(-50,-5));}}
		if (weapon.magazineSize > 11) {if (weapon.ammocount > 11){DrawImage("3MAG1",(-52,-5));} else {DrawImage("3MAG0",(-52,-5));}}
		if (weapon.magazineSize > 12) {if (weapon.ammocount > 12){DrawImage("3MAG1",(-54,-5));} else {DrawImage("3MAG0",(-54,-5));}}
		if (weapon.magazineSize > 13) {if (weapon.ammocount > 13){DrawImage("3MAG1",(-56,-5));} else {DrawImage("3MAG0",(-56,-5));}}
		if (weapon.magazineSize > 14) {if (weapon.ammocount > 14){DrawImage("3MAG1",(-58,-5));} else {DrawImage("3MAG0",(-58,-5));}}
		if (weapon.magazineSize > 15) {if (weapon.ammocount > 15){DrawImage("3MAG1",(-60,-5));} else {DrawImage("3MAG0",(-60,-5));}}
		if (weapon.magazineSize > 16) {if (weapon.ammocount > 16){DrawImage("3MAG1",(-62,-5));} else {DrawImage("3MAG0",(-62,-5));}}
		if (weapon.magazineSize > 17) {if (weapon.ammocount > 17){DrawImage("3MAG1",(-64,-5));} else {DrawImage("3MAG0",(-64,-5));}}
		if (weapon.magazineSize > 18) {if (weapon.ammocount > 18){DrawImage("3MAG1",(-66,-5));} else {DrawImage("3MAG0",(-66,-5));}}
		if (weapon.magazineSize > 19) {if (weapon.ammocount > 19){DrawImage("3MAG1",(-68,-5));} else {DrawImage("3MAG0",(-68,-5));}}
		if (weapon.magazineSize > 20) {if (weapon.ammocount > 20){DrawImage("3MAG1",(-70,-5));} else {DrawImage("3MAG0",(-70,-5));}}
		if (weapon.magazineSize > 21) {if (weapon.ammocount > 21){DrawImage("3MAG1",(-72,-5));} else {DrawImage("3MAG0",(-72,-5));}}
		if (weapon.magazineSize > 22) {if (weapon.ammocount > 22){DrawImage("3MAG1",(-74,-5));} else {DrawImage("3MAG0",(-74,-5));}}
		if (weapon.magazineSize > 23) {if (weapon.ammocount > 23){DrawImage("3MAG1",(-76,-5));} else {DrawImage("3MAG0",(-76,-5));}}
		if (weapon.magazineSize > 24) {if (weapon.ammocount > 24){DrawImage("3MAG1",(-78,-5));} else {DrawImage("3MAG0",(-78,-5));}}
		if (weapon.magazineSize > 25) {if (weapon.ammocount > 25){DrawImage("3MAG1",(-80,-5));} else {DrawImage("3MAG0",(-80,-5));}}
		if (weapon.magazineSize > 26) {if (weapon.ammocount > 26){DrawImage("3MAG1",(-82,-5));} else {DrawImage("3MAG0",(-82,-5));}}
		if (weapon.magazineSize > 27) {if (weapon.ammocount > 27){DrawImage("3MAG1",(-84,-5));} else {DrawImage("3MAG0",(-84,-5));}}
		if (weapon.magazineSize > 28) {if (weapon.ammocount > 28){DrawImage("3MAG1",(-86,-5));} else {DrawImage("3MAG0",(-86,-5));}}
		if (weapon.magazineSize > 29) {if (weapon.ammocount > 29){DrawImage("3MAG1",(-88,-5));} else {DrawImage("3MAG0",(-88,-5));}}
		if (weapon.magazineSize > 30) {if (weapon.ammocount > 30){DrawImage("3MAG1",(-90,-5));} else {DrawImage("3MAG0",(-90,-5));}}
		if (weapon.magazineSize > 31) {if (weapon.ammocount > 31){DrawImage("3MAG1",(-92,-5));} else {DrawImage("3MAG0",(-92,-5));}}
		if (weapon.magazineSize > 32) {if (weapon.ammocount > 32){DrawImage("3MAG1",(-94,-5));} else {DrawImage("3MAG0",(-94,-5));}}
		if (weapon.magazineSize > 33) {if (weapon.ammocount > 33){DrawImage("3MAG1",(-96,-5));} else {DrawImage("3MAG0",(-96,-5));}}
		if (weapon.magazineSize > 34) {if (weapon.ammocount > 34){DrawImage("3MAG1",(-98,-5));} else {DrawImage("3MAG0",(-98,-5));}}
		if (weapon.magazineSize > 35) {if (weapon.ammocount > 35){DrawImage("3MAG1",(-100,-5));} else {DrawImage("3MAG0",(-100,-5));}}
		if (weapon.magazineSize > 36) {if (weapon.ammocount > 36){DrawImage("3MAG1",(-102,-5));} else {DrawImage("3MAG0",(-102,-5));}}
		if (weapon.magazineSize > 37) {if (weapon.ammocount > 37){DrawImage("3MAG1",(-104,-5));} else {DrawImage("3MAG0",(-104,-5));}}
		if (weapon.magazineSize > 38) {if (weapon.ammocount > 38){DrawImage("3MAG1",(-106,-5));} else {DrawImage("3MAG0",(-106,-5));}}
		if (weapon.magazineSize > 39) {if (weapon.ammocount > 39){DrawImage("3MAG1",(-108,-5));} else {DrawImage("3MAG0",(-108,-5));}}
		if (weapon.magazineSize > 40) {if (weapon.ammocount > 40){DrawImage("3MAG1",(-110,-5));} else {DrawImage("3MAG0",(-110,-5));}}
		if (weapon.magazineSize > 41) {if (weapon.ammocount > 41){DrawImage("3MAG1",(-112,-5));} else {DrawImage("3MAG0",(-112,-5));}}
		if (weapon.magazineSize > 42) {if (weapon.ammocount > 42){DrawImage("3MAG1",(-114,-5));} else {DrawImage("3MAG0",(-114,-5));}}
		if (weapon.magazineSize > 43) {if (weapon.ammocount > 43){DrawImage("3MAG1",(-116,-5));} else {DrawImage("3MAG0",(-116,-5));}}
		if (weapon.magazineSize > 44) {if (weapon.ammocount > 44){DrawImage("3MAG1",(-118,-5));} else {DrawImage("3MAG0",(-118,-5));}}
		if (weapon.magazineSize > 45) {if (weapon.ammocount > 45){DrawImage("3MAG1",(-120,-5));} else {DrawImage("3MAG0",(-120,-5));}}
		if (weapon.magazineSize > 46) {if (weapon.ammocount > 46){DrawImage("3MAG1",(-122,-5));} else {DrawImage("3MAG0",(-122,-5));}}
		if (weapon.magazineSize > 47) {if (weapon.ammocount > 47){DrawImage("3MAG1",(-124,-5));} else {DrawImage("3MAG0",(-124,-5));}}
		if (weapon.magazineSize > 48) {if (weapon.ammocount > 48){DrawImage("3MAG1",(-126,-5));} else {DrawImage("3MAG0",(-126,-5));}}
		if (weapon.magazineSize > 49) {if (weapon.ammocount > 49){DrawImage("3MAG1",(-128,-5));} else {DrawImage("3MAG0",(-128,-5));}}
		if (weapon.magazineSize > 50) {if (weapon.ammocount > 50){DrawImage("3MAG1",(-130,-5));} else {DrawImage("3MAG0",(-130,-5));}}
		}
		
		if (ammotype1 != null)
		{
			if (ammotype1 && weapon && weapon.magazineSize > 0)
			{
				DrawInventoryIcon(ammotype1, (-14, -4));
				DrawString(mHUDFont, StringStruct.Format("%d/%d", weapon.ammoCount, ammoType1.amount), (-30, -30),
						   DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
				invY -= 20;
			}
			else
			{
				DrawInventoryIcon(ammotype1, (-14, -4));
				DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3), (-30, -30), DI_TEXT_ALIGN_RIGHT, translation: Font.CR_Sapphire);
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
