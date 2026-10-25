package com.david.holamundo;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.command.v2.ClientCommandManager;
import net.fabricmc.fabric.api.client.command.v2.ClientCommandRegistrationCallback;
import net.fabricmc.fabric.api.client.command.v2.FabricClientCommandSource;
import net.minecraft.class_2561;

/**
 * Mod HolaMundo para Minecraft Fabric 1.21.10.
 * Registra el comando cliente /hola que envía "!Hola mundo!" al chat del jugador.
 */
public class HolaMundoClient implements ClientModInitializer {

    @Override
    public void onInitializeClient() {
        // Registra el comando cliente /hola
        ClientCommandRegistrationCallback.EVENT.register((dispatcher, registryAccess) -> {
            dispatcher.register(ClientCommandManager.literal("hola")
                .executes(context -> {
                    FabricClientCommandSource source = context.getSource();
                    // class_2561.method_43470 es el método intermediary correspondiente a Text.literal(...)
                    source.sendFeedback(class_2561.method_43470("!Hola mundo!"));
                    return 1;
                })
            );
        });
    }
}
