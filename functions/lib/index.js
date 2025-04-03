"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.enviarAlerta = void 0;
const admin = __importStar(require("firebase-admin"));
const database_1 = require("firebase-functions/v2/database");
admin.initializeApp();
exports.enviarAlerta = (0, database_1.onValueCreated)('/lecturas/{lecturaId}', async (event) => {
    const data = event.data.val(); // Obtén los datos del evento
    const uid = data.uid;
    const timestamp = data.timestamp;
    // Buscar producto en Firestore
    const productRef = admin.firestore().collection('productos').where('idRfid', '==', uid);
    const productSnapshot = await productRef.get();
    if (!productSnapshot.empty) {
        const productData = productSnapshot.docs[0].data();
        // Guardar alerta en Firestore
        await admin.firestore().collection('alertas').add({
            nombreProducto: productData.nombreProducto,
            marca: productData.marca,
            modelo: productData.modelo,
            ubicacion: data.ubicacion,
            fotoProducto: productData.fotoProducto || '', // Manejo de foto opcional
            estado: productData.estado || 'Desconocido',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            leida: false, // Se marca como no leída por defecto
        });
        const mensaje = {
            notification: {
                title: 'ALERTA: Producto en Riesgo',
                body: `Producto ${productData.nombreProducto} en ${data.ubicacion}`,
            },
            data: {
                idRfid: uid,
                timestamp: timestamp,
                producto: JSON.stringify(productData),
            },
        };
        // Enviar notificación
        const dispositivoToken = data.dispositivo; // Asume que tienes el token del dispositivo
        if (dispositivoToken) {
            await admin.messaging().sendToDevice(dispositivoToken, mensaje);
        }
        else {
            console.log("No se encontró el token del dispositivo.");
        }
    }
});
//# sourceMappingURL=index.js.map