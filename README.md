# HolaMundo - Mod Minecraft Fabric 1.21.10

Mod para **Minecraft Fabric 1.21.10** que registra el comando cliente `/hola`. Al ejecutarlo en el juego, devuelve en el chat el mensaje:

```text
!Hola mundo!
```

---

## 🚀 Instalación rápida

El archivo `holamundo-1.0.0.jar` ya ha sido compilado y colocado automáticamente en tus carpetas de mods:
- `AppData/Roaming/.minecraft/essential_mod/fabric/1.21.10/mods/`
- `AppData/Roaming/.minecraft/mods/`

Para probarlo:
1. Abre tu **Minecraft Launcher** e inicia tu perfil de **Fabric 1.21.10**.
2. Entra a cualquier mundo (un jugador, servidor LAN, servidor multijugador o Realms).
3. Abre el chat y escribe:
   ```text
   /hola
   ```
4. Verás en pantalla:
   ```text
   !Hola mundo!
   ```

---

## 🛠️ Estructura del Proyecto

```
holamundo-mod/
├── build.ps1                 # Script de compilación automática ultrarrápida
├── build.bat                 # Doble clic para compilar en Windows
├── build.gradle              # Configuración de Fabric Loom para Gradle
├── settings.gradle           # Ajustes de proyecto Gradle
├── gradle.properties         # Versiones de Fabric, Minecraft 1.21.10 y Loader
├── README.md
├── build/libs/
│   └── holamundo-1.0.0.jar   # JAR compilado listo para usar
└── src/
    └── main/
        ├── java/
        │   └── com/david/holamundo/
        │       └── HolaMundoClient.java  # Código fuente del mod
        └── resources/
            ├── fabric.mod.json           # Metadata del mod
            └── assets/holamundo/
                └── icon.png              # Icono del mod
```

---

## 💻 Código Fuente (`HolaMundoClient.java`)

```java
package com.david.holamundo;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.command.v2.ClientCommandManager;
import net.fabricmc.fabric.api.client.command.v2.ClientCommandRegistrationCallback;
import net.fabricmc.fabric.api.client.command.v2.FabricClientCommandSource;
import net.minecraft.class_2561;

public class HolaMundoClient implements ClientModInitializer {

    @Override
    public void onInitializeClient() {
        ClientCommandRegistrationCallback.EVENT.register((dispatcher, registryAccess) -> {
            dispatcher.register(ClientCommandManager.literal("hola")
                .executes(context -> {
                    FabricClientCommandSource source = context.getSource();
                    // class_2561.method_43470(...) corresponde a Text.literal(...)
                    source.sendFeedback(class_2561.method_43470("!Hola mundo!"));
                    return 1;
                })
            );
        });
    }
}
```

---

## 🔧 ¿Cómo recompilar si haces cambios?

Si modificas el mensaje o agregas más comandos:

### Opción 1 (Inmediata sin descargas):
Ejecuta en PowerShell:
```powershell
./build.ps1
```
o simplemente haz doble clic en `build.bat`. Compila en 1 segundo usando el Java 21 de tu Minecraft y copia el `.jar` directamente a tus carpetas de mods.

### Opción 2 (Con Gradle y Fabric Loom):
Si prefieres usar el ecosistema estándar de Gradle:
```bash
./gradlew build
```
*(El archivo generado estará en `build/libs/`)*.
