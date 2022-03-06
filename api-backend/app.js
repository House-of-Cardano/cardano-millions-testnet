const express = required('express');

const feedQuery = require('./routes/query-db');

const app = express();

app.use('/querydb', feedQuery);

app.listen(8080);