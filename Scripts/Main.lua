Services.ResourceManager:addDirResource("Resources", false)
maxlights=4 -- make this editable by the settings window
require "Scripts/RoscoColors"


scene = Scene(Scene.SCENE_3D)
sceneEntity = SceneEntityInstance(scene, "Resources/scene.entity")
scene:addChild(sceneEntity)


camera = safe_cast(sceneEntity:getEntityById("main_camera", true), Camera)
scene:setActiveCamera(camera)

function lookDown()
	scene:getDefaultCamera():setPosition(0,10,0)
	scene:getDefaultCamera():lookAt(Vector3(0,0,0), Vector3(0,1,0))
end

--lookdown()

require "Scripts/ui"

ground = safe_cast(sceneEntity:getEntityById("ground", true), ScenePrimitive)
scene:addEntity(ground)
sphere =safe_cast(sceneEntity:getEntityById("sphere", true), ScenePrimitive)
scene:addEntity(sphere)

function loadLights()
	light = {}
	for i = 0,  scene:getNumLights()-1 do
		light[i] = safe_cast(scene:getLight(i), SceneLight)
		light[i].visible=false
		scene:addChild(light[i])
		local gel=Gels[light[i]:getEntityProp("Gel")]-- _G[light[i]:getEntityProp("Gel")]
		if gel ~=nil then
			light[i]:setLightColor(gel.r,gel.g,gel.b,gel.a)
			print(gel.r .. " " ..  gel.g .. " " .. gel.b)
		end
	end
end

loadLights()


function Update(elapsed)
	uiUpdate(elapsed)
	magic=(elapsed * 108.0)
--	sphere:Pitch(magic)
--	sphere:Yaw(magic)
	sphere:Yaw(magic*.25)
--	lightBase:Yaw(magic)
end