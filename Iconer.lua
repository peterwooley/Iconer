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

  -- Add the panel to the Interface Options
  InterfaceOptions_AddCategory(Iconer_Options);

  ---- Make a child panel
  --MyAddon.childpanel = CreateFrame( "Frame", "MyAddonChild", MyAddon.panel);
  --MyAddon.childpanel.name = "MyChild";
  ---- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
  --MyAddon.childpanel.parent = MyAddon.panel.name;
  ---- Add the child to the Interface Options
  --InterfaceOptions_AddCategory(MyAddon.childpanel);
end

function Iconer:revertOptions()
  print("Reverting Iconer options.")
end

Iconer:setup();
