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

local db;
local _, battleTag = BNGetInfo();

function Iconer:setup()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded

  function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Iconer" then
      if IconerDB == nil or IconerDB.icons == nil then
        IconerDB = {}
        IconerDB.icons = {}
      end
      db = IconerDB.icons;
      
      -- Setup Slash Commands
      SLASH_ICONER1 = '/iconer';
      SlashCmdList["ICONER"] = IconerCommand;


      -- Setup Options UI
      Iconer:registerOptions();
    end

  end

  frame:SetScript("OnEvent", frame.OnEvent);
end

function IconerCommand(msg, editbox)
  local clear = msg == "clear";

  if msg=="options" then
    InterfaceOptionsFrame_OpenToCategory(Iconer_Options);
    InterfaceOptionsFrame_OpenToCategory(Iconer_Options);
  end

  --if math.random() < 0.1 then
    --print("I like poop!");
  --end

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
  --options.cancel = Iconer.revertOptions;

  local friendsList = CreateFrame("Frame", nil, Iconer_Options_Friends);
  friendsList:SetSize(562,45);
  Iconer_Options_Friends.ScrollBar:ClearAllPoints();
  Iconer_Options_Friends.ScrollBar:SetPoint("TOPLEFT", Iconer_Options_Friends, "TOPRIGHT", -12, -18) ;
  Iconer_Options_Friends.ScrollBar:SetPoint("BOTTOMRIGHT", Iconer_Options_Friends, "BOTTOMRIGHT", -8, 17) ;
  Iconer_Options_Friends:SetScrollChild(friendsList);

  Iconer:createFriendsList(friendsList)


  Iconer_Options_Friends:SetClipsChildren(true);

  -- Add the panel to the Interface Options
  InterfaceOptions_AddCategory(Iconer_Options);
end

function Iconer:createFriendsList(friendsList)
  local friends, nf, friend = {}, {};

  -- Add self
  friends[1] = C_BattleNet.GetAccountInfoByID(select(3, BNGetInfo()));
  
  -- Add favorites and store non-favorites
  for i=1, BNGetNumFriends() do
    friend=C_BattleNet.GetFriendAccountInfo(i);
    if friend.isFavorite then
      friends[#friends+1] = friend;
    else
      nf[#nf+1] = friend;
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
    --btn:SetSize(532, 35);
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

function Iconer:revertOptions()
  print("Reverting Iconer options.")
end

Iconer:setup();
