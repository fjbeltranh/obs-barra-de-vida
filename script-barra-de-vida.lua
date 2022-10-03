obs           				= obslua


-- Variables

local path = script_path(); -- el path se encuentra donde el script
local estados = {}; -- cada posición es un conjunto
estados[1] = 
{
    {"1.png","1.png","1.png"},
    {"2.gif","2.png","2.png"},
    {"3.gif","3.png","3.png"}
};

local num_estados=table.getn(estados[1]);

local ANIMACION_DERECHA=1;
local ANIMACION_IZQUIERDA=2;
local ESTATICO=3;

local sentido=ESTATICO;

local is_pressed=false;

local nivel=3;

local hotkey_minus=obs.OBS_INVALID_HOTKEY_ID;
local hotkey_plus=obs.OBS_INVALID_HOTKEY_ID;



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

    nivel = obs.obs_data_get_int(settings, "nivel");    
    if(nivel==0) then nivel=1 end
    nivel_anterior=nivel

    local source_name_inicial="animacion";    
    

    obs.obs_data_set_default_string(settings, "source_name", source_name_inicial)
    obs.obs_data_set_default_int(settings, "nivel", nivel)

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

                if(nivel_anterior<nivel) then
                    sentido=ANIMACION_DERECHA
                elseif(nivel_anterior>nivel) then
                    sentido=ANIMACION_IZQUIERDA
                else
                    sentido=ESTATICO
                end

                nivel_anterior=nivel;

                obs.obs_data_set_string(source_settings, "local_file", path..estados[1][nivel][sentido])
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