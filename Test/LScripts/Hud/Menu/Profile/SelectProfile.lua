
SelectProfile =
{
	bgStartFrame = { 120, 243, 268 },
	bgEndFrame   = { 180, 267, 291 },

	firstTimeShowItems = 80,
	
	backAction = "PainMenu:ActivateScreen(ProfileMenu)",
	items =
	{
		EmptyBorder =
		{
			type = MenuItemTypes.Border,
			x = 252,
			y = 300,
			width = 530,
			height = 70,
			align = MenuAlign.Left
		},

		List =
		{
			type = MenuItemTypes.TextButtonEx,
			text = "Profile",
			desc = "",
			option = "SelectProfile",
			x	 = -1,
			y	 = 320,
			width = 400,
			fontBigSize = 38,
		},
		
		LoadSelected =
		{
			text = Languages.Texts[1685],
            		desc = Languages.Texts[1686],
			x	 = -1,
			y	 = 380,
			action = "PainMenu:SelectProfile(SelectProfile.items.List.visible[SelectProfile.items.List.currValue])",
			sndLightOn = "menu/menu/back-light-on",
			useItemBG = true,
			fontBigSize = 58,
			--textColor	= R3D.RGBA( 250, 250, 250, 255 ),
			disabledColor = R3D.RGBA( 155, 155, 155, 255 ),
			--descColor	= R3D.RGB( 255, 255, 255 ),
			--fontBigTex  = "HUD/font_texturka_alpha",
			--fontSmallTex  = "HUD/font_texturka_alpha",
		},
	},
}