local _, Iconer = ...

function Iconer:setup()
  -- Setup Slash Commands
  SLASH_ICONER1 = '/iconer';
  SlashCmdList["ICONER"] = IconerCommand;

  -- Setup Options UI
  Iconer:registerOptions();
end

function IconerCommand(msg, editbox)
  local clear = msg == "clear";

  if msg=="options" then
    InterfaceOptionsFrame_OpenToCategory(Iconer_Options);
    InterfaceOptionsFrame_OpenToCategory(Iconer_Options);
  end

  r=SetRaidTarget;
  r("player",0);
  if not clear then
    r("player",2);
  end
  ma={
    ["karawooley#1384"]=1,
    ["Daemodreth#1663"]=6,
    ["Andaline#1307"]=3,
    ["RunningUtes#1401"]=4
  };

  for i=1, BNGetNumFriends() do
    a=C_BattleNet.GetFriendAccountInfo(i);
    b=a.battleTag;
    c=a.gameAccountInfo.characterName;
    if c and ma[b] then
      r(c, 0)
      if not clear then
        r(c, ma[b])
      end
    end
  end
end


function Iconer:registerOptions()
  local options = Iconer_Options;
  options.name = "Iconer";
  options.okay = function (self) print("Options saved.") end;
  options.cancel = Iconer.revertOptions;

  local friendsList = CreateFrame("Frame", nil, Iconer_Options_Friends);
  friendsList:SetSize(562,900);
  Iconer_Options_Friends.ScrollBar:ClearAllPoints();
  Iconer_Options_Friends.ScrollBar:SetPoint("TOPLEFT", Iconer_Options_Friends, "TOPRIGHT", -12, -18) ;
  Iconer_Options_Friends.ScrollBar:SetPoint("BOTTOMRIGHT", Iconer_Options_Friends, "BOTTOMRIGHT", -7, 18) ;
  --friendsList.bg = friendsList:CreateTexture(nil, "Background");
  --friendsList.bg:SetAllPoints(true);
  --friendsList.bg:SetColorTexture(0.2, 0.6, 0, 0.8);
  Iconer_Options_Friends:SetScrollChild(friendsList);

  local btn = CreateFrame("Frame", nil, friendsList, "Iconer_FriendTemplate");
	btn:SetPoint("TOPLEFT", friendsList, "TOPLEFT", 0, 0);
  btn:SetSize(532, 35);
	btn.battleTag:SetText("You");
  tex = btn:CreateTexture("BattleTag Texture", "OVERLAY");
  tex:SetWidth(24);
  tex:SetHeight(24);
  tex:SetPoint("CENTER",btn.battleTag,"CENTER",0,0)
  tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	SetRaidTargetIconTexture(tex,2)
  btn.character:SetText(UnitName("player"));
	--btn:SetNormalFontObject("GameFontNormalLarge");
	--btn:SetHighlightFontObject("GameFontHighlightLarge");



  Iconer_Options_Friends:SetClipsChildren(true);

  -- Add the panel to the Interface Options
  InterfaceOptions_AddCategory(Iconer_Options);
end

function Iconer:revertOptions()
  print("Reverting Iconer options.")
end

Iconer:setup();
