// importar dependencias

import express from "express";
import { readProfiles, writeProfiles } from "/tmp/guild/plugins/model-profile/model-profiles";
import { flint_local_save } from "@opencode-ai/plugin-tools";

// inicio app

const app = express();
app.use(express.json()); // parsea json

// get para obtener modelos actuales

app.get("/api/sdd-models", (req, res) => {
    try {
        const profiles = readProfiles();
        if (!profiles) {
            return res.status(500).json({ error: "No se encontró model-profiles.json" });
        }
        const activeProfile = profiles.profiles[profiles.active_profile];
        const sddPhaseModels = activeProfile.sdd_phase_models || {};

        res.json(sddPhaseModels);
    }   catch (error) {
        res.status(500).json({ error: "Error al leer modelos" });
    }
});

// post guarda modelos

app.post("/api/sdd-models", async (req, res) => {
    try {
        const newModels = req.body;
        const profiles = readProfiles();
        if (!profiles) {
            return res.status(500).json({ error: "No se encontró model-profiles.json" });
        }
        const activeProfile = profiles.profiles[profiles.active_profile];
        activeProfile.sdd_phase_models = newModels;
        writeProfiles(profiles);

        await flint_local_save({
            topic_key: "sdd/models/config",
            title: "SDD Model Configuration",
            content: JSON.stringify(newModels),
            type: "configuration"
        });

        res.json({ success: true });
    }   catch (error) {
        res.status(500).json({ error: "Error al guardar modelos" });
    }
});

// iniciar el servidor

const PORT = 3000;
app.listen(PORT, () => {
    console.log("Servidor del skill corriendo en http://localhost:${PORT}");
});

// exportar la skill a opencode

export const SDDModelConfigurator = {
    command: "/configurar-models-sdd",
    type: "webview",
    url: "http://localhost:${PORT}/sdd-model-configurator"
};
