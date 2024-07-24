local _, Iconer = ...

local icons = {
  [0] = "None",
  [1] = "|cffffff00Star|r",
  [2] = "|cffff8000Circle|r",
  [3] = "|cffff00ffDiamond|r",
  [4] = "|cff7CFC00Triangle|r",
  [5] = "|cffc7c7cfMoon|r",
  [6] = "|cff00BFFFSquare|r",
  [7] = "|cffFF4500Cross|r",
  [8] = "|cffffffffSkull|r",
}

local db, auto;
local timeTillNext = 0;
local _, battleTag = BNGetInfo();

function Iconer:setup()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
  frame:RegisterEvent("GROUP_ROSTER_UPDATE"); -- Fired when saved variables are loaded

  function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Iconer" then
      if IconerDB == nil then
        IconerDB = {}
      end
      
      if IconerDB.icons == nil then
        IconerDB.icons = {}
      end
      db = IconerDB.icons;

      if IconerDB.auto == nil then
        IconerDB.auto = {
          group = false
        }
      end
      auto = IconerDB.auto;
      
      -- Setup Slash Commands
      SLASH_ICONER1 = '/iconer';
      SlashCmdList["ICONER"] = IconerCommand;


      -- Setup Options UI
      Iconer:registerOptions();
    elseif event == "GROUP_ROSTER_UPDATE" then
      -- Check if auto-icon is enabled
      if not auto.group then
        --print("Auto-icon is not enabled. Skipping.")
        return;
      end

      if GetNumSubgroupMembers() > 0 then
        --print("Group has members, so Iconer is being run.")
        IconerCommand()
      end
    end

  end

  frame:SetScript("OnEvent", frame.OnEvent);
end

function IconerCommand(msg, editbox)
  local clear = msg == "clear";

  if msg=="options" then
    Settings.OpenToCategory(Iconer_Options.categoryId);
    return
  end

  -- Check if enough time has past to apply
  if timeTillNext < GetTime() then
    --print("Enough time has past, running Iconer.")
    timeTillNext = GetTime()+1
  else
    --print("Not enough time has past, skipping Iconer.")
    return;
  end

  r=SetRaidTarget;

  local icon = db[battleTag];
  if icon then
    r("player",0);
    if not clear then
      r("player",icon);
    end
  end

  ma=db

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

  -- Setup Friends List
  local friendsList = CreateFrame("Frame", nil, Iconer_Options_Friends);
  friendsList:SetSize(1,1);
  Iconer_Options_Friends.ScrollBar:ClearAllPoints();
  Iconer_Options_Friends.ScrollBar:SetPoint("TOPLEFT", Iconer_Options_FriendsBackdrop, "TOPRIGHT", -14, -20) ;
  Iconer_Options_Friends.ScrollBar:SetPoint("BOTTOMRIGHT", Iconer_Options_FriendsBackdrop, "BOTTOMRIGHT", -10, 19) ;
  Iconer_Options_Friends:SetScrollChild(friendsList);

  Iconer:createFriendsList(friendsList)

  Iconer_Options_Friends:SetClipsChildren(true);

  -- Setup Auto-running options
  Iconer_Options_Auto:SetScript("OnClick", function(self)
    Iconer:setAutoGroup(self)
  end)
  Iconer_Options_Auto:SetChecked(auto.group)
  

  -- Add the panel to the Interface Options
  local category, layout = Settings.RegisterCanvasLayoutCategory(Iconer_Options, "Iconer");
  Iconer_Options.categoryId = category:GetID();
  Settings.RegisterAddOnCategory(category);
end

function Iconer:createFriendsList(friendsList)
  local friends, nf, friend = {}, {};

  
  -- Add self
  local wowAccountGUID = select(3, BNGetInfo())
  if(wowAccountGUID == nil) then
    -- When the user isn't logged into Battle.net, this will stop loading Iconer before errors are thrown
    return
  end
  friends[1] = C_BattleNet.GetAccountInfoByID(wowAccountGUID);
  
  -- Add favorites and store non-favorites
  for i=1, BNGetNumFriends() do
    friend=C_BattleNet.GetFriendAccountInfo(i);

    if friend then
      if friend.isFavorite then
        friends[#friends+1] = friend;
      else
        nf[#nf+1] = friend;
      end
    end
  end

  -- Add non-favorites to end of table
  for i=1,#nf do
    friends[#friends+1] = nf[i]
  end


  -- Create list of friends
  for i=1, #friends do
    a=friends[i]
    b=a.battleTag;
    c=a.gameAccountInfo.characterName;

    local btn = CreateFrame("Frame", nil, friendsList, "Iconer_FriendTemplate");
    btn:SetPoint("TOPLEFT", 0, -(i-1)*45) ;

    if b == battleTag then
      btn.battleTag:SetText("You");
      btn.character:SetText(UnitName("player"));
    else
      btn.battleTag:SetText(b);
      --btn.battleTag:SetText("FriendBattleTag#" .. math.ceil(math.random()*9999));
      btn.character:SetText(c and c or "Not playing" );
      if c == nil then btn.character:SetTextColor(.486,.518,.541) end
    end

    btn.dropDown = btn.dropdown;
    btn.dropDown.battleTag = b;

    UIDropDownMenu_SetWidth(btn.dropDown, 100)
    UIDropDownMenu_SetText(btn.dropDown, db[b] and icons[db[b]] or icons[0])

    -- Create and bind the initialization function to the dropdown menu
    UIDropDownMenu_Initialize(btn.dropDown, function(self, level, menuList)
      local info = UIDropDownMenu_CreateInfo()
      local battleTag = self.battleTag;
      
      for i=0,#icons do
        info.text, info.arg1, info.checked = icons[i], i, i == db[battleTag]
        info.menuList = i
        info.func = function(self, newValue)
          -- Update the dropdown text to the new selection
          UIDropDownMenu_SetText(btn.dropDown, icons[newValue])
          self.checked = true;

          -- Save the new selection to the db
          if newValue == 0 then
            db[battleTag] = nil;
          else
            db[battleTag] = newValue;
          end
        end

        UIDropDownMenu_AddButton(info)
      end
    end)
  end
end

function Iconer:setAutoGroup(button)
  auto.group = button:GetChecked()
end

Iconer:setup();
