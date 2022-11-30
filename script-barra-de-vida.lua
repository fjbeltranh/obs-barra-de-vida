obs= obslua




-- ---------------------------------------
-- FUNCIONES GLOBALES
-- ---------------------------------------




-- Hook: La descripción que se muestra en la ventana del Script
function script_description()

	return  
        [[
        <hr/><h1>Barra de Vida</h1>
        <p>Modificar desde config.json</p>
        ]];

end



-- Hook: Se llama para establecer la configuración predeterminada (si la hay) asociada con el script
function script_defaults(settings)

    -- carga la configuracion en variables
    local config=readJson();
    local source_name_default=config["source_name"];
    local source_base_name_default=config["source_base_name"];
    delay=config["delay"];
    path=config["path"]; if(path=="") then path=script_path(); end;
    folder = config["folder"]; if(folder~="") then folder=folder.."/"; end;
    folder_anim_mas = config["folder_anim_mas"]; if(folder_anim_mas~="") then folder_anim_mas=folder_anim_mas.."/"; end;
    folder_anim_menos = config["folder_anim_menos"]; if(folder_anim_menos~="") then folder_anim_menos=folder_anim_menos.."/"; end;
    folder_estatico = config["folder_estatico"]; if(folder_estatico~="") then folder_estatico=folder_estatico.."/"; end;
    estados = config["estados"];
    num_estados=table.getn(estados);
    
    -- variables globales
    my_settings=settings;
    is_pressed=false;
    hotkey_menos=obs.OBS_INVALID_HOTKEY_ID;
    hotkey_mas=obs.OBS_INVALID_HOTKEY_ID;
    local nivel_default=num_estados;
    nivel_anterior=nivel_default

    -- fija algunas fuentes
    obs.obs_data_set_default_string(settings, "source_name", source_name_default)
    obs.obs_data_set_default_string(settings, "source_base_name", source_base_name_default)
    obs.obs_data_set_default_int(settings, "nivel", nivel_default)
    
end


  
-- Hook: Se llama para cargar configuraciones específicas al principio del script (se ejecuta después de default)
function script_load(settings)    

    -- Hotkey menos
    hotkey_menos = obs.obs_hotkey_register_frontend("hotkey_menos", "Menos", on_hotkey_menos)
    local hotkey_menos_array = obs.obs_data_get_array(settings, "hotkey_menos")    
    obs.obs_hotkey_load(hotkey_menos, hotkey_menos_array)
    obs.obs_data_array_release(hotkey_menos_array)

    -- Hotkey mas
    hotkey_mas = obs.obs_hotkey_register_frontend("hotkey_mas", "Más", on_hotkey_mas)
    local hotkey_mas_array = obs.obs_data_get_array(settings, "hotkey_mas")
    obs.obs_hotkey_load(hotkey_mas, hotkey_mas_array)
    obs.obs_data_array_release(hotkey_mas_array)

end


-- Hook: Se llama cuando se descarga el script al cerrar obs.
function script_unload()

end



-- Hook: Se llama cuando se guarda el script. Necesario para cualquier dato de configuración interna adicional (no de  usuario) que pueda utilizar el script
function script_save(settings)

    -- Hotkey menos
    local hotkey_menos_array = obs.obs_hotkey_save(hotkey_menos)
    obs.obs_data_set_array(settings, "hotkey_menos", hotkey_menos_array)
    obs.obs_data_array_release(hotkey_menos_array)

    -- Hotkey mas
    local hotkey_mas_array = obs.obs_hotkey_save(hotkey_mas)
    obs.obs_data_set_array(settings, "hotkey_mas", hotkey_mas_array)
    obs.obs_data_array_release(hotkey_mas_array)

end



-- Hook: Se llama cuando el usuario ha cambiado la configuración de la secuencia de comandos (si la hay)
function script_update(settings)
    
    source_name = obs.obs_data_get_string(settings, "source_name")
    source_base_name = obs.obs_data_get_string(settings, "source_base_name")
    nivel = obs.obs_data_get_int(settings, "nivel")
    incremento = obs.obs_data_get_int(settings, "incremento")
    is_pressed=true    

end



-- Hook: Las propiedades definidas en la UI
function script_properties()
    
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Nombre de la Fuente", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "source_base_name", "Nombre de la Fuente Base", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int_slider(props, "nivel", "Nivel", 1, num_estados, 1)

    -- obs.obs_properties_add_button(props, "menos_button", "Menos", on_hotkey_menos)
    -- obs.obs_properties_add_button(props, "mas_button", "Mas", on_hotkey_mas)

    return props

end



-- Hook: Se llama constantemente por cada frame de procesamiento
function script_tick(seconds)

    if is_pressed then
           
        source = obs.obs_get_source_by_name(source_name)
        source_base = obs.obs_get_source_by_name(source_base_name)
        if source then

            source_settings=obs.obs_source_get_settings(source)
            source_base_settings=obs.obs_source_get_settings(source_base)
            if source_settings then

                local tipo="estatico";
                local subfolder=folder_estatico;

                if(nivel_anterior<nivel) then

                    tipo="anim_mas";
                    subfolder=folder_anim_mas;
                    delay_source=1;
                    delay_source_base=delay;

                elseif(nivel_anterior>nivel) then

                    tipo="anim_menos";
                    subfolder=folder_anim_menos;
                    delay_source=delay;
                    delay_source_base=delay_source+100;

                end

                nivel_anterior=nivel;
                                    
                obs.obs_data_set_string(source_settings, "local_file", path..folder..subfolder..estados[nivel][tipo])                    
                obs.timer_add(
                    function()
                        obs.obs_source_update(source, source_settings);
                        obs.remove_current_callback();
                    end, delay_source)

                obs.obs_data_set_string(source_base_settings, "local_file", path..folder..folder_estatico..estados[nivel]["estatico"])
                obs.timer_add(
                    function()
                        obs.obs_source_update(source_base, source_base_settings);
                        obs.remove_current_callback();
                    end, delay_source_base)

            end
            obs.obs_data_release(source_settings) 
            obs.obs_data_release(source_base_settings) 
        
        end
        obs.obs_source_release(source)
        obs.obs_source_release(source_base)

    end

    is_pressed=false

end


function updateBaseSource(surce_base, source_base_settings, file)

    obs.obs_data_set_string(source_base_settings, "local_file", file)
    obs.obs_source_update(source_base, source_base_settings)

end


-- ---------------------------------------
-- FUNCIONES LOCALES
-- ---------------------------------------



-- acción al pulsar la hotkey "menos"
function on_hotkey_menos(pressed)

    is_pressed = pressed
    if(pressed) then     
        if(nivel>1) then 
            obs.obs_data_set_int(my_settings, "nivel", nivel-1)
            script_update(my_settings)
        else
            is_pressed=false;
        end
    end
       
end


-- acción al pulsar la hotkey "mas"
function on_hotkey_mas(pressed)

    is_pressed = pressed
    if(pressed) then   
        if(nivel<num_estados) then
            obs.obs_data_set_int(my_settings, "nivel", nivel+1)
            script_update(my_settings)
        else
            is_pressed=false;            
        end            
    end

end


-- lee el archivo config.json que está en la misma carpeta que el script y lo devuelve como un objeto
function readJson()

    local json = require("dkjson")
    local json_data=obs.obs_data_create_from_json_file(script_path().."config.json");
    local content=obs.obs_data_get_json(json_data)
    obs.obs_data_release(json_data)
    return json.decode(content)

end