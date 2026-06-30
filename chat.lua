-- CHAT by: adk
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local LocalPlayer=Players.LocalPlayer

local D={
 WindowWidth=320,WindowHeight=200,MinimizedSize=40,CornerRadius=16,BubbleRadius=12,InputHeight=30,HeaderHeight=32,
 Font=Enum.Font.Gotham,FontBold=Enum.Font.GothamBold,FontSize_Title=12,FontSize_Sub=7,FontSize_Body=11,FontSize_Small=8,FontSize_Tiny=7,
 Surface=Color3.fromRGB(0,0,0),SurfaceLight=Color3.fromRGB(15,15,20),Accent=Color3.fromRGB(80,80,90),AccentHover=Color3.fromRGB(100,100,110),
 Text=Color3.fromRGB(220,220,225),TextSecondary=Color3.fromRGB(140,140,150),TextMuted=Color3.fromRGB(100,100,110),
 SentBubble=Color3.fromRGB(30,30,35),ReceivedBubble=Color3.fromRGB(20,20,25),AnimationSpeed=0.15
}

local S={Players={},Typing={},Minimized=false,Dragging=false,DragStart=nil,DragStartPos=nil,OnlineCount=0,ProcessedMessages={},LastTypingBroadcast=0}

local Gui=Instance.new("ScreenGui")
Gui.Name="ChatADK"
Gui.Parent=CoreGui
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.ResetOnSpawn=false

local function Round(P,Sz,Ps,Cl,Tr,Rd)
 local F=Instance.new("Frame")
 F.Size=Sz
 F.Position=Ps or UDim2.new(0,0,0,0)
 F.BackgroundColor3=Cl or D.Surface
 F.BackgroundTransparency=Tr or 0
 F.BorderSizePixel=0
 F.Parent=P
 local C=Instance.new("UICorner")
 C.CornerRadius=UDim.new(0,Rd or D.CornerRadius)
 C.Parent=F
 return F
end

local function GlassRect(P,Sz,Ps)
 local F=Round(P,Sz,Ps,Color3.fromRGB(0,0,0),0.3)
 local St=Instance.new("UIStroke")
 St.Color=Color3.fromRGB(60,60,70)
 St.Transparency=0.4
 St.Thickness=1
 St.Parent=F
 return F
end

local PrivateChannel=Instance.new("BindableEvent")
PrivateChannel.Name="ChatADK_Channel"

local Win=GlassRect(Gui,UDim2.new(0,D.WindowWidth,0,D.WindowHeight),UDim2.new(0.5,-D.WindowWidth/2,0.5,-D.WindowHeight/2))
Win.Name="MainWindow"
Win.ClipsDescendants=true

local Hdr=Instance.new("Frame")
Hdr.Size=UDim2.new(1,0,0,D.HeaderHeight)
Hdr.BackgroundColor3=Color3.fromRGB(0,0,0)
Hdr.BackgroundTransparency=0.5
Hdr.BorderSizePixel=0
Hdr.Parent=Win

local Tit=Instance.new("TextLabel")
Tit.Size=UDim2.new(0.5,0,0,14)
Tit.Position=UDim2.new(0.25,0,0,3)
Tit.BackgroundTransparency=1
Tit.Text="CHAT"
Tit.TextColor3=D.Text
Tit.Font=D.FontBold
Tit.TextSize=D.FontSize_Title
Tit.TextXAlignment=Enum.TextXAlignment.Center
Tit.Parent=Hdr

local Sub=Instance.new("TextLabel")
Sub.Size=UDim2.new(0.5,0,0,8)
Sub.Position=UDim2.new(0.25,0,0,17)
Sub.BackgroundTransparency=1
Sub.Text="by: adk"
Sub.TextColor3=D.TextMuted
Sub.Font=D.Font
Sub.TextSize=D.FontSize_Sub
Sub.TextXAlignment=Enum.TextXAlignment.Center
Sub.Parent=Hdr

local Onl=Instance.new("TextLabel")
Onl.Size=UDim2.new(0,90,0,8)
Onl.Position=UDim2.new(0.5,-45,0,25)
Onl.BackgroundTransparency=1
Onl.Text="🟢 1 online"
Onl.TextColor3=D.TextSecondary
Onl.Font=D.Font
Onl.TextSize=D.FontSize_Small
Onl.TextXAlignment=Enum.TextXAlignment.Center
Onl.Parent=Hdr

local MinB=Instance.new("TextButton")
MinB.Size=UDim2.new(0,18,0,18)
MinB.Position=UDim2.new(1,-38,0,7)
MinB.BackgroundColor3=D.SurfaceLight
MinB.BackgroundTransparency=0.5
MinB.Text="—"
MinB.TextColor3=D.Text
MinB.Font=D.FontBold
MinB.TextSize=10
MinB.BorderSizePixel=0
MinB.Parent=Hdr
local MinBC=Instance.new("UICorner")
MinBC.CornerRadius=UDim.new(0,4)
MinBC.Parent=MinB

local ClsB=Instance.new("TextButton")
ClsB.Size=UDim2.new(0,18,0,18)
ClsB.Position=UDim2.new(1,-17,0,7)
ClsB.BackgroundColor3=D.SurfaceLight
ClsB.BackgroundTransparency=0.5
ClsB.Text="✕"
ClsB.TextColor3=D.Text
ClsB.Font=D.FontBold
ClsB.TextSize=8
ClsB.BorderSizePixel=0
ClsB.Parent=Hdr
local ClsBC=Instance.new("UICorner")
ClsBC.CornerRadius=UDim.new(0,4)
ClsBC.Parent=ClsB

local Chat=Instance.new("ScrollingFrame")
Chat.Size=UDim2.new(1,-4,1,-D.HeaderHeight-D.InputHeight-28)
Chat.Position=UDim2.new(0,2,0,D.HeaderHeight+2)
Chat.BackgroundTransparency=1
Chat.BorderSizePixel=0
Chat.ScrollBarThickness=2
Chat.ScrollBarImageColor3=Color3.fromRGB(80,80,90)
Chat.CanvasSize=UDim2.new(0,0,0,10)
Chat.ScrollingDirection=Enum.ScrollingDirection.Y
Chat.Parent=Win

local MsgC=Instance.new("Frame")
MsgC.Size=UDim2.new(1,-4,0,10)
MsgC.Position=UDim2.new(0,2,0,0)
MsgC.BackgroundTransparency=1
MsgC.Parent=Chat

local MsgList=Instance.new("UIListLayout")
MsgList.Padding=UDim.new(0,3)
MsgList.HorizontalAlignment=Enum.HorizontalAlignment.Center
MsgList.SortOrder=Enum.SortOrder.LayoutOrder
MsgList.Parent=MsgC

local BottomPad=Instance.new("Frame")
BottomPad.Size=UDim2.new(1,0,0,10)
BottomPad.BackgroundTransparency=1
BottomPad.LayoutOrder=999999
BottomPad.Parent=MsgC

local TypI=Instance.new("TextLabel")
TypI.Size=UDim2.new(1,-10,0,10)
TypI.Position=UDim2.new(0,5,1,-D.InputHeight-36)
TypI.BackgroundTransparency=1
TypI.Text=""
TypI.TextColor3=D.TextSecondary
TypI.Font=D.Font
TypI.TextSize=D.FontSize_Small
TypI.TextXAlignment=Enum.TextXAlignment.Left
TypI.Parent=Win

local InpA=Instance.new("Frame")
InpA.Size=UDim2.new(1,-6,0,D.InputHeight+4)
InpA.Position=UDim2.new(0,3,1,-D.InputHeight-8)
InpA.BackgroundTransparency=1
InpA.Parent=Win

local InpBg=Round(InpA,UDim2.new(1,-34,0,D.InputHeight),UDim2.new(0,0,0,2),Color3.fromRGB(20,20,25),0.4,14)

local InpF=Instance.new("TextBox")
InpF.Size=UDim2.new(1,-10,1,0)
InpF.Position=UDim2.new(0,6,0,0)
InpF.BackgroundTransparency=1
InpF.PlaceholderText="Mensagem..."
InpF.PlaceholderColor3=D.TextMuted
InpF.Text=""
InpF.TextColor3=D.Text
InpF.Font=D.Font
InpF.TextSize=D.FontSize_Body
InpF.TextXAlignment=Enum.TextXAlignment.Left
InpF.ClearTextOnFocus=false
InpF.Parent=InpBg

local SndB=Instance.new("TextButton")
SndB.Size=UDim2.new(0,28,0,28)
SndB.Position=UDim2.new(1,-30,0,3)
SndB.BackgroundColor3=D.SurfaceLight
SndB.BackgroundTransparency=0.4
SndB.Text="➤"
SndB.TextColor3=Color3.fromRGB(200,200,210)
SndB.Font=D.FontBold
SndB.TextSize=11
SndB.BorderSizePixel=0
SndB.Parent=InpA
local SndC=Instance.new("UICorner")
SndC.CornerRadius=UDim.new(0,10)
SndC.Parent=SndB

local MinW=Instance.new("TextButton")
MinW.Size=UDim2.new(0,D.MinimizedSize,0,D.MinimizedSize)
MinW.Position=UDim2.new(1,-D.MinimizedSize-10,0,10)
MinW.BackgroundColor3=Color3.fromRGB(0,0,0)
MinW.BackgroundTransparency=0.3
MinW.Text="💬"
MinW.TextColor3=D.Text
MinW.Font=D.FontBold
MinW.TextSize=14
MinW.BorderSizePixel=0
MinW.Visible=false
MinW.Parent=Gui
local MinWC=Instance.new("UICorner")
MinWC.CornerRadius=UDim.new(0,10)
MinWC.Parent=MinW
local MinWS=Instance.new("UIStroke")
MinWS.Color=Color3.fromRGB(60,60,70)
MinWS.Transparency=0.4
MinWS.Thickness=1
MinWS.Parent=MinW

-- Character Bubble
local function CreateCharacterBubble(Player,Message)
 local Char=Player.Character
 if not Char then return end
 local Head=Char:FindFirstChild("Head")
 if not Head then return end
 local oldBubble=Head:FindFirstChild("ChatBubble_ADK")
 if oldBubble then oldBubble:Destroy() end
 local Bill=Instance.new("BillboardGui")
 Bill.Name="ChatBubble_ADK"
 Bill.Size=UDim2.new(0,200,0,60)
 Bill.StudsOffset=Vector3.new(0,3,0)
 Bill.AlwaysOnTop=true
 Bill.MaxDistance=50
 Bill.Parent=Head
 local Bg=Instance.new("Frame")
 Bg.Size=UDim2.new(1,0,1,-10)
 Bg.Position=UDim2.new(0,0,0,0)
 Bg.BackgroundColor3=Color3.fromRGB(255,255,255)
 Bg.BorderSizePixel=0
 Bg.Parent=Bill
 local BgC=Instance.new("UICorner")
 BgC.CornerRadius=UDim.new(0,8)
 BgC.Parent=Bg
 local Tri=Instance.new("Frame")
 Tri.Size=UDim2.new(0,12,0,10)
 Tri.Position=UDim2.new(0.5,-6,1,0)
 Tri.BackgroundColor3=Color3.fromRGB(255,255,255)
 Tri.BorderSizePixel=0
 Tri.Rotation=45
 Tri.Parent=Bill
 local NameLbl=Instance.new("TextLabel")
 NameLbl.Size=UDim2.new(1,-10,0,14)
 NameLbl.Position=UDim2.new(0,5,0,3)
 NameLbl.BackgroundTransparency=1
 NameLbl.Text=Player.Name
 NameLbl.TextColor3=Color3.fromRGB(50,50,60)
 NameLbl.Font=Enum.Font.GothamBold
 NameLbl.TextSize=10
 NameLbl.TextXAlignment=Enum.TextXAlignment.Left
 NameLbl.Parent=Bg
 local MsgLbl=Instance.new("TextLabel")
 MsgLbl.Size=UDim2.new(1,-10,1,-18)
 MsgLbl.Position=UDim2.new(0,5,0,16)
 MsgLbl.BackgroundTransparency=1
 MsgLbl.Text=Message
 MsgLbl.TextColor3=Color3.fromRGB(30,30,30)
 MsgLbl.Font=Enum.Font.Gotham
 MsgLbl.TextSize=11
 MsgLbl.TextXAlignment=Enum.TextXAlignment.Left
 MsgLbl.TextWrapped=true
 MsgLbl.Parent=Bg
 spawn(function()
  wait(6)
  for i=10,0,-1 do
   Bg.BackgroundTransparency=i/10
   MsgLbl.TextTransparency=i/10
   NameLbl.TextTransparency=i/10
   Tri.BackgroundTransparency=i/10
   wait(0.05)
  end
  Bill:Destroy()
 end)
end

-- Communication
local function SendData(Data)
 local json=game:GetService("HttpService"):JSONEncode(Data)
 LocalPlayer:SetAttribute("ChatADK_Data",json)
 LocalPlayer:SetAttribute("ChatADK_Timestamp",tick())
 LocalPlayer:SetAttribute("ChatADK_Active",true)
 PrivateChannel:Fire(Data)
end

local function CheckScriptUsers()
 local count=1
 for _,player in pairs(Players:GetPlayers())do
  if player~=LocalPlayer then
   local isActive=player:GetAttribute("ChatADK_Active")
   local timestamp=player:GetAttribute("ChatADK_Timestamp")
   local data=player:GetAttribute("ChatADK_Data")
   if isActive and timestamp and tick()-timestamp<10 then
    count=count+1
    if data then
     local msgKey=player.UserId.."_"..tostring(timestamp)
     if not S.ProcessedMessages[msgKey] then
      S.ProcessedMessages[msgKey]=true
      local success,decoded=pcall(function()
       return game:GetService("HttpService"):JSONDecode(data)
      end)
      if success and decoded then
       PrivateChannel:Fire(decoded)
      end
     end
    end
   end
  end
 end
 if count~=S.OnlineCount then
  S.OnlineCount=count
  Onl.Text=string.format("🟢 %d online",count)
 end
end

local function GetTime()
 return os.date("%H:%M")
end

local function UpdateTyping()
 local Tu={}
 for _,P in pairs(S.Typing)do
  if P and P~=LocalPlayer then table.insert(Tu,P.Name)end
 end
 if #Tu>0 then
  local T=table.concat(Tu,", ")
  if #Tu==1 then T=T.." está digitando..." else T=T.." estão digitando..." end
  TypI.Text="✏️ "..T
 else TypI.Text="" end
end

local msgCounter=0

local function CreateBubble(Usr,Cnt,Self,Tm)
 msgCounter=msgCounter+1
 local Tm=Tm or GetTime()
 local Mf=Instance.new("Frame")
 Mf.Size=UDim2.new(1,-4,0,0)
 Mf.BackgroundTransparency=1
 Mf.LayoutOrder=msgCounter
 Mf.Parent=MsgC
 local Ts=game:GetService("TextService"):GetTextSize(Cnt,D.FontSize_Body,D.Font,Vector2.new(D.WindowWidth*0.55,99999))
 local Bw=math.min(Ts.X+14,D.WindowWidth*0.62)
 local Bh=Ts.Y+8
 local TotalH=Bh+24
 local NmL=Instance.new("TextLabel")
 NmL.Size=UDim2.new(0,Bw,0,10)
 NmL.BackgroundTransparency=1
 NmL.Text=Self and "Você" or Usr
 NmL.TextColor3=D.TextSecondary
 NmL.Font=D.FontBold
 NmL.TextSize=D.FontSize_Small
 NmL.TextXAlignment=Self and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
 NmL.Parent=Mf
 if Self then NmL.Position=UDim2.new(1,-Bw-3,0,0) else NmL.Position=UDim2.new(0,3,0,0) end
 local Bb=Instance.new("Frame")
 Bb.BackgroundColor3=Self and D.SentBubble or D.ReceivedBubble
 Bb.BackgroundTransparency=0.3
 Bb.BorderSizePixel=0
 Bb.Parent=Mf
 local Bc=Instance.new("UICorner")
 Bc.CornerRadius=UDim.new(0,D.BubbleRadius)
 Bc.Parent=Bb
 local Tl=Instance.new("TextLabel")
 Tl.Size=UDim2.new(1,-8,1,-4)
 Tl.Position=UDim2.new(0,4,0,2)
 Tl.BackgroundTransparency=1
 Tl.Text=Cnt
 Tl.TextColor3=Color3.fromRGB(240,240,245)
 Tl.Font=D.Font
 Tl.TextSize=D.FontSize_Body
 Tl.TextXAlignment=Enum.TextXAlignment.Left
 Tl.TextWrapped=true
 Tl.RichText=true
 Tl.Parent=Bb
 Bb.Size=UDim2.new(0,Bw,0,Bh)
 if Self then Bb.Position=UDim2.new(1,-Bw-3,0,12) else Bb.Position=UDim2.new(0,3,0,12) end
 local TmL=Instance.new("TextLabel")
 TmL.Size=UDim2.new(0,Bw,0,8)
 TmL.BackgroundTransparency=1
 TmL.Text=Tm
 TmL.TextColor3=D.TextMuted
 TmL.Font=D.Font
 TmL.TextSize=D.FontSize_Tiny
 TmL.TextXAlignment=Self and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
 TmL.Parent=Mf
 if Self then TmL.Position=UDim2.new(1,-Bw-3,0,Bh+14) else TmL.Position=UDim2.new(0,3,0,Bh+14) end
 Mf.Size=UDim2.new(1,-4,0,TotalH)
 Bb.BackgroundTransparency=1
 Tl.TextTransparency=1
 NmL.TextTransparency=1
 TmL.TextTransparency=1
 spawn(function()
  TweenService:Create(Bb,TweenInfo.new(D.AnimationSpeed,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0.3}):Play()
  TweenService:Create(Tl,TweenInfo.new(D.AnimationSpeed),{TextTransparency=0}):Play()
  TweenService:Create(NmL,TweenInfo.new(D.AnimationSpeed),{TextTransparency=0}):Play()
  TweenService:Create(TmL,TweenInfo.new(D.AnimationSpeed),{TextTransparency=0}):Play()
 end)
 spawn(function()wait(0.05)Chat.CanvasPosition=Vector2.new(0,Chat.CanvasSize.Y.Offset+1000)end)
 return Mf
end

local function CreateSystemMessage(Cnt)
 msgCounter=msgCounter+1
 local F=Instance.new("Frame")
 F.Size=UDim2.new(1,-4,0,18)
 F.BackgroundTransparency=1
 F.LayoutOrder=msgCounter
 F.Parent=MsgC
 local L=Instance.new("TextLabel")
 L.Size=UDim2.new(0,140,0,14)
 L.Position=UDim2.new(0.5,-70,0,2)
 L.BackgroundColor3=Color3.fromRGB(20,20,25)
 L.BackgroundTransparency=0.5
 L.Text=Cnt
 L.TextColor3=D.TextSecondary
 L.Font=D.Font
 L.TextSize=D.FontSize_Small
 L.TextXAlignment=Enum.TextXAlignment.Center
 L.Parent=F
 local C=Instance.new("UICorner")
 C.CornerRadius=UDim.new(0,7)
 C.Parent=L
 spawn(function()wait(0.05)Chat.CanvasPosition=Vector2.new(0,Chat.CanvasSize.Y.Offset+1000)end)
 return F
end

local function SendMsg()
 local C=InpF.Text
 if C=="" or C:gsub(" ","")=="" then return end
 CreateBubble(LocalPlayer.Name,C,true)
 CreateCharacterBubble(LocalPlayer,C)
 InpF.Text=""
 SendData({Type="Message",Sender=LocalPlayer.Name,Content=C,Timestamp=GetTime(),UserId=LocalPlayer.UserId})
end

local function RecvMsg(Dt)
 if Dt.Sender==LocalPlayer.Name then return end
 CreateBubble(Dt.Sender,Dt.Content,false,Dt.Timestamp)
 local player=Players:FindFirstChild(Dt.Sender)
 if player then CreateCharacterBubble(player,Dt.Content)end
end

PrivateChannel.Event:Connect(function(Data)
 if Data.Type=="Message" then RecvMsg(Data)
 elseif Data.Type=="Join" and Data.Sender~=LocalPlayer.Name then
  S.Players[Data.UserId]=Players:FindFirstChild(Data.Sender)
  CheckScriptUsers()
  CreateSystemMessage("📥 "..Data.Sender.." entrou")
 elseif Data.Type=="Leave" then
  S.Players[Data.UserId]=nil
  S.Typing[Data.UserId]=nil
  CheckScriptUsers()
  UpdateTyping()
  CreateSystemMessage("📤 "..Data.Sender.." saiu")
 elseif Data.Type=="Typing" and Data.Sender~=LocalPlayer.Name then
  local P=Players:FindFirstChild(Data.Sender)
  if P then
   S.Typing[P.UserId]=P
   spawn(function()wait(3)S.Typing[P.UserId]=nil;UpdateTyping()end)
   UpdateTyping()
  end
 end
end)

SndB.MouseButton1Click:Connect(SendMsg)
InpF.FocusLost:Connect(function(Ep)if Ep then SendMsg()end end)

UserInputService.InputBegan:Connect(function(Input,GameProcessed)
 if GameProcessed then return end
 if Input.KeyCode==Enum.KeyCode.Return and InpF:IsFocused()then SendMsg()end
end)

InpF:GetPropertyChangedSignal("Text"):Connect(function()
 local Ct=tick()
 if Ct-S.LastTypingBroadcast<1.5 then return end
 S.LastTypingBroadcast=Ct
 SendData({Type="Typing",Sender=LocalPlayer.Name,UserId=LocalPlayer.UserId})
end)

MinB.MouseButton1Click:Connect(function()
 S.Minimized=true;Win.Visible=false;MinW.Visible=true
end)

MinW.MouseButton1Click:Connect(function()
 S.Minimized=false;Win.Visible=true;MinW.Visible=false
end)

ClsB.MouseButton1Click:Connect(function()
 SendData({Type="Leave",Sender=LocalPlayer.Name,UserId=LocalPlayer.UserId})
 LocalPlayer:SetAttribute("ChatADK_Active",false)
 Gui:Destroy()
end)

local function StartDrag(Input)
 S.Dragging=true;S.DragStart=Input.Position
 S.DragStartPos=S.Minimized and MinW.Position or Win.Position
 Input.Changed:Connect(function()if Input.UserInputState==Enum.UserInputState.End then S.Dragging=false end end)
end

Hdr.InputBegan:Connect(function(Input)
 if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then StartDrag(Input)end
end)
MinW.InputBegan:Connect(function(Input)
 if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then StartDrag(Input)end
end)

UserInputService.InputChanged:Connect(function(Input)
 if S.Dragging and (Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch)then
  local Delta=Input.Position-S.DragStart
  local newX=S.DragStartPos.X.Offset+Delta.X
  local newY=S.DragStartPos.Y.Offset+Delta.Y
  local ss=game:GetService("Workspace").CurrentCamera.ViewportSize
  newX=math.clamp(newX,-D.WindowWidth+40,ss.X-40)
  newY=math.clamp(newY,0,ss.Y-40)
  if S.Minimized then MinW.Position=UDim2.new(0,newX,0,newY)else Win.Position=UDim2.new(0,newX,0,newY)end
 end
end)

LocalPlayer:SetAttribute("ChatADK_Active",true)
LocalPlayer:SetAttribute("ChatADK_Timestamp",tick())
S.Players[LocalPlayer.UserId]=LocalPlayer
S.OnlineCount=1
Onl.Text="🟢 1 online"
CreateSystemMessage("👋 Bem-vindo!")
SendData({Type="Join",Sender=LocalPlayer.Name,UserId=LocalPlayer.UserId,Timestamp=GetTime()})
spawn(function()while wait(1)do CheckScriptUsers()end end)
spawn(function()while wait(3)do LocalPlayer:SetAttribute("ChatADK_Timestamp",tick())LocalPlayer:SetAttribute("ChatADK_Active",true)end end)
spawn(function()while wait(15)do local ct=tick()for key,_ in pairs(S.ProcessedMessages)do local p=key:split("_")if #p>=2 and tonumber(p[2])and ct-tonumber(p[2])>30 then S.ProcessedMessages[key]=nil end end end end)

SndB.MouseEnter:Connect(function()TweenService:Create(SndB,TweenInfo.new(0.15),{BackgroundTransparency=0.2}):Play()end)
SndB.MouseLeave:Connect(function()TweenService:Create(SndB,TweenInfo.new(0.15),{BackgroundTransparency=0.4}):Play()end)

spawn(function()wait(0.2)InpF:CaptureFocus()end)
print("✅ CHAT by: adk carregado!")
