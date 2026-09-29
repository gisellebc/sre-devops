const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8080';

app.get('/health', (req, res) => res.status(200).send('OK'));

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>SRE Challenge - Task Manager UI</title>
      <style>
        body { font-family: system-ui, sans-serif; padding: 2rem; max-width: 600px; margin: 0 auto; background: #f4f4f9; }
        .card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 1rem; }
        button { background: #0066cc; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer; }
        input { padding: 0.5rem; margin-right: 0.5rem; border: 1px solid #ccc; border-radius: 4px; }
      </style>
    </head>
    <body>
      <h1>Task Manager (SRE Mock App)</h1>
      <div class="card">
        <h3>Login Mock</h3>
        <input type="text" id="email" value="test@test.com" />
        <input type="password" id="password" value="password" />
        <button onclick="login()">Iniciar Sesión</button>
      </div>
      <div class="card">
        <h3>Tareas</h3>
        <button onclick="getTasks()">Cargar Tareas</button>
        <ul id="taskList"></ul>
      </div>
      <script>
        const API_URL = "${BACKEND_URL}";
        let token = "";

        async function login() {
          const res = await fetch(API_URL + "/auth/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              email: document.getElementById("email").value,
              password: document.getElementById("password").value
            })
          });
          const data = await res.json();
          if (data.token) {
            token = data.token;
            alert("Login exitoso!");
          } else {
            alert("Error en login");
          }
        }

        async function getTasks() {
          const res = await fetch(API_URL + "/tasks", {
            headers: { "Authorization": "Bearer " + token }
          });
          const tasks = await res.json();
          const list = document.getElementById("taskList");
          list.innerHTML = "";
          if (Array.isArray(tasks)) {
            tasks.forEach(t => {
              const li = document.createElement("li");
              li.textContent = t.title + " (" + t.status + ")";
              list.appendChild(li);
            });
          } else {
            alert("Error al cargar tareas o token ausente");
          }
        }
      </script>
    </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`[Frontend] Corriendo en puerto ${PORT}`);
});