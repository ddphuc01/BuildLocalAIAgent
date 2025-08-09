const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('api', {
  backendUrl: process.env.BACKEND_URL || 'http://localhost:8000'
});


