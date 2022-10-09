# Barra de Vida

Como instalar:

1. Crear una fuente de tipo multimedia en obs, posicionarla donde se quiera y desmarcar todas las casillas. Puedes llamarla por defecto "animacion"
2. Descargar todo en una misma carpeta
3. Editar el archivo de texto config.json según las consideraciones de más abajo. Por defecto actualmente funciona
4. Ir a OBS>Herramientas>Script y cargar script-barra-de-vida.lua.
5. [Opcional] Crear atajos en obs para los botones Menos y Más y asociarlos a streamdeck. Si no, puede manejarse desde la barra de nivel del apartado scripts.

Consideraciones:

* source_name es el nombre de la funte multimedia que servirá como base para las animaciones. Asegúrate de que tenga todas las propiedades desmarcadas.
* Todo los archivos del script deben estar en la misma carpeta
* Las imágenes, GIFs o incluso archivos de vídeos que conforman los estados de la barra están en la dirección marcada por el parámetro path (por defecto donde se encuentre el script)
* Si se quiere reorganizar en carpetas hay que indica folder y opcionalmente folder_anim_mas, folder_anim_menos y folder_estatico.
* Cada posición del parámetro estado está compuesto por tres elementos.
    - anim_mas: Es el archivo con la animación creciendo hasta esa posición (no tiene sentido en la primera posición)
    - anim_menos: Es el archivo con la animación decreciendo hasta esa posición (no tiene sentido en la última posición)
    - estatico: Es el archivo con el archivo de la posición estática en esa posición (para cuando vuelva o se mantenga)
* Para asociarlo al stream deck basta con asignarle combianciones de teclas desde obs a las propiedades Menos (decrementa la barra) y Más (incrementa la barra). Una vez hecho eso se puede utilizar en streamdeck dos botones de tipo Atajo con las teclas indicadas.


Consejo para esta versión:

* Lo ideal es definir muchos estados (por ejemplo 10) y si se quiere decrementar/aumentar en más de 1, darle tantas veces como se necesite en streamdeck o crear botones de acciones múltiples para cada incremento/decremento
* Si quieres escuchar un sonido con cada animación, con esta versión sólo sería posible creando la animación como un archivo de vídeo. Puede estudiarse para futuras versioens el incorporar clips de audio independientes con cada animación gif.
