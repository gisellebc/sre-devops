const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

// CORS: el UI en :3000 llama a :8080 (preflight OPTIONS en login y /tasks)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }
  next();
});

// Contador básico de peticiones para observabilidad
let requestCount = 0;
app.use((req, res, next) => {
  requestCount++;
  next();
});

// Endpoints de salud y métricas (SRE/Observabilidad)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date() });
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send(`# HELP http_requests_total Total de peticiones HTTP
# TYPE http_requests_total counter
http_requests_total ${requestCount}
`);
});

// Endpoints mock de la aplicación
app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (email === 'test@test.com' && password === 'password') {
    return res.json({ token: 'mock-jwt-token-sre-challenge-12345' });
  }
  return res.status(401).json({ error: 'Credenciales inválidas' });
});

app.get('/tasks', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No autorizado' });
  }
  res.json([
    { id: 1, title: 'Configurar Docker multi-stage build', status: 'completed' },
    { id: 2, title: 'Implementar Terraform o Manifiestos K8s', status: 'pending' },
    { id: 3, title: 'Definir SLOs y métricas en Prometheus', status: 'pending' }
  ]);
});

app.listen(PORT, () => {
  console.log(`[Backend] Corriendo en puerto ${PORT}`);
});