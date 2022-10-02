obs           				= obslua


-- ------------------------------------- 


luafileTitle = "Título";
desc = 
[[
<hr/><h1>]] .. luafileTitle ..[[</h1>
<p>Esto es la descripción</p>
]];

path = script_path(); -- el path se encuentra donde el script
estados = 
{
    {"1.png","1.png"},
    {"2.gif","2.png"},
    {"3.gif","3.png"}
};
source_name_inicial="animacion";
DERECHA=1;
IZQUIERDA=2;
sentido=IZQUIERDA;


-- ------------------------------------- 



function script_description()

	return string.format(desc)

end




function script_properties()

    props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Nombre de la Fuente", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int_slider(props, "nivel", "Nivel", 1, table.getn(estados), 1)
    return props

end


  

function script_load(settings)


end




function script_defaults(settings)

    is_pressed=false

    nivel_inicial = 1;  
    nivel_anterior = nivel_inicial;

    obs.obs_data_set_default_string(settings, "source_name", source_name_inicial)
    obs.obs_data_set_default_int(settings, "nivel", nivel_inicial)

end




function script_update(settings)

    source_name = obs.obs_data_get_string(settings, "source_name")
    nivel = obs.obs_data_get_int(settings, "nivel")
    is_pressed=true
    print(nivel)

end




function script_tick(seconds)


    if is_pressed then

        local source = obs.obs_get_source_by_name(source_name)
        if source then

            local source_settings=obs.obs_source_get_settings(source)
            if source_settings then

                if(nivel_anterior<=nivel) then
                    sentido=DERECHA
                else
                    sentido=IZQUIERDA 
                end
                nivel_anterior=nivel;

                obs.obs_data_set_string(source_settings, "local_file", path..estados[nivel][sentido])
                obs.obs_source_update(source, source_settings)

            end
            obs.obs_data_release(source_settings) 
        
        end
        obs.obs_source_release(source)

    end
    is_pressed=false;

end




function on_push_hotkey(pressed)

    is_pressed = pressed

end