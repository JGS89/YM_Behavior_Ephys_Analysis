Este repositorio contiene funciones y scripts para el procesamiento y análisis de sesiones experimentales en ratones, realizadas en una prueba de alternancia espontanea en un laberinto en forma de Y (*Y-Maze*). Se analiza la actividad de las neuronas de la mPFC en ratones ambulantes mientras realizan la prueba de YM.

Incluye

---

## ⚙️ Funciones incluidas

| Script                             | Descripción breve                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------|
| `convertir_clu_res_a_txt.m`       | Convierte archivos `.clu` y `.res` de Klusters a formato de texto exportable       |
| `convertir_rhd_a_dat.m`           | Extrae señales desde archivos `.rhd` de Intan y los guarda en formato `.dat`.      |
| `detectar_TTL_openmv.m`           | Detecta pulsos TTL de sincronización entre OpenMV y el sistema de adquisición.     |
| `pto_centro_YM.m`                 | Calcula el punto central del YM para separar el analisis en los 3 brazos.          |
| `ym_tripletes.m`                  | Calcula % de alternancia espontanea en la prueba de Y-maze.                        |
| `funcion_intervalos_YM.m`         | Genera intervalos de interés a partir de la posición del animal en el Y-maze.      |
| `calculo_intervalos_YM.m`         | Calcula intervalos de corrida hacia el centro y hacia la periferia del YM.         |

---

## 📌 Aplicación

Estas herramientas están diseñadas para ser usadas en tareas del tipo **Y-maze spontaneous alternation task**, con datos provenientes de:

- Adquisición de señales electrofisiologicas in-vivo con Tetrodos (Intan RHD2132)
- Spike sorting con **Neurosuite** (https://neurosuite.sourceforge.net/)
- Tracking con **ANY-maze v4.98 4**
- Sincronización por pulsos TTL (OpenMV Cam7, OpenMV IDE v4.0.1)

![YM_brazoss](https://github.com/user-attachments/assets/5ca7101c-70e1-422c-a781-682d294aa9d5)

- Este analisis fue utilizado en el trabajo de tesis doctoral:
  *Gonzalez Sanabria, Javier Alberto. (2023). Rol de la corteza prefrontal medial en la codificación de información contextual en un modelo murino de esquizofrenia.* (Tesis Doctoral. Universidad de Buenos Aires. Facultad de Ciencias Exactas y Naturales.). Recuperado de https://hdl.handle.net/20.500.12110/tesis_n7442_GonzalezSanabria

---

## 🧪 Requisitos

- MATLAB R2017a

---

## 👨‍🔬 Autor

**Javier Gonzalez Sanabria, PhD**  
*IFIBIO Houssay (UBA-CONICET), FMED, UBA*  
Desarrollado en colaboración con **Maria Florencia Santos**  
Contacto: javiergs89@gmail.com

---

## 📃 Licencia

Este código se distribuye con fines académicos y de investigación. Para otros usos, por favor contactar al autor.
