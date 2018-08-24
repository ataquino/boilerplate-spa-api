const express = require('express');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const jwt = require('express-jwt');
const router = require('../controllers/router');
const { log } = require('../utils/log');

const app = express();

log(process.env);

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(helmet());

app.use(jwt({ secret: process.env.TOKEN_SECRET }).unless({ path: ['/authorize'] }));

/* eslint-disable-next-line no-unused-vars */
app.use((err, req, res, next) => {
  if (err.name === 'UnauthorizedError') {
    res.status(401).json({ error: 'No authorization token was found' });
  } else {
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.use('/', router);

app.listen(process.env.PORT, () => {
  log(`Listening on port ${process.env.PORT}`);
});
