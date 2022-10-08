local obs = obslua




-- boolean = true

-- function toggle()
--   print(tostring(boolean))
--   boolean = not boolean
-- end

-- function htk_1_cb(pressed)
--   if pressed then
--     toggle()
--   end
-- end

-- key_1 = '{"htk_1": [ { "key": "OBS_KEY_2" } ]}'
-- json_s = key_1
-- default_hotkeys = {
--   {id='htk_1',des='Toggle something',callback=htk_1_cb},
-- }

-- function script_load(settings)

--   s = obs.obs_data_create_from_json(json_s)
--   for _,v in pairs(default_hotkeys) do
--     local a = obs.obs_data_get_array(s,v.id)
--     h = obs.obs_hotkey_register_frontend(v.id,v.des,v.callback)
--     obs.obs_hotkey_load(h,a)
--     obs.obs_data_array_release(a)
--   end
--   obs.obs_data_release(s)
-- end









  function readJson()

    local json = require("dkjson")
    local json_data=obs.obs_data_create_from_json_file(script_path().."config.json");
    local content=obs.obs_data_get_json(json_data)
    obs.obs_data_release(json_data)
    return json.decode(content)
end

a=readJson();
print(a["estados"][2]["anim_mas"])