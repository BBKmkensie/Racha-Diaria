# Configuración de Firebase para Racha Diaria

## Pasos para configurar Firebase

### 1. Crear un proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Crear un proyecto"
3. Ingresa el nombre del proyecto: `racha-diaria-app`
4. Habilita Google Analytics (opcional)
5. Crea el proyecto

### 2. Configurar Firestore Database

1. En el panel izquierdo, ve a "Firestore Database"
2. Haz clic en "Crear base de datos"
3. Selecciona "Iniciar en modo de prueba" (por ahora)
4. Elige una ubicación cercana a ti
5. Haz clic en "Habilitar"

### 3. Configurar Authentication

1. En el panel izquierdo, ve a "Authentication"
2. Haz clic en "Comenzar"
3. Ve a la pestaña "Sign-in method"
4. Habilita "Anónimo" (Anonymous)
5. Guarda los cambios

### 4. Configurar la aplicación Flutter

1. En el panel izquierdo, haz clic en el ícono de configuración (⚙️)
2. Selecciona "Configuración del proyecto"
3. Ve a la pestaña "General"
4. En "Tus aplicaciones", haz clic en el ícono de Web (</>)
5. Registra la aplicación con el nombre: `racha-diaria-web`
6. Copia la configuración de Firebase

### 5. Actualizar firebase_options.dart

Reemplaza los valores en `lib/firebase_options.dart` con la configuración real de tu proyecto:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'TU_API_KEY_AQUI',
  appId: 'TU_APP_ID_AQUI',
  messagingSenderId: 'TU_MESSAGING_SENDER_ID_AQUI',
  projectId: 'TU_PROJECT_ID_AQUI',
  authDomain: 'TU_PROJECT_ID.firebaseapp.com',
  storageBucket: 'TU_PROJECT_ID.appspot.com',
);
```

### 6. Configurar reglas de Firestore

En Firestore Database > Reglas, actualiza las reglas para permitir lectura/escritura autenticada:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura y escritura solo a usuarios autenticados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /readingProgress/{document} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 7. Ejecutar la aplicación

```bash
flutter pub get
flutter run -d windows
```

## Estructura de datos en Firestore

La aplicación creará la siguiente estructura:

```
users/
  {userId}/
    currentStreak: number
    longestStreak: number
    lastCompletedDate: string (ISO 8601)
    lastUpdated: timestamp
    readingProgress/
      {bookName}_{chapter}_{timestamp}/
        bookName: string
        chapter: number
        date: string (ISO 8601)
        isCompleted: boolean
```

## Características implementadas

- ✅ Autenticación anónima automática
- ✅ Sincronización automática de datos
- ✅ Almacenamiento offline (funciona sin internet)
- ✅ Indicador de estado de conexión
- ✅ Persistencia de racha y progreso de lectura

## Solución de problemas

### Error: "No Firebase App '[DEFAULT]' has been created"
- Verifica que `firebase_options.dart` tenga la configuración correcta
- Asegúrate de que `FirebaseService.initialize()` se llame en `main()`

### Error: "Permission denied"
- Verifica las reglas de Firestore
- Asegúrate de que la autenticación anónima esté habilitada

### Los datos no se sincronizan
- Verifica la conexión a internet
- Revisa la consola de Firebase para errores
- Verifica que el usuario esté autenticado (ícono en la app bar)

