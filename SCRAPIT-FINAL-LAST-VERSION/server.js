/* ============================================================
   SCRAPIT — Express Backend
   ------------------------------------------------------------
   NOTE: This is a DEVELOPMENT PROTOTYPE.
   Before production:
     - Replace hardcoded credentials with hashed passwords
     - Use a real database (Postgres/MongoDB)
     - Add rate limiting, helmet, HTTPS, JWT signing
     - Validate/sanitize all inputs with a schema library
   ============================================================ */

const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

/* ---------- Paths ---------- */
const DATA_DIR = path.join(__dirname, 'data');
const UPLOADS_DIR = path.join(__dirname, 'uploads');
const DB_FILE = path.join(DATA_DIR, 'database.json');

if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
if (!fs.existsSync(UPLOADS_DIR)) fs.mkdirSync(UPLOADS_DIR, { recursive: true });

/* ---------- Default database seed ---------- */
const DEFAULT_DB = {
  users: [
    {
      id: 1,
      name: 'Aditya Kumar',
      role: 'Scrap Manager',
      email: 'admin@scrapit.com',
      password: 'scrapit123',
      phone: '+91 98765 43210',
      business: 'Kumar Scrap Traders',
      gst: '33ABCDE1234F1Z5',
      address: '123, Green Street, Chennai, Tamil Nadu – 600001'
    }
  ],
  tokens: {},
  inventory: [
    { id: 'inv1', material: 'Aluminium', category: 'Metal', quantity: 2, pricePerKg: 180, estimatedValue: 360, date: '12 May 2026', image: null, confidence: 94 },
    { id: 'inv2', material: 'Copper',    category: 'Metal', quantity: 1.5, pricePerKg: 720, estimatedValue: 1080, date: '10 May 2026', image: null, confidence: 92 },
    { id: 'inv3', material: 'Iron',      category: 'Metal', quantity: 5, pricePerKg: 40, estimatedValue: 200, date: '08 May 2026', image: null, confidence: 90 },
    { id: 'inv4', material: 'Plastic',   category: 'Plastic', quantity: 3, pricePerKg: 30, estimatedValue: 90, date: '07 May 2026', image: null, confidence: 91 },
    { id: 'inv5', material: 'Paper',     category: 'Paper', quantity: 8, pricePerKg: 15, estimatedValue: 120, date: '05 May 2026', image: null, confidence: 89 }
  ],
  history: [
    { id: 'h1', type: 'scan', name: 'Aluminium', qty: 2, value: 360, group: 'Today', time: '09:45 AM', ts: Date.now() - 3600000 },
    { id: 'h2', type: 'inventory', name: 'Copper', qty: 1.5, value: 1080, group: 'Today', time: '08:30 AM', ts: Date.now() - 7200000 },
    { id: 'h3', type: 'scan', name: 'Plastic', qty: 1.5, value: 45, group: 'Yesterday', time: '06:20 PM', ts: Date.now() - 86400000 },
    { id: 'h4', type: 'transaction', name: 'Aluminium', qty: 2, value: 360, group: 'Today', time: '09:50 AM', ts: Date.now() - 3000000 }
  ],
  notifications: [
    { id: 'n1', title: 'New scan completed', body: 'Aluminium detected with 94% confidence.', icon: 'scan', read: false, ts: Date.now() - 120000 },
    { id: 'n2', title: 'Aluminium price updated', body: 'Market rate moved to ₹180 / kg (+5.2%).', icon: 'tag', read: false, ts: Date.now() - 3600000 },
    { id: 'n3', title: 'Inventory reminder', body: "3 items haven't been reviewed this week.", icon: 'box', read: false, ts: Date.now() - 7200000 },
    { id: 'n4', title: 'Buyer interest received', body: 'Green Scrap Traders viewed your Aluminium listing.', icon: 'users', read: false, ts: Date.now() - 10800000 }
  ],
  buyers: [
    { id: 'b1', name: 'Green Scrap Traders', distance: '2.1 km away', materials: ['Aluminium','Copper','Iron','Plastic'], rating: 4.5, reviews: 120, initials: 'GS', phone: '+919876543210' },
    { id: 'b2', name: 'Shree Ram Recyclers', distance: '3.4 km away', materials: ['Iron','Plastic','Paper','E-Waste'],   rating: 4.2, reviews: 98,  initials: 'SR', phone: '+919876543211' },
    { id: 'b3', name: 'Eco Metal Buyers',    distance: '4.6 km away', materials: ['Copper','Aluminium','Brass'],         rating: 4.7, reviews: 150, initials: 'EM', phone: '+919876543212' },
    { id: 'b4', name: 'Bright Scrap Centre', distance: '5.2 km away', materials: ['All Metal','Plastic'],                rating: 4.1, reviews: 75,  initials: 'BS', phone: '+919876543213' },
    { id: 'b5', name: 'Metro Recyclers',     distance: '6.0 km away', materials: ['Paper','Plastic','E-Waste'],          rating: 4.4, reviews: 64,  initials: 'MR', phone: '+919876543214' },
    { id: 'b6', name: 'Greenline Materials', distance: '7.2 km away', materials: ['Metal','Industrial Scrap'],           rating: 4.6, reviews: 88,  initials: 'GL', phone: '+919876543215' }
  ],
  pricing: [
    { material: 'Aluminium', pricePerKg: 180, changePercent: 5.2,  trend: 'up',   updatedAt: new Date().toISOString() },
    { material: 'Copper',    pricePerKg: 720, changePercent: 3.1,  trend: 'up',   updatedAt: new Date().toISOString() },
    { material: 'Iron',      pricePerKg: 40,  changePercent: -1.0, trend: 'down', updatedAt: new Date().toISOString() },
    { material: 'Brass',     pricePerKg: 480, changePercent: 2.3,  trend: 'up',   updatedAt: new Date().toISOString() },
    { material: 'Plastic',   pricePerKg: 30,  changePercent: 1.4,  trend: 'up',   updatedAt: new Date().toISOString() },
    { material: 'Paper',     pricePerKg: 15,  changePercent: -0.5, trend: 'down', updatedAt: new Date().toISOString() }
  ],
  settings: [
    { userId: 1, notifications: { pushScan: true, priceAlerts: true, invReminder: true }, preferences: { language: 'English', currency: 'INR (₹)', unit: 'kg' } }
  ],
  messages: [],
  uploads: []
};

/* ---------- DB helpers ---------- */
function loadDB() {
  try {
    if (!fs.existsSync(DB_FILE)) {
      fs.writeFileSync(DB_FILE, JSON.stringify(DEFAULT_DB, null, 2));
      return JSON.parse(JSON.stringify(DEFAULT_DB));
    }
    const raw = fs.readFileSync(DB_FILE, 'utf-8');
    const parsed = JSON.parse(raw);
    // Ensure all keys exist
    for (const k of Object.keys(DEFAULT_DB)) {
      if (!(k in parsed)) parsed[k] = JSON.parse(JSON.stringify(DEFAULT_DB[k]));
    }
    return parsed;
  } catch (err) {
    console.error('[DB] Failed to load, using defaults:', err.message);
    return JSON.parse(JSON.stringify(DEFAULT_DB));
  }
}

function saveDB(db) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
  } catch (err) {
    console.error('[DB] Failed to save:', err.message);
  }
}

let DB = loadDB();

/* ---------- Middleware ---------- */
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use('/uploads', express.static(UPLOADS_DIR));
app.use(express.static(__dirname, { index: 'index.html' }));

/* ---------- Multer (uploads) ---------- */
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOADS_DIR),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
    const name = crypto.randomBytes(12).toString('hex') + ext;
    cb(null, name);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req, file, cb) => {
    const ok = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!ok.includes(file.mimetype)) {
      return cb(new Error('Only JPG, PNG, or WEBP images are allowed.'));
    }
    cb(null, true);
  }
});

/* ---------- Auth helpers ---------- */
function generateToken() {
  return crypto.randomBytes(24).toString('hex');
}

function getUserFromReq(req) {
  const auth = req.headers.authorization || '';
  const token = auth.replace(/^Bearer\s+/i, '');
  if (!token || !DB.tokens[token]) return null;
  const userId = DB.tokens[token];
  return DB.users.find(u => u.id === userId) || null;
}

function requireAuth(req, res, next) {
  const user = getUserFromReq(req);
  if (!user) return res.status(401).json({ success: false, error: 'Unauthorized' });
  req.user = user;
  next();
}

/* ---------- Helpers ---------- */
function addHistory(entry) {
  const group = 'Today';
  const time = new Date().toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' });
  DB.history.unshift({
    id: 'h' + Date.now() + Math.random().toString(36).slice(2, 6),
    group, time, ts: Date.now(),
    ...entry
  });
  if (DB.history.length > 200) DB.history.length = 200;
}

function addNotification(title, body, icon = 'scan') {
  DB.notifications.unshift({
    id: 'n' + Date.now() + Math.random().toString(36).slice(2, 6),
    title, body, icon, read: false, ts: Date.now()
  });
  if (DB.notifications.length > 50) DB.notifications.length = 50;
}

/* ============================================================
   ROUTES
   ============================================================ */

/* ---------- Health ---------- */
app.get('/api/health', (_req, res) => {
  res.json({ success: true, status: 'ok', time: new Date().toISOString() });
});

/* ---------- AUTH ---------- */
app.post('/api/auth/register', (req, res) => {
  const { name, email, phone, password } = req.body || {};
  const cleanName = String(name || '').trim();
  const cleanEmail = String(email || '').trim().toLowerCase();
  const cleanPhone = String(phone || '').trim();

  if (cleanName.length < 2) {
    return res.status(400).json({ success: false, error: 'Full name is required' });
  }
  if (!/^\S+@\S+\.\S+$/.test(cleanEmail)) {
    return res.status(400).json({ success: false, error: 'Enter a valid email address' });
  }
  if (String(password || '').length < 6) {
    return res.status(400).json({ success: false, error: 'Password must be at least 6 characters' });
  }
  if (DB.users.some(u => String(u.email || '').toLowerCase() === cleanEmail)) {
    return res.status(409).json({ success: false, error: 'An account with this email already exists' });
  }

  const id = DB.users.reduce((max, u) => Math.max(max, Number(u.id) || 0), 0) + 1;
  const user = {
    id,
    name: cleanName,
    role: 'Scrap Manager',
    email: cleanEmail,
    password: String(password),
    phone: cleanPhone || '',
    business: '',
    gst: '',
    address: ''
  };

  DB.users.push(user);
  DB.settings.push({
    userId: id,
    notifications: { pushScan: true, priceAlerts: true, invReminder: true },
    preferences: { language: 'English', currency: 'INR (₹)', unit: 'kg' }
  });

  const token = generateToken();
  DB.tokens[token] = id;
  saveDB(DB);

  const safe = { id: user.id, name: user.name, role: user.role, email: user.email, phone: user.phone };
  res.status(201).json({ success: true, token, user: safe });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ success: false, error: 'Email and password required' });
  }
  const user = DB.users.find(u => u.email.toLowerCase() === String(email).toLowerCase());
  if (!user || user.password !== password) {
    return res.status(401).json({ success: false, error: 'Invalid credentials' });
  }
  const token = generateToken();
  DB.tokens[token] = user.id;
  saveDB(DB);
  const safe = { id: user.id, name: user.name, role: user.role, email: user.email };
  res.json({ success: true, token, user: safe });
});

app.get('/api/auth/me', requireAuth, (req, res) => {
  const { id, name, role, email, phone, business, gst, address } = req.user;
  res.json({ success: true, user: { id, name, role, email, phone, business, gst, address } });
});

app.post('/api/auth/logout', (req, res) => {
  const auth = req.headers.authorization || '';
  const token = auth.replace(/^Bearer\s+/i, '');
  if (token && DB.tokens[token]) {
    delete DB.tokens[token];
    saveDB(DB);
  }
  res.json({ success: true });
});

/* ---------- UPLOADS ---------- */
app.post('/api/uploads', requireAuth, upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ success: false, error: 'No file uploaded' });
  const rec = {
    id: 'u' + Date.now(),
    filename: req.file.filename,
    originalName: req.file.originalname,
    mimetype: req.file.mimetype,
    size: req.file.size,
    url: '/uploads/' + req.file.filename,
    ts: Date.now()
  };
  DB.uploads.unshift(rec);
  if (DB.uploads.length > 100) DB.uploads.length = 100;
  saveDB(DB);
  res.json({ success: true, file: rec });
});

/* ---------- AI SCAN ---------- */
app.post('/api/scan/analyze', requireAuth, (req, res) => {
  const { imageUrl, filename } = req.body || {};
  const MATERIALS = {
    'Aluminium': { price: 180, cat: 'Metal' },
    'Copper':    { price: 720, cat: 'Metal' },
    'Iron':      { price: 40,  cat: 'Metal' },
    'Brass':     { price: 480, cat: 'Metal' },
    'Plastic':   { price: 30,  cat: 'Plastic' },
    'Paper':     { price: 15,  cat: 'Paper' },
    'E-Waste':   { price: 120, cat: 'E-Waste' }
  };

  // Deterministic "detection" for demo mode
  const seed = String(filename || imageUrl || Date.now());
  let h = 0;
  for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) % 9973;
  const keys = Object.keys(MATERIALS);
  const material = keys[h % keys.length];
  const meta = MATERIALS[material];

  const quantity = Math.round((0.8 + ((h % 42) / 10)) * 10) / 10;
  const confidence = 88 + (h % 9);
  const pricePerKg = meta.price;
  const estimatedValue = Math.round(quantity * pricePerKg);

  addHistory({ type: 'scan', name: material, qty: quantity, value: estimatedValue });
  addNotification('New scan completed', `${material} detected with ${confidence}% confidence.`, 'scan');
  saveDB(DB);

  res.json({
    success: true,
    demo: true,
    result: {
      material,
      category: meta.cat,
      confidence,
      quantity,
      pricePerKg,
      estimatedValue,
      imageUrl: imageUrl || null,
      date: new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })
    }
  });
});

/* ---------- INVENTORY ---------- */
app.get('/api/inventory', requireAuth, (req, res) => {
  res.json({ success: true, inventory: DB.inventory });
});

app.post('/api/inventory', requireAuth, (req, res) => {
  const { material, quantity, pricePerKg, image, confidence } = req.body || {};
  if (!material || typeof quantity !== 'number' || quantity <= 0 ||
      typeof pricePerKg !== 'number' || pricePerKg <= 0) {
    return res.status(400).json({ success: false, error: 'Invalid inventory data' });
  }
  const CATEGORY_MAP = {
    Aluminium: 'Metal', Copper: 'Metal', Iron: 'Metal', Brass: 'Metal',
    Plastic: 'Plastic', Paper: 'Paper', 'E-Waste': 'E-Waste'
  };
  const item = {
    id: 'inv' + Date.now() + Math.random().toString(36).slice(2, 6),
    material,
    category: CATEGORY_MAP[material] || 'Other',
    quantity: Math.round(quantity * 100) / 100,
    pricePerKg,
    estimatedValue: Math.round(quantity * pricePerKg),
    date: new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }),
    image: image || null,
    confidence: confidence || null
  };
  DB.inventory.unshift(item);
  addHistory({ type: 'inventory', name: material, qty: item.quantity, value: item.estimatedValue });
  addNotification('Inventory updated', `${material} added (${item.quantity} kg).`, 'box');
  saveDB(DB);
  res.json({ success: true, item });
});

app.put('/api/inventory/:id', requireAuth, (req, res) => {
  const { id } = req.params;
  const idx = DB.inventory.findIndex(i => i.id === id);
  if (idx === -1) return res.status(404).json({ success: false, error: 'Item not found' });
  const { material, quantity, pricePerKg } = req.body || {};
  const item = DB.inventory[idx];
  if (material) item.material = material;
  if (typeof quantity === 'number' && quantity > 0) item.quantity = Math.round(quantity * 100) / 100;
  if (typeof pricePerKg === 'number' && pricePerKg > 0) item.pricePerKg = pricePerKg;
  item.estimatedValue = Math.round(item.quantity * item.pricePerKg);
  addHistory({ type: 'inventory', name: item.material, qty: item.quantity, value: item.estimatedValue });
  saveDB(DB);
  res.json({ success: true, item });
});

app.delete('/api/inventory/:id', requireAuth, (req, res) => {
  const { id } = req.params;
  const idx = DB.inventory.findIndex(i => i.id === id);
  if (idx === -1) return res.status(404).json({ success: false, error: 'Item not found' });
  const [removed] = DB.inventory.splice(idx, 1);
  addHistory({ type: 'inventory', name: removed.material, qty: -removed.quantity, value: -removed.estimatedValue });
  saveDB(DB);
  res.json({ success: true, removed });
});

/* ---------- PRICING ---------- */
app.get('/api/pricing', requireAuth, (req, res) => {
  res.json({ success: true, pricing: DB.pricing, updatedAt: new Date().toISOString() });
});

/* ---------- BUYERS ---------- */
app.get('/api/buyers', requireAuth, (req, res) => {
  res.json({ success: true, buyers: DB.buyers });
});

/* ---------- HISTORY ---------- */
app.get('/api/history', requireAuth, (req, res) => {
  res.json({ success: true, history: DB.history });
});

/* ---------- NOTIFICATIONS ---------- */
app.get('/api/notifications', requireAuth, (req, res) => {
  const unread = DB.notifications.filter(n => !n.read).length;
  res.json({ success: true, notifications: DB.notifications, unread });
});

app.put('/api/notifications/:id/read', requireAuth, (req, res) => {
  const n = DB.notifications.find(x => x.id === req.params.id);
  if (!n) return res.status(404).json({ success: false, error: 'Notification not found' });
  n.read = true;
  saveDB(DB);
  res.json({ success: true });
});

app.put('/api/notifications/read-all', requireAuth, (req, res) => {
  DB.notifications.forEach(n => { n.read = true; });
  saveDB(DB);
  res.json({ success: true });
});

/* ---------- SETTINGS ---------- */
app.get('/api/settings', requireAuth, (req, res) => {
  const s = DB.settings.find(x => x.userId === req.user.id) || DB.settings[0];
  res.json({ success: true, settings: s });
});

app.put('/api/settings', requireAuth, (req, res) => {
  const idx = DB.settings.findIndex(x => x.userId === req.user.id);
  const next = { userId: req.user.id, ...req.body };
  if (idx >= 0) DB.settings[idx] = { ...DB.settings[idx], ...next };
  else DB.settings.push(next);
  saveDB(DB);
  res.json({ success: true, settings: DB.settings.find(x => x.userId === req.user.id) });
});

/* ---------- CONTACT ---------- */
app.post('/api/contact', (req, res) => {
  const { name, email, subject, message } = req.body || {};
  if (!name || !email || !message) {
    return res.status(400).json({ success: false, error: 'Name, email, and message are required' });
  }
  const rec = {
    id: 'm' + Date.now(),
    name, email, subject: subject || '(no subject)', message,
    ts: Date.now()
  };
  DB.messages.unshift(rec);
  addNotification('New contact message', `${name} sent a message.`, 'mail');
  saveDB(DB);
  res.json({ success: true, message: rec });
});

/* ---------- 404 for unknown API ---------- */
app.use('/api', (_req, res) => {
  res.status(404).json({ success: false, error: 'API endpoint not found' });
});

/* ---------- Global error handler ---------- */
app.use((err, _req, res, _next) => {
  console.error('[ERROR]', err.message);
  // Never leak stack traces
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Server error'
  });
});

const DEFAULT_PORT = 3000;

function startServer(port) {
  const server = app.listen(port, () => {
    console.log(`🚀 SCRAPIT server running at http://localhost:${port}`);
  });

  server.on("error", (error) => {
    if (error.code === "EADDRINUSE") {
      console.log(`⚠️ Port ${port} is already in use.`);

      if (port < 3010) {
        console.log(`🔄 Trying port ${port + 1}...`);
        startServer(port + 1);
      } else {
        console.error("❌ No available port found.");
      }
    } else {
      console.error("❌ Server error:", error);
    }
  });
}

startServer(DEFAULT_PORT);