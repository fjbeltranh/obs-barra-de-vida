obs= obslua



-- Variables



local is_pressed=false;



local hotkey_minus=obs.OBS_INVALID_HOTKEY_ID;
local hotkey_plus=obs.OBS_INVALID_HOTKEY_ID;

print ("base")

-- Hook: La descripción que se muestra en la ventana del Script
function script_description()

	return  
        [[
        <hr/><h1>Barra de Vida</h1>
        <p>Esto es la descripción</p>
        ]];

end



-- Hook: Las propiedades definidas en la UI
function script_properties()

    print("properties")
    props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Nombre de la Fuente", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int_slider(props, "nivel", "Nivel", 1, num_estados, 1)

    return props

end


  
-- Hook: Al cargar el script
function script_load(settings)
    print("load")

    -- Hotkey minus
    hotkey_minus = obs.obs_hotkey_register_frontend("hotkey_minus", "Menos", on_hotkey_minus)
    local hotkey_minus_array = obs.obs_data_get_array(settings, "hotkey_minus")    
    obs.obs_hotkey_load(hotkey_minus, hotkey_minus_array)
    obs.obs_data_array_release(hotkey_minus_array)

    -- Hotkey plus
    hotkey_plus = obs.obs_hotkey_register_frontend("hotkey_plus", "Más", on_hotkey_plus)
    local hotkey_plus_array = obs.obs_data_get_array(settings, "hotkey_plus")
    obs.obs_hotkey_load(hotkey_plus, hotkey_plus_array)
    obs.obs_data_array_release(hotkey_plus_array)

end



-- Hook: 
function script_save(settings)

    print("save")
    -- Hotkey minus
    local hotkey_minus_array = obs.obs_hotkey_save(hotkey_minus)
    obs.obs_data_set_array(settings, "hotkey_minus", hotkey_minus_array)
    obs.obs_data_array_release(hotkey_minus_array)

    -- Hotkey plus
    local hotkey_plus_array = obs.obs_hotkey_save(hotkey_plus)
    obs.obs_data_set_array(settings, "hotkey_plus", hotkey_plus_array)
    obs.obs_data_array_release(hotkey_plus_array)

end



-- 
function script_defaults(settings)

    print("defaults")
    my_settings=settings;

    -- carga la configuracion
    local config=readJson();
    source_name_default=config["source_name"];
    path=config["path"]; if(path=="") then path=script_path(); end;
    folder = config["folder"]; if(folder~="") then folder=folder.."/"; end;
    folder_anim_mas = config["folder_anim_mas"]; if(folder_anim_mas~="") then folder_anim_mas=folder_anim_mas.."/"; end;
    folder_anim_menos = config["folder_anim_menos"]; if(folder_anim_menos~="") then folder_anim_menos=folder_anim_menos.."/"; end;
    folder_estatico = config["folder_estatico"]; if(folder_estatico~="") then folder_estatico=folder_estatico.."/"; end;
    estados = config["estados"];
    num_estados=table.getn(estados);
    nivel_default=num_estados;
    nivel_anterior=nivel_default

    obs.obs_data_set_default_string(settings, "source_name", source_name_default)
    obs.obs_data_set_default_int(settings, "nivel", nivel_default)
end




function script_update(settings)

    print("update")
    source_name = obs.obs_data_get_string(settings, "source_name")
    nivel = obs.obs_data_get_int(settings, "nivel")
    incremento = obs.obs_data_get_int(settings, "incremento")
    is_pressed=true

    print("nivel="..nivel)
end




function script_tick(seconds)


    if is_pressed then
        print("tick")      
        local source = obs.obs_get_source_by_name(source_name)
        if source then

            local source_settings=obs.obs_source_get_settings(source)
            if source_settings then

                local tipo="estatico"
                local subfolder=folder_estatico;
                if(nivel_anterior<nivel) then
                    tipo="anim_mas";
                    subfolder=folder_anim_mas;
                elseif(nivel_anterior>nivel) then
                    tipo="anim_menos";
                    subfolder=folder_anim_menos;
                end

                nivel_anterior=nivel;

                obs.obs_data_set_string(source_settings, "local_file", path..folder..subfolder..estados[nivel][tipo])
                obs.obs_source_update(source, source_settings)

            end
            obs.obs_data_release(source_settings) 
        
        end
        obs.obs_source_release(source)

    end

    is_pressed=false;

end






function on_hotkey_minus(pressed)

    is_pressed = pressed
    if(pressed) then      
        print("minus")   
        if(nivel>1) then 
            obs.obs_data_set_int(my_settings, "nivel", nivel-1)
            script_update(my_settings)
        else
            is_pressed=false;
        end
    end
       
end


function on_hotkey_plus(pressed)

    is_pressed = pressed
    if(pressed) then   
        print("plus")
        if(nivel<num_estados) then
            obs.obs_data_set_int(my_settings, "nivel", nivel+1)
            script_update(my_settings)
        else
            is_pressed=false;            
        end            
    end

end


function readJson()

    local json = require("dkjson")
    local json_data=obs.obs_data_create_from_json_file(script_path().."config.json");
    local content=obs.obs_data_get_json(json_data)
    obs.obs_data_release(json_data)
    return json.decode(content)

  
end