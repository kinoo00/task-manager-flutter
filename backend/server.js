const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

const SECRET = 'your-secret-key-change-in-production';
let users = [];
let projects = [];
let tasks = [];
let nextId = 1;

// Authenticate middleware
const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Unauthorized' });
  try {
    const decoded = jwt.verify(token, SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

// ---- Auth ----
app.post('/auth/register', async (req, res) => {
  console.log('Register request body:', req.body);
  const { name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Missing fields: name, email, password required' });
  }
  if (users.find(u => u.email === email)) {
    return res.status(400).json({ message: 'Email already exists' });
  }
  const hashed = await bcrypt.hash(password, 10);
  const user = { id: nextId++, name, email, passwordHash: hashed };
  users.push(user);
  const token = jwt.sign({ userId: user.id }, SECRET);
  res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
});

app.post('/auth/login', async (req, res) => {
  console.log('Login request body:', req.body);
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password required' });
  }
  const user = users.find(u => u.email === email);
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  const token = jwt.sign({ userId: user.id }, SECRET);
  res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
});

// ---- Projects ----
app.get('/projects', authenticate, (req, res) => {
  const userProjects = projects.filter(p => p.userId === req.userId);
  res.json(userProjects);
});

app.post('/projects', authenticate, (req, res) => {
  const { title, description, status } = req.body;
  if (!title) return res.status(400).json({ message: 'Title required' });
  const project = { id: nextId++, title, description, status: status || 'Active', userId: req.userId };
  projects.push(project);
  res.status(201).json(project);
});

// ---- Tasks ----
app.get('/projects/:projectId/tasks', authenticate, (req, res) => {
  const project = projects.find(p => p.id === parseInt(req.params.projectId) && p.userId === req.userId);
  if (!project) return res.status(404).json({ message: 'Project not found' });
  const projectTasks = tasks.filter(t => t.projectId === project.id);
  res.json(projectTasks);
});

app.post('/projects/:projectId/tasks', authenticate, (req, res) => {
  const project = projects.find(p => p.id === parseInt(req.params.projectId) && p.userId === req.userId);
  if (!project) return res.status(404).json({ message: 'Project not found' });
  const { title, priority, status } = req.body;
  if (!title) return res.status(400).json({ message: 'Title required' });
  const task = { id: nextId++, projectId: project.id, title, status: status || 'Pending', priority: priority || 'Medium' };
  tasks.push(task);
  res.status(201).json(task);
});

app.patch('/tasks/:taskId/done', authenticate, (req, res) => {
  const task = tasks.find(t => t.id === parseInt(req.params.taskId));
  if (!task) return res.status(404).json({ message: 'Task not found' });
  const project = projects.find(p => p.id === task.projectId && p.userId === req.userId);
  if (!project) return res.status(403).json({ message: 'Forbidden' });
  task.status = 'Done';
  res.json(task);
});

const PORT = 5000;
app.listen(PORT, () => console.log(`🚀 Backend running on http://localhost:${PORT}`));