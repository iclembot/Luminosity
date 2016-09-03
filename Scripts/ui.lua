-- User Interface overlay for Luminosity

-- Ivans's scenelabel fix: 
SceneLabel.defaultAnchor = Vector3(-1.0, -1.0, 0.0)
SceneLabel.defaultPositionAtBaseline = true
SceneLabel.defaultSnapToPixels = true
SceneLabel.createMipmapsForLabels = false

-- Fix fuzzy fonts:
Services.Renderer:setTextureFilteringMode(Renderer.TEX_FILTERING_NEAREST)

-- Some useful globals:
vpheight = Services.Renderer:getViewportHeight()
vpwidth = Services.Renderer:getViewportWidth() 
globalPool = Services.ResourceManager:getGlobalPool()

print(Services.Core:getDefaultWorkingDirectory())
print(Services.Core:getUserHomeDirectory())

-- get Default UI values from config: 
local polycode_path = "../../.." -- "C:/devel/Polycodedist"
-- CoreServices.getInstance():getConfig():loadConfig("Polycode", polycode_path.."/IDE/UIThemes/dark/theme.xml")
-- CoreServices.getInstance():getResourceManager():addArchive(polycode_path.."/IDE/UIThemes/dark/")
Services.Config:loadConfig("Polycode", polycode_path.."/IDE/UIThemes/dark/theme.xml")

-- CoreServices.getInstance():getConfig():loadConfig("Polycode", "Resources/UIThemes/default/theme.xml")
 CoreServices.getInstance():getResourceManager():addArchive(polycode_path.."/IDE/UIThemes/dark/")
CoreServices.getInstance():getConfig():setNumericValue("Polycode", "uiTextInputFontSizeMultiline", 12)
CoreServices.getInstance():getConfig():setNumericValue("Polycode", "uiTextInputFontSize",12)
CoreServices.getInstance():getConfig():setNumericValue("Polycode", "uiTextInputFontOffsetY",0)
CoreServices.getInstance():getConfig():setNumericValue("Polycode", "textBgSkinT",7)
CoreServices.getInstance():getConfig():setNumericValue("Polycode", "textBgSkinPadding",6)
CoreServices.getInstance():getConfig():setNumericValue("Polycode", "textEditLineSpacing",24)

-- get the screen metrics and output to debug:
xRes=1280-- 
xRes=Services.Core:getScreenWidth()-- or 1024
yRes=800 --
yRes=Services.Core:getScreenHeight()  --getBackingYRes()-- or 640
print("Res: " .. xRes .. " --**-- " .. yRes)
print("fps: " .. Services.Core:getFPS())

ghost= SceneLight(SceneLight.POINT_LIGHT, scene, 5.0)
ghost:setPosition(0,15,0)
ghost.enabled=false
scene:addLight(ghost)

function ghostlighter()
-- put a for loop here to check all lights up to maxlights for enabled, logical and the result of each light with a local var
	if not scene:getLight(1).enabled and not scene:getLight(2).enabled and not scene:getLight(3).enabled and not scene:getLight(4).enabled then
		ghost.enabled=true
	else
		ghost.enabled=false
	end
end

-- Create a new Scene for UI elements
overlay=Scene(Scene.SCENE_2D_TOPLEFT)
--fadeplane=ScenePrimitive(ScenePrimitive.TYPE_VPLANE, xRes, yRes)
--fadeplane:setColor(1,1,1,1)
--fadeplane:setAnchorPoint(Vector3(-1,-1,0))
--fadelevel=1.0
--faderate=.07
--fading=true
--overlay:addChild(fadeplane)
overlay:getDefaultCamera():setOrthoSize(xRes,yRes)

window = UIWindow("Q to Quit", 300, 300)
window:setPosition(60,440,0)
window.visible=false
overlay:addChild(window)


sett_but=UIImageButton("Resources/ui_luminosity/settings_icon.png" , 1 , 48,48 ) 
sett_but:setPosition(20,vpheight/2,0)
overlay:addChild(sett_but)

function butt_clik(t, event)
	window:showWindow()
end

sett_but:addEventListener(nil, butt_clik, UIEvent.CLICK_EVENT)

add_but=UIImageButton("Resources/ui_luminosity/add_entity.png" , 1 , 48,48 ) 
add_but:setPosition(20,vpheight/2+80,0)
overlay:addChild(add_but)

function addbutt_clik(t, event)
	window:hideWindow()
end

add_but:addEventListener(nil, addbutt_clik, UIEvent.CLICK_EVENT)

class "lite" (UIElement) --(Entity)

function lite:lite(i) 
	UIElement.UIElement(self)
	-- self.processInputEvents = true
	self.img=UIImageButton("Resources/ui_luminosity/light_icon.png" , 1 , 48,48 )
	self:addChild(self.img)
	self.scn_lite=safe_cast( scene:getLight(math.min(i,scene:getNumLights()-1) ), SceneLight)
	self.img:addEventListener(self, self.litesclk, UIEvent.CLICK_EVENT)

	self.colorPicker= UIColorPicker()
	self.colorPicker:setPosition(60, 0)
	self.colorPicker:setWindowCaption(self.scn_lite.id)
	self:addChild(self.colorPicker)

	self.colorBox = UIColorBox(self.colorPicker, self.scn_lite.lightColor , 30, 30)
	self.colorBox:setPosition(10, 60)
	self:addChild(self.colorBox)
	self.colorBox:addEventListener(self, self.colorChange, UIEvent.CHANGE_EVENT)
	
	self.globalMenu = UIGlobalMenu() --this will be used for the dropping-down entries
	self.globalMenu:setPosition(90,0)
	overlay:addChild(self.globalMenu) --	self.colorPicker:addChild(self.globalMenu)
	
	self.gelCombo = UIComboBox(self.globalMenu, 80)	--create new ComboBox
	self.gelCombo:setPosition(240, 200)
	self.colorPicker:addChild(self.gelCombo)
	self.gelCombo:addComboItem(self.scn_lite:getEntityProp("Gel"))	--add items
	
	for k, v in pairs (Gels) do
	  	self.gelCombo:addComboItem(k)
	end 
	self.gelCombo:addEventListener(self, self.onGelChange, UIEvent.CHANGE_EVENT) --register to receive event when another entry has been selected
end

function lite:onGelChange(t, event)
	self.scn_lite:setEntityProp("Gel",self.gelCombo:getSelectedItem().label)
	local gel=Gels[self.scn_lite:getEntityProp("Gel")]  -- _G[light[i]:getEntityProp("Gel")]
	if gel ~=nil then
		self.scn_lite:setLightColor(gel.r,gel.g,gel.b,gel.a)
		print(gel.r .. " " ..  gel.g .. " " .. gel.b)
	end
	self.colorPicker:setPickerColor(gel)
end

function lite:colorChange(t, event)
	local selcol= self.colorBox:getSelectedColor()
	self.scn_lite:setLightColor(selcol.r,selcol.g,selcol.b,selcol.a)
end

function lite:litesclk(t, event)
	if self.scn_lite.enabled==true then
		self.scn_lite.enabled=false
		self.colorBox.visible=false
	else
		self.scn_lite.enabled=true
		self.colorBox.visible=true
	end	
	ghostlighter()
end

lites={}

for i = 0, maxlights-1 do
	lites[i]= lite(i)
	lites[i]:setPosition((vpwidth/maxlights)*i+20,20,0)
	lites[i].visible=false
	overlay:addChild(lites[i])
end

lite_but=UIImageButton("Resources/ui_luminosity/lights_icon.png" , 1 , 48,48 ) 
lite_but:setPosition(20,vpheight/2+160,0)
overlay:addChild(lite_but)

vislites=0

function litebutt_clik(t, event)
	lites[vislites].visible=true
	vislites=math.min(vislites+1,maxlights-1)
	ghostlighter()
end

lite_but:addEventListener(nil, litebutt_clik, UIEvent.CLICK_EVENT)


fpslabel = UILabel("Videomode:" .. xRes .."X" ..yRes .." FPS:" .. Services.Core:getFPS(), 14, "mono", Label.ANTIALIAS_FULL)
fpslabel:setPosition(window.padding, window.topPadding)
window:addChild(fpslabel)

timepast=0
timelabel = UILabel("Time:" .. timepast, 14, "mono", Label.ANTIALIAS_FULL)
timelabel:setPosition(window.padding, window.topPadding+20)
window:addChild(timelabel)

wireframeChkBox = UICheckBox("Wireframe:", false)
wireframeChkBox:setPosition(window.padding, window.topPadding+50)
window:addChild(wireframeChkBox)

function onChkChange(t, event)
	sphere.overlayWireframe=wireframeChkBox:isChecked()
end

wireframeChkBox:addEventListener(nil, onChkChange, UIEvent.CHANGE_EVENT)


wireColorPicker= UIColorPicker()
wireColorPicker:setPosition(window.padding+300, window.topPadding+20)
window:addChild(wireColorPicker)

wireColorBox= UIColorBox(wireColorPicker, Color(.2,.5,1,.2), 30, 30)
wireColorBox:setPosition(window.padding+100, window.topPadding+45)
window:addChild(wireColorBox)

function onColorChange(t, event)
	sphere.wireFrameColor=wireColorBox:getSelectedColor()
end

wireColorBox:addEventListener(nil, onColorChange, UIEvent.CHANGE_EVENT)

fsButton = UIButton("Toggle Fullscreen", 160)
fsButton:setPosition(window.padding+10, window.topPadding+88)
window:addChild(fsButton)


fullScreen=false
function fsButton_clik(t, event)
	-- Toggle go fullscreen:
	if fullScreen then
		fullScreen=false
		xRes=vpwidth
		yRes=vpheight
	else
		fullScreen=true
		xRes=Services.Core:getScreenWidth()
		yRes=Services.Core:getScreenHeight()  
	end
	vSync=false
	aaLevel=0
	anisotropyLevel=0
	retinaSupport=false
	Services.Core:setVideoMode(xRes , yRes , fullScreen , vSync , aaLevel , anisotropyLevel , retinaSupport )
	Services.Core:resizeTo(xRes,yRes)
	Services.Core:enableMouse(true)
end

fsButton:addEventListener(nil, fsButton_clik, UIEvent.CLICK_EVENT)

globalMenu = UIGlobalMenu() --this will be used for the dropping-down entries
--overlay:addChild(globalMenu)

shineCombo = UIComboBox(globalMenu, 180)	--create new ComboBox
shineCombo:setPosition(window.padding, window.topPadding+170)
window:addChild(shineCombo)

shineCombo:addComboItem("Shiny")	--add items
shineCombo:addComboItem("Eggshell")
shineCombo:addComboItem("Matte")

binding = sphere:getLocalShaderOptions()
param = binding:addParam(ProgramParam.PARAM_NUMBER, "shininess")--getLocalParamByName("shininess")

function onMatChange(t, event)
	if shineCombo:getSelectedIndex() == 0 then
		param:setNumber(50)
	elseif shineCombo:getSelectedIndex() == 1 then
		param:setNumber(15)
	else
		param:setNumber(0)
	end
end

shineCombo:addEventListener(nil, onMatChange, UIEvent.CHANGE_EVENT)

overlay:addChild(globalMenu)

overlay.rootEntity.processInputEvents = true
	
function uiUpdate(elapsed)
	timepast=(timepast+elapsed)
	timelabel:setText("" .. timepast)
	fpslabel:setText("Videomode:" .. xRes .."X" ..yRes .." FPS:" .. Services.Core:getFPS())

--	if fading then
--		if (fadelevel > 0) then
--			fadelevel=fadelevel-elapsed*faderate
--			fadeplane:setColor(0,0,0,fadelevel)
--		else
--		fading=false
--		end
--	end

end