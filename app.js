// app.js
const express = require('express');
const app = express();
app.get('/', (_req, res) => res.send('Hello from Node + Docker + Jenkins!'));
app.listen(3000, () => console.log('App running on http://localhost:3000'));
